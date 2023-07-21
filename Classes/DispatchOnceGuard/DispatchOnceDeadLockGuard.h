//
//  DispatchOnceDeadLockGuard.h
//  TestDemo
//
//  Created by pianxian on 2018/11/23.
//  Copyright © 2018 MiKiMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSObject (DeadLockGuard)

extern void DODG_dispatch_once(NSString *location,
                               dispatch_once_t *predicate,
                               DISPATCH_NOESCAPE dispatch_block_t block);

extern void DODG_dispatch_sync_safe_main(dispatch_block_t block);
extern void DODG_dispatch_async_safe_main(dispatch_block_t block);

// 启动死锁防护
+ (void)DODG_startDispatchOnceDeadLockGuard;

+ (void)DODG_setCallback:(dispatch_block_t)callback;

@end
