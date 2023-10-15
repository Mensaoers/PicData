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
        NSLog(@"Hello, Coder!");

//        [Manager renameAllPicturesOfDirectoryAtPath:@"/Volumes/LZP_HDD/.12AC169F959B49C89E3EE409191E2EF1/Program Files (x86)/Program File/rt" andTxtFileRemove:YES];
//        [Manager renameAllPicturesOfDirectoryAtPath:@"/Volumes/T7/.12AC169F959B49C89E3EE409191E2EF1/Program Files (x86)" andTxtFileRemove:YES];
        [Manager removeTargetFilesAtPath:@"/Volumes/T7/.12AC169F959B49C89E3EE409191E2EF1/Program Files (x86)" ContainsKeyword:@"txt"];
    }
    return 0;

}

