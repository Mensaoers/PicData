//
//  ContentParserManager.h
//  PicData
//
//  Created by Garenge on 2020/4/20.
//  Copyright © 2020 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "PicContentModel.h"
#import "PicSourceModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContentParserManager : NSObject

singleton_interface(ContentParserManager);

- (void)parserWithSourceModel:(PicSourceModel *)sourceModel ContentModel:(PicContentModel *)contentModel needDownload:(BOOL)needDownload;

@end

NS_ASSUME_NONNULL_END
