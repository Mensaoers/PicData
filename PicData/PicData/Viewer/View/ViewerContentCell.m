//
//  ViewerContentCell.m
//  PicData
//
//  Created by 鹏鹏 on 2020/12/27.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "ViewerContentCell.h"

@interface ViewerContentCell()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ViewerContentCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = UIColor.whiteColor;
        [self.contentView addSubview:bgView];

        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];

        bgView.layer.cornerRadius = 8;
        bgView.layer.masksToBounds = YES;

        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:10];
        titleLabel.textColor = pdColor(63, 63, 63, 1);
        titleLabel.numberOfLines = 3;
        [bgView addSubview:titleLabel];
        self.titleLabel = titleLabel;

        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(2);
            make.right.mas_equalTo(-2);
            make.height.mas_lessThanOrEqualTo(40);
            make.bottom.mas_equalTo(-2);
        }];

        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.backgroundColor = UIColor.clearColor;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [bgView addSubview:imageView];
        self.imageView = imageView;

        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(2);
            make.left.mas_equalTo(2);
            make.right.mas_equalTo(2);
            make.bottom.equalTo(titleLabel.mas_top).with.offset(-2);
        }];

        self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
        self.contentView.layer.shadowOffset = CGSizeMake(0,0);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
        self.contentView.layer.shadowOpacity = 0.15;//阴影透明度，默认0
        self.contentView.layer.shadowRadius = 5;//阴影半径，默认3
    }
    return self;
}

- (void)setFileModel:(ViewerFileModel *)fileModel {
    _fileModel = fileModel;

    if (fileModel.isFolder) {
        self.imageView.image = [UIImage imageNamed:@"file_type_v_folder"];
    } else {
        if ([fileModel.fileName.pathExtension containsString:@"txt"]) {
            self.imageView.image = [UIImage imageNamed:@"file_type_v_txt"];
        } else {
            [self.imageView sd_setImageWithURL:[NSURL fileURLWithPath:[self.targetPath stringByAppendingPathComponent:fileModel.fileName]] placeholderImage:[UIImage imageNamed:@"file_type_v_image"]];
        }
    }
    self.titleLabel.text = fileModel.fileName;
}
@end
