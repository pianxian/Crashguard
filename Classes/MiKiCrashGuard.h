//
//  MiKiCrashGuard.h
//  MiKiCrashGuard
//
//  Created by pianxian on 2020/7/20.
//  Copyright © 2020 MiKi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define MiKiCGSafeBlock(atBlock, ...) \
    if(atBlock) { atBlock(__VA_ARGS__); }

typedef NS_ENUM(NSUInteger, MiKiCrashGuardReportType) {
    MiKiCrashGuardReportType_CrashGuard,
    MiKiCrashGuardReportType_DataRace,
    MiKiCrashGuardReportType_UIThread,
};

typedef void(^MIKICG_LogCallback)(NSString *log);
typedef void(^MIKICG_ReportCallback)(NSString *msg, MiKiCrashGuardReportType type);

@interface MiKiCrashGuard : NSObject

/// 日志回调
@property (nonatomic, copy, class) MIKICG_LogCallback logCallback;

/// 上报回调
@property (nonatomic, copy, class) MIKICG_ReportCallback reportCallback;

#pragma mark - Crash Guard
/// 是否已经开启基础防护
+ (BOOL)isCrashGuardOpen;

/// 开启、关闭基础防护
+ (void)enableCrashGuardInstantly:(BOOL)enabled;

/// 设置黑名单类，黑名单类不进行防护
+ (void)setBaseGuardBlackList:(NSArray<NSString *> *)blacklist;

/// 发生异常时的回调，sdk 内部已经上报 crashreport
+ (void)setAbnormalReportCallback:(void(^)(NSString *))reportBlock;


#pragma mark - DataRace
/// 开启 NSArray、NSDictionary 数据竞争检测，iOS 10 以上才会起效
+ (void)startDataRaceScan;

/// 设置数据竞争上报后的回调，可用来展示弹窗，堆栈在非DEBUG下是未符号化的
+ (void)setDataRaceCallback:(BOOL (^)(NSString *msg, NSString *stack))callback;


#pragma mark - ANRDetectUtils
/// 开启 ANR 辅助定位（只是辅助定位ANR，不能代替ANR上报）
+ (void)startANRDetect;

/// 关闭ANR 辅助定位
+ (void)stopANRDetect;

/// 设置多久需要输出主线程堆栈，默认2s
+ (void)setStackDetectDuration:(NSTimeInterval)duration;

/// 堆栈回调
+ (void)setANRStackDetectCallback:(void (^)(NSString *msg))callback;


#pragma mark - DispatchOnce Guard

FOUNDATION_EXTERN void MiKiCG_dispatch_once(NSString *location,
                               dispatch_once_t *predicate,
                               DISPATCH_NOESCAPE dispatch_block_t block);

FOUNDATION_EXTERN void MiKiCG_dispatch_sync_safe_main(dispatch_block_t block);
FOUNDATION_EXTERN void MiKiCG_dispatch_async_safe_main(dispatch_block_t block);

#define dispatch_miki_once(...) \
NSString *location = [NSString stringWithFormat:@"DODG_[%s]", __PRETTY_FUNCTION__]; \
MiKiCG_dispatch_once(location, __VA_ARGS__) \

#define dispatch_sync_safe_main MiKiCG_dispatch_sync_safe_main
#define dispatch_async_safe_main MiKiCG_dispatch_async_safe_main

/// 开启 DispatchOnce 死锁防护，需要更换 API 调用：dispatch_miki_once、dispatch_sync_safe_main
+ (void)startDispatchOnceDeadLockGuard;

+ (void)setDispatchOnceDeadLockCallback:(dispatch_block_t)callback;

@end

NS_ASSUME_NONNULL_END
