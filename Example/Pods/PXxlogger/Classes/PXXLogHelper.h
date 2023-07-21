//
//  PXXLogHelper.h
//  PXxlogger
//
//  Created by pianxian 2023/7/12.
//

#import <Foundation/Foundation.h>
#import "PXMarco.h"

NS_ASSUME_NONNULL_BEGIN

@interface PXXLogHelper : NSObject

+ (void)logInitWithLogPath:(NSString *)logPath
                     level:(ATHLogLevel)level
               maxByteSize:(uint64_t)maxByteSize
               maxDuration:(uint64_t)maxDuration;

+ (void)logDeInit;

+ (void)logWithLevel:(ATHLogLevel)logLevel
          moduleName:(const char*)moduleName
            fileName:(const char*)fileName
          lineNumber:(int)lineNumber
            funcName:(const char*)funcName
             message:(NSString *)message;

+ (void)logWithLevel:(ATHLogLevel)logLevel
          moduleName:(const char*)moduleName
            fileName:(const char*)fileName
          lineNumber:(int)lineNumber
            funcName:(const char*)funcName
              format:(NSString *)format, ...;

+ (BOOL)shouldLog:(ATHLogLevel)level;

+ (void)flush;

+ (void)flushUnsafely;

@end
#define PXXLogInternal(level, module, file, line, func, prefix, format, ...) \
do { \
    if ([PXXLogHelper shouldLog:level]) { \
        NSString *aMessage = [NSString stringWithFormat:@"%@%@", prefix, [NSString stringWithFormat:format, ##__VA_ARGS__, nil]]; \
        [PXXLogHelper logWithLevel:level moduleName:module fileName:file lineNumber:line funcName:func message:aMessage]; \
    } \
} while(0)

NS_ASSUME_NONNULL_END
