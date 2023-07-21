//
//  NSMutableDictionary+crashguard.m
//  crashreport
//
//  Created by pianxian on 17/5/3.
//  Copyright © 2017年 DW. All rights reserved.
//

#import "NSMutableDictionary+crashguard.h"
#import <objc/runtime.h>
#import "NSObject+crashguard.h"

@implementation NSMutableDictionary (crashguard)

+ (void)swizzle_forNSMutableDictionary;
{
    [NSObject cg_swizzleInstanceMethod:objc_getClass("__NSDictionaryM") newSEL:@selector(setObject_swizzled:forKey:) origSEL:@selector(setObject:forKey:)];
    [NSObject cg_swizzleInstanceMethod:objc_getClass("__NSDictionaryM") newSEL:@selector(removeObjectForKey_swizzle:) origSEL:@selector(removeObjectForKey:)];
}
#pragma mark swizzled method
- (void)setObject_swizzled:(id)anObject forKey:(id<NSCopying>)aKey
{
    if( !anObject || !aKey )
    {
        NSString* msg = [NSString stringWithFormat:@"dictionary object set %@ for key:%@",anObject,aKey];
        [NSObject cg_reportAbnormalMsg:msg];
        return;
    }
    else
    {
        [self setObject_swizzled:anObject forKey:aKey];
    }
}

- (void)removeObjectForKey_swizzle:(id)aKey
{
    if ( nil == aKey )
    {
        [NSObject cg_reportAbnormalMsg:[NSString stringWithFormat:@"dictionary remove object for nil"]];
        return;
    }
    [self removeObjectForKey_swizzle:aKey];
}
@end
