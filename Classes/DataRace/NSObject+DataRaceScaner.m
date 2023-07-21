//
//  NSObject+DataRaceScaner.m
//  TestDemo
//
//  Created by pianxian on 2019/1/17.
//  Copyright © 2019 MiKi. All rights reserved.
//

#import "NSObject+DataRaceScaner.h"
#import "NSMutableArray+DataRaceScaner.h"
#import "NSMutableDictionary+DataRaceScaner.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#include <os/lock.h>
#include <pthread.h>

#import "MiKiCrashGuard.h"
#import "MiKiCGMacro.h"

/*-------------------------------------*/

static BOOL isWarning = NO;
static DataRaceScanerCallBack reportCallback = nil;

static NSNumber * GetCurrentThreadId()
{
    mach_port_t machTID = pthread_mach_thread_np(pthread_self());
    return @(machTID);
}

/*-------------------------------------*/

void DRS_ISSwizzleInstanceMethod(Class className, SEL originalSelector, SEL alternativeSelector)
{
    MiKiCG_ISSwizzleInstanceMethod(className, originalSelector, alternativeSelector);
}

void DRS_ReportDataRace(NSString *error, NSNumber *writeThread)
{
    if (isWarning) {
        return;
    }
    isWarning = YES;
    NSString *currentStack = [NSThread callStackSymbols].description;
    NSString *stack = [NSString stringWithFormat:@"current:%@、write:%@\n%@", writeThread, GetCurrentThreadId(), currentStack];
    NSString *abnormalMsg = [NSString stringWithFormat:@"%@\n%@", error, stack];

    BOOL shouldReport = !reportCallback || reportCallback(error, stack);
    if (shouldReport) {
        MiKiCGSafeBlock(MiKiCrashGuard.reportCallback, abnormalMsg, MiKiCrashGuardReportType_DataRace);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        isWarning = NO;
    });
}

BOOL DRS_JudgeIfDataRace(NSNumber *thread)
{
    return nil != thread && ![thread isEqualToValue:GetCurrentThreadId()];
}

/*-------------------------------------*/

@implementation NSObject (DataRaceScaner)

+ (void)drs_start;
{
    // iOS 10 之后才有 os_unfair_lock，iOS 10 Hook 太多系统类会有崩溃
    if ([UIDevice currentDevice].systemVersion.floatValue < 11.0) {
        return;
    }
    [NSMutableArray miki_startDataRaceScanner];
    [NSMutableDictionary miki_startDataRaceScanner];
}

+ (void)drs_observeCallback:(DataRaceScanerCallBack)callback
{
    reportCallback = callback;
}

#pragma mark - unfairlock
- (void)setDrs_unfairLock:(drs_os_unfair_lock_t)lock
{
    NSData *data = [NSData dataWithBytes:&lock length:sizeof(lock)];
    objc_setAssociatedObject(self, @selector(drs_unfairLock), data, OBJC_ASSOCIATION_RETAIN);
}

- (drs_os_unfair_lock_t)drs_unfairLock
{
    drs_os_unfair_lock_t lock;
    if (!objc_getAssociatedObject(self, @selector(drs_unfairLock))) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
        os_unfair_lock_t ll = (os_unfair_lock_t)(&lock);
        *ll = OS_UNFAIR_LOCK_INIT;
#pragma clang diagnostic pop
        [self setDrs_unfairLock:lock];
        return lock;
    }
    NSData *data = objc_getAssociatedObject(self, @selector(drs_unfairLock));
    [data getBytes:&lock length:sizeof(lock)];
    return lock;
}

#pragma mark - thread
- (void)setDrs_thread:(NSNumber *)drs_thread
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    drs_os_unfair_lock_t lock = self.drs_unfairLock;
    os_unfair_lock_lock((os_unfair_lock_t)(&lock));
    objc_setAssociatedObject(self, @selector(drs_thread), drs_thread, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    os_unfair_lock_unlock((os_unfair_lock_t)(&lock));
#pragma clang diagnostic pop
}

- (NSNumber *)drs_thread
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    drs_os_unfair_lock_t lock = self.drs_unfairLock;
    os_unfair_lock_lock((os_unfair_lock_t)(&lock));
    NSNumber *thread = objc_getAssociatedObject(self, @selector(drs_thread));
    os_unfair_lock_unlock((os_unfair_lock_t)(&lock));
#pragma clang diagnostic pop
    return thread;
}

#pragma mark - writing
- (void)drs_startWritingCompletion:(dispatch_block_t)block
{
    self.drs_thread = GetCurrentThreadId();
    if (block) {
         block();
    }
    self.drs_thread = nil;
}

@end
