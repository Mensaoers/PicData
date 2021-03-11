//
//  Plugin.m
//  PicData_macPlugin
//
//  Created by 鹏鹏 on 2021/3/11.
//

#import "Plugin.h"

@implementation Plugin

- (BOOL)openFileOrDirWithPath:(NSString *)path {
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[NSURL fileURLWithPath:path]]];
    return YES;
}

+ (BOOL)openFileOrDirWithPath:(NSString *)path {
    return [[Plugin new] openFileOrDirWithPath:path];
}

@end
