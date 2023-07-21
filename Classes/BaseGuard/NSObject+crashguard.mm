//
//  NSObject+crashguard.m
//  mikicrashguard
//
//  Created by pianxian on 17/4/21.
//  Copyright © 2017年 MiKi.inc. All rights reserved.
//

#import "NSObject+crashguard.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

#import "NSArray+crashguard.h"
#import "NSMutableArray+crashguard.h"
#import "NSDictionary+crashguard.h"
#import "NSMutableDictionary+crashguard.h"
#import "NSSet+crashguard.h"
#import "NSString+crashguard.h"
#import "CrashGuardGeneralLock.h"

#import "UINavigationController+crashguard.h"
#import "NSNumber+crashguard.h"
#import "NSCache+crashguard.h"
#import "NSData+crashguard.h"
#import "NSAttributedString+crashguard.h"
#import "NSJSONSerialization+crashguard.h"
#import "NSURLSession+crashguard.h"
//#import "NSURLSessionTaskMetrics+crashguard.h"
#import "CALayer+CrashGuard.h"

#import "MiKiCrashGuard.h"
#import "NSLayoutConstraint+crashguard.h"

void* originalClassKey = &originalClassKey;

static BlockAbnormalReport abnormalReportBlock = nil;

static NSArray<NSString *> *_blackList = nil;

static NSMutableArray<dispatch_block_t>* CrashGuardArrRevertcg_swizzleClassMethods = nil;
static NSMutableArray<dispatch_block_t>* CrashGuardArrRevertcg_swizzleInstanceMethods = nil;

static BOOL crashGuardSwitch = NO;

#define IF_NOT_IN_BLACKLIST(cls,statement) \
if (![_blackList containsObject:NSStringFromClass([cls class])]) {statement;}

@implementation NSObject (crashguard)

+ (void)swizzle_forClasses
{
    [NSObject swizzle_forUnrecognizedSelector];
    
    IF_NOT_IN_BLACKLIST(NSArray, [NSArray swizzle_forNSArray]);
    IF_NOT_IN_BLACKLIST(NSDictionary, [NSDictionary swizzle_forNSDictionary]);
    IF_NOT_IN_BLACKLIST(NSString, [NSString swizzle_forString]);
    
    IF_NOT_IN_BLACKLIST(NSMutableArray, [NSMutableArray swizzle_forNSMutableArray]);
    IF_NOT_IN_BLACKLIST(NSMutableDictionary, [NSMutableDictionary swizzle_forNSMutableDictionary]);
    IF_NOT_IN_BLACKLIST(NSAttributedString, [NSAttributedString swizzle_forAttributedString]);
    
    IF_NOT_IN_BLACKLIST(NSObject, [NSObject swizzle_forKVC]);
    IF_NOT_IN_BLACKLIST(NSNumber, [NSNumber swizzle_forCrashGuard]);
    IF_NOT_IN_BLACKLIST(NSCache, [NSCache swizzle_forNSCache]);
    
    IF_NOT_IN_BLACKLIST(NSData, [NSData swizzle_forNSData]);
    IF_NOT_IN_BLACKLIST(NSJSONSerialization, [NSJSONSerialization swizzle_forJSONSerialization]);
    IF_NOT_IN_BLACKLIST(NSURLSession, [NSURLSession swizzle_forURLSession]);
    IF_NOT_IN_BLACKLIST(NSLayoutConstraint, [NSLayoutConstraint swizzle_forNSLayoutConstraint]);
    IF_NOT_IN_BLACKLIST(CALayer, [CALayer swizzle_forCALayer]);
    
//    [UINavigationController swizzle_forCrashGuard];
    
//    if (@available(iOS 10.0, *)) {
//        IF_NOT_IN_BLACKLIST(NSURLSessionTaskMetrics,
//                            [NSURLSessionTaskMetrics swizzle_forNSURLSessionTaskMetrics]);
//    }
}

#pragma mark switches
+ (BOOL)cg_isCrashGuardOpen
{
    return crashGuardSwitch;
}

+ (void)cg_enableCrashGuardInstantly:(BOOL)enabled
{
    crashGuardSwitch = enabled;
    if( !enabled )
    {
        for ( dispatch_block_t block in CrashGuardArrRevertcg_swizzleClassMethods ) {
            block();
        }
        for ( dispatch_block_t block in CrashGuardArrRevertcg_swizzleInstanceMethods ) {
            block();
        }
        if( CrashGuardArrRevertcg_swizzleClassMethods )
        {
            CrashGuardArrRevertcg_swizzleClassMethods = nil;
        }
        if( CrashGuardArrRevertcg_swizzleInstanceMethods )
        {
            CrashGuardArrRevertcg_swizzleInstanceMethods = nil;
        }
    }
    else
    {
        [NSObject swizzle_forClasses];
    }
}

