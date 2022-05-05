//
//  TasksTCell.m
//  PicData
//
//  Created by 鹏鹏 on 2022/5/5.
//  Copyright © 2022 garenge. All rights reserved.
//

#import "TasksTCell.h"

@interface TasksTCell()

@property (nonatomic, strong) UIImageView *thumbnailIMV;

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation TasksTCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

        UIImageView *thumbnailIMV = [[UIImageView alloc] init];
        thumbnailIMV.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:thumbnailIMV];
        self.thumbnailIMV = thumbnailIMV;

        [thumbnailIMV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(5);
            make.left.mas_equalTo(10);
            make.bottom.mas_equalTo(-5);
            make.width.equalTo(thumbnailIMV.mas_height);
        }];

        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.numberOfLines = 3;
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;

        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(thumbnailIMV.mas_right).with.offset(10);
            make.right.mas_equalTo(-20);
            make.top.mas_equalTo(10);
            make.bottom.mas_equalTo(-10);
        }];
    }
    return self;
}

- (void)setTaskModel:(PicContentTaskModel *)taskModel {
    _taskModel = taskModel;

    [self.thumbnailIMV sd_setImageWithURL:[NSURL URLWithString:taskModel.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"blank"] options:SDWebImageAllowInvalidSSLCertificates];

    self.titleLabel.text = [NSString stringWithFormat:@"%@-%@", taskModel.sourceTitle, taskModel.title];

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];

    NSString *sourceTitleStr = [NSString stringWithFormat:@" [%@] ", taskModel.sourceTitle];
    NSMutableAttributedString *attributedSourceString = [[NSMutableAttributedString alloc] initWithString:sourceTitleStr];
    [attributedSourceString addAttributes:@{NSForegroundColorAttributeName: [UIColor grayColor],
                                            NSFontAttributeName: [UIFont systemFontOfSize:15],
                                            NSBackgroundColorAttributeName: pdColor(230, 230, 230, 1)}
                                    range:NSMakeRange(0, sourceTitleStr.length)];

    [attributedString appendAttributedString:attributedSourceString];

    NSString *titleStr = taskModel.title;
    NSMutableAttributedString *attributedTitleString = [[NSMutableAttributedString alloc] initWithString:titleStr];
    [attributedTitleString addAttributes:@{NSForegroundColorAttributeName: [UIColor darkTextColor], NSFontAttributeName: [UIFont systemFontOfSize:18]} range:NSMakeRange(0, titleStr.length)];

    [attributedString appendAttributedString:attributedTitleString];

    self.titleLabel.attributedText = attributedString;
}

@end
