//
//  PXFileManager.m
//  PXxlogger
//
//  Created by pianxian on 2022/12/27.
//

#import "PXXLoggerFileManager.h"
#if __has_include(<YYCategories/YYCategories.h>)
#import <YYCategories/YYCategories.h>
#endif

@interface PXXLoggerFileManager ()
{
//    NSUInteger _maximumNumberOfLogFiles;
//    unsigned long long _logFilesDiskQuota;
    NSString *_logsDirectory;
}

@end

@implementation PXXLoggerFileManager

- (instancetype)initWithLogsDirectory:(NSString *)aLogsDirectory
{
    if ((self = [super init])  ) {
        _logsDirectory = aLogsDirectory;
        if (_logsDirectory.length <= 0) {
            _logsDirectory = [PXXLoggerFileManager defaultLogsDirectory];
        }
    }
    return self;
}

- (NSString *)logsDirectory
{
    // 假如文件被删除的话，我们可以重建目录，所以每次都判断
    if (![[NSFileManager defaultManager] fileExistsAtPath:_logsDirectory]) {
        NSError *err = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:_logsDirectory
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:&err]) {
            NSLog(@"ATHLogDefaultFileManager: Error creating logsDirectory: %@", err);
        }
    }

    return _logsDirectory;
}

/**
 * 默认的日志文件路径
 **/
+ (NSString *)defaultLogsDirectory
{
#if TARGET_OS_IPHONE
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *baseDir = paths.firstObject;
    NSString *logsDirectory = [baseDir stringByAppendingPathComponent:@"Logs"];

#else
    NSString *appName = [[NSProcessInfo processInfo] processName];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? paths[0] : NSTemporaryDirectory();
    NSString *logsDirectory = [[basePath stringByAppendingPathComponent:@"Logs"] stringByAppendingPathComponent:appName];

#endif

    return logsDirectory;
}

- (void)deleteAllLogFiles
{
    NSArray *filePaths = [self unsortedLogFilePaths];

    if (filePaths.count > 0) {
        for (NSUInteger i = 0; i < filePaths.count; i++) {
            NSString *path = filePaths[i];

            NSLog(@"PXXLoggerFileManager: Deleting file: %@", path);

            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
    }
    NSLog(@"after ATHLogDefaultFileManager: deleteAllLogFiles, sortedLogFileInfos: %lu", [self unsortedLogFilePaths].count);
}

- (NSArray *)unsortedLogFilePaths
{
    NSString *logsDirectory = [self logsDirectory];
    NSArray *fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:logsDirectory error:nil];

    NSMutableArray *unsortedLogFilePaths = [NSMutableArray arrayWithCapacity:[fileNames count]];

    for (NSString *fileName in fileNames) {
        // Filter out any files that aren't log files. (Just for extra safety)

#if TARGET_IPHONE_SIMULATOR
        // In case of iPhone simulator there can be 'archived' extension. isLogFile:
        // method knows nothing about it. Thus removing it for this method.
        //
        // See full explanation in the header file.
        NSString *theFileName = [fileName stringByReplacingOccurrencesOfString:@".archived"
                                                                    withString:@""];

        if ([self isLogFile:theFileName])
#else

        if ([self isLogFile:fileName])
#endif
        {
            NSString *filePath = [logsDirectory stringByAppendingPathComponent:fileName];

            [unsortedLogFilePaths addObject:filePath];
        }
    }

    return unsortedLogFilePaths;
}

- (NSArray *)sortedLogFilePathsByCreatedAt
{
    NSMutableArray *unsortedLogFilePaths = [self unsortedLogFilePaths].mutableCopy;
    
    [unsortedLogFilePaths sortUsingComparator:^NSComparisonResult(NSString * _Nonnull obj1, NSString * _Nonnull obj2) {
        NSFileManager* fm = [NSFileManager defaultManager];
        NSDictionary* attrs1 = [fm attributesOfItemAtPath:obj1 error:nil];
        NSDictionary* attrs2 = [fm attributesOfItemAtPath:obj2 error:nil];
        NSDate *date1 = (NSDate*)[attrs1 objectForKey: NSFileCreationDate];
        NSDate *date2 = (NSDate*)[attrs2 objectForKey: NSFileCreationDate];
        if (date1 && date2) {
            return [date1 compare:date2];
        }
        return NSOrderedSame;
    }];
    return unsortedLogFilePaths;
}

- (BOOL)isLogFile:(NSString *)fileName
{
    BOOL isLogFile = [fileName hasSuffix:@".xlog"];
    return isLogFile;
}
@end
