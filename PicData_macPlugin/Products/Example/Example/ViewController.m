//
//  ViewController.m
//  Example
//
//  Created by 鹏鹏 on 2022/9/26.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

#if TARGET_OS_MACCATALYST
    NSString *filePath = @"/Users";

    NSString *bundleFile = @"PicData_macPlugin.bundle";
    NSURL *bundleURL = [[[NSBundle mainBundle] builtInPlugInsURL] URLByAppendingPathComponent:bundleFile];
    if (!bundleURL) {
        return;
    }
    NSBundle *pluginBundle = [NSBundle bundleWithURL:bundleURL];
    NSString *className = @"Plugin";
    Class Plugin= [pluginBundle classNamed:className];
    //    Plugin *obj = [[Plugin alloc] init];
    SEL openSel = NSSelectorFromString(@"openFileOrDirWithPath:");
    if ([Plugin respondsToSelector:openSel]) {
        [Plugin performSelector:NSSelectorFromString(@"openFileOrDirWithPath:") withObject:filePath];
    }
#endif
}


@end
