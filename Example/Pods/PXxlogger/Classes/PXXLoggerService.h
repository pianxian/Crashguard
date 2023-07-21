//
//  PXXLoggerSvc.h
//  PXxlogger
//
//  Created by pianxian on 2022/12/27.
//

#import <Foundation/Foundation.h>

@class PXFileLoggerConfig;

NS_ASSUME_NONNULL_BEGIN

@interface PXXLoggerService : NSObject

+ (instancetype)sharedInstance;

+ (BOOL)configFileLogger:(PXFileLoggerConfig *)config;

+ (void)flush;

+ (void)flushUnsafely;

+ (NSString *)logDirectory;

/// 获取所有 log 文件
+ (NSArray<NSString *> *)logFiles;

/// 获取所有 log 文件
/// @param maxSize 设置最大获取的文件大小
+ (NSArray<NSString *> *)logFilesWithMaxSize:(NSInteger)maxSize;

@end

NS_ASSUME_NONNULL_END
