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
        UILabel *label = [UILabel new];
        label.textColor = [UIColor blackColor];
        label.font = PDSYSTEMFONT_15;
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor whiteColor];
        label.tag = tagsC + i;
        label.text = tagsFrame.tagsArray[i];
        label.frame = CGRectFromString(tagsFrame.tagsFrames[i]);
        label.userInteractionEnabled = YES;
        label.layer.borderWidth = 1;
        label.layer.borderColor = [UIColor lightGrayColor].CGColor;
        label.layer.cornerRadius = 4;
        label.layer.masksToBounds = YES;
        [self.contentView addSubview:label];

        UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [label addGestureRecognizer:ges];
    }
}

- (void)tapAction:(UITapGestureRecognizer *)sender {

    NSInteger index = sender.view.tag - tagsC;
    if (self.delegate && [self.delegate respondsToSelector:@selector(tagsViewCell:didSelectTags:indexPath:)]) {
        [self.delegate tagsViewCell:self didSelectTags:index indexPath:self.indexPath];
    }
}

@end
