//
//  SharedListTableViewCell.m
//  PicData
//
//  Created by Garenge on 2024/4/28.
//  Copyright © 2024 garenge. All rights reserved.
//

#import "SharedListTableViewCell.h"

@interface SharedListTableViewCell()

@property (nonatomic, strong) UIImageView *selectedIconIMGV;
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

    self.backgroundColor = UIColor.clearColor;

    UIView *bgView = [UIView new];
    bgView.backgroundColor = UIColor.whiteColor;
    bgView.layer.cornerRadius = 8;
    bgView.layer.masksToBounds = YES;
    [self.contentView addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 8, 8, 8));
    }];

    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.alignment = UIStackViewAlignmentTop;
    stackView.spacing = 8;
    [bgView addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];

    UIImageView *selectedIconIMGV = [[UIImageView alloc] init];
    [stackView addArrangedSubview:selectedIconIMGV];
    self.selectedIconIMGV = selectedIconIMGV;
    [selectedIconIMGV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.width.height.mas_equalTo(24);
        make.top.mas_equalTo(16);
    }];

    UIView *rightView = [[UIView alloc] init];
    [stackView addArrangedSubview:rightView];
    [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.mas_equalTo(0);
    }];

    UIImageView *iconIMGV = [[UIImageView alloc] init];
    iconIMGV.contentMode = UIViewContentModeScaleAspectFit;
    [rightView addSubview:iconIMGV];
    self.iconIMGV = iconIMGV;

    [iconIMGV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(8);
        make.top.mas_equalTo(8);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];

    UILabel *fileNameLabel = [[UILabel alloc] init];
    fileNameLabel.font = [UIFont systemFontOfSize:14];
    fileNameLabel.textColor = UIColor.blackColor;
    fileNameLabel.numberOfLines = 3;
    fileNameLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [rightView addSubview:fileNameLabel];
    self.fileNameLabel = fileNameLabel;

    [fileNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(iconIMGV.mas_right).offset(8);
        make.top.equalTo(iconIMGV);
        make.right.mas_equalTo(-16);
    }];

    UILabel *sizeLabel = [[UILabel alloc] init];
    sizeLabel.font = [UIFont systemFontOfSize:12];
    sizeLabel.textColor = UIColor.lightGrayColor;
    [rightView addSubview:sizeLabel];
    self.sizeLabel = sizeLabel;
    [sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(fileNameLabel);
        make.top.mas_equalTo(fileNameLabel.mas_bottom).offset(4);
        make.height.mas_equalTo(18);
        make.bottom.mas_equalTo(-8);
    }];
}

- (void)setIsEditing:(BOOL)isEditing {
    _isEditing = isEditing;
    self.selectedIconIMGV.hidden = !isEditing;
}

- (void)setModel:(ViewerFileSModel *)model {
    _model = model;

    self.selectedIconIMGV.image = model.isSelected ? [UIImage systemImageNamed:@"checkmark.circle.fill"] : [UIImage systemImageNamed:@"circle"];

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
