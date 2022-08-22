//
//  NetListTCell.h
//  PicData
//
//  Created by 鹏鹏 on 2022/7/10.
//  Copyright © 2022 garenge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PicNetModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NetListTCell : UITableViewCell

@property (nonatomic, strong) PicNetModel *hostModel;
@property (nonatomic, assign) BOOL isForcus;

@end

NS_ASSUME_NONNULL_END
