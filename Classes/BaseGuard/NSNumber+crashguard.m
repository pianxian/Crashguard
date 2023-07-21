//
//  NSNumber+crashguard.m
//  CrashGuarder
//
//  Created by pianxian on 2018/6/1.
//  Copyright © 2018年 MiKi. All rights reserved.
//

#import "NSNumber+crashguard.h"
#import "NSObject+crashguard.h"
#import <objc/runtime.h>

@implementation NSNumber (crashguard)

+ (void)swizzle_forCrashGuard;
{
    Class clsCFNum = objc_getClass("__NSCFNumber");
    [NSObject cg_swizzleInstanceMethod:clsCFNum newSEL:@selector(isEqualToNumber_swizzleForCrashGuard:) origSEL:@selector(isEqualToNumber:)];
}

- (BOOL)isEqualToNumber_swizzleForCrashGuard:(NSNumber *)number;
{
    if( !number )
    {
        [NSObject cg_reportAbnormalMsg:@"compare to nil Number"];
        return NO;
    }
    return [self isEqualToNumber_swizzleForCrashGuard:number];
}

@end
