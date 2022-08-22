//
//  NetListTCell.m
//  PicData
//
//  Created by 鹏鹏 on 2022/7/10.
//  Copyright © 2022 garenge. All rights reserved.
//

#import "NetListTCell.h"

@interface NetListTCell()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *tipsLabel;

@end

@implementation NetListTCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

        UIButton *copyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [copyBtn setTitle:@"复制地址" forState:UIControlStateNormal];
        copyBtn.layer.cornerRadius = 6;
        copyBtn.layer.borderWidth = 1;
        copyBtn.layer.borderColor = UIColor.lightGrayColor.CGColor;
        [copyBtn addTarget:self action:@selector(copyBtnClickedAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:copyBtn];

        [copyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.right.mas_equalTo(-10);
            make.size.mas_equalTo(CGSizeMake(100, 40));
        }];

        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:17];
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;

        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.mas_equalTo(12);
            make.right.equalTo(copyBtn.mas_left).mas_equalTo(-12);
        }];

        UILabel *tipsLabel = [[UILabel alloc] init];
        tipsLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:tipsLabel];
        self.tipsLabel = tipsLabel;

        [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLabel.mas_bottom).offset(8);
            make.left.right.equalTo(titleLabel);
            make.bottom.mas_equalTo(-10);
        }];
    }
    return self;
}

- (void)setIsForcus:(BOOL)isForcus {
    _isForcus = isForcus;

    self.backgroundColor = _isForcus ? [UIColor redColor] : [UIColor whiteColor];
}

- (void)setHostModel:(PicNetModel *)hostModel {
    _hostModel = hostModel;

    self.titleLabel.text = hostModel.title;
    self.tipsLabel.text = hostModel.tips;
}

- (void)copyBtnClickedAction:(UIButton *)sender {
    [UIPasteboard generalPasteboard].string = self.hostModel.title;
    [MBProgressHUD showInfoOnView:AppTool.getAppKeyWindow WithStatus:@"已经复制到粘贴板"];
}

@end
