//
//  PXFileManager.h
//  PXxlogger
//
//  Created by pianxian on 2022/12/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PXXLoggerFileManager : NSObject

- (instancetype)initWithLogsDirectory:(NSString *)aLogsDirectory;

- (NSString *)logsDirectory;

/// 清理全部日志文件
- (void)deleteAllLogFiles;

- (NSArray *)unsortedLogFilePaths;

- (NSArray *)sortedLogFilePathsByCreatedAt;

@end

NS_ASSUME_NONNULL_END
