//
//  PPCatalystHandle.m
//  PPCatalystTool
//
//  Created by 鹏鹏 on 2022/10/15.
//

#import "PPCatalystHandle.h"

@interface PPCatalystHandle()

@end

@implementation PPCatalystHandle

- (void)showLog {
    NSLog(@"123");
}

static NSString *bundleFileName = @"PPCatalystPlugin.bundle";
static NSString *bundlePluginClassName = @"PPCatalystPlugin";
static NSString *frameworkName = @"PPCatalystTool";

static PPCatalystHandle *_instance;
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (PPCatalystHandle *)sharedPPCatalystHandle {
    if (nil == _instance) {
        _instance = [[PPCatalystHandle alloc] init];
    }
    return _instance;
}

- (NSBundle *)searchBundleWithBundleName:(NSString *)bundleName ofType:(NSString *)ext {

    NSBundle *bundle;

    NSURL *bundleURL = [[[NSBundle mainBundle] builtInPlugInsURL] URLByAppendingPathComponent:bundleFileName];
    NSLog(@"bundleURL.path: %@", bundleURL.path);
    if (bundleURL) {
        bundle = [NSBundle bundleWithURL:bundleURL];
        if (bundle) {
            return bundle;
        }
    }

    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:ext];
    if (nil == bundlePath || bundlePath.length == 0) {
        bundleURL = [[NSBundle mainBundle] bundleURL];
        NSLog(@"bundleURL.path_1: %@", bundleURL.path);
        NSURL *associateBundleURL = [bundleURL URLByAppendingPathComponent:@"Contents"];
        associateBundleURL = [associateBundleURL URLByAppendingPathComponent:@"PlugIns"];
        associateBundleURL = [associateBundleURL URLByAppendingPathComponent:bundleName];
        NSLog(@"associateBundleURL.path: %@", associateBundleURL.path);
        bundle = [NSBundle bundleWithURL:associateBundleURL];
    } else {
        bundle = [NSBundle bundleWithPath:bundlePath];
    }
    return bundle;
}

- (Class)getBundleClassWithName:(NSString *)className {

    NSBundle *bundle = [self searchBundleWithBundleName:bundleFileName ofType:nil];
    if (!bundle) {
        NSLog(@"获取bundle: %@失败", bundleFileName);
        return nil;
    }
    NSLog(@"bundle: %@", bundle);
    [bundle load];
    Class bundleClass= [bundle classNamed:className];
    return bundleClass;
}

- (NSNumber *)openFileOrDirWithPath:(NSString *)path {

#if TARGET_OS_MACCATALYST
    NSString *selectorString = @"openFileOrDirWithPath:";

    Class bundleClass= [self getBundleClassWithName:bundlePluginClassName];

    return [self performSelfMethodWithString:selectorString target:bundleClass object:path];
#else
    return NO;
#endif
}

- (NSURL *)selectSingleFileWithFolderPath:(NSString *)folderPath {

#if TARGET_OS_MACCATALYST
    NSString *selectorString = @"selectSingleFileWithFolderPath:";

    Class bundleClass= [self getBundleClassWithName:bundlePluginClassName];

    NSURL *selectedFileURL = [self performSelfMethodWithString:selectorString target:bundleClass object:folderPath];
    NSLog(@"我选中了%@", selectedFileURL);
    NSData *data = [NSData dataWithContentsOfURL:selectedFileURL];
    NSLog(@"文件大小: %ld", data.length);

    return selectedFileURL;
#else
    return nil;
#endif
}

- (NSURL *)selectFolderWithPath:(NSString *)folderPath {

#if TARGET_OS_MACCATALYST
    NSString *selectorString = @"selectFolderWithPath:";

    Class bundleClass= [self getBundleClassWithName:bundlePluginClassName];

    NSURL *selectedFileURL = [self performSelfMethodWithString:selectorString target:bundleClass object:folderPath];
    NSLog(@"我选中了%@", selectedFileURL);

    return selectedFileURL;
#else
    return nil;
#endif
}

/// 执行自定义方法
- (id)performSelfMethodWithString:(NSString *)funcString target:(id)target object:(id)object {
    if (nil == funcString || funcString.length == 0) {
        return nil;
    }

    SEL selector = NSSelectorFromString(funcString);

    if ([target respondsToSelector:selector]) {

        IMP imp = [target methodForSelector:selector];
        id (*func)(id, SEL, id) = (void *)imp;
        return func(target, selector, object);
    } else {
        return nil;
    }
}

/// 执行自定义方法
- (id)performSelfFuncWithString:(NSString *)funcString target:(id)target object:(id)object {
    if (nil == funcString || funcString.length == 0) {
        return nil;
    }
    SEL selector = NSSelectorFromString(funcString);

    if ([target respondsToSelector:selector]) {

        return [target performSelector:selector withObject:object];
    } else {
        return nil;
    }
}

@end
