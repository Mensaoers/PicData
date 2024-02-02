#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NSArray+ppEx.h"
#import "PPToolKit.h"

FOUNDATION_EXPORT double PPToolKitVersionNumber;
FOUNDATION_EXPORT const unsigned char PPToolKitVersionString[];

