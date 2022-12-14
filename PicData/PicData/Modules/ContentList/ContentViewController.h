//
//  ContentViewController.h
//  PicData
//
//  Created by Garenge on 2020/4/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PicSourceModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContentViewController : BaseViewController

@property (nonatomic, strong) PicSourceModel *sourceModel;
- (instancetype)initWithSourceModel:(PicSourceModel *)sourceModel;

@end

NS_ASSUME_NONNULL_END
