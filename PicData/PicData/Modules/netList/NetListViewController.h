//
//  NetListViewController.h
//  PicData
//
//  Created by 鹏鹏 on 2022/2/18.
//  Copyright © 2022 garenge. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface NetListViewController : BaseViewController

@property (nonatomic, assign) CGFloat targetWidth;
@property (nonatomic, copy) void(^refreshBlock)(void);

@end

NS_ASSUME_NONNULL_END

