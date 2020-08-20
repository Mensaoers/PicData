//
//  TransViewCell.m
//  PicData
//
//  Created by CleverPeng on 2020/8/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "TransViewCell.h"

@interface TransViewCell()

@property (nonatomic, strong) UIImageView *thumbnailIV;
@property (nonatomic, strong) UILabel *contentTitleL;
@property (nonatomic, strong) UILabel *progressL;

@end

@implementation TransViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UIImageView *thumbnailIV = [[UIImageView alloc] init];
        [self.contentView addSubview:thumbnailIV];
        self.thumbnailIV = thumbnailIV;

        [thumbnailIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(8);
            make.top.mas_equalTo(8);
            make.bottom.mas_equalTo(-8);
            make.height.equalTo(thumbnailIV.mas_width);
        }];

        UILabel *contentTitleL = [[UILabel alloc] init];
        contentTitleL.font = [UIFont systemFontOfSize:14];
        contentTitleL.numberOfLines = 2;
        contentTitleL.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self.contentView addSubview:contentTitleL];
        self.contentTitleL = contentTitleL;

        [contentTitleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(thumbnailIV.mas_right).with.offset(8);
            make.right.mas_equalTo(-60);
            make.centerY.equalTo(thumbnailIV);
        }];

        UILabel *progressL = [[UILabel alloc] init];
        progressL.font = [UIFont systemFontOfSize:12];
        progressL.numberOfLines = 0;
        [self.contentView addSubview:progressL];
        self.progressL = progressL;

        [progressL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(contentTitleL.mas_right).with.offset(8);
            make.right.mas_equalTo(-8);
            make.centerY.equalTo(thumbnailIV);
        }];
    }
    return self;
}

- (void)setContentModel:(PicContentModel *)contentModel {
    _contentModel = contentModel;

    [self.thumbnailIV sd_setImageWithURL:[NSURL URLWithString:contentModel.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"blank"]];

    self.contentTitleL.text = contentModel.title;

    self.progressL.text = [NSString stringWithFormat:@"%d\n/\n%d", contentModel.downloadedCount, contentModel.totalCount];
}

- (void)setDownloadedCount:(int)downloadCount {
    self.contentModel.downloadedCount = downloadCount;
    self.progressL.text = [NSString stringWithFormat:@"%d\n/\n%d", self.contentModel.downloadedCount, self.contentModel.totalCount];
}
- (void)setTotalCount:(int)totalCount {
    self.contentModel.totalCount = totalCount;
    self.progressL.text = [NSString stringWithFormat:@"%d\n/\n%d", self.contentModel.downloadedCount, self.contentModel.totalCount];
}

@end
