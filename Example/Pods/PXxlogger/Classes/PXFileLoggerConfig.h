//
//  PXFileLoggerConfig.h
//  PXxlogger
//
//  Created by pianxian on 2022/12/27.
//

#import <Foundation/Foundation.h>
#import "PXMarco.h"

NS_ASSUME_NONNULL_BEGIN

@interface PXFileLoggerConfig : NSObject

/**
 * 允许最多的日志文件数量，0-表示使用默认
 */
@property (nonatomic, assign) unsigned int maxNumberOfFiles;
/**
 * 允许单个日志文件的最大尺寸，0-表示使用默认
 * (in bytes)
 */
@property (nonatomic, assign) unsigned long long maxFileSize;
/**
 * 允许占用的磁盘空间大小，0-表示使用默认
 * optional
 * (in bytes)
 */
@property (nonatomic, assign) unsigned long long diskQuota;
/**
 * 指定日志文件目录，传空则由组件自行决定
 */
@property (nonatomic, assign) NSString * _Nullable directory;
/**
 * 日志文件的归档频率，比如24小时
 * optional
 * (in seconds)
 */
@property (nonatomic, assign) NSTimeInterval rollingFrequency;
/**
 * 设定输出的日志级别, 0 == TLogLevel
 */
@property (nonatomic, assign) ATHLogLevel level;
/**
 * 设定写入File的日志是否加密
 */
@property (nonatomic, assign) BOOL logCrypt;
/**
 * 使用加密功能，加密单行日志的size, 默认是4KB，先预留做占位
 * (in bytes)
 */
@property (nonatomic, assign) unsigned long long bufferSize;;
/**
 * 设定是否统计tag对应日志大小，目前默认1000条采样一次
 */
@property (nonatomic, assign) BOOL enableTagSize;
/// 日志最大的存储时间（秒），默认为 0，不删除
@property (nonatomic, assign) unsigned long long maxDuration;

@end

NS_ASSUME_NONNULL_END
