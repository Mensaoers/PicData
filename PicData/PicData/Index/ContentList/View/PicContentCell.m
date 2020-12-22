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
        
        UIImageView *thumbnailIV = [[UIImageView alloc] init];
        thumbnailIV.backgroundColor = UIColor.clearColor;
        thumbnailIV.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:thumbnailIV];
        self.thumbnailIV = thumbnailIV;
        
        [thumbnailIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
            make.height.mas_equalTo(frame.size.width * 360.0 / 250.0);
        }];

        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.numberOfLines = 3;
        titleLabel.font = [UIFont systemFontOfSize:12];
        titleLabel.textColor = pdColor(63, 63, 63, 1);
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(-35);
            make.top.equalTo(thumbnailIV.mas_bottom);
            make.bottom.mas_equalTo(0);
//            make.height.mas_equalTo(40);
        }];
        
        UIButton *downBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [downBtn setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
        [downBtn addTarget:self action:@selector(downBtnClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:downBtn];
        
        [downBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(titleLabel);
            make.right.mas_equalTo(-3);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
        
        self.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
        self.layer.shadowOffset = CGSizeMake(3,3);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
        self.layer.shadowOpacity = 0.05;//阴影透明度，默认0
        self.layer.shadowRadius = 3;//阴影半径，默认3

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
    [self.thumbnailIV sd_setImageWithURL:[NSURL URLWithString:contentModel.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"blank"]];
}

@end
