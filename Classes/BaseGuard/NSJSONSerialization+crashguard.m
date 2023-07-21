//
//  NSJSONSerialization+crashguard.m
//  CrashGuarder
//
//  Created by pianxian on 2018/11/19.
//  Copyright © 2018 MiKi. All rights reserved.
//

#import "NSJSONSerialization+crashguard.h"
#import "NSObject+crashguard.h"
#import <objc/runtime.h>

@implementation NSJSONSerialization (crashguard)

+ (void)swizzle_forJSONSerialization
{
    [NSObject cg_swizzleClassMethod:[NSJSONSerialization class] newSEL:@selector(guard_JSONObjectWithData:options:error:) origSEL:@selector(JSONObjectWithData:options:error:)];
}

+ (nullable id)guard_JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error
{
    if( !data )
    {
        NSString* msg = [NSString stringWithFormat:@"NSJSONSerialization data parameter is nil"];
        [NSObject cg_reportAbnormalMsg:msg];
        return nil;
    }
    return [self guard_JSONObjectWithData:data options:opt error:error];
}

@end
