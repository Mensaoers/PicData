//
//  PicContentCell.m
//  PicData
//
//  Created by Garenge on 2020/4/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "PicContentCell.h"

@interface PicContentCell()

@property (nonatomic, strong) UIImageView *thumbnailIV;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *downBtn;

@end

@implementation PicContentCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = UIColor.whiteColor;
        [self.contentView addSubview:bgView];
        
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        
        bgView.layer.cornerRadius = 4;
        bgView.layer.masksToBounds = YES;
        
        UIImageView *thumbnailIV = [[UIImageView alloc] init];
        thumbnailIV.backgroundColor = UIColor.clearColor;
        thumbnailIV.contentMode = UIViewContentModeScaleAspectFit;
        [bgView addSubview:thumbnailIV];
        self.thumbnailIV = thumbnailIV;
        
        [thumbnailIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
            make.bottom.mas_equalTo(-50);
        }];

        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.numberOfLines = 3;
        titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        titleLabel.font = [UIFont systemFontOfSize:12];
        titleLabel.textColor = pdColor(63, 63, 63, 1);
        [bgView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(2);
            make.right.mas_equalTo(-2);
            make.top.equalTo(thumbnailIV.mas_bottom).with.offset(2);
            make.bottom.mas_equalTo(-2);
        }];

        [self.contentView layoutIfNeeded];
        
        UIButton *downBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [downBtn setImage:[[UIImage imageNamed:@"download"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [downBtn addTarget:self action:@selector(downBtnClickAction:) forControlEvents:UIControlEventTouchUpInside];
        downBtn.layer.cornerRadius = titleLabel.mj_h * 0.5;
        downBtn.backgroundColor = pdColor(222, 222, 222, 0.5);
        [bgView addSubview:downBtn];
        
        [downBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.top.bottom.equalTo(titleLabel);
            make.width.equalTo(downBtn.mas_height);
        }];
        
        self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
        self.contentView.layer.shadowOffset = CGSizeMake(0,0);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
        self.contentView.layer.shadowOpacity = 0.15;//阴影透明度，默认0
        self.contentView.layer.shadowRadius = 5;//阴影半径，默认3

    }
    return self;
}

- (void)downBtnClickAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(contentCell:downBtnClicked:contentModel:)]) {
        [self.delegate contentCell:self downBtnClicked:sender contentModel:self.contentModel];
    }
}

- (void)setContentModel:(PicContentModel *)contentModel {
    _contentModel = contentModel;
    
    self.titleLabel.text = contentModel.title;
    [self.titleLabel sizeToFit];
    [self.thumbnailIV sd_setImageWithURL:[NSURL URLWithString:contentModel.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"blank"] options:SDWebImageAllowInvalidSSLCertificates];
}

@end
