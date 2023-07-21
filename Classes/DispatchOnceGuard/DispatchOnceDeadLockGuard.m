//
//  DispatchOnceDeadLockGuard.m
//  TestDemo
//
//  Created by pianxian on 2018/11/26.
//  Copyright © 2018 MiKiMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <dispatch/base.h> // for HeaderDoc
#import "DispatchOnceDeadLockGuard.h"
#import "MiKiCrashGuard.h"
#import "MiKiCGMacro.h"

/*-------------------------------------*/

static BOOL DODG_MainThreadDispatchFlag = NO;
static BOOL DODG_ShouldStart = NO;

static NSMutableDictionary<NSString *, NSMutableArray *> *DODG_threadLocations = nil; // 记录各线程进了哪些dispatch_once
static NSMutableDictionary<NSString *, NSNumber *> *DODG_threadSyncFlags = nil; // 记录各线程是否有同步操作
static dispatch_semaphore_t _semaphore;


static inline void _dispatch_sync_safe_main(dispatch_block_t block) {
    assert(block != nil);
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

static inline void _dispatch_async_safe_main(dispatch_block_t block) {
    assert(block != nil);
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

static dispatch_block_t _callback;
static inline void _callBackIfNeed(void) {
    if (_callback) {
        _callback();
    }
}


#define LOG_ASSERT(format, arg...) \
NSAssert(NO, format, ##arg);

#define KEY_FOR_THREAD(thread) [NSString stringWithFormat:@"%p", thread]

#pragma mark - Thread Location

dispatch_semaphore_t DODG_semaphore(void)
{
    if (!_semaphore) {
        _semaphore = dispatch_semaphore_create(1);
    }
    return _semaphore;
}

void DODG_semaphore_sync(dispatch_block_t block)
{
    dispatch_semaphore_wait(DODG_semaphore(), DISPATCH_TIME_FOREVER);
    block();
    dispatch_semaphore_signal(DODG_semaphore());
}

void DODG_recordThreadLocation(NSObject *thread, NSString *location)
{
    DODG_semaphore_sync(^{
        if (!DODG_threadLocations) {
            DODG_threadLocations = [[NSMutableDictionary alloc] init];
        }
        NSMutableArray *locations = [DODG_threadLocations objectForKey:KEY_FOR_THREAD(thread)];
        if (!locations) {
            locations = [[NSMutableArray alloc] init];
        }
        [locations addObject:location];
        [DODG_threadLocations setObject:locations forKey:KEY_FOR_THREAD(thread)];
    });
}

void DODG_removeThreadLocation(NSObject *thread, NSString *location)
{
    DODG_semaphore_sync(^{
        if (DODG_threadLocations && DODG_threadLocations[KEY_FOR_THREAD(thread)]) {
            [DODG_threadLocations[KEY_FOR_THREAD(thread)] removeObject:location];
            if (!DODG_threadLocations[KEY_FOR_THREAD(thread)].count) {
                [DODG_threadLocations removeObjectForKey:KEY_FOR_THREAD(thread)];
            }
        }
    });
}

NSArray * DODG_getThreadLocations(NSObject *thread)
{
    __block NSMutableArray *locations = nil;
    if (!DODG_threadLocations) {
        return nil;
    }
    DODG_semaphore_sync(^{
        locations = [DODG_threadLocations objectForKey:KEY_FOR_THREAD(thread)].copy;
    });
    return locations;
}

#pragma mark - Thread SyncFlag
void DODG_setThreadSyncFlag(NSObject *thread)
{
    DODG_semaphore_sync(^{
        if (!DODG_threadSyncFlags) {
            DODG_threadSyncFlags = [[NSMutableDictionary alloc] init];
        }
        [DODG_threadSyncFlags setObject:@(YES) forKey:KEY_FOR_THREAD(thread)];
    });
}

void DODG_resetThreadSyncFlag(NSObject *thread)
{
    DODG_semaphore_sync(^{
        if (DODG_threadSyncFlags && DODG_threadSyncFlags[KEY_FOR_THREAD(thread)]) {
            [DODG_threadSyncFlags removeObjectForKey:KEY_FOR_THREAD(thread)];
        }
    });
}


#pragma mark - Judge

static BOOL IfDeadLockJudgeBySub(void)
{
    NSArray *subLocations = DODG_getThreadLocations([NSThread currentThread]);
    NSArray *mainLocations = DODG_getThreadLocations([NSThread mainThread]);

    NSString *subLocation = subLocations.count > 0 ? subLocations.lastObject : @"";
    NSString *mainLocation = mainLocations.count > 0 ? mainLocations.lastObject : @"";

    MiKiCG_INFO(@"[DeadLock] current location:%@, main loacation:%@", subLocation, mainLocation);
    
    if (subLocation.length == 0 && mainLocation.length == 0) {
        return NO;
    }

    // 主线程 block、子线程入口等于主线程入口，才会死锁
    return DODG_MainThreadDispatchFlag && ![NSThread isMainThread] && [subLocation isEqualToString:mainLocation];
}

static BOOL IfDeadLockJudgeByMain(NSString *mainLocation)
{
    // 主线程在进once前先判断是否有线程sync，且线程入口等于主线程入口，死锁
    if (![NSThread isMainThread]) {
        return NO;
    }

    __block BOOL isSameLocation = NO;
    __block BOOL isSyncCall = NO;

    DODG_semaphore_sync(^{
        for (NSString * threadID in DODG_threadLocations.allKeys) {
            if ([DODG_threadLocations[threadID].lastObject isEqualToString:mainLocation]) {
                isSameLocation = YES;
                isSyncCall = [DODG_threadSyncFlags objectForKey:threadID];
                if (isSyncCall) {
                    break;
                }
            }
        }
    });
    return isSameLocation && isSyncCall;
}

static BOOL IfOnceCycle(NSThread *currentThread, NSString *location)
{
    return [DODG_getThreadLocations(currentThread) containsObject:location];
}

#pragma mark - Setter

static void SetMainThreadDispatchFlag(BOOL flag)
{
    if ([NSThread isMainThread]) {
        DODG_MainThreadDispatchFlag = flag;
    }
}

static void SetSubThreadSyncFlag(BOOL flag, dispatch_block_t block)
{
    if (!flag) {
        SafeBlock(block);
        return;
    }
    DODG_setThreadSyncFlag([NSThread currentThread]);
    SafeBlock(block);
    DODG_resetThreadSyncFlag([NSThread currentThread]);
}

#pragma mark - Hook

void DODG_dispatch_once(NSString *location,
                   dispatch_once_t *predicate,
                   DISPATCH_NOESCAPE dispatch_block_t block)
{
    if (!DODG_ShouldStart) {
        _dispatch_once(predicate, block);
        return;
    }
    
    dispatch_block_t hook_block = ^{
        // 主线程调用了block说明已经不再阻塞（主线程直接进once的情况）
        SetMainThreadDispatchFlag(NO);
        block();
    };

    NSThread *currentThread = [NSThread currentThread];

    if (IfOnceCycle(currentThread, location)) {
        NSString *tips = [NSString stringWithFormat:@"Dispatch once cycle!! \n locations: %@, current: %@",
                          DODG_getThreadLocations(currentThread),
                          location];
        MiKiCG_INFO(@"[DeadLock] %@", tips);
        _callBackIfNeed();
#if DEBUG
        assert(false);
#endif
        return;
    }

    if (DISPATCH_EXPECT(*predicate, ~0l) != ~0l) {
        DODG_recordThreadLocation(currentThread, location);
        SetMainThreadDispatchFlag(YES);

        if (!IfDeadLockJudgeByMain(location)) {
           _dispatch_once(predicate, hook_block);
        } else {
            MiKiCG_INFO(@"[DeadLock] Main Thread DeadLock！！！return.");
            _callBackIfNeed();
        }

        SetMainThreadDispatchFlag(NO);
        DODG_removeThreadLocation(currentThread, location);
    } else {
        // 如果已经once过的，会走这个分支
        dispatch_compiler_barrier();
    }
    DISPATCH_COMPILER_CAN_ASSUME(*predicate == ~0l);

}

void DODG_dispatch_sync_safe_main(dispatch_block_t block)
{
    if (!DODG_ShouldStart) {
        _dispatch_sync_safe_main(block);
        return;
    }
    
    if ([NSThread isMainThread] || !DODG_getThreadLocations([NSThread currentThread])) {
        _dispatch_sync_safe_main(block);
        return;
    }

    if (IfDeadLockJudgeBySub()) {
        MiKiCG_INFO(@"[DeadLock] dispatch_sync_safe_main DeadLock！！！change to async.");
        _dispatch_async_safe_main(block);
        _callBackIfNeed();
        return;
    }

    SetSubThreadSyncFlag(YES, ^{
        _dispatch_sync_safe_main(block);
    });
}

void DODG_dispatch_async_safe_main(dispatch_block_t block)
{
    _dispatch_async_safe_main(block);
}


#pragma mark - NSOperationQueue (DeadLockGuard)
@implementation NSOperationQueue (DeadLockGuard)

+ (void)DODG_deadLockGuard
{
    MiKiCG_ISSwizzleInstanceMethod([NSOperationQueue class],
                                 @selector(waitUntilAllOperationsAreFinished),
                                 @selector(DODGHook_waitUntilAllOperationsAreFinished));

    MiKiCG_ISSwizzleInstanceMethod([NSOperationQueue class],
                                 @selector(addOperations:waitUntilFinished:),
                                 @selector(DODGHook_addOperations:waitUntilFinished:));

}

- (void)DODGHook_waitUntilAllOperationsAreFinished
{
    if (IfDeadLockJudgeBySub()) {
        LOG_ASSERT(@"deadlock DODG_[%s]", __PRETTY_FUNCTION__);
        _callBackIfNeed();
    } else {
        SetSubThreadSyncFlag(YES, ^{
            [self DODGHook_waitUntilAllOperationsAreFinished];
        });
    }
}

- (void)DODGHook_addOperations:(NSArray<NSOperation *> *)ops waitUntilFinished:(BOOL)wait
{
    if (wait && IfDeadLockJudgeBySub()) {
        LOG_ASSERT(@"deadlock DODG_[%s]", __PRETTY_FUNCTION__);
        [self DODGHook_addOperations:ops waitUntilFinished:NO];
        _callBackIfNeed();
    } else {
        SetSubThreadSyncFlag(wait, ^{
            [self DODGHook_addOperations:ops waitUntilFinished:wait];
        });
    }
}

@end


#pragma mark - NSOperation (DeadLockGuard)
@implementation NSOperation (DeadLockGuard)

+ (void)DODG_deadLockGuard
{
    MiKiCG_ISSwizzleInstanceMethod([NSOperation class],
                                 @selector(waitUntilFinished),
                                 @selector(DODGHook_waitUntilFinished));
}

- (void)DODGHook_waitUntilFinished
{
    if (IfDeadLockJudgeBySub()) {
        LOG_ASSERT(@"deadlock DODG_[%s]", __PRETTY_FUNCTION__);
        _callBackIfNeed();
    } else {
        SetSubThreadSyncFlag(YES, ^{
            [self DODGHook_waitUntilFinished];
        });
    }
}

@end

#pragma mark - NSObject (DeadLockGuard)

@implementation NSObject (DeadLockGuard)

+ (void)DODG_startDispatchOnceDeadLockGuard
{
    DODG_semaphore();
    DODG_ShouldStart = YES;
    [NSObject DODG_deadLockGuard];
    [NSOperation DODG_deadLockGuard];
    [NSOperationQueue DODG_deadLockGuard];
}

+ (void)DODG_setCallback:(dispatch_block_t)callback
{
    _callback = callback;
}

+ (void)DODG_deadLockGuard
{
    MiKiCG_ISSwizzleInstanceMethod([NSObject class],
                                 @selector(performSelectorOnMainThread:withObject:waitUntilDone:),
                                 @selector(DODGHook_performSelectorOnMainThread:withObject:waitUntilDone:));
}

- (void)DODGHook_performSelectorOnMainThread:(SEL)aSelector withObject:(nullable id)arg waitUntilDone:(BOOL)wait
{
    if (wait && IfDeadLockJudgeBySub()) {
        LOG_ASSERT(@"deadlock DODG_[%s]", __PRETTY_FUNCTION__);
        [self DODGHook_performSelectorOnMainThread:aSelector withObject:arg waitUntilDone:NO];
        _callBackIfNeed();
    } else {
        SetSubThreadSyncFlag(wait, ^{
            [self DODGHook_performSelectorOnMainThread:aSelector withObject:arg waitUntilDone:wait];
        });
    }
}

@end


