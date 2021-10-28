//
//  main.m
//  ReName
//
//  Created by 鹏鹏 on 2021/6/12.
//

#import <Foundation/Foundation.h>
#import "Manager.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        // @"/Users/pengpeng/Desktop/0x"

        [Manager renameAllPicturesOfDirectoryAtPath:@"/Volumes/LZP_HDD/.12AC169F959B49C89E3EE409191E2EF1/Program Files (x86)/Program File/rt"];
        [Manager removeAllTxtFileOfDirectoryAtPath:@"/Volumes/LZP_HDD/.12AC169F959B49C89E3EE409191E2EF1/Program Files (x86)/Program File/rt"];
    }
    return 0;

}
