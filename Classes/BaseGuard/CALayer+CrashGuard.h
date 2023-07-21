//
//  CALayer+Test.h
//  YWhat
//
//  Created by wuhuan on 2021/1/28.
//  Copyright © 2021 YXST. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface CALayer (CrashGuard)

+ (void)swizzle_forCALayer;

@end

NS_ASSUME_NONNULL_END
