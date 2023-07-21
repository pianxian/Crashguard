#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "ANRStackDetectUtils.h"
#import "MiKiUncaughtExceptionHandler.h"
#import "MikiWeakTimer.h"
#import "CALayer+CrashGuard.h"
#import "NSArray+crashguard.h"
#import "NSAttributedString+crashguard.h"
#import "NSCache+crashguard.h"
#import "NSData+crashguard.h"
#import "NSDictionary+crashguard.h"
#import "NSJSONSerialization+crashguard.h"
#import "NSLayoutConstraint+crashguard.h"
#import "NSMutableArray+crashguard.h"
#import "NSMutableDictionary+crashguard.h"
#import "NSNumber+crashguard.h"
#import "NSObject+crashguard.h"
#import "NSSet+crashguard.h"
#import "NSString+crashguard.h"
#import "NSURLSession+crashguard.h"
#import "UINavigationController+crashguard.h"
#import "UIView+crashguard.h"
#import "NSMutableArray+DataRaceScaner.h"
#import "NSMutableDictionary+DataRaceScaner.h"
#import "NSObject+DataRaceScaner.h"
#import "DispatchOnceDeadLockGuard.h"
#import "MiKiCGMacro.h"
#import "MiKiCrashGuard.h"
#import "MikiBacktraceLogger.h"

FOUNDATION_EXPORT double CrashguardVersionNumber;
FOUNDATION_EXPORT const unsigned char CrashguardVersionString[];

