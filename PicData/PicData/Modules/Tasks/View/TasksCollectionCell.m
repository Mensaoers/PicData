//
//  TasksCollectionCell.m
//  PicData
//
//  Created by 鹏鹏 on 2022/5/5.
//  Copyright © 2022 garenge. All rights reserved.
//

#import "TasksCollectionCell.h"

@interface TasksCollectionCell()

@property (nonatomic, strong) UIImageView *thumbnailIV;

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation TasksCollectionCell

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
        thumbnailIV.contentMode = UIViewContentModeScaleAspectFill;
        [bgView addSubview:thumbnailIV];
        self.thumbnailIV = thumbnailIV;

        [thumbnailIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
            make.bottom.mas_equalTo(-60);
        }];

        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.numberOfLines = 3;
        titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        titleLabel.font = [UIFont systemFontOfSize:12];
        titleLabel.textColor = pdColor(63, 63, 63, 1);
        [bgView addSubview:titleLabel];
        self.titleLabel = titleLabel;

        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(2);
            make.right.mas_equalTo(-2);// (-35);
            make.top.equalTo(thumbnailIV.mas_bottom).with.offset(4);
            make.bottom.mas_equalTo(-2);
        }];

        self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
        self.contentView.layer.shadowOffset = CGSizeMake(0,0);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
        self.contentView.layer.shadowOpacity = 0.15;//阴影透明度，默认0
        self.contentView.layer.shadowRadius = 5;//阴影半径，默认3
    }
    return self;
}

- (void)setTaskModel:(PicContentTaskModel *)taskModel {
    _taskModel = taskModel;

    [self.thumbnailIV sd_setImageWithURL:[NSURL URLWithString:taskModel.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"blank"] options:SDWebImageAllowInvalidSSLCertificates];

    self.titleLabel.text = [NSString stringWithFormat:@"%@-%@", taskModel.sourceTitle, taskModel.title];

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];

    NSString *sourceTitleStr = [NSString stringWithFormat:@" [%@] ", taskModel.sourceTitle];
    NSMutableAttributedString *attributedSourceString = [[NSMutableAttributedString alloc] initWithString:sourceTitleStr];
    [attributedSourceString addAttributes:@{NSForegroundColorAttributeName: [UIColor grayColor],
                                            NSFontAttributeName: [UIFont systemFontOfSize:12],
                                            NSBackgroundColorAttributeName: pdColor(230, 230, 230, 1)}
                                    range:NSMakeRange(0, sourceTitleStr.length)];

    [attributedString appendAttributedString:attributedSourceString];

    NSString *titleStr = taskModel.title;
    NSMutableAttributedString *attributedTitleString = [[NSMutableAttributedString alloc] initWithString:titleStr];
    [attributedTitleString addAttributes:@{NSForegroundColorAttributeName: [UIColor darkTextColor], NSFontAttributeName: [UIFont systemFontOfSize:14]} range:NSMakeRange(0, titleStr.length)];

    [attributedString appendAttributedString:attributedTitleString];

    self.titleLabel.attributedText = attributedString;
}

@end
