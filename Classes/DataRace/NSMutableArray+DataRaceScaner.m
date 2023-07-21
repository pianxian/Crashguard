//
//  NSMutableArray+DataRaceScaner.m
//  TestDemo
//
//  Created by pianxian on 2019/1/14.
//  Copyright © 2019 MiKi. All rights reserved.
//

#import "NSMutableArray+DataRaceScaner.h"
#import "NSObject+DataRaceScaner.h"
#import <objc/runtime.h>

#import "MiKiCGMacro.h"

@implementation NSMutableArray (DataRaceScaner)

#pragma mark - Swizzle

+ (void)miki_startDataRaceScanner
{
    
    Class __NSArrayM = objc_getClass("__NSArrayM");
    
    // read
    DRS_SWIZZLELOGIC(__NSArrayM, objectAtIndex:);
    DRS_SWIZZLELOGIC(__NSArrayM, count);
    DRS_SWIZZLELOGIC(__NSArrayM, containsObject:);
    DRS_SWIZZLELOGIC(__NSArrayM, indexOfObject:);
    DRS_SWIZZLELOGIC(__NSArrayM, objectAtIndexedSubscript:);
    DRS_SWIZZLELOGIC(__NSArrayM, indexOfObject:inRange:);
    DRS_SWIZZLELOGIC(__NSArrayM, indexOfObjectIdenticalTo:);
    DRS_SWIZZLELOGIC(__NSArrayM, isEqualToArray:);
    DRS_SWIZZLELOGIC(__NSArrayM, firstObject);
    DRS_SWIZZLELOGIC(__NSArrayM, lastObject);
    DRS_SWIZZLELOGIC(__NSArrayM, objectEnumerator);
    DRS_SWIZZLELOGIC(__NSArrayM, reverseObjectEnumerator);
    DRS_SWIZZLELOGIC(__NSArrayM, enumerateObjectsUsingBlock:)
    DRS_SWIZZLELOGIC(__NSArrayM, enumerateObjectsWithOptions:usingBlock:)
    
    // write
    DRS_SWIZZLELOGIC(__NSArrayM, addObject:);
    DRS_SWIZZLELOGIC(__NSArrayM, insertObject:atIndex:);
    DRS_SWIZZLELOGIC(__NSArrayM, removeLastObject);
    DRS_SWIZZLELOGIC(__NSArrayM, removeObjectAtIndex:);
    DRS_SWIZZLELOGIC(__NSArrayM, setObject:atIndexedSubscript:);
    DRS_SWIZZLELOGIC(__NSArrayM, addObjectsFromArray:);
    DRS_SWIZZLELOGIC(__NSArrayM, replaceObjectAtIndex:withObject:);
    DRS_SWIZZLELOGIC(__NSArrayM, exchangeObjectAtIndex:withObjectAtIndex:);
    DRS_SWIZZLELOGIC(__NSArrayM, removeAllObjects);
    DRS_SWIZZLELOGIC(__NSArrayM, removeObject:);
    DRS_SWIZZLELOGIC(__NSArrayM, removeObject:inRange:);
    DRS_SWIZZLELOGIC(__NSArrayM, removeObjectIdenticalTo:);
    DRS_SWIZZLELOGIC(__NSArrayM, removeObjectIdenticalTo:inRange:);
    DRS_SWIZZLELOGIC(__NSArrayM, removeObjectsInArray:);
    DRS_SWIZZLELOGIC(__NSArrayM, removeObjectsInRange:);
    DRS_SWIZZLELOGIC(__NSArrayM, replaceObjectsInRange:withObjectsFromArray:);
    DRS_SWIZZLELOGIC(__NSArrayM, replaceObjectsInRange:withObjectsFromArray:range:);
    
    MiKiCG_INFO(@"DataRace __NSArrayM hook finish");
}

#pragma mark - Read

- (id)drs_objectAtIndex:(NSUInteger)index
{
    DRS_READLOGINC(nil, [self drs_objectAtIndex:index]);
}

- (NSUInteger)drs_count
{
    DRS_READLOGINC(0, [self drs_count]);
}

- (BOOL)drs_containsObject:(id)anObject
{
    DRS_READLOGINC(NO, [self drs_containsObject:anObject]);
}

- (NSUInteger)drs_indexOfObject:(id)anObject
{
    DRS_READLOGINC(0, [self drs_indexOfObject:anObject]);
}

- (id)drs_objectAtIndexedSubscript:(NSUInteger)idx
{
    DRS_READLOGINC(nil, [self drs_objectAtIndexedSubscript:idx]);
}

