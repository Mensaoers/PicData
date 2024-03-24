//
//  PicBrowserToolViewHandler.m
//  PicData
//
//  Created by Garenge on 2020/11/25.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "PicBrowserToolViewHandler.h"
#import "YBIBCopywriter.h"
#import "YBIBUtilities.h"

@interface PicBrowserToolViewHandler()

@property (nonatomic, strong) UIView *operationView;
@property (nonatomic, strong) UIButton *saveToAlbumeBtn;
@property (nonatomic, strong) UIButton *shareToOtherBtn;

@property (nonatomic, strong) YBIBTopView *topView;

@end

@implementation PicBrowserToolViewHandler

#pragma mark - <YBIBToolViewHandler>

@synthesize yb_containerView = _yb_containerView;
@synthesize yb_currentData = _yb_currentData;
@synthesize yb_containerSize = _yb_containerSize;
@synthesize yb_currentOrientation = _yb_currentOrientation;
@synthesize yb_currentPage = _yb_currentPage;
@synthesize yb_totalPage = _yb_totalPage;

- (CGSize)operationViewSize {
    CGSize viewSize = CGSizeMake(92, 44);
    return viewSize;
}

- (void)yb_containerViewIsReadied {
    [self.yb_containerView addSubview:self.topView];
    [self layoutWithExpectOrientation:self.yb_currentOrientation()];
}

- (void)yb_hide:(BOOL)hide {
    self.operationView.hidden = hide;
}

- (void)yb_pageChanged {
    self.topView.operationButton.hidden = YES;
    [self.topView setPage:self.yb_currentPage() totalPage:self.yb_totalPage()];
}

- (void)yb_orientationChangeAnimationWithExpectOrientation:(UIDeviceOrientation)orientation {
    // 旋转的效果自行处理了
}

- (void)layoutWithExpectOrientation:(UIDeviceOrientation)orientation {
    CGSize containerSize = self.yb_containerSize(orientation);
    UIEdgeInsets padding = YBIBPaddingByBrowserOrientation(orientation);
    
    CGRect frame = CGRectMake(padding.left, padding.top, containerSize.width - padding.left - padding.right, [YBIBTopView defaultHeight]);
    self.topView.frame = frame;
    CGSize size = [self operationViewSize];
    self.operationView.frame = CGRectMake(frame.size.width - size.width, 0, size.width, frame.size.height);
}

#pragma mark - event
- (void)savePicToAlbumAction:(UIButton *)sender {
    // 拿到当前的数据对象（此案例都是图片）
    YBIBImageData *data = (YBIBImageData *)self.yb_currentData();
    [data yb_saveToPhotoAlbum];
}

- (void)sharePicToOtherAction:(UIButton *)sender {
    YBIBImageData *data = (YBIBImageData *)self.yb_currentData();

    if (data.imageURL.absoluteString.length > 0) {
        // 网络图片
        UIPasteboard.generalPasteboard.string = data.imageURL.absoluteString;
        [MBProgressHUD showInfoOnView:self.yb_containerView WithStatus:@"地址已复制" afterDelay:1];
        return;
    } else if (data.image) {
        // 直接传的data对象, 可以忽略操作
        return;
    }

    if (![[NSFileManager defaultManager] fileExistsAtPath:data.imagePath]) {
        [MBProgressHUD showInfoOnView:self.yb_containerView WithStatus:@"获取文件地址异常" afterDelay:1];
        return;
    }
    NSURL *fileURL = [NSURL fileURLWithPath:data.imagePath];

#if TARGET_OS_MACCATALYST

    [AppTool shareFileWithURLs:@[fileURL] sourceView:sender completionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {

    }];

    return;

#endif

    [AppTool shareWithActivityItems:@[fileURL] sourceView:sender completionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        if (completed) {
            NSLog(@"分享成功!");
        } else {
            NSLog(@"分享失败!");
        }
    }];
}

#pragma mark - getters
- (YBIBTopView *)topView {
    if (!_topView) {
        _topView = [YBIBTopView new];
        _topView.operationType = YBIBTopViewOperationTypeMore;
        
        [_topView addSubview:self.operationView];
    }
    return _topView;
}

- (UIView *)operationView {
    if (nil == _operationView) {
        CGSize size = [self operationViewSize];
        _operationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        _operationView.backgroundColor = UIColor.clearColor;
        
        UIButton *shareToOtherBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        shareToOtherBtn.frame = CGRectMake(0, 0, size.height, size.height);
#if TARGET_OS_MACCATALYST
        [shareToOtherBtn setImage:[UIImage imageNamed:@"show"] forState:UIControlStateNormal];
#else
        [shareToOtherBtn setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
#endif
        shareToOtherBtn.backgroundColor = UIColor.clearColor;
        [shareToOtherBtn addTarget:self action:@selector(sharePicToOtherAction:) forControlEvents:UIControlEventTouchUpInside];
        [_operationView addSubview:shareToOtherBtn];
        self.shareToOtherBtn = shareToOtherBtn;
        
        UIButton *saveToAlbumeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        saveToAlbumeBtn.frame = CGRectMake(size.width - size.height, 0, size.height, size.height);
        [saveToAlbumeBtn setImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
        saveToAlbumeBtn.backgroundColor = UIColor.clearColor;
        [saveToAlbumeBtn addTarget:self action:@selector(savePicToAlbumAction:) forControlEvents:UIControlEventTouchUpInside];
        [_operationView addSubview:saveToAlbumeBtn];
        self.saveToAlbumeBtn = saveToAlbumeBtn;
    }
    return _operationView;
}

@end
