//
//  UIView+crashguard.m
//  crashreport
//
//  Created by pianxian on 2017/6/8.
//  Copyright © 2017年 DW. All rights reserved.
//

#import "UIView+crashguard.h"
#import "NSObject+crashguard.h"
#import "MiKiCGMacro.h"
static BOOL isWarning = NO;

@implementation UIView (crashguard)

+ (void)load
{
    BOOL revert = true;
#if __has_include(<LookinServer/UIView+LookinServer.h>)
    revert = false;
#endif
    static dispatch_once_t onceToken;
    dispatch_miki_once(&onceToken, ^{
        [NSObject cg_swizzleInstanceMethod:[UIView class] newSEL:@selector(initWithFrame_swizzle:) origSEL:@selector(initWithFrame:) revert:revert];
        [NSObject cg_swizzleInstanceMethod:[UIView class] newSEL:@selector(removeFromSuperview_swizzle) origSEL:@selector(removeFromSuperview) revert:revert];
        [NSObject cg_swizzleInstanceMethod:[UIView class] newSEL:@selector(insertSubview_swizzle:atIndex:) origSEL:@selector(insertSubview:atIndex:) revert:revert];
        [NSObject cg_swizzleInstanceMethod:[UIView class] newSEL:@selector(exchangeSubviewAtIndex_swizzle:withSubviewAtIndex:) origSEL:@selector(exchangeSubviewAtIndex:withSubviewAtIndex:) revert:revert];
        [NSObject cg_swizzleInstanceMethod:[UIView class] newSEL:@selector(addSubview_swizzle:) origSEL:@selector(addSubview:) revert:revert];
        [NSObject cg_swizzleInstanceMethod:[UIView class] newSEL:@selector(insertSubview_swizzle:belowSubview:) origSEL:@selector(insertSubview:belowSubview:) revert:revert];
        [NSObject cg_swizzleInstanceMethod:[UIView class] newSEL:@selector(insertSubview_swizzle:aboveSubview:) origSEL:@selector(insertSubview:aboveSubview:) revert:revert];
        [NSObject cg_swizzleInstanceMethod:[UIView class] newSEL:@selector(bringSubviewToFront_swizzle:) origSEL:@selector(bringSubviewToFront:) revert:revert];
        [NSObject cg_swizzleInstanceMethod:[UIView class] newSEL:@selector(sendSubviewToBack_swizzle:) origSEL:@selector(sendSubviewToBack:) revert:revert];
        [NSObject cg_swizzleInstanceMethod:[UIView class] newSEL:@selector(isDescendantOfView_swizzle:) origSEL:@selector(isDescendantOfView:) revert:revert];
        [NSObject cg_swizzleInstanceMethod:[UIView class] newSEL:@selector(setNeedsLayout_swizzle) origSEL:@selector(setNeedsLayout) revert:revert];
        [NSObject cg_swizzleInstanceMethod:[UIView class] newSEL:@selector(layoutIfNeeded_swizzle) origSEL:@selector(layoutIfNeeded) revert:revert];
        [NSObject cg_swizzleInstanceMethod:[UIView class] newSEL:@selector(setNeedsDisplay_swizzle) origSEL:@selector(setNeedsDisplay) revert:revert];
        [NSObject cg_swizzleInstanceMethod:[UIView class] newSEL:@selector(setNeedsDisplayInRect_swizzle:) origSEL:@selector(setNeedsDisplayInRect:) revert:revert];
    });
}

+ (void)checkWhetherInNonMainthread:(NSString*)selector;
{
    if( ![NSThread isMainThread] )
    {
        NSString *str = [NSString stringWithFormat:@"[MiKiCrash] UIView method(%@) called at nonmainthread", selector];
        MiKiCG_INFO(str);
        MiKiCGSafeBlock(MiKiCrashGuard.reportCallback, str, MiKiCrashGuardReportType_UIThread);
    }
}

- (instancetype)initWithFrame_swizzle:(CGRect)frame
{
    [UIView checkWhetherInNonMainthread:NSStringFromSelector(_cmd)];
    return [self initWithFrame_swizzle:frame];
}

- (void)removeFromSuperview_swizzle;
{
    [UIView checkWhetherInNonMainthread:NSStringFromSelector(_cmd)];
    [self removeFromSuperview_swizzle];
}

- (void)insertSubview_swizzle:(UIView *)view atIndex:(NSInteger)index;
{
    [UIView checkWhetherInNonMainthread:NSStringFromSelector(_cmd)];
    [self insertSubview_swizzle:view atIndex:index];
}

- (void)exchangeSubviewAtIndex_swizzle:(NSInteger)index1 withSubviewAtIndex:(NSInteger)index2;
{
    [UIView checkWhetherInNonMainthread:NSStringFromSelector(_cmd)];
    [self exchangeSubviewAtIndex_swizzle:index1 withSubviewAtIndex:index2];
}

- (void)addSubview_swizzle:(UIView *)view;
{
    [UIView checkWhetherInNonMainthread:NSStringFromSelector(_cmd)];
    [self addSubview_swizzle:view];
}

- (void)insertSubview_swizzle:(UIView *)view belowSubview:(UIView *)siblingSubview;
{
    [UIView checkWhetherInNonMainthread:NSStringFromSelector(_cmd)];
    [self insertSubview_swizzle:view belowSubview:siblingSubview];
}

- (void)insertSubview_swizzle:(UIView *)view aboveSubview:(UIView *)siblingSubview;
{
    [UIView checkWhetherInNonMainthread:NSStringFromSelector(_cmd)];
    [self insertSubview_swizzle:view aboveSubview:siblingSubview];
}

- (void)bringSubviewToFront_swizzle:(UIView *)view;
{
    [UIView checkWhetherInNonMainthread:NSStringFromSelector(_cmd)];
    [self bringSubviewToFront_swizzle:view];
}

- (void)sendSubviewToBack_swizzle:(UIView *)view;
{
    [UIView checkWhetherInNonMainthread:NSStringFromSelector(_cmd)];
    [self sendSubviewToBack_swizzle:view];
}

- (BOOL)isDescendantOfView_swizzle:(UIView *)view;  // returns YES for self.
{
    [UIView checkWhetherInNonMainthread:NSStringFromSelector(_cmd)];
    return [self isDescendantOfView_swizzle:view];
}

- (nullable __kindof UIView *)viewWithTag_swizzle:(NSInteger)tag; // recursive search. includes self
{
    [UIView checkWhetherInNonMainthread:NSStringFromSelector(_cmd)];
    return [self viewWithTag_swizzle:tag];
}

// Allows you to perform layout before the drawing cycle happens. -layoutIfNeeded forces layout early
- (void)setNeedsLayout_swizzle;
{
    [UIView checkWhetherInNonMainthread:NSStringFromSelector(_cmd)];
    [self setNeedsLayout_swizzle];
}

- (void)layoutIfNeeded_swizzle;
{
    [UIView checkWhetherInNonMainthread:NSStringFromSelector(_cmd)];
    [self layoutIfNeeded_swizzle];
}

- (void)setNeedsDisplay_swizzle;
{
    [UIView checkWhetherInNonMainthread:NSStringFromSelector(_cmd)];
    [self setNeedsDisplay_swizzle];
}

- (void)setNeedsDisplayInRect_swizzle:(CGRect)rect;
{
    [UIView checkWhetherInNonMainthread:NSStringFromSelector(_cmd)];
    [self setNeedsDisplayInRect_swizzle:rect];
}
@end
