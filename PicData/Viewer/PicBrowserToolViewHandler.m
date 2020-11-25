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
    if (![[NSFileManager defaultManager] fileExistsAtPath:data.imagePath]) {
        [MBProgressHUD showInfoOnView:self.yb_containerView WithStatus:@"获取文件地址异常" afterDelay:1];
        return;
    }
    NSURL *fileURL = [NSURL fileURLWithPath:data.imagePath];
    
    /** 划重点
     *  imageBrowser是加载在keyWindow上的, 遮挡住控制器keyWindow.rootViewController
     *  控制器弹出新的界面都没有imageBrowser的界面高, 都会被遮挡
     *  也就是说, 我们哪怕获取了顶层控制器, present:activityVC的时候, 也会被预览图遮住
     *  所以我们新建一个临时的window, 设置一个空白的控制器tmpViewController
     *  用这个临时控制器去弹出分享视图activityVC
     */
    UIWindow *tmpWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UIViewController *topRootViewController = [[UIViewController alloc] init];
    topRootViewController.view.backgroundColor = [UIColor clearColor];
        tmpWindow.windowLevel = UIWindowLevelAlert - 1;
        tmpWindow.rootViewController = topRootViewController;
        [tmpWindow makeKeyAndVisible];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[fileURL] applicationActivities:nil];
    activityVC.completionWithItemsHandler = ^(UIActivityType __nullable activityType, BOOL completed, NSArray *__nullable returnedItems, NSError *__nullable activityError) {
        NSLog(@"调用分享的应用id :%@", activityType);
        [tmpWindow resignKeyWindow];
        if (completed) {
            NSLog(@"分享成功!");
        } else {
            NSLog(@"分享失败!");
        }
    };

    if ([[UIDevice currentDevice].model isEqualToString:@"iPhone"]) {
        [topRootViewController presentViewController:activityVC animated:YES completion:nil];
    } else if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
        UIPopoverPresentationController *popover = activityVC.popoverPresentationController;
        if (popover) {
            popover.sourceView = sender;
            popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
        }
        [topRootViewController presentViewController:activityVC animated:YES completion:nil];
    } else {
        //do nothing
    }
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
        [shareToOtherBtn setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
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
