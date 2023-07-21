//
//  PXXLoggerSvc.m
//  PXxlogger
//
//  Created by pianxian on 2022/12/27.
//

#import "PXXLoggerService.h"
#import "PXFileLoggerConfig.h"
#import "PXXLogHelper.h"
#import "PXXLoggerFileManager.h"

@interface PXXLoggerService()

@property (nonatomic, strong) PXXLoggerFileManager *logFileManager;

@end

@implementation PXXLoggerService

+ (instancetype)sharedInstance
{
    static PXXLoggerService *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[PXXLoggerService alloc] init];
    });
    return _instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    }
    return self;
}

- (void)applicationWillTerminate:(NSNotification *)notifi
{
    // [PXXLoggerSvc flush];
    [PXXLogHelper logDeInit];
}

+ (BOOL)configFileLogger:(PXFileLoggerConfig *)config
{
    PXXLoggerService *logger = [self sharedInstance];
    logger.logFileManager = [[PXXLoggerFileManager alloc] initWithLogsDirectory:config.directory];
    PXXLoggerFileManager *fileManager = logger.fileManager;
    [PXXLogHelper logInitWithLogPath:fileManager.logsDirectory
                                 level:config.level
                           maxByteSize:config.maxFileSize
                           maxDuration:config.maxDuration];
    return YES;
}

- (PXXLoggerFileManager *)fileManager
{
    return _logFileManager;
}

+ (void)flushUnsafely
{
    [PXXLogHelper flushUnsafely];
}

/**
 * 因为日志是异步进行打印的，所以可能存在需要flush的情况
 * 日志框架本身应该在应用退出的时候主动调用，以及App crash的时候应该由应用层主动调用
 **/
+ (void)flush
{
    [PXXLogHelper flush];
}

+ (NSString *)logDirectory
{
    PXXLoggerService *logger = [self sharedInstance];
    PXXLoggerFileManager *fileManager = [logger fileManager];
    return fileManager.logsDirectory;
}

+ (NSArray<NSString *> *)logFiles
{
    PXXLoggerService *logger = [self sharedInstance];
    PXXLoggerFileManager *fileManager = [logger fileManager];
    return fileManager.sortedLogFilePathsByCreatedAt;
}

+ (NSArray<NSString *> *)logFilesWithMaxSize:(NSInteger)maxSize
{
    PXXLoggerService *logger = [self sharedInstance];
    PXXLoggerFileManager *fileManager = [logger fileManager];
    NSMutableArray *max = NSMutableArray.array;
    NSInteger cur = 0;
    for (NSString *file in fileManager.sortedLogFilePathsByCreatedAt.reverseObjectEnumerator.allObjects) {
        NSError *error = nil;
        NSDictionary* attrs = [NSFileManager.defaultManager attributesOfItemAtPath:file error:&error];
        if (error) {
            continue;
        }
        cur += [attrs[NSFileSize] longLongValue];
        if (cur > maxSize) {
            break;
        }
        [max addObject:file];
    }
    return max;
}

@end
