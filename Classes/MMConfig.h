//
//  MMConfig.h
//  fresh
//
//  Created by apple on 2019/4/1.
//  Copyright © 2019年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMCommon.h"

/**
 * 0: "开发环境",
 * 1: "测试环境",
 * 2: "预发环境",
 * 3: "线上测试环境",
 * 4: "生产环境"
 */

typedef enum
{
    MMEnvironmentDevelopment = 0,       //0: "开发环境"
    MMEnvironmentTest = 1,              //1: "测试环境"
    MMEnvironmentPreannouncement = 2,   //2: "预发环境"
    MMEnvironmentTestOnline = 3,        //3: "线上测试环境"
    MMEnvironmentProduction = 4         //4: "生产环境"
}MMEnvironmentType;

@interface MMConfig : NSObject

// 单例
+ (instancetype _Nonnull )shareInstance;
// 当前环境名称
- (nonnull NSString *)currentEnvironmentName;
// 获取当前环境的number
- (NSInteger) currentEnvironmentNumber;
// 切换环境
- (void)switchTo: (MMEnvironmentType)environment;
// 根据key，读取当前环境下某个配置，
- (nonnull NSString *)stringValueForKey:(nonnull NSString *)key;
// 获取当前的全部配置
- (nonnull NSDictionary *)currentConfigs;

@end
