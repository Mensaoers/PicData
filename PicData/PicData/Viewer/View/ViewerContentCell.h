//
//  ViewerContentCell.h
//  PicData
//
//  Created by 鹏鹏 on 2020/12/27.
//  Copyright © 2020 garenge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewerFileModel.h"

NS_ASSUME_NONNULL_BEGIN
static CGFloat ViewerContentImageScale = 1; // 360.0 / 250.0
@interface ViewerContentCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) NSString *targetPath;

@property (nonatomic, strong) ViewerFileModel *fileModel;

@end

NS_ASSUME_NONNULL_END
