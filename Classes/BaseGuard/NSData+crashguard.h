//
//  NSData+crashguard.h
//  CrashGuarder
//
//  Created by pianxian on 2018/8/17.
//  Copyright © 2018 MiKi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (crashguard)

+ (void)swizzle_forNSData;

@end

NS_ASSUME_NONNULL_END
