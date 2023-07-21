//
//  NSLayoutConstraint+crashguard.m
//  MiKiCrashGuard
//
//  Created by pianxian on 2021/10/27.
//   Copyright © 2021 MiKi. All rights reserved.
//

#import "NSLayoutConstraint+crashguard.h"
#import "NSObject+crashguard.h"

@implementation NSLayoutConstraint (crashguard)

+ (void)swizzle_forNSLayoutConstraint
{
    [NSObject cg_swizzleClassMethod:[self class] newSEL:@selector(constraintWithItem:attribute:relatedBy:toItem:attribute:multiplier:constant:) origSEL:@selector(guard_constraintWithItem:attribute:relatedBy:toItem:attribute:multiplier:constant:)];
}

+ (instancetype)guard_constraintWithItem:(id)view1
                               attribute:(NSLayoutAttribute)attr1
                               relatedBy:(NSLayoutRelation)relation
                                  toItem:(id)view2
                               attribute:(NSLayoutAttribute)attr2
                              multiplier:(CGFloat)multiplier
                                constant:(CGFloat)c
{
    @try {
        return [self guard_constraintWithItem:view1 attribute:attr1 relatedBy:relation toItem:view2 attribute:attr2 multiplier:multiplier constant:c];
    } @catch (NSException *exception) {
        [NSObject cg_reportAbnormalMsg:exception.description];
        return nil;
    } @finally {
    }
}

@end
