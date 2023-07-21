//
//  CrashGuardGeneralLock.cpp
//  crashreport
//
//  Created by pianxian on 2017/8/28.
//  Copyright © 2017年 DW. All rights reserved.
//

#include "CrashGuardGeneralLock.h"
#include <UIKit/UIKit.h>
#include <iostream>

CrashGuardGeneralLock::CrashGuardGeneralLock()
{
    unfair = ([UIDevice currentDevice].systemVersion.floatValue >= 10);
    if( unfair )
    {
        unfairlock = OS_UNFAIR_LOCK_INIT;
    }
    else
    {
        mutexValid = (pthread_mutex_init(&mutex, NULL) == 0);
    }
}

CrashGuardGeneralLock::~CrashGuardGeneralLock()
{
    if( !unfair && mutexValid )
    {
        pthread_mutex_destroy(&mutex);
    }
}

void CrashGuardGeneralLock::lock()
{
    if( unfair )
    {
        os_unfair_lock_lock(&unfairlock);
    }
    else if( mutexValid )
    {
        pthread_mutex_lock(&mutex);
    }
}

void CrashGuardGeneralLock::unlock()
{
    if( unfair )
    {
        os_unfair_lock_unlock(&unfairlock);
    }
    else if( mutexValid )
    {
        pthread_mutex_unlock(&mutex);
    }
}
