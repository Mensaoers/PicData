//
//  ViewerFileModel.h
//  PicData
//
//  Created by 鹏鹏 on 2020/11/5.
//  Copyright © 2020 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ViewerFileModel : NSObject

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, assign) BOOL isFolder;

- (instancetype)initWithName:(NSString *)fileName isFolder:(BOOL)isFolder;
+ (instancetype)modelWithName:(NSString *)fileName isFolder:(BOOL)isFolder;
@end

NS_ASSUME_NONNULL_END
