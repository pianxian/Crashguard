//
//  NSCache+crashguard.h
//  CrashGuarder
//
//  Created by pianxian on 2018/8/3.
//  Copyright © 2018 MiKi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSCache (crashguard)

+ (void)swizzle_forNSCache;

@end

NS_ASSUME_NONNULL_END
