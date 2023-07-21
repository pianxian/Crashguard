//
//  UINavigationController+crashguard.m
//  CrashGuarder
//
//  Created by pianxian on 2018/3/14.
//  Copyright © 2018年 MiKi. All rights reserved.
//

#import "UINavigationController+crashguard.h"
#import "NSObject+crashguard.h"
#import <objc/runtime.h>

@implementation UINavigationController (crashguard)

+ (void)swizzle_forCrashGuard;
{
    Class navcls = [UINavigationController class];
    [NSObject cg_swizzleInstanceMethod:navcls
                                newSEL:@selector(pushViewController_crashguardswizzle:animated:)
                               origSEL:@selector(pushViewController:animated:)];
    
    [NSObject cg_swizzleInstanceMethod:navcls
                                newSEL:@selector(popViewControllerAnimated_crashguardswizzle:)
                               origSEL:@selector(popViewControllerAnimated:)];
    
}

- (BOOL)prohibitPushPop
{
   return [objc_getAssociatedObject(self, @selector(prohibitPushPop)) boolValue];
}

- (void)setProhibitPushPop:(BOOL) prohibitPushPop
{
   objc_setAssociatedObject(self, @selector(prohibitPushPop), @(prohibitPushPop), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Intercept Pop, Push, PopToRootVC

- (UIViewController *)popViewControllerAnimated_crashguardswizzle:(BOOL)animated
{
    if (self.prohibitPushPop) {
        NSLog(@"prohibitPushPop::popViewControllerAnimated");
        return nil;
    }
    
    self.prohibitPushPop = YES;
    UIViewController *vc = [self popViewControllerAnimated_crashguardswizzle:animated];
    [CATransaction setCompletionBlock:^{
       self.prohibitPushPop = NO;
    }];
    return vc;
}

- (void)pushViewController_crashguardswizzle:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.prohibitPushPop) {
        NSLog(@"prohibitPushPop::pushViewController");
        return;
    }

    self.prohibitPushPop = YES;
    [self pushViewController_crashguardswizzle:viewController animated:animated];
    [CATransaction setCompletionBlock:^{
       self.prohibitPushPop = NO;
    }];
}


@end

