//
//  PXXLogHelper.m
//  PXxlogger
//
//  Created by pianxian on 2023/7/12.
//

#import "PXXLogHelper.h"
#import <sys/xattr.h>
#import <mars/xlog/xloggerbase.h>
#import <mars/xlog/xlogger.h>
#import <mars/xlog/appender.h>

static NSUInteger g_processID = 0;

@implementation PXXLogHelper
+ (void)logInitWithLogPath:(NSString *)logPath
                     level:(ATHLogLevel)level
               maxByteSize:(uint64_t)maxByteSize
               maxDuration:(uint64_t)maxDuration
{
//    NSString* logPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/xlogger"];
    NSLog(@"xlogger path:%@", logPath);
    
    // set do not backup for logpath
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    setxattr([logPath UTF8String], attrName, &attrValue, sizeof(attrValue), 0, 0);

    TLogLevel tlevel = [self athLogLevel2TLogLevel:level];
    xlogger_SetLevel(tlevel);
    mars::xlog::appender_set_console_log(tlevel <= kLevelDebug);
    // issue: 使用 printf，因为有些项目会把 nslog 给用 #define 干掉了
    mars::xlog::appender_set_console_fun(mars::xlog::kConsolePrintf);
    
    mars::xlog::XLogConfig config;
    config.mode_ = mars::xlog::kAppenderAsync;
    config.logdir_ = [logPath UTF8String];
    config.nameprefix_ = "PX";
    config.pub_key_ = "";
    config.compress_mode_ = mars::xlog::kZlib;
    config.compress_level_ = 6;
    config.cachedir_ = "";
    config.cache_days_ = 0;
    appender_open(config);
    if (0 == maxByteSize) {
        mars::xlog::appender_set_max_file_size(50 * 1024 * 1024);
    } else {
        mars::xlog::appender_set_max_file_size(maxByteSize);
    }
    if (maxDuration > 0) {
        mars::xlog::appender_set_max_alive_duration(maxDuration);
    }
}

+ (void)logDeInit
{
    mars::xlog::appender_close();
}

+ (void)logWithLevel:(ATHLogLevel)logLevel
          moduleName:(const char*)moduleName
            fileName:(const char*)fileName
          lineNumber:(int)lineNumber
            funcName:(const char*)funcName
             message:(NSString *)message {
    XLoggerInfo info;
    info.level = [self athLogLevel2TLogLevel:logLevel];
    info.tag = moduleName;
    info.filename = fileName;
    info.func_name = funcName;
    info.line = lineNumber;
    gettimeofday(&info.timeval, NULL);
    info.tid = (uintptr_t)[NSThread currentThread];
    info.maintid = (uintptr_t)[NSThread mainThread];
    info.pid = g_processID;
    xlogger_Write(&info, message.UTF8String);
}

+ (void)logWithLevel:(ATHLogLevel)logLevel
          moduleName:(const char*)moduleName
            fileName:(const char*)fileName
          lineNumber:(int)lineNumber
            funcName:(const char*)funcName
              format:(NSString *)format, ...
{
    if ([self shouldLog:logLevel]) {
        va_list argList;
        va_start(argList, format);
        NSString* message = [[NSString alloc] initWithFormat:format arguments:argList];
        [self logWithLevel:logLevel
                moduleName:moduleName
                  fileName:fileName
                lineNumber:lineNumber
                  funcName:funcName
                   message:message];
        va_end(argList);
    }
}

+ (BOOL)shouldLog:(ATHLogLevel)level
{
    if ([self athLogLevel2TLogLevel:level] >= xlogger_Level()) {
        return YES;
    }
    
    return NO;
}

+ (void)flush
{
    mars::xlog::appender_flush();
}

+ (void)flushUnsafely
{
    mars::xlog::appender_flush_sync();
}

+ (TLogLevel)athLogLevel2TLogLevel:(ATHLogLevel)level
{
    TLogLevel tLogLevel = kLevelNone;
    switch (level) {
        case ATHLogLevelOff:
            break;

        case ATHLogLevelError:
            tLogLevel = kLevelError;
            break;

        case ATHLogLevelWarning:
            tLogLevel = kLevelWarn;
            break;

        case ATHLogLevelImportant:
            tLogLevel = kLevelFatal;
            break;

        case ATHLogLevelInfo:
            tLogLevel = kLevelInfo;
            break;

        case ATHLogLevelTest:
        case ATHLogLevelDebug:
            tLogLevel = kLevelDebug;
            break;

        case ATHLogLevelVerbose:
            tLogLevel = kLevelVerbose;
            break;

        case ATHLogLevelAll:
            tLogLevel = kLevelAll;
            break;

        default:
            break;
    }
    return tLogLevel;
}

@end
