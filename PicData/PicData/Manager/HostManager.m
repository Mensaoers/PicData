//
//  HostManager.m
//  PicData
//
//  Created by 鹏鹏 on 2022/3/23.
//  Copyright © 2022 garenge. All rights reserved.
//

#import "HostManager.h"
#define KHOSTURLKEY @"KHOSTURLKEY"

@implementation HostManager

singleton_implementation(HostManager)

@synthesize currentHostModel = _currentHostModel;

- (PicNetModel *)currentHostModel {
    if (nil == _currentHostModel) {

        NSString *host_url = [self getHost_url];
        for (PicNetModel *netModel in [self hostModels]) {
            if ([netModel.HOST_URL isEqualToString:host_url]) {
                _currentHostModel = netModel;
            }
        }

        if (nil == _currentHostModel) {
            _currentHostModel = [self hostModels].firstObject;
            [self saveHost_url:_currentHostModel.HOST_URL];
        }
    }
    return _currentHostModel;
}

- (void)setCurrentHostModel:(PicNetModel *)currentHostModel {
    _currentHostModel = currentHostModel;

    [self saveHost_url:currentHostModel.HOST_URL];
}

- (NSString *)getHost_url {
    NSString *host_url = [[NSUserDefaults standardUserDefaults] valueForKey:KHOSTURLKEY];
    NSLog(@"获取到HOST: %@", host_url);
    return host_url;
}

- (BOOL)saveHost_url:(NSString *)host_url {
    NSLog(@"保存HOST: %@", host_url);
    [[NSUserDefaults standardUserDefaults] setValue:host_url forKey:KHOSTURLKEY];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

@synthesize hostModels = _hostModels;
- (NSArray<PicNetModel *> *)hostModels {
    if (nil == _hostModels) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"PicNet" ofType:@"json"];
        NSError *jsError = nil;
        NSArray *array = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath] options:NSJSONReadingMutableContainers error:&jsError];
        if (nil == jsError) {
            _hostModels = [PicNetModel mj_objectArrayWithKeyValuesArray:array];
        }

        if (nil == _hostModels || _hostModels.count == 0) {
            PicNetModel *netModel = [PicNetModel new];
            netModel.title = @"https://www.tu963.cc";
            netModel.sourceType = 2;
            netModel.HOST_URL = @"https://www.tu963.cc";
            _hostModels = @[netModel];
        }
    }
    return _hostModels;
}

@end
