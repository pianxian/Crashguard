//
//  MiKiCrashGuard.m
//  MiKiCrashGuard
//
//  Created by pianxian on 2020/7/20.
//  Copyright © 2020 MiKi. All rights reserved.
//

#import "MiKiCrashGuard.h"
#import "NSObject+DataRaceScaner.h"
#import "NSObject+crashguard.h"
#import "DispatchOnceDeadLockGuard.h"
#import "ANRStackDetectUtils.h"

#import <objc/runtime.h>

static MIKICG_LogCallback mikigc_logcallback = nil;
static MIKICG_ReportCallback mikigc_reportcallback = nil;

void MiKiCG_ISSwizzleInstanceMethod(Class className, SEL originalSelector, SEL alternativeSelector)
{
    Method originalMethod = class_getInstanceMethod(className, originalSelector);
    Method alternativeMethod = class_getInstanceMethod(className, alternativeSelector);
    
    if (class_addMethod(className,
                        originalSelector,
                        method_getImplementation(alternativeMethod),
                        method_getTypeEncoding(alternativeMethod)))
    {
        class_replaceMethod(className,
                            alternativeSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, alternativeMethod);
    }
}

@implementation MiKiCrashGuard

+ (MIKICG_LogCallback)logCallback
{
    return mikigc_logcallback;
}

+ (void)setLogCallback:(MIKICG_LogCallback)logCallback
{
    mikigc_logcallback = [logCallback copy];
}

+ (MIKICG_ReportCallback)reportCallback
{
    return mikigc_reportcallback;
}

+ (void)setReportCallback:(MIKICG_ReportCallback)reportCallback
{
    mikigc_reportcallback = [reportCallback copy];
}

#pragma mark -
+ (BOOL)isCrashGuardOpen
{
    return [NSObject cg_isCrashGuardOpen];
}

+ (void)enableCrashGuardInstantly:(BOOL)enabled
{
    [NSObject cg_enableCrashGuardInstantly:enabled];
}

+ (void)setBaseGuardBlackList:(NSArray<NSString *> *)blacklist
{
    [NSObject cg_setBaseGuardBlackList:blacklist];
}

+ (void)setAbnormalReportCallback:(void(^)(NSString *))reportBlock
{
    if (reportBlock) {
        [NSObject cg_setAbnormalReportCallback:reportBlock];
    }
}

#pragma mark - DataRace
+ (void)startDataRaceScan
{
    [NSObject drs_start];
}

+ (void)setDataRaceCallback:(BOOL (^)(NSString *msg, NSString *stack))callback;
{
    [NSObject drs_observeCallback:callback];
}


#pragma mark - ANRDetectUtils
+ (void)startANRDetect
{
    [ANRStackDetectUtils start];
}

+ (void)stopANRDetect
{
    [ANRStackDetectUtils stop];
}

+ (void)setStackDetectDuration:(NSTimeInterval)duration
{
    [ANRStackDetectUtils setStackDetectDuration:duration];
}

+ (void)setANRStackDetectCallback:(void (^)(NSString *msg))callback
{
    [ANRStackDetectUtils setANRStackDetectCallback:callback];
}

#pragma mark - DispatchOnce Guard

void MiKiCG_dispatch_once(NSString *location,
                        dispatch_once_t *predicate,
                        DISPATCH_NOESCAPE dispatch_block_t block)
{
    DODG_dispatch_once(location, predicate, block);
}

void MiKiCG_dispatch_sync_safe_main(dispatch_block_t block)
{
    DODG_dispatch_sync_safe_main(block);
}

void MiKiCG_dispatch_async_safe_main(dispatch_block_t block)
{
    DODG_dispatch_async_safe_main(block);
}

+ (void)startDispatchOnceDeadLockGuard
{
    [NSObject DODG_startDispatchOnceDeadLockGuard];
}

+ (void)setDispatchOnceDeadLockCallback:(dispatch_block_t)callback
{
    [NSObject DODG_setCallback:callback];
}

@end
