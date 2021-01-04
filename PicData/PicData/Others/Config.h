
//
//  Config.h
//  PicData
//
//  Created by Garenge on 2020/4/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#ifndef Config_h
#define Config_h

#define SQLite_USER @"admin"

#define PDBlockSelf __weak __typeof(&*self)weakSelf = self;
#define pdColor(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define PDSCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define PDSCREENHEIGHT [UIScreen mainScreen].bounds.size.height

#define PDSYSTEMFONT_13 [UIFont systemFontOfSize:13]

#define BackgroundColor [UIColor colorWithRed:245.0 / 255 green:245.0 / 255 blue:245.0 / 255 alpha:1]
#define ThemeColor [UIColor colorWithRed:212.0 / 255 green:35.0 / 255 blue:122.0 / 255 alpha:1]
#define ThemeDisabledColor [UIColor colorWithRed:191.0 / 255 green:191.0 / 255 blue:191.0 / 255 alpha:1]

#endif /* Config_h */
