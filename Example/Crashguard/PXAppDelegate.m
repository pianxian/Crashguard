//
//  PXAppDelegate.m
//  Crashguard
//
//  Created by huweiwei on 07/21/2023.
//  Copyright (c) 2023 huweiwei. All rights reserved.
//

#import "PXAppDelegate.h"
@import Crashguard;
@import PXxlogger;


static NSDictionary * DataRaceWhiteList(void)
{
    static NSDictionary *whiteList = nil;
    static dispatch_once_t onceToken;
    dispatch_miki_once(&onceToken, ^{
        whiteList = @{
            @"Stack": @[
                @"SSDKLogService", // ShareSDK
                @"AFImageDownloader" // AFImageDownloader
            ],
            @"Queue": @[
                @"SendLog", // ShareSDK
                @"HttpDispatcher", // ShareSDK
                @"alamofire.imagedownloader" // AFImageDownloader
            ]
        };
    });
    return whiteList;
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"
static BOOL IsInDataRaceWhiteListQueue(dispatch_queue_t queue)
{
    for (NSString *queueSymbols in DataRaceWhiteList()[@"Queue"]) {
        if ([queue.description containsString:queueSymbols]) {
            return YES;
        }
    }
    return NO;
}
#pragma clang diagnostic pop

@implementation PXAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    PXFileLoggerConfig *config = [[PXFileLoggerConfig alloc] init];
    // 存储 7 天
    config.maxDuration = 7 * 24 * 60 * 60;
#if !APPSTORE
    config.level = ATHLogLevelAll;
#else
    config.level = ATHLogLevelInfo;
#endif
    [PXXLoggerService configFileLogger:config];
    [self crashintiliza];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)crashintiliza
{
    [MiKiUncaughtExceptionHandler.sharedInstance installUncaughtExceptionHandler];
    [MiKiUncaughtExceptionHandler.sharedInstance installSignalHandler];
    [self.class reportCrash];
    [self.class parseCrashGuardSwitch];
    [self.class enableANRDetect];
    [self.class startDispatchOnceDeadLockGuard];
}

// TODO:这里可以添加上报方案
+ (void)reportCrash
{
    [MiKiCrashGuard setLogCallback:^(NSString *msg){
        PXXLOG_INFO("Crash", @"MiKiCrashGuard: %@", msg);
    }];
    [MiKiCrashGuard setReportCallback:^(NSString * _Nonnull msg, MiKiCrashGuardReportType type) {
        NSString *typeStr = @"";
        switch (type) {
            case MiKiCrashGuardReportType_CrashGuard:
                typeStr = @"CrashGuard";
                break;
            case MiKiCrashGuardReportType_DataRace:
                typeStr = @"DataRace";
                break;
            case MiKiCrashGuardReportType_UIThread:
                typeStr = @"UIThread";
                break;;
        }
        PXXLOG_INFO("Crash", @"Crash report type: %@; msg: %@;", typeStr, msg);
#if DEBUG
  
        if (type == MiKiCrashGuardReportType_CrashGuard) {
            return;
        }
        NSArray<NSString *> * stack = [NSThread callStackSymbols];
        NSString *stackmsg = [NSString stringWithFormat:@"%@\n callStackSymbols:\n %@", msg,stack];
        [self showAlert:[NSString stringWithFormat:@"发生 %@ 了，开发关注一下", typeStr]
                    des:stackmsg];
#endif
    }];
}

+ (void)enableANRDetect
{
    // 设置 ANR 时间，如果主线程卡顿超过 3 秒，输出 ANR
    [MiKiCrashGuard setStackDetectDuration:3];
    // 发生 ANR 的回调
    [MiKiCrashGuard setANRStackDetectCallback:^(NSString *msg) {
        PXXLOG_INFO("ANR", @"ANRDetectUtils: %@", msg);
    }];
    PXXLOG_INFO("ANR", @"anr detection enabled");
    [MiKiCrashGuard startANRDetect];
    PXXLOG_INFO("ANR", @"start ANR assist");
}

+ (void)parseCrashGuardSwitch
{
    BOOL openGuard = true;
    // 只有在构建机的包，才会使用崩溃防护
//#if APPSTORE
//    openGuard = true;
//#endif
        
    [MiKiCrashGuard enableCrashGuardInstantly:openGuard];
    
    // 测试用的构建包才发这个提醒
#if DEBUG
    [MiKiCrashGuard setAbnormalReportCallback:^(NSString * _Nonnull msg) {
        NSArray<NSString *> * stack = [NSThread callStackSymbols];
        NSString *stackmsg = [NSString stringWithFormat:@"%@\n callStackSymbols:\n %@", msg,stack];
        PXXLOG_INFO("Crash", @"GuardedCrash, abnormalMsg: %@. callStackSymbols: %@", msg, stack);
        [self showAlert:@"发生崩溃防护，开发看一下" des:stackmsg];
    }];
#endif
}

+ (void)showAlert:(NSString *)title des:(NSString *)des
{
    dispatch_async(dispatch_get_main_queue(), ^{
    
        UIAlertController *alertScene = [UIAlertController alertControllerWithTitle:@"发生崩溃防护，开发看一下" message:des preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *pastAction = [UIAlertAction actionWithTitle:@"复制堆栈" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [UIPasteboard generalPasteboard].string = des;
        }];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertScene addAction:pastAction];
        [alertScene addAction:confirmAction];
        
        [[self keyWindow].rootViewController presentViewController:alertScene animated:YES completion:nil];
    });
}



+ (void)enableDataRace
{
#if !BEAT && !APPSTORE
    [MiKiCrashGuard startDataRaceScan];
    [MiKiCrashGuard setDataRaceCallback:^BOOL(NSString *msg, NSString *stack) {
        if (IsInDataRaceWhiteListStack(stack)) {
            return NO;
        }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        dispatch_queue_t currentQ = dispatch_get_current_queue();
        if (IsInDataRaceWhiteListQueue(currentQ)) {
            return NO;
        }
#pragma clang diagnostic pop
        NSString *extendLog = [NSString stringWithFormat:@"DataRace occurred in queue: %@", currentQ];
        PXXLOG_INFO("DataRace", @"%@", extendLog);
        return YES;
    }];
#endif
}

static BOOL IsInDataRaceWhiteListStack(NSString * stack)
{
    for (NSString *symbols in DataRaceWhiteList()[@"Stack"]) {
        if ([stack containsString:symbols]) {
            return YES;
        }
    }
    return NO;
}

+ (void)startDispatchOnceDeadLockGuard
{
    [MiKiCrashGuard startDispatchOnceDeadLockGuard];
}

+ (UIWindow *)keyWindow;
{
    NSArray *array = [[[UIApplication sharedApplication] connectedScenes] allObjects];
    if (array.firstObject != nil) {
        UIWindowScene *windowScene = (UIWindowScene *)array.firstObject;
        id<UIWindowSceneDelegate> delegate = (id<UIWindowSceneDelegate>)windowScene.delegate;
        UIWindow *mainWindow = delegate.window;
        if (mainWindow) {
            return mainWindow;
        }
    }
    return UIApplication.sharedApplication.delegate.window;
}
@end
