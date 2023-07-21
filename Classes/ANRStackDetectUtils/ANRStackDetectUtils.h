//
//  ANRStackDetectUtils.h
//  libBaseService
//
//  Created by pianxian on 2018/9/18.
//  Copyright © 2018 MiKi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ANRStackDetectUtils : NSObject

+ (void)start;

+ (void)stop;

+ (void)setStackDetectDuration:(NSTimeInterval)duration;

+ (void)setANRStackDetectCallback:(void (^)(NSString *msg))callback;

@end

NS_ASSUME_NONNULL_END
