//
//  NSURLSession+crashguard.h
//  CrashGuardSDK
//
//  Created by pianxian on 2020/2/12.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLSession (crashguard)

+ (void)swizzle_forURLSession;

@end

NS_ASSUME_NONNULL_END
