//
//  ViewerCell.m
//  PicData
//
//  Created by 鹏鹏 on 2020/11/5.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "ViewerCell.h"

@interface ViewerCell()

@property (nonatomic, strong) UIView * bgView;

@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, strong) UILabel *fileNameLabel;

@property (nonatomic, strong) UIImageView *arrowImageView;


@end

@implementation ViewerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        self.contentView.backgroundColor = BackgroundColor;

        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = UIColor.whiteColor;
        [self.contentView addSubview:bgView];
        self.bgView = bgView;

        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(8);
            make.left.mas_equalTo(8);
            make.right.mas_equalTo(-8);
            make.bottom.mas_equalTo(0);
        }];

        bgView.layer.cornerRadius = 4;

        UIImageView *iconImageView = [[UIImageView alloc] init];
        iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.bgView addSubview:iconImageView];
        self.iconImageView = iconImageView;

        [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bgView);
            make.left.mas_equalTo(16);
            make.size.mas_equalTo(CGSizeMake(44, 44));
        }];

        UIImageView *arrowImageView = [[UIImageView alloc] init];
        arrowImageView.image = [UIImage imageNamed:@"operation_right"];
        [self.bgView addSubview:arrowImageView];
        self.arrowImageView = arrowImageView;

        [arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bgView);
            make.right.mas_equalTo(-16);
            make.size.mas_equalTo(CGSizeMake(44, 44));
        }];

        UILabel *fileNameLabel = [[UILabel alloc] init];
        fileNameLabel.font = [UIFont systemFontOfSize:15];
        fileNameLabel.numberOfLines = 2;
        fileNameLabel.textAlignment = NSTextAlignmentLeft;
        [self.bgView addSubview:fileNameLabel];
        self.fileNameLabel = fileNameLabel;

        [fileNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(iconImageView);
            make.left.equalTo(iconImageView.mas_right).with.offset(8);
            make.right.equalTo(arrowImageView.mas_left).with.offset(-8);
        }];
    }
    return self;
}

- (void)setFileModel:(ViewerFileModel *)fileModel {
    _fileModel = fileModel;

    if (fileModel.isFolder) {
        self.iconImageView.image = [UIImage imageNamed:@"file_type_v_folder"];
    } else {
        if ([fileModel.fileName.pathExtension containsString:@"txt"]) {
            self.iconImageView.image = [UIImage imageNamed:@"file_type_v_txt"];
        } else {
            [self.iconImageView sd_setImageWithURL:[NSURL fileURLWithPath:[self.targetPath stringByAppendingPathComponent:fileModel.fileName]] placeholderImage:[UIImage imageNamed:@"file_type_v_image"]];
        }
    }
    self.fileNameLabel.text = fileModel.fileName;
}

@end
