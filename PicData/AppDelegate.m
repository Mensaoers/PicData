//
//  AppDelegate.m
//  PicData
//
//  Created by Garenge on 2020/4/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "AppDelegate.h"
#import "IndexViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    IndexViewController *indexVC = [[IndexViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:indexVC];
    [self.window setRootViewController:navi];
    [self.window makeKeyAndVisible];
    
    TRSessionConfiguration *configuraion = [[TRSessionConfiguration alloc] init];
    configuraion.allowsCellularAccess = YES;
    self.sessionManager = [[TRSessionManager alloc] initWithIdentifier:@"ViewController" configuration:configuraion];
    
    return YES;
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler {
    if (identifier == self.sessionManager.identifier) {
        self.sessionManager.completionHandler = completionHandler;
    }
}

@end
