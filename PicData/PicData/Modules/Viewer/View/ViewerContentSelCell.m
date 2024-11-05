//
//  ViewerContentSelCell.m
//  PicData
//
//  Created by Garenge on 2024/11/3.
//  Copyright © 2024 garenge. All rights reserved.
//

#import "ViewerContentSelCell.h"
#import "ViewerFileSModel.h"

@implementation ViewerContentSelCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubviews_jkl];
    }
    return self;
}

- (void)setupSubviews_jkl {
    UIImageView *selImageView = [[UIImageView alloc] initWithImage: [UIImage systemImageNamed:@"circle"]];
    [self.contentView addSubview:selImageView];
    selImageView.hidden = YES;
    self.selImageView = selImageView;
    [selImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(24);
        make.right.mas_equalTo(-8);
        make.top.mas_equalTo(8);
    }];
}

- (void)setIsEditing:(BOOL)isEditing {
    _isEditing = isEditing;
    
    if (isEditing) {
        self.selImageView.hidden = NO;
        self.selImageView.image = [UIImage systemImageNamed:@"circle"];
    } else {
        self.selImageView.hidden = YES;
    }
}

- (void)setFileModel:(ViewerFileModel *)fileModel {
    [super setFileModel:fileModel];
    
    if ([fileModel isKindOfClass:[ViewerFileSModel class]]) {
        self.selImageView.image = ((ViewerFileSModel *)fileModel).isSelected ? [UIImage systemImageNamed:@"checkmark.circle.fill"] : [UIImage systemImageNamed:@"circle"];
    }
}

@end
