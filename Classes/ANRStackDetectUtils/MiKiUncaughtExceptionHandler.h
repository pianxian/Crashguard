//
//  YYExtensionUncaughtExceptionHandler.h
//  Empty
//
//  Created by pianxian on 2022/1/13.
//  Copyright © 2022 com.sango. All rights reserved.
//

#import <Foundation/Foundation.h>

//OC 的Exception
void InstallUncaughtExceptionHandler(void);

// signal的exception
void InstallSignalHandler(void);

@interface MiKiUncaughtExceptionHandler: NSObject

+ (instancetype)sharedInstance;

- (void)installUncaughtExceptionHandler;

- (void)installSignalHandler;

@end
