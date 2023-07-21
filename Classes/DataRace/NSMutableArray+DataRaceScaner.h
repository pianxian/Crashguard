//
//  NSMutableArray+DataRaceScaner.h
//  TestDemo
//
//  Created by pianxian on 2019/1/14.
//  Copyright © 2019 MiKi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (DataRaceScaner)

+ (void)miki_startDataRaceScanner;

@end

