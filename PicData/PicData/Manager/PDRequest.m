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
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 12_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1.2 Mobile/15E148 Safari/604.1" forHTTPHeaderField:@"User-agent"];
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:completionHandler];
    [dataTask resume];
}

+ (void)requestToCheckVersion:(BOOL)autoCheck onView:(UIView *)onView completehandler:(void (^)(void))completehandler {
    NSString *paramsString = [NSString stringWithFormat:@"_api_key=afa1255fbfe95e7e5cc2502d0b159b0c&appKey=de806dcb2f8f3f74c1f04ce6a18b610c&buildVersion=%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
   [self postWith:@"https://www.pgyer.com/apiv2/app/check" paramsString:paramsString completeHandler:^(NSString * _Nullable responseString, NSDictionary * _Nullable responseDataDic, BOOL isSuccess, NSString * _Nullable message) {

       if (completehandler) {
           completehandler();
       }

       if (!isSuccess) {
           [MBProgressHUD showInfoOnView:onView WithStatus:message afterDelay:1];
           return;
       }

       BOOL buildHaveNewVersion = [responseDataDic[@"buildHaveNewVersion"] boolValue];

       if (autoCheck && !buildHaveNewVersion) {
           return;
       }

       NSString *urlString = @"https://www.pgyer.com/PicData";
       NSString *buildPassword = @"527888";
       NSString *messageAlert = [NSString stringWithFormat:@"即将打开地址: %@, 密码: %@", urlString, buildPassword];
       NSString *titleAlert = @"版本提醒";
       NSString *downloadTitle = @"重新安装";

       if (buildHaveNewVersion) {
           downloadTitle = @"直接安装";
           // 有新版本
           NSString *buildUpdateDescription = responseDataDic[@"buildUpdateDescription"];
           NSString *buildVersion = responseDataDic[@"buildVersion"];
           messageAlert = [NSString stringWithFormat:@"检测到最新版本V%@%@", buildVersion, buildUpdateDescription.length > 0 ? [NSString stringWithFormat:@"\n%@", buildUpdateDescription] : @""];
       } else {
           // 无新版本
           messageAlert = [NSString stringWithFormat:@"当前已是最新版本, 打开地址: %@, 密码: %@", urlString, buildPassword];
       }

       UIAlertController *alert = [UIAlertController alertControllerWithTitle:titleAlert message:messageAlert preferredStyle:UIAlertControllerStyleAlert];

       [alert addAction:[UIAlertAction actionWithTitle:@"复制密码去打开网页" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
           UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
           pasteboard.string = buildPassword;
           [UIApplication.sharedApplication openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
       }]];

       NSString *downloadURL = responseDataDic[@"downloadURL"];

       if (downloadURL.length > 0) {
           [alert addAction:[UIAlertAction actionWithTitle:downloadTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
               [UIApplication.sharedApplication openURL:[NSURL URLWithString:downloadURL] options:@{} completionHandler:nil];
           }]];
       }

       [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil]];
       [UIApplication.sharedApplication.windows.firstObject.rootViewController presentViewController:alert animated:YES completion:nil];
   }];
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
