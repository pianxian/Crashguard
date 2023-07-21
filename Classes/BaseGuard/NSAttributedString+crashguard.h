//
//  NSAttributedString+crashguard.h
//  CrashGuardSDK
//
//  Created by pianxian on 2018/12/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSAttributedString (crashguard)

+ (void)swizzle_forAttributedString;

@end

NS_ASSUME_NONNULL_END
