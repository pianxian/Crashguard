//
//  NSMutableDictionary+DataRaceScaner.h
//  TestDemo
//
//  Created by pianxian on 2019/1/31.
//  Copyright © 2019 MiKi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (DataRaceScaner)

+ (void)miki_startDataRaceScanner;

@end

