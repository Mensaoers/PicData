//
//  DetailViewController.h
//  PicData
//
//  Created by Garenge on 2020/4/20.
//  Copyright © 2020 garenge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PicSourceModel.h"
#import "PicContentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DetailViewController : UIViewController

@property (nonatomic, strong) PicSourceModel *sourceModel;
@property (nonatomic, strong) PicContentModel *contentModel;

@end

NS_ASSUME_NONNULL_END
