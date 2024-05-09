//
//  SharedListTableViewCell.h
//  PicData
//
//  Created by Garenge on 2024/4/28.
//  Copyright © 2024 garenge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewerFileSModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SharedListTableViewCell : UITableViewCell

@property (nonatomic, strong) ViewerFileSModel *model;
@property (nonatomic, assign) BOOL isEditing;

@end

NS_ASSUME_NONNULL_END
