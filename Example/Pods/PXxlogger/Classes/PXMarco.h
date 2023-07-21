//
//  PXMarco.h
//  Pods
//
//  Created by pianxian on 2023/7/12.
//

#ifndef PXMarco_h
#define PXMarco_h

/**
 *  每条日志的类别. 和level共同用于过滤日志.
 */
typedef NS_OPTIONS(NSUInteger, ATHLogFlag){
    /**
     *  0...0000001
     */
    ATHLogFlagError      = (1 << 0),
    /**
     *  0...0000010
     */
    ATHLogFlagWarning    = (1 << 1),
    /**
     *  0...0000100
     */
    ATHLogFlagImportant  = (1 << 2),
    /**
     *  0...0001000
     */
    ATHLogFlagInfo       = (1 << 3),
    /**
     *  0...0010000
     */
    ATHLogFlagTest       = (1 << 4),
    /**
     *  0...0100000
     */
    ATHLogFlagDebug      = (1 << 5),
    /**
     *  0...1000000
     */
    ATHLogFlagVerbose    = (1 << 6)
};

/**
 *  日志级别，用于过滤日志（accompany with logFlag）
 */
typedef NS_ENUM(NSUInteger, ATHLogLevel){
    /**
     *  默认值，不输出任何日志
     */
    ATHLogLevelOff       = 0,
    /**
     *  只输出错误日志
     */
    ATHLogLevelError     = (ATHLogFlagError),
    /**
     *  输出错误和警告日志
     */
    ATHLogLevelWarning   = (ATHLogLevelError   | ATHLogFlagWarning),
    /**
     *  输出错误、警告和重要日志
     */
    ATHLogLevelImportant = (ATHLogLevelWarning   | ATHLogFlagImportant),
    /**
     *  输出错误、警告、重要和信息级别日志
     */
    ATHLogLevelInfo      = (ATHLogLevelImportant | ATHLogFlagInfo),
    /**
     *  输出错误、警告、重要、信息和测试级别日志
     */
    ATHLogLevelTest      = (ATHLogLevelInfo     | ATHLogFlagTest),
    /**
     *  输出错误、警告、重要、信息、测试和调试级别日志
     */
    ATHLogLevelDebug     = (ATHLogLevelTest     | ATHLogFlagDebug),
    /**
     *  输出verbose以上级别日志
     */
    ATHLogLevelVerbose   = (ATHLogLevelDebug   | ATHLogFlagVerbose),
    
    /**
     *  输出所有日志 (1...11111)
     */
    ATHLogLevelAll       = NSUIntegerMax
};
#endif /* PXMarco_h */
