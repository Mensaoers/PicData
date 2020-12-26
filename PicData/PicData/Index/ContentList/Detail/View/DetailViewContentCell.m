//
//  DetailViewContentCell.m
//  PicData
//
//  Created by Garenge on 2020/4/20.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "DetailViewContentCell.h"

@interface DetailViewContentCell()

@property (nonatomic, strong) UIImageView *conImgView;

@end

@implementation DetailViewContentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

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

- (void)setUrl:(NSString *)url {
    if ([url isEqualToString:_url]) {
        return;
    }
    _url = url;
    PDBlockSelf
    [self.conImgView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"blank"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (nil == error) {
            CGSize imageSize = image.size;
            CGFloat height = imageSize.height * weakSelf.conImgView.mj_w / imageSize.width + 9;
//            NSLog(@"imageSize:%@, imageView.width: %f, height:%f", NSStringFromCGSize(imageSize), weakSelf.conImgView.mj_w, height);
            [weakSelf.conImgView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(height);
            }];
            if (weakSelf.updateCellHeightBlock) {
                weakSelf.updateCellHeightBlock(weakSelf.indexpath, height);
            }
        }
    }];
}

@end
