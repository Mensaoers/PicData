//
//  SharedListTableViewCell.m
//  PicData
//
//  Created by Garenge on 2024/4/28.
//  Copyright © 2024 garenge. All rights reserved.
//

#import "SharedListTableViewCell.h"

@interface SharedListTableViewCell()

@property (nonatomic, strong) UIImageView *iconIMGV;
@property (nonatomic, strong) UILabel *fileNameLabel;
@property (nonatomic, strong) UILabel *sizeLabel;

@end

@implementation SharedListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {

    UIImageView *iconIMGV = [[UIImageView alloc] init];
    iconIMGV.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:iconIMGV];
    self.iconIMGV = iconIMGV;

    [iconIMGV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.top.mas_equalTo(8);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];

    UILabel *fileNameLabel = [[UILabel alloc] init];
    fileNameLabel.font = [UIFont systemFontOfSize:14];
    fileNameLabel.textColor = UIColor.blackColor;
    fileNameLabel.numberOfLines = 3;
    [self.contentView addSubview:fileNameLabel];
    self.fileNameLabel = fileNameLabel;

    [fileNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(iconIMGV.mas_right).offset(16);
        make.top.equalTo(iconIMGV);
        make.right.mas_equalTo(-16);
    }];

    UILabel *sizeLabel = [[UILabel alloc] init];
    sizeLabel.font = [UIFont systemFontOfSize:12];
    sizeLabel.textColor = UIColor.lightGrayColor;
    [self.contentView addSubview:sizeLabel];
    self.sizeLabel = sizeLabel;
    [sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(fileNameLabel);
        make.top.mas_equalTo(fileNameLabel.mas_bottom).offset(4);
        make.height.mas_equalTo(18);
        make.bottom.mas_equalTo(-8);
    }];
}

- (void)setModel:(ViewerFileModel *)model {
    _model = model;
    self.fileNameLabel.text = model.fileName;
    if ([@[@"doc", @"pdf"] containsObject:model.fileName.pathExtension.lowercaseString]) {
        self.iconIMGV.image = [UIImage systemImageNamed:@"doc.richtext"];
    } else if ([@[@"rar", @"zip"] containsObject:model.fileName.pathExtension.lowercaseString]){
        self.iconIMGV.image = [UIImage systemImageNamed:@"doc.zipper"];
    } else {
        self.iconIMGV.image = [UIImage systemImageNamed:@"doc.questionmark"];
    }
    self.sizeLabel.text = [NSString fileSizeFormat:model.fileSize];
}

@end
