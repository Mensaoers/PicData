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
        UIImageView *conImgView = [[UIImageView alloc] init];
        conImgView.backgroundColor = UIColor.clearColor;
        conImgView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:conImgView];
        self.conImgView = conImgView;
        
        [conImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
    }
    return self;
}

- (void)setUrl:(NSString *)url {
//    PDBlockSelf
    [self.conImgView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"blank"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (nil == error) {
            // CGSize imageSize = image.size;
            // NSLog(@"imageSize:%@, imageView.width: %f, height:%f", NSStringFromCGSize(imageSize), weakSelf.conImgView.mj_w, imageSize.height * weakSelf.conImgView.mj_w / imageSize.width);
        }
    }];
}

@end
