//
//  PDDownloadManager.h
//  PicData
//
//  Created by Garenge on 2020/4/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "PicSourceModel.h"
#import "PicContentModel.h"

#define DOWNLOADSPATH @"/Users/garenge/Downloads/PicDownload"

NS_ASSUME_NONNULL_BEGIN

@interface PDDownloadManager : NSObject

singleton_interface(PDDownloadManager);

- (NSString *)getDirPathWithSource:(nullable PicSourceModel *)sourceModel contentModel:(nullable PicContentModel *)contentModel;
- (void)downWithSource:(PicSourceModel *)sourceModel contentModel:(PicContentModel *)contentModel urls:(NSArray *)urls;

@end

NS_ASSUME_NONNULL_END
