//
//  ViewerContentSelCell.h
//  PicData
//
//  Created by Garenge on 2024/11/3.
//  Copyright © 2024 garenge. All rights reserved.
//

#import <PicDataSDK/PicDataSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface ViewerContentSelCell : ViewerContentCell

@property (nonatomic, strong) UIImageView *selImageView;

@property (nonatomic, assign) BOOL isEditing;

@end

NS_ASSUME_NONNULL_END
