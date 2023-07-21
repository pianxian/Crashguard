//
//  MikiWeakTimer.m
//  Hydra
//
//  Created by pianxian Tsui on 2023/2/23.
//  Copyright © 2023 MiKi Inc. All rights reserved.
//

#import "MikiWeakTimer.h"
#import <UIKit/UIKit.h>
#import <libkern/OSAtomic.h>

#if !__has_feature(objc_arc)
#error MikiWeakTimer is ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif

#if OS_OBJECT_USE_OBJC
#define ms_gcd_property_qualifier strong
#define ms_release_gcd_object(object)
#else
#define ms_gcd_property_qualifier assign
#define ms_release_gcd_object(object) dispatch_release(object)
#endif

@interface MikiWeakTimer () {
    struct {
        uint32_t timerIsInvalidated;
    } _timerFlags;
}

@property ( nonatomic, assign) NSTimeInterval timeInterval;
@property ( nonatomic, weak) id target;
@property ( nonatomic, assign) SEL selector;
@property ( nonatomic, strong) id userInfo;
@property ( nonatomic, assign) BOOL repeats;

@property ( nonatomic, ms_gcd_property_qualifier) dispatch_queue_t privateSerialQueue;

@property ( nonatomic, ms_gcd_property_qualifier) dispatch_source_t timer;

/// 默认不开启，开启后APP进入后台Timer将挂起，进入前台恢复
@property (nonatomic,assign, getter=isStrictMode) BOOL strictMode;
@property (nonatomic,assign, getter=isEnterBackgroud) BOOL enterBackgroud;
@property (nonatomic, assign) BOOL doSuspend;
@property (nonatomic, assign) BOOL doInvalidate;

@end

@implementation MikiWeakTimer

@synthesize tolerance = _tolerance;

- (id)initWithTimeInterval:(NSTimeInterval)timeInterval target:(id)target selector:(SEL)selector userInfo:(id)userInfo repeats:(BOOL)repeats dispatchQueue:(dispatch_queue_t)dispatchQueue
{
    self = [self _initWithTimeInterval:timeInterval target:target selector:selector userInfo:userInfo repeats:repeats dispatchQueue:dispatchQueue];
    _strictMode = false;
    if (self.isStrictMode) {
        [self p_addNotify];
    }
    return self;
}

- (id)init
{
    return [self initWithTimeInterval:0
                               target:nil
                             selector:NULL
                             userInfo:nil
                              repeats:NO
                        dispatchQueue:nil];
}

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval target:(id)target selector:(SEL)selector userInfo:(id)userInfo repeats:(BOOL)repeats dispatchQueue:(dispatch_queue_t)dispatchQueue
{
    MikiWeakTimer *timer = [[self alloc] initWithTimeInterval:timeInterval
                                                       target:target
                                                     selector:selector
                                                     userInfo:userInfo
                                                      repeats:repeats
                                                dispatchQueue:dispatchQueue];
    
    [timer schedule];
    
    return timer;
}

+ (instancetype)scheduledTimerToMainQueueWithTimeInterval:(NSTimeInterval)timeInterval
                                                   target:(id)target
                                                 selector:(SEL)selector
                                                 userInfo:(id)userInfo
                                                  repeats:(BOOL)repeats
{
    return [self scheduledTimerWithTimeInterval:timeInterval
                                         target:target
                                       selector:selector
                                       userInfo:userInfo
                                        repeats:repeats
                                  dispatchQueue:dispatch_get_main_queue()];
}

- (void)dealloc
{
    [self invalidate];
    if (self.isStrictMode) {
        [self p_removeNotify];
    }
    ms_release_gcd_object(_privateSerialQueue);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p> time_interval=%f target=%@ selector=%@ userInfo=%@ repeats=%d timer=%@",
            NSStringFromClass([self class]),
            self,
            self.timeInterval,
            self.target,
            NSStringFromSelector(self.selector),
            self.userInfo,
            self.repeats,
            self.timer];
}

#pragma mark -

- (void)setTolerance:(NSTimeInterval)tolerance
{
    @synchronized(self) {
        if (tolerance != _tolerance) {
            _tolerance = tolerance;
            
            [self resetTimerProperties];
        }
    }
}

- (NSTimeInterval)tolerance
{
    @synchronized(self) {
        return _tolerance;
    }
}

- (void)resetTimerProperties
{
    int64_t intervalInNanoseconds = (int64_t)(self.timeInterval * NSEC_PER_SEC);
    int64_t toleranceInNanoseconds = (int64_t)(self.tolerance * NSEC_PER_SEC);
    
    dispatch_source_set_timer(self.timer,
                              dispatch_time(DISPATCH_TIME_NOW, intervalInNanoseconds),
                              (uint64_t)intervalInNanoseconds,
                              toleranceInNanoseconds
                              );
}

- (void)schedule
{
    [self resetTimerProperties];
    
    __weak MikiWeakTimer *weakSelf = self;
    
    dispatch_source_set_event_handler(self.timer, ^{
        [weakSelf timerFired];
    });
    
    dispatch_resume(self.timer);
}

