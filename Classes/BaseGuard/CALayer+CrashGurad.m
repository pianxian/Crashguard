//
//  CALayer+Test.m
//  YWhat
//
//  Created by wuhuan on 2021/1/28.
//  Copyright © 2021 YXST. All rights reserved.
//

#import "CALayer+CrashGuard.h"
#import "NSObject+crashguard.h"

@implementation CALayer (CrashGuard)

+ (void)swizzle_forCALayer
{
    [NSObject cg_swizzleInstanceMethod:[CALayer class] newSEL:@selector(setPosition_swizzle:) origSEL:@selector(setPosition:)];
    [NSObject cg_swizzleInstanceMethod:[CALayer class] newSEL:@selector(setBounds_swizzle:) origSEL:@selector(setBounds:)];
}

- (void)setPosition_swizzle:(CGPoint)position
{
    if (isnan(position.x) || isnan(position.y) || isinf(position.x) || isinf(position.y)) {
        [self setPosition_swizzle:CGPointZero];
    } else {
        [self setPosition_swizzle:position];
    }
}

- (void)setBounds_swizzle:(CGRect)bounds
{
    if (isnan(bounds.origin.x) || isnan(bounds.origin.y) || isnan(bounds.size.width) || isnan(bounds.size.height)) {
        [self setBounds_swizzle:CGRectZero];
    } else {
        [self setBounds_swizzle:bounds];
    }
}

@end
