//
//  ViewerController.h
//  PicData
//
//  Created by Garenge on 2020/11/4.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ViewerController : BaseViewController

/// 上衣个页面传过来的路径
@property (nonatomic, strong) NSString *targetFilePath;

@end

NS_ASSUME_NONNULL_END
