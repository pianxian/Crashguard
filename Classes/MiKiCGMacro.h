//
//  MiKiCGMacro.h
//  MiKiCrashGuard
//
//  Created by pianxian on 2020/8/3.
//  Copyright © 2020 MiKi. All rights reserved.
//

#ifndef MiKiCGMacro_h
#define MiKiCGMacro_h

#import "MiKiCrashGuard.h"

extern void MiKiCG_ISSwizzleInstanceMethod(Class className, SEL originalSelector, SEL alternativeSelector);

#define MiKiCG_INFO(fmt, ...) \
MiKiCGSafeBlock(MiKiCrashGuard.logCallback, ([NSString stringWithFormat:fmt, ##__VA_ARGS__]))

#define SafeBlock(atBlock, ...) \
    if(atBlock) { atBlock(__VA_ARGS__); }

#endif /* MiKiCGMacro_h */