- (NSUInteger)drs_indexOfObject:(id)anObject inRange:(NSRange)range
{
    DRS_READLOGINC(0, [self drs_indexOfObject:anObject inRange:range]);
}

- (NSUInteger)drs_indexOfObjectIdenticalTo:(id)anObject
{
    DRS_READLOGINC(0, [self drs_indexOfObjectIdenticalTo:anObject]);
}

- (NSUInteger)drs_indexOfObjectIdenticalTo:(id)anObject inRange:(NSRange)range
{
    DRS_READLOGINC(0, [self drs_indexOfObjectIdenticalTo:anObject inRange:range]);
}

- (BOOL)drs_isEqualToArray:(NSArray *)otherArray
{
    DRS_READLOGINC(NO, [self drs_isEqualToArray:otherArray]);
}

- (id)drs_firstObject
{
    DRS_READLOGINC(nil, [self drs_firstObject]);
}

- (id)drs_lastObject
{
    DRS_READLOGINC(nil, [self drs_lastObject]);
}

- (NSEnumerator *)drs_objectEnumerator
{
    DRS_READLOGINC(nil, [self drs_objectEnumerator]);
}

- (NSEnumerator *)drs_reverseObjectEnumerator
{
    DRS_READLOGINC(nil, [self drs_reverseObjectEnumerator]);
}

- (void)drs_enumerateObjectsUsingBlock:(void (NS_NOESCAPE ^)(id _Nonnull, NSUInteger, BOOL * _Nonnull))block
{
    DRS_READLOGINCVOID([self drs_enumerateObjectsUsingBlock:block]);
}

- (void)drs_enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (NS_NOESCAPE ^)(id _Nonnull, NSUInteger, BOOL * _Nonnull))block
{
    DRS_READLOGINCVOID([self drs_enumerateObjectsWithOptions:opts usingBlock:block]);
}

#pragma mark - Writing

- (void)drs_addObject:(id)anObject
{
    DRS_WRITELOGIC([self drs_addObject:anObject]);
}

- (void)drs_insertObject:(id)anObject atIndex:(NSUInteger)index;
{
    DRS_WRITELOGIC([self drs_insertObject:anObject atIndex:index]);
}

- (void)drs_removeLastObject
{
    DRS_WRITELOGIC([self drs_removeLastObject]);
}

- (void)drs_removeObjectAtIndex:(NSUInteger)index;
{
    DRS_WRITELOGIC([self drs_removeObjectAtIndex:index]);
}

- (void)drs_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
{
    DRS_WRITELOGIC([self drs_replaceObjectAtIndex:index withObject:anObject]);
}

- (void)drs_setObject:(id)anObject atIndexedSubscript:(NSUInteger)idx
{
    DRS_WRITELOGIC([self drs_setObject:anObject atIndexedSubscript:idx]);
}

- (void)drs_addObjectsFromArray:(NSArray *)otherArray
{
    DRS_WRITELOGIC([self drs_addObjectsFromArray:otherArray]);
}

- (void)drs_exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2
{
    DRS_WRITELOGIC([self drs_exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2]);
}

- (void)drs_removeAllObjects
{
    DRS_WRITELOGIC([self drs_removeAllObjects]);
}

- (void)drs_removeObject:(id)anObject inRange:(NSRange)range
{
    DRS_WRITELOGIC([self drs_removeObject:anObject inRange:range]);
}

- (void)drs_removeObject:(id)anObject
{
    DRS_WRITELOGIC([self drs_removeObject:anObject]);
}

- (void)drs_removeObjectIdenticalTo:(id)anObject
{
    DRS_WRITELOGIC([self drs_removeObjectIdenticalTo:anObject]);
}

- (void)drs_removeObjectIdenticalTo:(id)anObject inRange:(NSRange)range
{
    DRS_WRITELOGIC([self drs_removeObjectIdenticalTo:anObject inRange:range]);
}

- (void)drs_removeObjectsInArray:(NSArray *)otherArray
{
    DRS_WRITELOGIC([self drs_removeObjectsInArray:otherArray]);
}

- (void)drs_removeObjectsInRange:(NSRange)range
{
    DRS_WRITELOGIC([self drs_removeObjectsInRange:range]);
}

- (void)drs_replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray
{
    DRS_WRITELOGIC([self drs_replaceObjectsInRange:range withObjectsFromArray:otherArray]);
}

- (void)drs_replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray range:(NSRange)otherRange
{
    DRS_WRITELOGIC([self drs_replaceObjectsInRange:range withObjectsFromArray:otherArray range:otherRange]);
}

@end
