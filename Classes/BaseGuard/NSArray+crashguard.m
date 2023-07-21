//
//  NSArray+crashguard.m
//  crashreport
//
//  Created by pianxian on 17/5/2.
//  Copyright © 2017年 DW. All rights reserved.
//

#import "NSArray+crashguard.h"
#import "NSObject+crashguard.h"
#import <objc/runtime.h>

@implementation NSArray (crashguard)

+ (void)swizzle_forNSArray;
{
    Class __NSArrayI = objc_getClass("__NSArrayI");
    Class __NSArray0 = objc_getClass("__NSArray0");
    Class __NSSingleObjectArrayI = objc_getClass("__NSSingleObjectArrayI");
    Class __NSPlaceholderArray = objc_getClass("__NSPlaceholderArray");
    
    //class method
    [NSObject cg_swizzleClassMethod:__NSPlaceholderArray newSEL:@selector(arrayWithObjects_swizzle:count:) origSEL:@selector(arrayWithObjects:count:)];
    //objectatindex
    [NSObject cg_swizzleInstanceMethod:__NSArrayI newSEL:@selector(guard_objectAtIndex:) origSEL:@selector(objectAtIndex:)];
    [NSObject cg_swizzleInstanceMethod:__NSArray0 newSEL:@selector(guard_ZeroObjectAtIndex:) origSEL:@selector(objectAtIndex:)];
    [NSObject cg_swizzleInstanceMethod:__NSSingleObjectArrayI newSEL:@selector(guard_singleObjectAtIndex:) origSEL:@selector(objectAtIndex:)];
    [NSObject cg_swizzleInstanceMethod:__NSArrayI newSEL:@selector(subarrayWithRange_swizzle:) origSEL:@selector(subarrayWithRange:)];
    [NSObject cg_swizzleInstanceMethod:__NSArrayI newSEL:@selector(objectAtIndexedSubscript_swizzleForArrayI:) origSEL:@selector(objectAtIndexedSubscript:)];
    
    [NSObject cg_swizzleClassMethod:[NSArray class] newSEL:@selector(guard_arrayWithArray:) origSEL:@selector(arrayWithArray:)];
}

#pragma mark swizzled method
+ (instancetype)guard_arrayWithArray:(NSArray *)array
{
    if (!array) {
        array = @[];
    }
    return [self guard_arrayWithArray:array];
}

- (id)objectAtIndexedSubscript_swizzleForArrayI:(NSUInteger)idx
{
    if( idx >= self.count )
    {
        NSString* msg = [NSString stringWithFormat:@"idx:%@ out of bounds",@(idx)];
        [NSObject cg_reportAbnormalMsg:msg];
        return nil;
    }
    return [self objectAtIndexedSubscript_swizzleForArrayI:idx];
}

+ (instancetype)arrayWithObjects_swizzle:(id  _Nonnull const [])objects count:(NSUInteger)cnt
{
    id obj[cnt];
    int j = 0;
    for( int i = 0; i < cnt; ++i )
    {
        if( objects[i] )
        {
            obj[j++] = objects[i];
        }
        else
        {
            NSString* msg = [NSString stringWithFormat:@"arraywithobjects with nil at:%@",@(i)];
            [NSObject cg_reportAbnormalMsg:msg];
        }
    }
    return [self arrayWithObjects_swizzle:obj count:j];
}

- (NSArray *)subarrayWithRange_swizzle:(NSRange)range
{
    if( range.location + range.length > self.count )
    {
        NSString* msg = [NSString stringWithFormat:@"outrange subarray(%@,%@) from array(%@ items)",@(range.location),@(range.length),@(self.count)];
        [NSObject cg_reportAbnormalMsg:msg];
        if( range.location >= self.count )
        {
            return nil;
        }
        else
        {
            return [self subarrayWithRange_swizzle:NSMakeRange(range.location, self.count-range.location)];
        }
    }
    else
    {
        return [self subarrayWithRange_swizzle:range];
    }
}

- (id)guard_objectAtIndex:(NSUInteger)index
{
    if (index >= self.count){
        NSString* msg = [NSString stringWithFormat:@"index:%@ out of array(%@ items) bounds",@(index),@(self.count)];
        [NSObject cg_reportAbnormalMsg:msg];
        return nil;
    }
    return [self guard_objectAtIndex:index];
}

- (id)guard_singleObjectAtIndex:(NSUInteger)index
{
    if (index >= self.count){
        NSString* msg = [NSString stringWithFormat:@"index1:%@ out of array(%@ items) bounds",@(index),@(self.count)];
        [NSObject cg_reportAbnormalMsg:msg];
        return nil;
    }
    return [self guard_singleObjectAtIndex:index];
}

- (id)guard_ZeroObjectAtIndex:(NSUInteger)index
{
    if (index >= self.count){
        NSString* msg = [NSString stringWithFormat:@"index0:%@ out of array(%@ items) bounds",@(index),@(self.count)];
        [NSObject cg_reportAbnormalMsg:msg];
        return nil;
    }
    return [self guard_ZeroObjectAtIndex:index];
}

- (void)getObjectsZero_swizzle:(id  _Nonnull *)objects range:(NSRange)range
{
    if( !objects )
    {
        NSString* msg = [NSString stringWithFormat:@"get objects:zero with null objectspointer"];
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
        [self getObjectsZero_swizzle:objects range:range];
    }
}

- (void)getObjectsSingle_swizzle:(id  _Nonnull *)objects range:(NSRange)range
{
    if( !objects )
    {
        NSString* msg = [NSString stringWithFormat:@"get objects:single with null objectspointer"];
        [NSObject cg_reportAbnormalMsg:msg];
        return;
    }
    else if( range.location + range.length > self.count )
    {
        NSString* msg = [NSString stringWithFormat:@"get objects outrange subarray(%@,%@) from array(%@ items)",@(range.location),@(range.length),@(self.count)];
        [NSObject cg_reportAbnormalMsg:msg];
        *objects = nil;
    }
    else
    {
        [self getObjectsSingle_swizzle:objects range:range];
    }
}

- (void)getObjects_swizzle:(id  _Nonnull *)objects range:(NSRange)range
{
    if( !objects )
    {
        NSString* msg = [NSString stringWithFormat:@"get objects with null objectspointer"];
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

- (NSArray<id> *)objectsAtIndexesArrayI_swizzle:(NSIndexSet *)indexes;
{
    if( indexes.firstIndex + indexes.count > self.count )
    {
        NSString* msg = [NSString stringWithFormat:@"objects indexes(%@,%@) outrange from array(%@ items)",@(indexes.firstIndex),@(indexes.count),@(self.count)];
        [NSObject cg_reportAbnormalMsg:msg];
        return nil;
    }
    else
    {
        return [self objectsAtIndexesArrayI_swizzle:indexes];
    }
}
@end
