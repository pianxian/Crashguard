//
//  NSNumber+crashguard.h
//  CrashGuarder
//
//  Created by pianxian on 2018/6/1.
//  Copyright © 2018年 MiKi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (crashguard)

+ (void)swizzle_forCrashGuard;

@end
