//
//  NSLayoutConstraint+crashguard.h
//  MiKiCrashGuard
//
//  Created by pianxian on 2021/10/27.
//   Copyright © 2021 MiKi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSLayoutConstraint (crashguard)

+ (void)swizzle_forNSLayoutConstraint;

@end

NS_ASSUME_NONNULL_END
