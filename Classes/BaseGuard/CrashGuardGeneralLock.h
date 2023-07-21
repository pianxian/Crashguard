//
//  CrashGuardGeneralLock.hpp
//  crashreport
//
//  Created by pianxian on 2017/8/28.
//  Copyright © 2017年 DW. All rights reserved.
//

#ifndef CrashGuardGeneralLock_hpp
#define CrashGuardGeneralLock_hpp

#include <stdio.h>
#include <os/lock.h>
#include <pthread.h>

class CrashGuardGeneralLock
{
public:
    CrashGuardGeneralLock();
    ~CrashGuardGeneralLock();
    void lock();
    void unlock();
private:
    os_unfair_lock unfairlock;
    pthread_mutex_t  mutex;
    bool    unfair;
    bool    mutexValid;
};

#endif /* GeneralLock_hpp */
