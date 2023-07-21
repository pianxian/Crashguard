//
//  NSObject+DataRaceScaner.h
//  TestDemo
//
//  Created by pianxian on 2019/1/17.
//  Copyright © 2019 MiKi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define DRS_WEAKIFY(obj) \
__weak __typeof__(obj) obj##_weak_ = obj;

#define DRS_STRONGIFY(obj) \
__strong __typeof__(obj##_weak_) obj = obj##_weak_;

#define DRS_REPORTRACE(WriteThread) \
NSString *errorStr = [NSString stringWithFormat:@"Data Race in \n%s, pls check your code", __PRETTY_FUNCTION__]; \
DRS_ReportDataRace(errorStr, WriteThread); \

#define DRS_WRITING(method)  \
DRS_WEAKIFY(self)[self drs_startWritingCompletion:^{DRS_STRONGIFY(self) method;}]; \

#define DRS_SWIZZLELOGIC(_class, _selStr) \
DRS_ISSwizzleInstanceMethod(_class, @selector(_selStr), @selector(drs_##_selStr));

/*--------------Write------------------*/

#define DRS_WRITELOGIC(method) \
NSNumber* drsThread = self.drs_thread; \
if (DRS_JudgeIfDataRace(drsThread)) { DRS_REPORTRACE(drsThread) return; } DRS_WRITING(method);

/*--------------Read-------------------*/

#define DRS_READLOGINC(default, method) \
NSNumber* drsThread = self.drs_thread; \
if (DRS_JudgeIfDataRace(drsThread)) { DRS_REPORTRACE(drsThread) return default;} return method;

#define DRS_READLOGINCVOID(method) \
NSNumber* drsThread = self.drs_thread; \
if (DRS_JudgeIfDataRace(drsThread)) { DRS_REPORTRACE(drsThread) return;} return method;

/*-------------------------------------*/

typedef struct drs_os_unfair_lock_s {
    uint32_t _drs_os_unfair_lock_opaque;
} drs_os_unfair_lock_t;

typedef BOOL(^DataRaceScanerCallBack)(NSString *msg, NSString *stack);

CG_EXTERN void DRS_ISSwizzleInstanceMethod(Class className, SEL originalSelector, SEL alternativeSelector);
CG_EXTERN void DRS_ReportDataRace(NSString *error, NSNumber *writingThread);
CG_EXTERN BOOL DRS_JudgeIfDataRace(NSNumber *thread);

/*-------------------------------------*/

@interface NSObject (DataRaceScaner)

@property (atomic, assign) drs_os_unfair_lock_t drs_unfairLock;
@property (nonatomic, strong) NSNumber *drs_thread; //记录当前写操作的线程信息

// 启动 DataRace
+ (void)drs_start;

// 检测到 DataRace 后回调
+ (void)drs_observeCallback:(DataRaceScanerCallBack)callback;

// 开始写操作
- (void)drs_startWritingCompletion:(dispatch_block_t)block;

@end
