//
//  ViewerViewController.h
//  PicData
//
//  Created by 鹏鹏 on 2020/11/22.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ViewerViewController : BaseViewController

@property(nonatomic, strong) NSString *filePath;

@property (nonatomic, copy) void(^backBlock)(NSString *filePath);

@end

NS_ASSUME_NONNULL_END
