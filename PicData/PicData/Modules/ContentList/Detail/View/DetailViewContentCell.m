//
//  DetailViewContentCell.m
//  PicData
//
//  Created by Garenge on 2020/4/20.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "DetailViewContentCell.h"

@interface DetailViewContentCell()

@property (nonatomic, assign) CGSize lastSize;

@property (nonatomic, strong) NSString *url;

@end

@implementation DetailViewContentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

        self.backgroundColor = UIColor.clearColor;

        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView *conImgView = [[UIImageView alloc] init];
        conImgView.backgroundColor = UIColor.clearColor;
        conImgView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:conImgView];
        self.conImgView = conImgView;
        
        [conImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.mas_equalTo(5);
            make.right.mas_equalTo(-5);
            make.bottom.mas_equalTo(-4);
        }];
        
        conImgView.layer.cornerRadius = 4;
        conImgView.layer.masksToBounds = YES;
    }
    return self;
}

- (void)setImageUrl:(NSString *)imageUrl refererUrl:(NSString *)refererUrl sourceType:(int)sourceType {

    if ([imageUrl isEqualToString:_url]) {
        if (fabs(self.targetImageWidth - self.lastSize.width) >= 4 || fabs(self.mj_h - self.lastSize.height) >= 4) {
            [self updateImageViewSize:self.conImgView.image.size force:YES];
        }
        return;
    }
    _url = imageUrl;

    SDWebImageContext *context = @{SDWebImageContextCustomManager: [AppTool sdWebImageManager:refererUrl sourceType:sourceType]};

    PDBlockSelf
    [self.conImgView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"blank"] options:SDWebImageAllowInvalidSSLCertificates context: context progress: nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (nil == error && [weakSelf.url isEqualToString:imageUrl]) {
            CGSize imageSize = image.size;
            [weakSelf updateImageViewSize:imageSize force:NO];
        }
    }];
}

- (void)updateImageViewSize:(CGSize)imageSize force:(BOOL)force {

    CGFloat height = imageSize.height * self.targetImageWidth / imageSize.width;
    self.lastSize = CGSizeMake(self.targetImageWidth, height);

    if (self.updateCellHeightBlock) {
        self.updateCellHeightBlock(self.indexpath, height + 9, force);
    }
}

@end
