//
//  NSJSONSerialization+crashguard.h
//  CrashGuarder
//
//  Created by pianxian on 2018/11/19.
//  Copyright © 2018 MiKi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSJSONSerialization (crashguard)

+ (void)swizzle_forJSONSerialization;

@end

NS_ASSUME_NONNULL_END
