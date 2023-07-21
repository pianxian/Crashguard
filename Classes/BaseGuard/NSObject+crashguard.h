//
//  NSObject+crashguard.h
//  mikicrashguard
//
//  Created by pianxian on 17/4/21.
//  Copyright © 2017年 MiKi.inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^BlockAbnormalReport)(NSString* abnormalMsg);
typedef NS_ENUM(NSUInteger, MiKiCrashGuardReportType);

@interface NSObject(utility)

+ (void)cg_swizzleClassMethod:(Class)theClass newSEL:(SEL)newSEL origSEL:(SEL)origSEL;
+ (void)cg_swizzleInstanceMethod:(Class)theClass newSEL:(SEL)newSEL origSEL:(SEL)origSEL;
+ (void)cg_swizzleInstanceMethod:(Class)theClass newSEL:(SEL)newSEL origSEL:(SEL)origSEL revert:(BOOL)revert;
+ (void)cg_swizzleInstanceMethod:(Class)targetClass replacedSEL:(SEL)targetSwizzledSEL withOrigSEL:(SEL)origSwizzledSEL from:(Class)origClass;

@end

@interface NSObject (crashguard)

+ (BOOL)cg_isCrashGuardOpen;
+ (void)cg_enableCrashGuardInstantly:(BOOL)enabled;

/// 设置黑名单
+ (void)cg_setBaseGuardBlackList:(NSArray<NSString *> *)blacklist;

/// 设置回调
+ (void)cg_setAbnormalReportCallback:(BlockAbnormalReport)reportBlock;

/// 上报异常
+ (void)cg_reportAbnormalMsg:(NSString*)msg;
+ (void)cg_reportAbnormalMsg:(NSString*)msg type:(MiKiCrashGuardReportType)type;

@end
