//
//  NSMutableArray+crashguard.m
//  crashreport
//
//  Created by pianxian on 2017/6/21.
//  Copyright © 2017年 DW. All rights reserved.
//

#import "NSMutableArray+crashguard.h"
#import "NSObject+crashguard.h"
#import <objc/runtime.h>

@implementation NSMutableArray (crashguard)

+ (void)swizzle_forNSMutableArray;
{
    Class __NSArrayM = objc_getClass("__NSArrayM");
    [NSObject cg_swizzleInstanceMethod:__NSArrayM newSEL:@selector(addObject_swizzled:) origSEL:@selector(addObject:)];
    [NSObject cg_swizzleInstanceMethod:__NSArrayM newSEL:@selector(removeObjectAtIndex_swizzled:) origSEL:@selector(removeObjectAtIndex:)];
    [NSObject cg_swizzleInstanceMethod:__NSArrayM newSEL:@selector(removeObjectsInRange_swizzled:) origSEL:@selector(removeObjectsInRange:)];
    [NSObject cg_swizzleInstanceMethod:__NSArrayM newSEL:@selector(insertObject_swizzle:atIndex:) origSEL:@selector(insertObject:atIndex:)];
    [NSObject cg_swizzleInstanceMethod:__NSArrayM newSEL:@selector(replaceObjectAtIndex_swizzle:withObject:) origSEL:@selector(replaceObjectAtIndex:withObject:)];
    [NSObject cg_swizzleInstanceMethod:__NSArrayM newSEL:@selector(setObject_swizzle:atIndexedSubscript:) origSEL:@selector(setObject:atIndexedSubscript:)];
    [NSObject cg_swizzleInstanceMethod:__NSArrayM newSEL:@selector(addObjectsFromArray_swizzle:) origSEL:@selector(addObjectsFromArray:)];
    
    if (@available(iOS 15.0, *)) {
        // BugFix: (iOS 15 以上不 HOOK，影响系统行为导致内存没法及时释放)
        return;
    }
    
    if (@available(iOS 11.0, *)) {
        [NSObject cg_swizzleInstanceMethod:__NSArrayM newSEL:@selector(objectAtIndexedSubscript_swizzleForArrayM:) origSEL:@selector(objectAtIndexedSubscript:)];
        [NSObject cg_swizzleInstanceMethod:__NSArrayM newSEL:@selector(objectAtIndex_swizzled:) origSEL:@selector(objectAtIndex:)];
    }
}

#pragma mark swizzled method
- (id)objectAtIndexedSubscript_swizzleForArrayM:(NSUInteger)idx
{
    if( idx >= self.count )
    {
        NSString* msg = [NSString stringWithFormat:@"idx:%@ out of bounds",@(idx)];
        [NSObject cg_reportAbnormalMsg:msg];
        return nil;
    }
    return [self objectAtIndexedSubscript_swizzleForArrayM:idx];
}

- (void)removeObjectsInRange_swizzled:(NSRange)range
{
    if( range.location+range.length > self.count )
    {
        NSString* msg = [NSString stringWithFormat:@"array remove range(%@,%@) out of array(%@ items)",@(range.location),@(range.length),@(self.count)];
        [NSObject cg_reportAbnormalMsg:msg];
    }
    else
    {
        [self removeObjectsInRange_swizzled:range];
    }
}

- (void)removeObjectAtIndex_swizzled:(NSUInteger)index
{
    if( index >= self.count )
    {
        NSString* msg = [NSString stringWithFormat:@"array remove %@ out of array(%@ items) bounds",@(index),@(self.count)];
        [NSObject cg_reportAbnormalMsg:msg];
    }
    else
    {
        [self removeObjectAtIndex_swizzled:index];
    }
}

- (id)objectAtIndex_swizzled:(NSUInteger)index;
{
    if( index >= self.count )
    {
        NSString* msg = [NSString stringWithFormat:@"index:%@ out of array(%@ items) bounds",@(index),@(self.count)];
        [NSObject cg_reportAbnormalMsg:msg];
        return nil;
    }
    else
    {
        return [self objectAtIndex_swizzled:index];
    }
}

- (void)addObject_swizzled:(id)anObject
{
    if( anObject )
    {
        [self addObject_swizzled:anObject];
    }
    else
    {
        NSString* msg = [NSString stringWithFormat:@"mutable array add nil"];
        [NSObject cg_reportAbnormalMsg:msg];
    }
}

- (void)insertObject_swizzle:(id)anObject atIndex:(NSUInteger)index
{
    if( anObject && index <= self.count )
    {
        [self insertObject_swizzle:anObject atIndex:index];
    }
    else
    {
        NSString* msg = [NSString stringWithFormat:@"insert index:%@(%@) to array(%@ items)",@(index),anObject,@(self.count)];
        [NSObject cg_reportAbnormalMsg:msg];
    }
}

- (void)replaceObjectAtIndex_swizzle:(NSUInteger)index withObject:(id)anObject;
{
    if( anObject && index < self.count )
    {
        [self replaceObjectAtIndex_swizzle:index withObject:anObject];
    }
    else
    {
        NSString* msg = [NSString stringWithFormat:@"replace index:%@(%@) of array(%@ items)",@(index),anObject,@(self.count)];
        [NSObject cg_reportAbnormalMsg:msg];
    }
}

- (NSArray<id> *)objectsAtIndexesArrayM_swizzle:(NSIndexSet *)indexes;
{
    if( indexes.firstIndex + indexes.count > self.count )
    {
        NSString* msg = [NSString stringWithFormat:@"objects indexes(%@,%@) outrange from array(%@ items)",@(indexes.firstIndex),@(indexes.count),@(self.count)];
        [NSObject cg_reportAbnormalMsg:msg];
        return nil;
    }
    else
    {
        return [self objectsAtIndexesArrayM_swizzle:indexes];
    }
}

- (void)setObject_swizzle:(id)obj atIndexedSubscript:(NSUInteger)idx
{
    if( idx <= self.count && obj )
    {
        [self setObject_swizzle:obj atIndexedSubscript:idx];
    }
    else
    {
        NSString* msg = [NSString stringWithFormat:@"setindex:%@(%@) to array(%@ items)",@(idx),obj,@(self.count)];
        [NSObject cg_reportAbnormalMsg:msg];
    }
}

- (void)getObjects_swizzle:(id  _Nonnull *)objects range:(NSRange)range
{
    if( !objects )
    {
        NSString* msg = [NSString stringWithFormat:@"get objects:arrm with null objectspointer"];
        [NSObject cg_reportAbnormalMsg:msg];
        return;
    }
    else if( range.location + range.length > self.count )
    {
        NSString* msg = [NSString stringWithFormat:@"get objects outrange subarray(%@,%@) from array(%@ items)",@(range.location),@(range.length),@(self.count)];
        [NSObject cg_reportAbnormalMsg:msg];
    }
    else
    {
        [self getObjects_swizzle:objects range:range];
    }
}

- (void)addObjectsFromArray_swizzle:(NSArray *)otherArray
{
    if( otherArray && ![otherArray isKindOfClass:[NSArray class]] )
    {
        [NSObject cg_reportAbnormalMsg:[NSString stringWithFormat:@"NSInvalidArgumentException: -[NSMutableArray addObjectsFromArray:]: array argument is not an NSArray,self:%@,argument:%@",self,otherArray]];
    }
    else
    {
        [self addObjectsFromArray_swizzle:otherArray];
    }
}
@end
