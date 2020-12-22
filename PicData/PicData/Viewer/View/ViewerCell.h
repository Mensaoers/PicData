//
//  ViewerCell.h
//  PicData
//
//  Created by 鹏鹏 on 2020/11/5.
//  Copyright © 2020 garenge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewerFileModel.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *ViewerCellIdentifier = @"ViewerCellIdentifier";

@interface ViewerCell : UITableViewCell

@property (nonatomic, strong) NSString *targetPath;

@property (nonatomic, strong) ViewerFileModel *fileModel;

@end

NS_ASSUME_NONNULL_END
