//
//  NSMutableArray+crashguard.h
//  crashreport
//
//  Created by pianxian on 2017/6/21.
//  Copyright © 2017年 DW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (crashguard)

+ (void)swizzle_forNSMutableArray;

@end
