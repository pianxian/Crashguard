//
//  PXXLoggerUtil.h
//  Pods
//
//  Created by pianxian on 2023/7/12.
//

#ifndef PXXLoggerUtil_h
#define PXXLoggerUtil_h
#import "PXXLogHelper.h"

#define __FILENAME__ (strrchr(__FILE__,'/')+1)

/**
 *  Module Logging
 */
#define PXXLOG_ERROR(module, format, ...) PXXLogInternal(ATHLogLevelError, module, __FILENAME__, __LINE__, __FUNCTION__, @"Error:", format, ##__VA_ARGS__)
#define PXXLOG_WARNING(module, format, ...) PXXLogInternal(ATHLogLevelWarning, module, __FILENAME__, __LINE__, __FUNCTION__, @"Warning:", format, ##__VA_ARGS__)
#define PXXLOG_INFO(module, format, ...) PXXLogInternal(ATHLogLevelInfo, module, __FILENAME__, __LINE__, __FUNCTION__, @"Info:", format, ##__VA_ARGS__)
#define PXXLOG_DEBUG(module, format, ...) PXXLogInternal(ATHLogLevelDebug, module, __FILENAME__, __LINE__, __FUNCTION__, @"Debug:", format, ##__VA_ARGS__)

#endif /* PXXLoggerUtil_h */