+ (void)cg_setBaseGuardBlackList:(NSArray<NSString *> *)blacklist
{
    _blackList = blacklist;
}

#pragma mark swizzled&private
+ (void)swizzle_forUnrecognizedSelector;
{
    [self cg_swizzleInstanceMethod:[NSObject class] newSEL:@selector(methodSignatureForSelector_swizzle:) origSEL:@selector(methodSignatureForSelector:)];
    [self cg_swizzleInstanceMethod:[NSObject class] newSEL:@selector(forwardingTargetForSelector_swizzle:) origSEL:@selector(forwardingTargetForSelector:)];
    [self cg_swizzleInstanceMethod:[NSObject class] newSEL:@selector(forwardInvocation_swizzle:) origSEL:@selector(forwardInvocation:)];
    
    [self cg_swizzleClassMethod:[NSObject class] newSEL:@selector(class_methodSignatureForSelector_swizzle:) origSEL:@selector(methodSignatureForSelector:)];
    [self cg_swizzleClassMethod:[NSObject class] newSEL:@selector(class_forwardInvocation_swizzle:) origSEL:@selector(forwardInvocation:)];
}

+ (void)swizzle_forKVC
{
    [self cg_swizzleInstanceMethod:[NSObject class] newSEL:@selector(setNilValueForKey_swizzle:) origSEL:@selector(setNilValueForKey:)];
    [self cg_swizzleInstanceMethod:[NSObject class] newSEL:@selector(setValue_swizzle:forUndefinedKey:) origSEL:@selector(setValue:forUndefinedKey:)];
    [self cg_swizzleInstanceMethod:[NSObject class] newSEL:@selector(valueForUndefinedKey_swizzleForCrashGuard:) origSEL:@selector(valueForUndefinedKey:)];
}

+ (void)cg_reportAbnormalMsg:(NSString *)msg
{
    MiKiCGSafeBlock(MiKiCrashGuard.reportCallback, msg, MiKiCrashGuardReportType_CrashGuard);
    if( abnormalReportBlock ) {
        abnormalReportBlock(msg);
    }
}

+ (void)cg_setAbnormalReportCallback:(BlockAbnormalReport)reportBlock
{
    abnormalReportBlock = [reportBlock copy];
}

#pragma mark - class crashguard for unrecognizedSelector

+ (NSMethodSignature *)class_methodSignatureForSelector_swizzle:(SEL)aSelector
{
    NSMethodSignature* method = [self class_methodSignatureForSelector_swizzle:aSelector];
    
    if( !method )
    {
        Method selfMethod = class_getClassMethod([self class],@selector(forwardInvocation:));
        Method thisMethod = class_getClassMethod([NSObject class], @selector(forwardInvocation:));
        if( selfMethod == thisMethod)
        {
            method = [NSMethodSignature signatureWithObjCTypes:"@@:"];
        }
    }
    return method;
}

+ (void)class_forwardInvocation_swizzle:(NSInvocation *)anInvocation
{
    NSString* abnormalMsg = nil;
    NSString* selector = NSStringFromSelector(anInvocation.selector);
    Class cls = objc_getAssociatedObject(self, originalClassKey);
    if( cls )
    {
        abnormalMsg = [NSString stringWithFormat:@"bad access to [%@ %@] at obj:%@",NSStringFromClass(cls),selector,self];
    }
    else
    {
        abnormalMsg = [NSString stringWithFormat:@"not recognized selector:%@ sent to %@",selector,self];
    }
    [NSObject cg_reportAbnormalMsg:abnormalMsg];
    
    [anInvocation setSelector:@selector(unrecognizedSelectorCrashGuard)];
    [anInvocation invoke];
}

#pragma mark - instance crashguard for unrecognizedSelector

- (id)forwardingTargetForSelector_swizzle:(SEL)aSelector
{
    id obj = [self forwardingTargetForSelector_swizzle:aSelector];
    
    return obj;
}

- (NSMethodSignature *)methodSignatureForSelector_swizzle:(SEL)aSelector
{
    NSMethodSignature* method = [self methodSignatureForSelector_swizzle:aSelector];
    
    if( !method )
    {
        Method selfMethod = class_getInstanceMethod([self class],@selector(forwardInvocation:));
        Method thisMethod = class_getInstanceMethod([NSObject class], @selector(forwardInvocation:));
        if(selfMethod == thisMethod)
        {
            method = [NSMethodSignature signatureWithObjCTypes:"@@:"];
        }
    }
    return method;
}

