//
//  NSString+crashguard.m
//  CrashGuarder
//
//  Created by pianxian on 2017/11/15.
//  Copyright © 2017年 MiKi. All rights reserved.
//

#import "NSString+crashguard.h"
#import "NSObject+crashguard.h"
#import <objc/runtime.h>


@implementation NSString (crashguard)

+ (void)swizzle_forString;
{
    Class ClusterStringCF = objc_getClass("__NSCFString");   //cfconstantstring and mutablestring implementation
    Class ClusterStringTagPointer = objc_getClass("NSTaggedPointerString");
    
    [NSObject cg_swizzleInstanceMethod:ClusterStringCF newSEL:@selector(substringWithRange_CFSwizzle:) origSEL:@selector(substringWithRange:)];
    [NSObject cg_swizzleInstanceMethod:ClusterStringTagPointer newSEL:@selector(substringWithRange_TPSwizzle:) origSEL:@selector(substringWithRange:)];
    [NSObject cg_swizzleInstanceMethod:ClusterStringCF newSEL:@selector(stringByAppendingString_swizzle:) origSEL:@selector(stringByAppendingString:)];
    
    [NSObject cg_swizzleInstanceMethod:ClusterStringCF newSEL:@selector(substringFromIndex_CFSwizzle:) origSEL:@selector(substringFromIndex:)];
    [NSObject cg_swizzleInstanceMethod:ClusterStringCF newSEL:@selector(appendString_crashguardswizzle:) origSEL:@selector(appendString:)];
    [NSObject cg_swizzleInstanceMethod:ClusterStringTagPointer newSEL:@selector(substringFromIndex_TPSwizzle:) origSEL:@selector(substringFromIndex:)];
    
    [NSObject cg_swizzleInstanceMethod:ClusterStringTagPointer newSEL:@selector(rangeOfString_swizzle:options:range:locale:) origSEL:@selector(rangeOfString:options:range:locale:)];
    
    [NSObject cg_swizzleInstanceMethod:ClusterStringCF newSEL:@selector(replaceCharactersInRange_swizzle:withString:) origSEL:@selector(replaceCharactersInRange:withString:)];
    
    [NSObject cg_swizzleClassMethod:[NSString class] newSEL:@selector(stringWithUTF8String_swizzle:) origSEL:@selector(stringWithUTF8String:)];
    [NSObject cg_swizzleClassMethod:[NSString class] newSEL:@selector(stringWithCString_crashguardswizzle:encoding:) origSEL:@selector(stringWithCString:encoding:)];
    [NSObject cg_swizzleClassMethod:[NSMutableString class] newSEL:@selector(stringWithString_crashguardswizzle:) origSEL:@selector(stringWithString:)];
    
    [NSObject cg_swizzleInstanceMethod:[NSString class] newSEL:@selector(guard_stringByReplacingOccurrencesOfString:withString:options:range:) origSEL:@selector(stringByReplacingOccurrencesOfString:withString:options:range:)];
}


#pragma mark swizzle
+ (nullable instancetype)stringWithCString_crashguardswizzle:(const char *)cString encoding:(NSStringEncoding)enc
{
    if( cString )
    {
        return [NSString stringWithCString_crashguardswizzle:cString encoding:enc];
    }
    return nil;
}

+ (nullable instancetype)stringWithUTF8String_swizzle:(const char *)nullTerminatedCString;
{
    if( !nullTerminatedCString )
    {
        [NSObject cg_reportAbnormalMsg:[NSString stringWithFormat:@"create NSString with NULL cstring"]];
        return nil;
    }
    return [NSString stringWithUTF8String_swizzle:nullTerminatedCString];
}

+ (instancetype)stringWithString_crashguardswizzle:(NSString *)string
{
    if (string) {
        return [NSMutableString stringWithString_crashguardswizzle:string];
    }
    return nil;
}

- (NSRange)rangeOfString_swizzle:(NSString *)searchString options:(NSStringCompareOptions)mask range:(NSRange)range locale:(nullable NSLocale *)locale
{
    if (searchString) {
        if (range.location + range.length <= self.length) {
            return [self rangeOfString_swizzle:searchString options:mask range:range locale:locale];
        } else if (range.location < self.length) {
            return [self rangeOfString_swizzle:searchString options:mask range:NSMakeRange(range.location, self.length-range.location) locale:locale];
        }
        [NSObject cg_reportAbnormalMsg:@"-[string rangeOfString:options:range:locale:]: out of range"];
        return NSMakeRange(NSNotFound, 0);
    } else {
        [NSObject cg_reportAbnormalMsg:@"-[string rangeOfString:options:range:locale:]: nil argument"];
        return NSMakeRange(NSNotFound, 0);
    }
}

- (NSString *)stringByAppendingString_swizzle:(NSString *)aString
{
    if (aString && [aString isKindOfClass:[NSString class]]) {
        return [self stringByAppendingString_swizzle:aString];
    }
    return self;
}

- (void)appendString_crashguardswizzle:(NSString *)aString
{
    if (aString && [aString isKindOfClass:[NSString class]]) {
        [self appendString_crashguardswizzle:aString];
    }
}

#pragma mark substringfromindex
- (NSString*)substringFromIndex_CFSwizzle:(NSUInteger)from
{
    if( from <= self.length )
    {
        return [self substringFromIndex_CFSwizzle:from];
    }
    else
    {
        [NSObject cg_reportAbnormalMsg:[NSString stringWithFormat:@"%@ out of range of:%@",@(from),self]];
        return nil;
    }
}

- (NSString*)substringFromIndex_TPSwizzle:(NSUInteger)from
{
    if( from <= self.length )
    {
        return [self substringFromIndex_TPSwizzle:from];
    }
    else
    {
        [NSObject cg_reportAbnormalMsg:[NSString stringWithFormat:@"%@ out of range of:%@",@(from),self]];
        return nil;
    }
}

#pragma mark substringwithrange
- (NSString *)substringWithRange_CFSwizzle:(NSRange)range;
{
    if( (range.location <= self.length) && (range.location+range.length <= self.length) )
    {
        return [self substringWithRange_CFSwizzle:range];
    }
    else
    {
        [NSObject cg_reportAbnormalMsg:[NSString stringWithFormat:@"range(%@,%@) out of string:%@",@(range.location),@(range.length),self]];
        return nil;
    }
}

- (NSString*)substringWithRange_TPSwizzle:(NSRange)range
{
    if( (range.location <= self.length) && (range.location+range.length <= self.length) )
    {
        return [self substringWithRange_TPSwizzle:range];
    }
    else
    {
        [NSObject cg_reportAbnormalMsg:[NSString stringWithFormat:@"range(%@,%@) out of string:%@",@(range.location),@(range.length),self]];
        return nil;
    }
}

#pragma mark replaceCharactersInRange
- (void)replaceCharactersInRange_swizzle:(NSRange)range withString:(NSString *)str;
{
    if( range.location + range.length > self.length )
    {
        NSString* msg = [NSString stringWithFormat:@"NSMutableString replaceCharactersInRange Range or index out of bounds, length:%@, range:%@", @(self.length), NSStringFromRange(range)];
        [NSObject cg_reportAbnormalMsg:msg];
    }
    else
    {
        return [self replaceCharactersInRange_swizzle:range withString:str];
    }
}

- (NSString *)guard_stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange
{
    NSString *newTarget = target ?: @"";
    NSString *newReplace = replacement ?: @"";
    return [self guard_stringByReplacingOccurrencesOfString:newTarget withString:newReplace options:options range:searchRange];
}



@end




