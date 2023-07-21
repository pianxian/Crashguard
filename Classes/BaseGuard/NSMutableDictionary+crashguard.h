//
//  NSMutableDictionary+crashguard.h
//  crashreport
//
//  Created by pianxian on 17/5/3.
//  Copyright © 2017年 DW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (crashguard)

+ (void)swizzle_forNSMutableDictionary;

@end