- (void)fire
{
    [self timerFired];
}

- (void)invalidate
{
    if (self.isStrictMode) {
        if (!_doInvalidate) {
            _doInvalidate = YES;
            dispatch_source_t timer = self.timer;
            dispatch_source_cancel(timer);
            ms_release_gcd_object(timer);
        }
        if (self.doSuspend) {
            [self p_recoveTimer];
        }
        return;
    }
    // We check with an atomic operation if it has already been invalidated. Ideally we would synchronize this on the private queue,
    // but since we can't know the context from which this method will be called, dispatch_sync might cause a deadlock.
    if (!OSAtomicTestAndSetBarrier(7, &_timerFlags.timerIsInvalidated)) {
        dispatch_source_t timer = self.timer;
        dispatch_async(self.privateSerialQueue, ^{
            dispatch_source_cancel(timer);
            ms_release_gcd_object(timer);
        });
    }
}

- (void)timerFired
{
    // Checking attomatically if the timer has already been invalidated.
    if (OSAtomicAnd32OrigBarrier(1, &_timerFlags.timerIsInvalidated)) {
        return;
    }
    
    // We're not worried about this warning because the selector we're calling doesn't return a +1 object.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.target performSelector:self.selector withObject:self];
#pragma clang diagnostic pop
    
    if (!self.repeats) {
        [self invalidate];
    }
}

#pragma mark -
- (id)_initWithTimeInterval:(NSTimeInterval)timeInterval
                     target:(id)target
                   selector:(SEL)selector
                   userInfo:(id)userInfo
                    repeats:(BOOL)repeats
              dispatchQueue:(dispatch_queue_t)dispatchQueue
{
    NSParameterAssert(target);
    NSParameterAssert(selector);
    NSParameterAssert(dispatchQueue);
    
    if ([dispatchQueue isKindOfClass:NSClassFromString(@"MiKiDispatchQueue")]) {
        NSAssert(NO, @"MikiWeakTimer's dispatchQueue should be kind of 'dispatch_queue_t' not 'dispatch_miki_queue_t'");
        return nil;
    }
    
    if ((self = [super init])) {
        self.timeInterval = timeInterval;
        self.target = target;
        self.selector = selector;
        self.userInfo = userInfo;
        self.repeats = repeats;
        
        NSString *privateQueueName = [NSString stringWithFormat:@"com.miki.MikiWeakTimer.%p", self];
        self.privateSerialQueue = dispatch_queue_create([privateQueueName cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(self.privateSerialQueue, dispatchQueue);
        
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                            0,
                                            0,
                                            self.privateSerialQueue);
    }
    
    return self;
}

#pragma mark - Background Monitor

-(void)p_suspendTimer
{
    if (!self.isStrictMode || self.doSuspend) {
        return;
    }
    if (self.timer) {
        self.doSuspend = YES;
        dispatch_suspend(_timer);
    }
}
- (void)p_recoveTimer
{
    if (!self.isStrictMode || !self.doSuspend) {
        return;
    }
    if (self.timer) {
        dispatch_resume(_timer);
        self.doSuspend = NO;
    }
}

#pragma mark  notify
- (void)p_addNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(p_onDidEnterBackgroundNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(p_onApplicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)p_removeNotify
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)p_onDidEnterBackgroundNotification:(NSNotification *)notify
{
    self.enterBackgroud = YES;
    [self p_suspendTimer];
}

- (void)p_onApplicationWillEnterForeground:(NSNotification *)notify
{
    if (self.isEnterBackgroud) {
        self.enterBackgroud = NO;
        [self p_recoveTimer];
    }
}

@end

@implementation MikiWeakTimer (Background)

- (id)miki_initBackgroudTimerWithTimeInterval:(NSTimeInterval)timeInterval
                                       target:(id)target
                                     selector:(SEL)selector
                                     userInfo:(id)userInfo
                                      repeats:(BOOL)repeats
                                dispatchQueue:(dispatch_queue_t)dispatchQueue
{
    return [self _initWithTimeInterval:timeInterval target:target selector:selector userInfo:userInfo repeats:repeats dispatchQueue:dispatchQueue];
}

+ (instancetype)miki_scheduledBackgroudTimerWithTimeInterval:(NSTimeInterval)timeInterval
                                                      target:(id)target
                                                    selector:(SEL)selector
                                                    userInfo:(id)userInfo
                                                     repeats:(BOOL)repeats
                                               dispatchQueue:(dispatch_queue_t)dispatchQueue
{
    MikiWeakTimer *timer = [[self alloc] miki_initBackgroudTimerWithTimeInterval:timeInterval
                                                                          target:target
                                                                        selector:selector
                                                                        userInfo:userInfo
                                                                         repeats:repeats
                                                                   dispatchQueue:dispatchQueue];
    
    [timer schedule];
    return timer;
}

@end
