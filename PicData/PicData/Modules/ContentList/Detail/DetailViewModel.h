//
//  DetailViewModel.h
//  PicData
//
//  Created by Garenge on 2020/4/20.
//  Copyright © 2020 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetailViewModel : NSObject

@property (nonatomic, strong) NSString *detailTitle;
@property (nonatomic, strong) NSArray *contentImgsUrl;

@property (nonatomic, strong) NSString *currentUrl;
@property (nonatomic, strong) NSString *nextUrl;

@property (nonatomic, strong) NSString *suggesTitle;
@property (nonatomic, strong) NSArray *suggesArray;

/// Default is YES. Only can set one time;
@property (nonatomic, assign) BOOL canUpdateTitle;

@end

NS_ASSUME_NONNULL_END
