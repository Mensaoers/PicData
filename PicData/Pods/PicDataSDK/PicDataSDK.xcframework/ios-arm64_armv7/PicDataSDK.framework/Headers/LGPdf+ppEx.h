//
//  LGPdf+ppEx.h
//  PicDataSDK
//
//  Created by 鹏鹏 on 2022/1/26.
//

#import "LGPdf.h"

NS_ASSUME_NONNULL_BEGIN

/// 创建pdf
@interface LGPdf (ppEx)

/// 创建pdf(考虑到文件数组可能需要筛选, 用block回传下标的方式获取图片资源)
/// @param imageCount 多少张图
/// @param width pdf的宽度
/// @param sepmargin 上下边框留白
/// @param pdfPath 导出路径
/// @param password 密码
/// @param minWidth 筛选图片的最小宽度
/// @param enmuHandler 回调获取图片
+ (void)createPdfWithImageCount:(NSInteger)imageCount width:(CGFloat)width sepmargin:(CGFloat)sepmargin pdfPath:(NSString *)pdfPath password:(NSString *)password minWidth:(CGFloat)minWidth enmuHandler:(UIImage * _Nullable (^ _Nonnull)(NSInteger index))enmuHandler;

@end

NS_ASSUME_NONNULL_END
