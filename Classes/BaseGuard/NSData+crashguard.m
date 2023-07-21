//
//  NSData+crashguard.m
//  CrashGuarder
//
//  Created by pianxian on 2018/8/17.
//  Copyright © 2018 MiKi. All rights reserved.
//

#import "NSData+crashguard.h"
#import "NSObject+crashguard.h"
#import <objc/runtime.h>

@implementation NSData (crashguard)

+ (void)swizzle_forNSData
{
    [NSObject cg_swizzleInstanceMethod:[NSData class] newSEL:@selector(guard_initWithBase64EncodedString:options:) origSEL:@selector(initWithBase64EncodedString:options:)];
    [NSObject cg_swizzleInstanceMethod:[NSData class] newSEL:@selector(guard_subdataWithRange:) origSEL:@selector(subdataWithRange:)];
}

- (nullable instancetype)guard_initWithBase64EncodedString:(NSString *)base64String options:(NSDataBase64DecodingOptions)options
{
    if( !base64String )
    {
        NSString* msg = [NSString stringWithFormat:@"NSData attempt to init with a nil Base64EncodedString"];
        [NSObject cg_reportAbnormalMsg:msg];
        return [self guard_initWithBase64EncodedString:@"" options:options];
    }
    return [self guard_initWithBase64EncodedString:base64String options:options];
}

- (NSData *)guard_subdataWithRange:(NSRange)range
{
    if (range.location + range.length > self.length) {
        return self;
    } else {
        return [self guard_subdataWithRange:range];
    }
}

@end

