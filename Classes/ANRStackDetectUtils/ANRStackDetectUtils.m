//
//  ANRStackDetectUtils.m
//  libBaseService
//
//  Created by pianxian on 2018/9/18.
//  Copyright © 2018 MiKi. All rights reserved.
//

#import "ANRStackDetectUtils.h"
#import "MikiWeakTimer.h"
#import "MikiBacktraceLogger.h"


typedef void(^ANRDetectCallBack)(NSString *msg);

static int kStackDetectDuration = 2;

@interface ANRStackDetectUtils ()

@property (atomic, strong) NSDate *lastMainDate;
@property (nonatomic) ANRDetectCallBack callback;

@end

@implementation ANRStackDetectUtils {
    dispatch_queue_t _communicateQ;
    MikiWeakTimer *_communicateTimer;
    MikiWeakTimer *_mainTimer;
}

+ (instancetype)shareInstance
{
    static id instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (void)start
{
    [[ANRStackDetectUtils shareInstance] initTimer];
}

+ (void)stop
{
     [[ANRStackDetectUtils shareInstance] invalidateTimer];
}

+ (void)setANRStackDetectCallback:(void (^)(NSString *msg))callback
{
    [ANRStackDetectUtils shareInstance].callback = callback;
}

+ (void)setStackDetectDuration:(NSTimeInterval)duration
{
    kStackDetectDuration = duration;
}

#pragma mark - Private
- (void)initTimer
{
    if (!_communicateQ) {
        _communicateQ = dispatch_queue_create("com.miki.anr.stackdetect", DISPATCH_QUEUE_SERIAL);
    }
    [self invalidateTimer];
    
    _communicateTimer = [MikiWeakTimer scheduledTimerWithTimeInterval:1
                                                           target:self
                                                         selector:@selector(communicateTimerCallback)
                                                         userInfo:nil
                                                          repeats:YES
                                                    dispatchQueue:_communicateQ];
    
    _mainTimer = [MikiWeakTimer scheduledTimerWithTimeInterval:1
                                                    target:self
                                                  selector:@selector(mainTimerCallback)
                                                  userInfo:nil
                                                   repeats:YES
                                             dispatchQueue:dispatch_get_main_queue()];
    self.lastMainDate = [NSDate date];
}

- (void)invalidateTimer
{
    if (_mainTimer) {
        [_mainTimer invalidate];
        _mainTimer = nil;
    }
    if (_communicateTimer) {
        [_communicateTimer invalidate];
        _communicateTimer = nil;
    }
}

#pragma mark - Timer Callback
- (void)communicateTimerCallback
{
    NSDate *date = [NSDate date];
    int duration = floor(fabs([date timeIntervalSinceDate:self.lastMainDate]));
    
    // 主线程卡住每 kStackDetectDuration 秒后，打印一下主线程堆栈
    if (!CFRunLoopIsWaiting(CFRunLoopGetMain())
        && duration != 0
        && duration % kStackDetectDuration == 0) {
        NSString *backtrace = [MikiBacktraceLogger bs_backtraceOfMainThread];
        NSString *stackLog = [NSString stringWithFormat:@"DetectDuration: %@, nowWait: %@, mainStack: %@",
                              @(kStackDetectDuration),
                              @(duration),
                              backtrace];
        if (_callback) {
            _callback(stackLog);
        }
    }
}

- (void)mainTimerCallback
{
    self.lastMainDate = [NSDate date];
}

@end
