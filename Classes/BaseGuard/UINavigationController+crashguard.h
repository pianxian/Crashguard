//
//  UINavigationController+crashguard.h
//  CrashGuarder
//
//  Created by pianxian on 2018/3/14.
//  Copyright © 2018年 MiKi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (crashguard)

+ (void)swizzle_forCrashGuard;

@end
