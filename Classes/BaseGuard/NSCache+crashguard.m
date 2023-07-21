//
//  NSCache+crashguard.m
//  CrashGuarder
//
//  Created by pianxian on 2018/8/3.
//  Copyright © 2018 MiKi. All rights reserved.
//

#import "NSCache+crashguard.h"
#import "NSObject+crashguard.h"
#import <objc/runtime.h>

@implementation NSCache (crashguard)

+ (void)swizzle_forNSCache
{
    [NSObject cg_swizzleInstanceMethod:[NSCache class] newSEL:@selector(guard_setObject:forKey:cost:) origSEL:@selector(setObject:forKey:cost:)];
}

- (void)guard_setObject:(id)obj forKey:(id)key cost:(NSUInteger)g;
{
    if( !obj )
    {
        NSString* msg = [NSString stringWithFormat:@"NSCache attempt to insert nil value for key: %@", key];
        [NSObject cg_reportAbnormalMsg:msg];
        return;
    }
    return [self guard_setObject:obj forKey:key cost:g];
}

@end