- (void)forwardInvocation_swizzle:(NSInvocation *)anInvocation
{
    NSString* abnormalMsg = nil;
    NSString* selector = NSStringFromSelector(anInvocation.selector);
    Class cls = objc_getAssociatedObject(self, originalClassKey);
    if( cls )
    {
        abnormalMsg = [NSString stringWithFormat:@"bad access to [%@ %@] at obj:%@",NSStringFromClass(cls),selector,self];
    }
    else
    {
        abnormalMsg = [NSString stringWithFormat:@"not recognized selector:%@ sent to %@",selector,self];
    }
    [NSObject cg_reportAbnormalMsg:abnormalMsg];
    
    [anInvocation setSelector:@selector(unrecognizedSelectorCrashGuard)];
    [anInvocation invoke];
}

- (id)unrecognizedSelectorCrashGuard
{
    return nil;
}

#pragma mark kvc
- (void)setNilValueForKey_swizzle:(NSString *)key
{
    NSString* abnormalMsg = [NSString stringWithFormat:@"NSInvalidArgumentException: %@ set nil for scalar key:%@",self,key];
    [NSObject cg_reportAbnormalMsg:abnormalMsg];
}

- (void)setValue_swizzle:(id)value forUndefinedKey:(NSString *)key
{
    NSString* abnormalMsg = [NSString stringWithFormat:@"NSUndefinedKeyException: %@ not key value-compliant for key:%@,value:%@",self,key,value];
    [NSObject cg_reportAbnormalMsg:abnormalMsg];
}

- (nullable id)valueForUndefinedKey_swizzleForCrashGuard:(NSString *)key;
{
    NSString* abnormalMsg = [NSString stringWithFormat:@"NSUndefinedKeyException: %@ not key value-compliant for key:%@",self,key];
    [NSObject cg_reportAbnormalMsg:abnormalMsg];
    return nil;
}

@end

@implementation NSObject(utility)

+ (void)cg_swizzleClassMethod:(Class)theClass newSEL:(SEL)newSEL origSEL:(SEL)origSEL
{
    if( !theClass )
    {
        return;
    }
    Method newmethod = class_getClassMethod(theClass, newSEL);
    Method origmethod = class_getClassMethod(theClass, origSEL);
    if( !newmethod || !origmethod )
    {
        return;
    }
    method_exchangeImplementations(newmethod, origmethod);
    if( !CrashGuardArrRevertcg_swizzleClassMethods )
    {
        CrashGuardArrRevertcg_swizzleClassMethods = [NSMutableArray new];
    }
    [CrashGuardArrRevertcg_swizzleClassMethods addObject:[^{
        method_setImplementation(origmethod, method_getImplementation(newmethod));
    } copy]];
}

+ (void)cg_swizzleInstanceMethod:(Class)theClass newSEL:(SEL)newSEL origSEL:(SEL)origSEL
{
    [self cg_swizzleInstanceMethod:theClass newSEL:newSEL origSEL:origSEL revert:true];
}

+ (void)cg_swizzleInstanceMethod:(Class)theClass newSEL:(SEL)newSEL origSEL:(SEL)origSEL revert:(BOOL)revert
{
    if( !theClass )
    {
        return;
    }
    Method newmethod = class_getInstanceMethod(theClass, newSEL);
    Method origmethod = class_getInstanceMethod(theClass, origSEL);
    if( !newmethod || !origmethod )
    {
        return;
    }
    method_exchangeImplementations(newmethod, origmethod);
    if( !CrashGuardArrRevertcg_swizzleInstanceMethods )
    {
        CrashGuardArrRevertcg_swizzleInstanceMethods = [NSMutableArray new];
    }
    if (!revert) {
        return;
    }
    [CrashGuardArrRevertcg_swizzleInstanceMethods addObject:[^{
        method_setImplementation(origmethod, method_getImplementation(newmethod));
    } copy]];
}

+ (void)cg_swizzleInstanceMethod:(Class)targetClass replacedSEL:(SEL)targetSwizzledSEL withOrigSEL:(SEL)origSwizzledSEL from:(Class)origClass;
{
    if( !origClass )
    {
        return;
    }
    Method origMethod = class_getInstanceMethod(origClass, origSwizzledSEL);
    if( !(origMethod && targetClass && class_addMethod(targetClass,origSwizzledSEL,method_getImplementation(origMethod),method_getTypeEncoding(origMethod))) )
    {
        return;
    }
    [self cg_swizzleInstanceMethod:targetClass newSEL:origSwizzledSEL origSEL:targetSwizzledSEL];
}


@end
