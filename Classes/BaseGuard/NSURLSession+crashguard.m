//
//  NSURLSession+crashguard.m
//  CrashGuardSDK
//
//  Created by pianxian on 2020/2/12.
//

#import "NSURLSession+crashguard.h"
#import "NSObject+crashguard.h"
#import <objc/runtime.h>

@implementation NSURLSession (crashguard)

+ (void)swizzle_forURLSession
{
    [NSObject cg_swizzleInstanceMethod:[NSURLSession class] newSEL:@selector(guard_dataTaskWithRequest:)
                            origSEL:@selector(dataTaskWithRequest:)];
    [NSObject cg_swizzleInstanceMethod:[NSURLSession class] newSEL:@selector(guard_dataTaskWithRequest:completionHandler:)
                            origSEL:@selector(dataTaskWithRequest:completionHandler:)];
    [NSObject cg_swizzleInstanceMethod:[NSURL class] newSEL:@selector(guard_initFileURLWithPath:)
                            origSEL:@selector(initFileURLWithPath:)];
    
}

- (NSURLSessionDataTask *)guard_dataTaskWithRequest:(NSURLRequest *)request
{
    if (!request) {
         [NSObject cg_reportAbnormalMsg:[NSString stringWithFormat:@"NSURLSession Cannot create task from nil request"]];
        return nil;
    }
    return [self guard_dataTaskWithRequest:request];
}

- (NSURLSessionDataTask *)guard_dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler
{
    if (!request) {
        [NSObject cg_reportAbnormalMsg:[NSString stringWithFormat:@"NSURLSession Cannot create task from nil request"]];
        return nil;
    }
    return [self guard_dataTaskWithRequest:request completionHandler:completionHandler];
}

- (NSURL *)guard_initFileURLWithPath:(NSString *)path
{
    if (!path) {
        [NSObject cg_reportAbnormalMsg:[NSString stringWithFormat:@"-[NSURL initFileURLWithPath:]: nil string parameter"]];
        return nil;
    }
    return [self guard_initFileURLWithPath:path];
}

@end
