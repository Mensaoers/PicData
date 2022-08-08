//
//  PDRequest.m
//  PicData
//
//  Created by CleverPeng on 2020/8/2.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "PDRequest.h"

@interface PDRequest() <NSURLSessionDelegate>

@end

@implementation PDRequest

singleton_implementation(PDRequest)

+ (NSURLSessionDataTask *)getWithURL:(NSURL *)URL completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler {
    return [PDRequest getWithURL:URL isPhone:YES completionHandler:completionHandler];
}

+ (NSURLSessionDataTask *)getWithURL:(NSURL *)URL isPhone:(BOOL)isPhone completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler {
    if (isPhone) {
        return [PDRequest getWithURL:URL userAgent:@"Mozilla/5.0 (iPhone; CPU iPhone OS 12_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1.2 Mobile/15E148 Safari/604.1" completionHandler:completionHandler];
    } else {
        return [PDRequest getWithURL:URL userAgent:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36" completionHandler:completionHandler];
    }
}

+ (NSURLSessionDataTask *)getWithURL:(NSURL *)URL userAgent:(NSString *)userAgent completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setValue:userAgent forHTTPHeaderField:@"User-agent"];

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 10;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:[PDRequest sharedPDRequest] delegateQueue:nil];// [NSURLSession sessionWithConfiguration:config];
    // [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:[PDRequest sharedPDRequest] delegateQueue:nil];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:completionHandler];
    [dataTask resume];
    return dataTask;
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

        UIViewController *presentingViewController = UIApplication.sharedApplication.windows.firstObject.rootViewController;
        [presentingViewController showAlertWithTitle:titleAlert message:messageAlert confirmTitle:downloadTitle confirmHandler:^(UIAlertAction * _Nonnull action) {
            BOOL isDebugged = AmIBeingDebugged();
            if (isDebugged) {

                [presentingViewController showAlertWithTitle:nil message:@"调试模式下不支持直接安装app" confirmTitle:@"好的" confirmHandler:nil];
            } else {
                [UIApplication.sharedApplication openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
            }

            PPIsBlockExecute(completehandler);
        } cancelTitle:@"取消" cancelHandler:^(UIAlertAction * _Nonnull action) {
            PPIsBlockExecute(completehandler);
        }];
    }
}

+ (void)postWith:( NSString * _Nonnull )urlString paramsString:( NSString * _Nullable )paramsString completeHandler:(void(^)(NSString * __nullable responseString, NSDictionary * __nullable responseDataDic, BOOL isSuccess, NSString * _Nullable message))completeHandler; {

    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [mutableRequest setHTTPMethod:@"POST"];
    [mutableRequest setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [mutableRequest setHTTPBody:[paramsString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSession *session = [NSURLSession sharedSession];
    // [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:[PDRequest sharedPDRequest] delegateQueue:nil];

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

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    NSLog(@"didReceiveChallenge ");
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSLog(@"server ---------");
        //        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        NSString *host = challenge.protectionSpace.host;
        NSLog(@"%@", host);

        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];


        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    }
    else if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate])
        {
            //客户端证书认证
            //TODO:设置客户端证书认证
            // load cert
            NSLog(@"client");
            NSString *path = [[NSBundle mainBundle]pathForResource:@"client"ofType:@"p12"];
            NSData *p12data = [NSData dataWithContentsOfFile:path];
            CFDataRef inP12data = (__bridge CFDataRef)p12data;
            SecIdentityRef myIdentity;
            OSStatus status = [self extractIdentity:inP12data toIdentity:&myIdentity];
            if (status != 0) {
                return;
            }
            SecCertificateRef myCertificate;
            SecIdentityCopyCertificate(myIdentity, &myCertificate);
            const void *certs[] = { myCertificate };
            CFArrayRef certsArray =CFArrayCreate(NULL, certs,1,NULL);
            NSURLCredential *credential = [NSURLCredential credentialWithIdentity:myIdentity certificates:(__bridge NSArray*)certsArray persistence:NSURLCredentialPersistencePermanent];
            //        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
            //         网上很多错误代码如上，正确的为：
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        }
}

- (OSStatus)extractIdentity:(CFDataRef)inP12Data toIdentity:(SecIdentityRef*)identity {
    OSStatus securityError = errSecSuccess;
    CFStringRef password = CFSTR("123456");
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { password };
    CFDictionaryRef options = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    securityError = SecPKCS12Import(inP12Data, options, &items);
    if (securityError == 0)
        {
            CFDictionaryRef ident = CFArrayGetValueAtIndex(items,0);
            const void *tempIdentity = NULL;
            tempIdentity = CFDictionaryGetValue(ident, kSecImportItemIdentity);
            *identity = (SecIdentityRef)tempIdentity;
        }
    else
        {
            NSLog(@"clinet.p12 error!");
        }

    if (options) {
        CFRelease(options);
    }
    return securityError;
}

@end
