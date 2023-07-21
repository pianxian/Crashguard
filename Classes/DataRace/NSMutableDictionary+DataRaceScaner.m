//
//  NSMutableDictionary+DataRaceScaner.m
//  TestDemo
//
//  Created by pianxian on 2019/1/31.
//  Copyright © 2019 MiKi. All rights reserved.
//

#import "NSMutableDictionary+DataRaceScaner.h"
#import "NSObject+DataRaceScaner.h"
#import <objc/runtime.h>

#import "MiKiCGMacro.h"

@implementation NSMutableDictionary (DataRaceScaner)

+ (void)miki_startDataRaceScanner
{
    Class __NSDictionaryM = objc_getClass("__NSDictionaryM");
    
    // read
    DRS_SWIZZLELOGIC(__NSDictionaryM, count);
    DRS_SWIZZLELOGIC(__NSDictionaryM, objectForKey:);
    DRS_SWIZZLELOGIC(__NSDictionaryM, allKeysForObject:);
    DRS_SWIZZLELOGIC(__NSDictionaryM, keyEnumerator);
    DRS_SWIZZLELOGIC(__NSDictionaryM, objectEnumerator);
    DRS_SWIZZLELOGIC(__NSDictionaryM, objectsForKeys:notFoundMarker:);
    DRS_SWIZZLELOGIC(__NSDictionaryM, getObjects:andKeys:count:);
    DRS_SWIZZLELOGIC(__NSDictionaryM, objectForKeyedSubscript:);
    DRS_SWIZZLELOGIC(__NSDictionaryM, enumerateKeysAndObjectsWithOptions:usingBlock:);
    
    // write
    DRS_SWIZZLELOGIC(__NSDictionaryM, setObject:forKey:);
    DRS_SWIZZLELOGIC(__NSDictionaryM, removeObjectForKey:);
    DRS_SWIZZLELOGIC(__NSDictionaryM, addEntriesFromDictionary:);
    DRS_SWIZZLELOGIC(__NSDictionaryM, removeAllObjects);
    DRS_SWIZZLELOGIC(__NSDictionaryM, removeObjectsForKeys:);
    DRS_SWIZZLELOGIC(__NSDictionaryM, setObject:forKeyedSubscript:);
    DRS_SWIZZLELOGIC(__NSDictionaryM, setDictionary:);
    
    MiKiCG_INFO(@"DataRace __NSDictionaryM hook finish");
}

#pragma mark - Read

- (NSUInteger)drs_count
{
    DRS_READLOGINC(0, [self drs_count]);
}

- (id)drs_objectForKey:(id)aKey
{
    DRS_READLOGINC(nil, [self drs_objectForKey:aKey]);
}

- (NSArray *)drs_allKeys
{
    DRS_READLOGINC(@[], [self drs_allKeys]);
}

- (NSArray *)drs_allKeysForObject:(id)anObject
{
    DRS_READLOGINC(@[], [self drs_allKeysForObject:anObject]);
}

- (NSArray *)drs_allValues
{
    DRS_READLOGINC(@[], [self drs_allKeys]);
}

- (NSEnumerator *)drs_objectEnumerator
{
    DRS_READLOGINC(nil, [self drs_objectEnumerator]);
}

- (NSEnumerator *)drs_keyEnumerator
{
    DRS_READLOGINC(nil, [self drs_keyEnumerator]);
}

- (NSArray *)drs_objectsForKeys:(NSArray *)keys notFoundMarker:(id)marker
{
    DRS_READLOGINC(@[], [self drs_objectsForKeys:keys notFoundMarker:marker]);
}

- (id)drs_objectForKeyedSubscript:(id)key
{
    DRS_READLOGINC(nil, [self drs_objectForKeyedSubscript:key]);
}

- (void)drs_getObjects:(__unsafe_unretained id _Nonnull [])objects andKeys:(__unsafe_unretained id _Nonnull [])keys count:(NSUInteger)count
{
    DRS_READLOGINCVOID([self drs_getObjects:objects andKeys:keys count:count]);
}

- (void)drs_enumerateKeysAndObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (NS_NOESCAPE^)(id _Nonnull, id _Nonnull, BOOL * _Nonnull))block
{
    DRS_READLOGINCVOID([self drs_enumerateKeysAndObjectsWithOptions:opts usingBlock:block]);
}

#pragma mark - Write

- (void)drs_setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    DRS_WRITELOGIC([self drs_setObject:anObject forKey:aKey]);
}

- (void)drs_removeObjectForKey:(id)aKey
{
    DRS_WRITELOGIC([self drs_removeObjectForKey:aKey]);
}

- (void)drs_addEntriesFromDictionary:(NSDictionary *)otherDictionary
{
   DRS_WRITELOGIC([self drs_addEntriesFromDictionary:otherDictionary]);
}

- (void)drs_removeAllObjects
{
    DRS_WRITELOGIC([self drs_removeAllObjects]);
}

- (void)drs_removeObjectsForKeys:(NSArray *)keyArray
{
    DRS_WRITELOGIC([self drs_removeObjectsForKeys:keyArray]);
}

- (void)drs_setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key
{
    DRS_WRITELOGIC([self drs_setObject:obj forKeyedSubscript:key]);
}

- (void)drs_setDictionary:(NSDictionary *)otherDictionary
{
    DRS_WRITELOGIC([self drs_setDictionary:otherDictionary]);
}

@end
