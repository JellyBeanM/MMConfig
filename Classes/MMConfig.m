//
//  MMConfig.m
//  fresh
//
//  Created by apple on 2019/4/1.
//  Copyright © 2019年 Facebook. All rights reserved.
//

#import "MMConfig.h"
//#import "FMDB.h"

@interface MMConfig()

@property(nonatomic, strong) NSMutableDictionary *configsByEnv;

@property(nonatomic, assign) NSNumber *envFromJson;

//哈哈

@end

@implementation MMConfig

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static MMConfig *_singleton;
    dispatch_once(&onceToken, ^{
        _singleton = [[[self class] alloc] init];
    });
    return _singleton;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.configsByEnv = [NSMutableDictionary new];
        [self readConfigsByDb];
        [self readDefaultEnvironmentByJson];
    }
    return self;
}

#pragma mark - 读取项目中ConfigData.db，解析全部配置
- (NSMutableDictionary *)readConfigsByDb{
    NSString* jsonString = [self queryConfigData];
    NSAssert(jsonString,@"ConfigData.db file maybe miss configJsonData column");
    if (jsonString == nil) {
        return nil;
    }
    NSData *fileData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id configs = [NSJSONSerialization JSONObjectWithData:fileData options:NSJSONReadingAllowFragments error:&error];
    if(configs && [configs isKindOfClass:[NSDictionary class]]){
        _configsByEnv = [[(NSDictionary *)configs valueForKey:@"configs"] mutableCopy];
        MMLog(@"MMConfig从数据库读取的配置字典为：")
        MMLog(@"%@", _configsByEnv);
    } else {
        NSString * ss = [NSString stringWithFormat:@"MMConfig-readConfigsByDb-Error:数据库读取配置字典异常：%@-%@",error,configs];
        NSAssert(error,ss);
    }
    return _configsByEnv;
}

- (NSString* )queryConfigData {
    NSString * configData;
    NSString *filePath = [NSBundle.mainBundle pathForResource:@"ConfigData" ofType:@"db"];
    NSAssert(filePath,@"Can`t find ConfigData.db file in mainBundle, please checkout project config");
//    FMDatabase * db = [FMDatabase databaseWithPath:filePath];
//    if ([db open]) {
//        [db setKey:@"xghltubobo1011"];
//        NSString * sql = @"select * from configData";
//        FMResultSet * rs = [db executeQuery:sql];
//        while ([rs next]) {
//            configData = [rs stringForColumn:@"configJsonData"];
//        }
//        [db close];
//    }
    return configData;
}


#pragma mark - 读取项目中config.json，读取当前需要使用的环境
- (NSInteger) readDefaultEnvironmentByJson{
    if (!_envFromJson) {
        NSString *filePath = [NSBundle.mainBundle pathForResource:@"config" ofType:@"json"];
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        NSData *fileData = [NSData dataWithContentsOfURL:fileURL];
        NSError *error = nil;
        NSDictionary * configs = [NSJSONSerialization JSONObjectWithData:fileData options:NSJSONReadingAllowFragments error:&error];
        NSString * e = [NSString stringWithFormat:@"configs.json 文件解析失败 %@",error];
        NSAssert(!error,e);
        _envFromJson = [configs valueForKey:@"environment"]?:@4;
    }
    return [_envFromJson integerValue];
}

- (NSString *)currentEnvironmentName;{
    switch ([self getCurrentEnv]) {
        case MMEnvironmentProduction:
            return @"生产环境";
            break;
        case MMEnvironmentDevelopment:
            return @"开发环境";
            break;
        case MMEnvironmentTest:
            return @"测试环境";
            break;
        case MMEnvironmentTestOnline:
            return @"测试线上环境";
            break;
        case MMEnvironmentPreannouncement:
            return @"预发布生产环境";
            break;
        default:
            return @"错误未知环境";
            break;
    }
}

- (NSInteger) currentEnvironmentNumber {
    return [self getCurrentEnv];
}
- (void)switchTo: (MMEnvironmentType)environment {
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:@(environment) forKey:@"environment"];
}

- (NSInteger) getCurrentEnv {
    NSInteger envType;
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    id result = [userDefault objectForKey:@"environment"];
    if (result == nil) {
        envType = [_envFromJson integerValue];
    } else {
        envType = [result integerValue];
    }
    return envType;
}

- (NSDictionary *)currentConfigs {
    NSDictionary *configs;
    switch ([self getCurrentEnv]) {
        case MMEnvironmentProduction:
            configs = (NSDictionary *)[self.configsByEnv valueForKey:@"production"];
            break;
        case MMEnvironmentDevelopment:
            configs = (NSDictionary *)[self.configsByEnv valueForKey:@"development"];
            break;
        case MMEnvironmentTest:
            configs = (NSDictionary *)[self.configsByEnv valueForKey:@"test"];
            break;
        case MMEnvironmentTestOnline:
            configs = (NSDictionary *)[self.configsByEnv valueForKey:@"testOnline"];
            break;
        case MMEnvironmentPreannouncement:
            configs = (NSDictionary *)[self.configsByEnv valueForKey:@"preannouncement"];
            break;
        default:
            configs = @{};
            break;
    }
    return configs;
}

- (nonnull NSString *)stringValueForKey:(nonnull NSString *)key {
    
    switch ([self getCurrentEnv]) {
        case MMEnvironmentProduction:
        {
            NSString *value = [[self.configsByEnv valueForKey:@"production"] valueForKey:key];
            NSAssert(value, @"key not found, please check");
            return value;
        }
            break;
        case MMEnvironmentDevelopment:
        {
            NSString *value = [[self.configsByEnv valueForKey:@"development"] valueForKey:key];
            NSAssert(value, @"key not found, please check");
            return value;
        }
            break;
        case MMEnvironmentTest:
        {
            NSString *value = [[self.configsByEnv valueForKey:@"test"] valueForKey:key];
            NSAssert(value, @"key not found, please check");
            return value;
        }
            break;
        case MMEnvironmentTestOnline:
        {
            NSString *value = [[self.configsByEnv valueForKey:@"testOnline"] valueForKey:key];
            NSAssert(value, @"key not found, please check");
            return value;
        }
            break;
        case MMEnvironmentPreannouncement:
        {
            NSString *value = [[self.configsByEnv valueForKey:@"preannouncement"] valueForKey:key];
            NSAssert(value, @"key not found, please check");
            return value;
        }
            break;
        default:{
            NSAssert(false, @"config environment is error");
            return @"null";
        }
            break;
    }
}
@end

