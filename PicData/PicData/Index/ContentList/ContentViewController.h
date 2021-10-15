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

typedef  NSArray <PicContentModel *>*_Nonnull(^LoadDataBlock)(void);
@interface ContentViewController : BaseViewController

@property (nonatomic, strong) PicSourceModel *sourceModel;
- (instancetype)initWithSourceModel:(PicSourceModel *)sourceModel;

@property (nonatomic, copy) LoadDataBlock loadDataBlock;
@property (nonatomic, copy) void(^loadMoreDataBlock)(void(^loadDataBlock)(NSArray <PicContentModel *>*));

@end

NS_ASSUME_NONNULL_END
