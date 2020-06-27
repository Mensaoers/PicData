//
//  DetailViewContentCell.h
//  PicData
//
//  Created by Garenge on 2020/4/20.
//  Copyright © 2020 garenge. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DetailViewContentCell;

@interface DetailViewContentCell : UITableViewCell

@property (nonatomic, strong) NSIndexPath *indexpath;

@property (nonatomic, strong) NSString *url;

@end

NS_ASSUME_NONNULL_END
