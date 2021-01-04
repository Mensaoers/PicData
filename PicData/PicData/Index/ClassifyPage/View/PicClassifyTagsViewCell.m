//
//  PicClassifyTagsViewCell.m
//  TagsDemo
//
//  Created by Administrator on 16/1/21.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "PicClassifyTagsViewCell.h"

@implementation PicClassifyTagsViewCell

+ (id)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"tags";
    PicClassifyTagsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[PicClassifyTagsViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

static NSInteger tagsC = 9527;
- (void)setTagsFrame:(PicClassifyTagsFrame *)tagsFrame
{
    _tagsFrame = tagsFrame;
    [self.contentView removeAllSubviews];
    for (NSInteger i=0; i<tagsFrame.tagsArray.count; i++) {
        UIButton *tagsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [tagsBtn setTitle:tagsFrame.tagsArray[i] forState:UIControlStateNormal];
        [tagsBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        tagsBtn.titleLabel.font = PDSYSTEMFONT_13;
        tagsBtn.backgroundColor = [UIColor whiteColor];
        tagsBtn.layer.borderWidth = 1;
        tagsBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        tagsBtn.layer.cornerRadius = 4;
        tagsBtn.layer.masksToBounds = YES;
        [tagsBtn addTarget:self action:@selector(tagsButtonClickedAction:) forControlEvents:UIControlEventTouchUpInside];
        tagsBtn.frame = CGRectFromString(tagsFrame.tagsFrames[i]);
        tagsBtn.tag = tagsC + i;
        [self.contentView addSubview:tagsBtn];
    }
}

- (void)tagsButtonClickedAction:(UIButton *)sender {
    NSInteger index = sender.tag - tagsC;
    if (self.delegate && [self.delegate respondsToSelector:@selector(tagsViewCell:didSelectTags:indexPath:)]) {
        [self.delegate tagsViewCell:self didSelectTags:index indexPath:self.indexPath];
    }
    
}

@end
