//
//  YYExtensionUncaughtExceptionHandler.m
//  Empty
//
//  Created by pianxian on 2022/1/13.
//  Copyright © 2022 com.sango. All rights reserved.
//

#include <libkern/OSAtomic.h>
#include <execinfo.h>
#import <UIKit/UIKit.h>
#import "MiKiUncaughtExceptionHandler.h"

#if __has_include(<PXxlogger/PXXLoggerUtil.h>)
@import PXxlogger;
#endif
//#define kExtensionName [MAINPRODUCT_BUNDLE_IDENTIFIER containsString:Extension_NotificationService] ? Extension_NotificationService : Extenion_NotificationContent

static NSUncaughtExceptionHandler *previousUncaughtExceptionHandler;

void HandleException(NSException *exception) {
    NSArray *stackArray = [exception callStackSymbols];
    
    NSString *reason = [exception reason];
    
    NSString *name = [exception name];
    
    NSString *exceptionInfo = [NSString stringWithFormat:@"Crash!!!:\nException reason：%@\nException name：%@\nException stack：%@",name, reason, stackArray];

#if __has_include(<PXxlogger/PXXLoggerUtil.h>)
    MiKiXLOG_ERROR("Crash", @"%@", exceptionInfo);
    [MiKiXLogHelper flush];
#endif


    // 调用之前崩溃的回调函数
    if (previousUncaughtExceptionHandler) {
        previousUncaughtExceptionHandler(exception);
    }
    
    // 杀掉程序，这样可以防止同时抛出的SIGABRT被SignalException捕获
    kill(getpid(), SIGKILL);
}

void InstallUncaughtExceptionHandler(void) {
    // Backup original handler
    previousUncaughtExceptionHandler = NSGetUncaughtExceptionHandler();
    
    NSSetUncaughtExceptionHandler(&HandleException);
}

void SignalExceptionHandler(int signal)
{
    NSMutableString *infoStr = [[NSMutableString alloc] init];
    [infoStr appendString:@"Crash!!!:\nStack:\n"];
    void* callstack[128];
    int i, frames = backtrace(callstack, 128);
    char** strs = backtrace_symbols(callstack, frames);
    for (i = 0; i <frames; ++i) {
        [infoStr appendFormat:@"%s\n", strs[i]];
    }
    free(strs);
#if __has_include(<PXxlogger/PXXLoggerUtil.h>)
    MiKiXLOG_ERROR("Crash", @"%@", infoStr);
    [MiKiXLogHelper flush];
#endif

    
    kill(getpid(), SIGKILL);
}


void InstallSignalHandler(void)
{
    // hong up ，挂断。本信号在用户终端连接(正常或非正常)结束时发出,
    signal(SIGHUP, SignalExceptionHandler);
    // 程序终止(interrupt)信号, 用于通知前台进程组终止进程
    signal(SIGINT, SignalExceptionHandler);
    // 和SIGINT类似, 用于通知前台进程组终止进程
    signal(SIGQUIT, SignalExceptionHandler);
    
    // SIGABRT:abort 函数生成的信号
    signal(SIGABRT, SignalExceptionHandler);
    // SIGILL: 执行了非法指令， 通常是因为可执行文件本身出现错误, 或者试图执行数据段. 堆栈溢出也有可能产生这个信号。
    signal(SIGILL, SignalExceptionHandler);
    // SIGSEGV: 试图访问未分配给自己的内存, 或试图往没有写权限的内存地址写数据.
    signal(SIGSEGV, SignalExceptionHandler);
    // SIGFPE: FPE是floating-point exception（浮点异常）的首字母缩略字
    signal(SIGFPE, SignalExceptionHandler);
    //  SIGBUS: 非法地址, 包括内存地址对齐(alignment)出错(如访问不属于自己存储空间或只读存储空间)
    //  它与SIGSEGV的区别在于后者是由于对合法存储地址的非法访问触发的(如访问不属于自己存储空间或只读存储空间)。
    signal(SIGBUS, SignalExceptionHandler);
    // SIGPIPE: 管道破裂。这个信号通常在进程间通信产生，比如采用FIFO(管道)通信的两个进程，读管道没打开或者意外终止就往管道写，写进程会收到SIGPIPE信号。
    // 此外用Socket通信的两个进程，写进程在写Socket的时候，读进程已经终止。
    signal(SIGPIPE, SignalExceptionHandler);
    // SIGSYS: 系统调用传入非法参数
    // signal(SIGSYS, SignalExceptionHandler);
    // SIGTRAP: 断点指令错误，常用于 debug
    // signal(SIGTRAP, SignalExceptionHandler);
}


@implementation MiKiUncaughtExceptionHandler

+ (instancetype)sharedInstance
{
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)installUncaughtExceptionHandler {
    InstallUncaughtExceptionHandler();
}

- (void)installSignalHandler {
    InstallSignalHandler();
}

@end
