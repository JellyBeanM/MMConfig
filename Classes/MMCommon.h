//
//  MMCommon.h
//  fresh
//
//  Created by apple on 2019/4/1.
//  Copyright © 2019年 Facebook. All rights reserved.
//

#ifndef MMCommon_h
#define MMCommon_h

// Debug Logging
#ifdef DEBUG
#define MMLog(x, ...) NSLog(x, ## __VA_ARGS__);
#else
#define MMLog(x, ...)
#endif

#endif /* MMCommon_h */
