
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

#endif /* Config_h */
