//
//  NSDictionary+crashguard.m
//  CrashGuarder
//
//  Created by pianxian on 2017/8/4.
//  Copyright © 2017年 MiKiplatform. All rights reserved.
//

#import "NSDictionary+crashguard.h"
#import "NSObject+crashguard.h"

@implementation NSDictionary (crashguard)

+ (void)swizzle_forNSDictionary;
{
    //防护NSDictionary 字面量
    [NSObject cg_swizzleClassMethod:[NSDictionary class] newSEL:@selector(dictionaryWithObjects_swizzled:forKeys:count:) origSEL:@selector(dictionaryWithObjects:forKeys:count:)];
    [NSObject cg_swizzleClassMethod:[NSDictionary class] newSEL:@selector(dictionaryWithObjectsAndKeys_swizzled:) origSEL:@selector(dictionaryWithObjectsAndKeys:)];
    
    [NSObject cg_swizzleInstanceMethod:[NSDictionary class] newSEL:@selector(objectForKeyedSubscript_swizzled:) origSEL:@selector(objectForKeyedSubscript:)];
}

#pragma mark swizzled method
+ (instancetype)dictionaryWithObjectsAndKeys_swizzled:(id)firstObject, ...
{
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    id eachObject;
    va_list argumentList;
    if (firstObject)
    {
        [objects addObject: firstObject];
        va_start(argumentList, firstObject);
        NSUInteger index = 1;
        while ((eachObject = va_arg(argumentList, id)))
        {
            (index++ & 0x01) ? [keys addObject: eachObject] : [objects addObject: eachObject];
        }
        va_end(argumentList);
    }
    
    if (objects.count != keys.count)

    {
        NSString* msg = [NSString stringWithFormat:@"dictionaryWithObjectsAndKeys for mismatchkeyvalue:%@_%@",@(keys.count),@(objects.count)];
        [NSObject cg_reportAbnormalMsg:msg];
        (objects.count < keys.count)?[keys removeLastObject]:[objects removeLastObject];
    }
    
    return [self dictionaryWithObjects:objects forKeys:keys];
}

+ (instancetype)dictionaryWithObjects_swizzled:(const id  _Nonnull *)objects forKeys:(const id<NSCopying>  _Nonnull *)keys count:(NSUInteger)cnt
{
    id safeObjects[cnt];
    id safeKeys[cnt];
    NSUInteger j = 0;
    for (NSUInteger i = 0; i < cnt; i++) {
        id key = keys[i];
        id obj = objects[i];
        if (!key || !obj ) {
            NSString* msg = [NSString stringWithFormat:@"dictionaryWithObjects for hollow item at idx:%@(%@_%@)",@(j),key,obj];
            [NSObject cg_reportAbnormalMsg:msg];
            continue;
        }
        safeKeys[j] = key;
        safeObjects[j] = obj;
        j++;
    }
    return [self dictionaryWithObjects_swizzled:safeObjects forKeys:safeKeys count:j];
}

- (nullable id)objectForKeyedSubscript_swizzled:(id)key
{
    if (key == nil || [key isKindOfClass:NSNull.class]) {
        return nil;
    } else {
        return [self objectForKeyedSubscript_swizzled:key];
    }
}

@end
