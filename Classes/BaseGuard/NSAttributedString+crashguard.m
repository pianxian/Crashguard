//
//  NSAttributedString+crashguard.m
//  CrashGuardSDK
//
//  Created by pianxian on 2018/12/12.
//

#import "NSAttributedString+crashguard.h"
#import "NSObject+crashguard.h"
#import <objc/runtime.h>

@implementation NSAttributedString (crashguard)

+ (void)swizzle_forAttributedString
{
    Class __NSConcreteMutableAttributedString = objc_getClass("NSConcreteMutableAttributedString");
    Class __NSBigMutableString = objc_getClass("NSBigMutableString");
    
    [NSObject cg_swizzleInstanceMethod:__NSConcreteMutableAttributedString newSEL:@selector(guard_initWithString:attributes:) origSEL:@selector(initWithString:attributes:)];
    
    [NSObject cg_swizzleInstanceMethod:__NSConcreteMutableAttributedString newSEL:@selector(guard_initWithString:) origSEL:@selector(initWithString:)];
    [NSObject cg_swizzleInstanceMethod:__NSBigMutableString newSEL:@selector(guard_substringWithRange:) origSEL:@selector(substringWithRange:)];
    
    [NSObject cg_swizzleInstanceMethod:[NSAttributedString class] newSEL:@selector(attributedSubstringFromRange_crashguardswizzle:) origSEL:@selector(attributedSubstringFromRange:)];
    
}

#pragma mark attributedSubstringFromRange
- (NSAttributedString *)attributedSubstringFromRange_crashguardswizzle:(NSRange)range
{
    if (range.location + range.length > self.length) {
        NSString* msg = [NSString stringWithFormat:@"NSAttributedString attributedSubstringFromRange Range or index out of bounds, length:%@, range:%@", @(self.length), NSStringFromRange(range)];
        [NSObject cg_reportAbnormalMsg:msg];
        return self;
    } else {
        return [self attributedSubstringFromRange_crashguardswizzle:range];
    }
}

- (instancetype)guard_initWithString:(NSString *)str attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attrs
{
    if (!str) {
        NSString* msg = [NSString stringWithFormat:@"NSConcreteMutableAttributedString initWithString:attributes:: nil value"];
        [NSObject cg_reportAbnormalMsg:msg];
        return [self guard_initWithString:@""];
    } else {
        return [self guard_initWithString:str attributes:attrs];
    }
}

- (instancetype)guard_initWithString:(NSString *)str
{
    if (!str) {
        NSString* msg = [NSString stringWithFormat:@"NSConcreteMutableAttributedString initWithString:: nil value"];
        [NSObject cg_reportAbnormalMsg:msg];
        return [self guard_initWithString:@""];
    } else {
        return [self guard_initWithString:str];
    }
}

- (instancetype *)guard_substringWithRange:(NSRange)range
{
    if( (range.location <= self.length) && (range.location+range.length <= self.length) )
    {
        return [self guard_substringWithRange:range];
    }
    else
    {
        [NSObject cg_reportAbnormalMsg:[NSString stringWithFormat:@"range(%@,%@) out of string:%@",@(range.location),@(range.length),self]];
        return nil;
    }
}

@end
