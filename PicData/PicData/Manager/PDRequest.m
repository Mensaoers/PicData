//
//  PDRequest.m
//  PicData
//
//  Created by CleverPeng on 2020/8/2.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "PDRequest.h"

@implementation PDRequest

+ (void)getWithURL:(NSURL *)URL completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler {
    [PDRequest getWithURL:URL isPhone:YES completionHandler:completionHandler];
}

+ (void)getWithURL:(NSURL *)URL isPhone:(BOOL)isPhone completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler {
    if (isPhone) {
        [PDRequest getWithURL:URL userAgent:@"Mozilla/5.0 (iPhone; CPU iPhone OS 12_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1.2 Mobile/15E148 Safari/604.1" completionHandler:completionHandler];
    } else {
        [PDRequest getWithURL:URL userAgent:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36 Edg/89.0.774.63" completionHandler:completionHandler];
    }
}

+ (void)getWithURL:(NSURL *)URL userAgent:(NSString *)userAgent completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setValue:userAgent forHTTPHeaderField:@"User-agent"];
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:completionHandler];
    [dataTask resume];
}

+ (void)requestToCheckVersion:(BOOL)autoCheck onView:(UIView *)onView completehandler:(void (^)(void))completehandler {
    // 蒲公英封禁了该app bundleID, 目前不请求更新了
    if (autoCheck) {
        if (completehandler) {
            completehandler();
        }
        return;
    } else {
        NSString *urlString = @"itms-services://?action=download-manifest&url=https://www.garenge.top/PicData/picdata.plist";
        NSString *messageAlert = [NSString stringWithFormat:@"是否直接安装: %@", urlString];
        NSString *titleAlert = @"版本提醒";
        NSString *downloadTitle = @"安装";

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:titleAlert message:messageAlert preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:downloadTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

            BOOL isDebugged = AmIBeingDebugged();
            if (isDebugged) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"调试模式下不支持直接安装app" preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil]];
                [UIApplication.sharedApplication.windows.firstObject.rootViewController presentViewController:alert animated:YES completion:nil];
            } else {
                [UIApplication.sharedApplication openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
            }

            if (completehandler) {
                completehandler();
            }
        }]];

        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            if (completehandler) {
                completehandler();
            }
        }]];
        [UIApplication.sharedApplication.windows.firstObject.rootViewController presentViewController:alert animated:YES completion:nil];
    }
}

+ (void)postWith:( NSString * _Nonnull )urlString paramsString:( NSString * _Nullable )paramsString completeHandler:(void(^)(NSString * __nullable responseString, NSDictionary * __nullable responseDataDic, BOOL isSuccess, NSString * _Nullable message))completeHandler; {

    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [mutableRequest setHTTPMethod:@"POST"];
    [mutableRequest setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [mutableRequest setHTTPBody:[paramsString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSession *session = [NSURLSession sharedSession];

    PDBlockSelf
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:mutableRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        [weakSelf parasResponse:data completeHandler:^(NSString * _Nullable responseString, NSDictionary * _Nullable responseDataDic, BOOL isSuccess, NSString * _Nullable message) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(error) {
                    completeHandler(responseString, nil, NO, @"网络请求失败");
                    return;
                }
                completeHandler(responseString, responseDataDic, isSuccess, message);
            });
        }];
    }];
    [dataTask resume];
}

+ (void)parasResponse:(NSData *)data completeHandler:(void(^)(NSString * __nullable responseString, NSDictionary * __nullable responseDataDic, BOOL isSuccess, NSString * _Nullable message))completeHandler {
    if (nil == data || data.length == 0) {
        completeHandler(@"", nil, NO, @"数据解析失败");
        return;
    }

    NSString *returnDataStr = [NSString stringByReplaceUnicode:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];

        // 解析
    NSError *readError = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&readError];

    if (readError) {
        completeHandler(returnDataStr, nil, NO, @"数据解析失败");
        return;
    }

    if ([dictionary[@"code"] intValue] == 0) {
        NSDictionary *dic = dictionary[@"data"];
        completeHandler(returnDataStr, dic, YES, @"");
        return;
    } else {
        completeHandler(returnDataStr, nil, NO, @"请求失败");
        return;
    }
}
@end
