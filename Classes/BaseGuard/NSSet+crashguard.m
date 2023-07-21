//
//  NSSet+crashguard.m
//  CrashGuarder
//
//  Created by pianxian on 2017/11/15.
//  Copyright © 2017年 MiKi. All rights reserved.
//

#import "NSSet+crashguard.h"
#import "NSObject+crashguard.h"

@implementation NSSet (crashguard)

+ (void)swizzle_forSet
{
    [NSObject cg_swizzleClassMethod:[NSSet class] newSEL:@selector(setWithObject_swizzle:) origSEL:@selector(setWithObject:)];
}

+ (instancetype)setWithObject_swizzle:(id)object;
{
    if( object )
    {
        return [self setWithObject_swizzle:object];
    }
    else
    {
        [NSObject cg_reportAbnormalMsg:@"set creation setwithobject:nil"];
        return nil;
    }
}

@end
