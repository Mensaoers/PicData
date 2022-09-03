//
//  TasksCollectionCell.m
//  PicData
//
//  Created by 鹏鹏 on 2022/5/5.
//  Copyright © 2022 garenge. All rights reserved.
//

#import "TasksCollectionCell.h"
#import "PPStatusView.h"

static CGFloat TitleHeight = 56;
static CGFloat progressWidth = 46;
@interface TasksProgressView : UIView

- (void)setProgressFinished:(NSInteger)finished total:(NSInteger)total;

@end

@interface TasksProgressView()

@property (nonatomic, strong) PPStatusView *statusView;
@property (nonatomic, strong) UILabel *progressLabel;

@end

@implementation TasksProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

        PPStatusView *statusView = [[PPStatusView alloc] initWithFrame:CGRectMake(0, 0, progressWidth - 8, progressWidth - 8)];
        [self addSubview:statusView];
        self.statusView = statusView;

        [statusView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(4, 4, 4, 4));
        }];

        UILabel *progressLabel = [[UILabel alloc] init];
        progressLabel.font = [UIFont systemFontOfSize:8];
        progressLabel.textAlignment = NSTextAlignmentCenter;
        progressLabel.textColor = UIColor.whiteColor;
        [self addSubview:progressLabel];
        self.progressLabel = progressLabel;

        [progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
    return self;
}

- (void)setProgressFinished:(NSInteger)finished total:(NSInteger)total {
    self.progressLabel.text = [NSString stringWithFormat:@"%ld/%ld", finished, total];

    self.statusView.showProgress = finished != total;
    self.statusView.progress = finished * 1.0 / total;
    [self.statusView show];
}

@end

@interface TasksCollectionCell()

@property (nonatomic, strong) UIImageView *thumbnailIV;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) TasksProgressView *progressView;

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
        thumbnailIV.layer.masksToBounds = YES;
        [bgView addSubview:thumbnailIV];
        self.thumbnailIV = thumbnailIV;

        [thumbnailIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
            make.bottom.offset(-2 - TitleHeight);
        }];

        TasksProgressView *progressView = [[TasksProgressView alloc] initWithFrame:CGRectMake(0, 0, progressWidth, progressWidth)];
        [bgView addSubview:progressView];
        self.progressView = progressView;

        [progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(progressWidth);
            make.top.mas_equalTo(2);
            make.right.mas_equalTo(-2);
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
            make.bottom.offset(-2);
            make.right.mas_equalTo(-2);
            make.height.mas_equalTo(TitleHeight);
        }];

        self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
        self.contentView.layer.shadowOffset = CGSizeMake(0,0);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
        self.contentView.layer.shadowOpacity = 0.15;//阴影透明度，默认0
        self.contentView.layer.shadowRadius = 5;//阴影半径，默认3
    }
    return self;
}

- (void)updateProgress:(PicContentTaskModel *)taskModel {
    if (taskModel.status == 2) {
        // 2表示下载中
        [self.progressView setProgressFinished:taskModel.downloadedCount total:taskModel.totalCount];
    }
}

- (void)setTaskModel:(PicContentTaskModel *)taskModel {
    _taskModel = taskModel;

    [self.thumbnailIV sd_setImageWithURL:[NSURL URLWithString:taskModel.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"blank"] options:SDWebImageAllowInvalidSSLCertificates];

    self.titleLabel.text = [NSString stringWithFormat:@"%@-%@", taskModel.sourceTitle, taskModel.title];

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];

    NSString *sourceTitleStr = [NSString stringWithFormat:@" [%@] ", taskModel.sourceTitle];
    NSMutableAttributedString *attributedSourceString = [[NSMutableAttributedString alloc] initWithString:sourceTitleStr];
    [attributedSourceString addAttributes:@{NSForegroundColorAttributeName: [UIColor grayColor],
                                            NSFontAttributeName: [UIFont systemFontOfSize:11],
                                            NSBackgroundColorAttributeName: pdColor(230, 230, 230, 1)}
                                    range:NSMakeRange(0, sourceTitleStr.length)];

    [attributedString appendAttributedString:attributedSourceString];

    NSString *titleStr = taskModel.title;
    NSMutableAttributedString *attributedTitleString = [[NSMutableAttributedString alloc] initWithString:titleStr];
    [attributedTitleString addAttributes:@{NSForegroundColorAttributeName: [UIColor darkTextColor], NSFontAttributeName: [UIFont systemFontOfSize:12]} range:NSMakeRange(0, titleStr.length)];

    [attributedString appendAttributedString:attributedTitleString];

    self.titleLabel.attributedText = attributedString;

    if (taskModel.status == 2) {
        // 2表示下载中
        self.progressView.hidden = NO;
        [self.progressView setProgressFinished:taskModel.downloadedCount total:taskModel.totalCount];
    } else {
        self.progressView.hidden = YES;
    }
}

@end
