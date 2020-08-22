//
//  AddNetTaskVC.m
//  PicData
//
//  Created by CleverPeng on 2020/8/18.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "AddNetTaskVC.h"

@interface AddNetTaskVC ()

@property (weak, nonatomic) IBOutlet UITextField *contentTF;
@property (weak, nonatomic) IBOutlet UITextField *titleTF;

@property (weak, nonatomic) IBOutlet UITextView *multiTextView;

@property (nonatomic, strong) NSLock *lock;

@end

@implementation AddNetTaskVC

- (NSLock *)lock {
    if (nil == _lock) {
        _lock = [[NSLock alloc] init];
    }

    return _lock;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadNavigationItem];
    [self loadMainView];
}

- (void)loadNavigationItem {
    self.navigationItem.title = @"创建网络任务";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(sureToAdd:)];
}

- (void)loadMainView {
    self.view.backgroundColor = UIColor.whiteColor;
    self.multiTextView.layer.cornerRadius = 4;
    self.multiTextView.layer.borderWidth = 1;
    self.multiTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)prepareSourceWithUrl:(NSString *)url title:(NSString *)title resultHandler:(void(^)(PicSourceModel *sourceModel, PicContentModel *contentModel))result {

    if ([url containsString:@"_"]) {
        NSRange range = [url rangeOfString:@"_"];
        url = [[url substringToIndex:range.location] stringByAppendingString:@".html"];
    }
    PDBlockSelf
    dispatch_queue_t serialDiapatchQueue = dispatch_queue_create("com.test.queue", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(serialDiapatchQueue, ^{
        // 创建一个SourceModel
        PicSourceModel *sourceModel = [[PicSourceModel alloc] init];
        sourceModel.title = @"网络美女";

        sourceModel.HOST_URL = @"https://m.aitaotu.com";
        sourceModel.url = @"";
        sourceModel.sourceType = 2;


        [weakSelf.lock lock];
        if ([PicSourceModel queryTableWhere:[NSString stringWithFormat:@"where title = \"%@\"", @"网络美女"]].count == 0) {
            [sourceModel insertTable];
        }
        [weakSelf.lock unlock];

        PicContentModel *contentModel = [[PicContentModel alloc] init];
        contentModel.title = title;
        contentModel.HOST_URL = sourceModel.HOST_URL;
        contentModel.sourceTitle = sourceModel.title;
        contentModel.thumbnailUrl = @"";
        contentModel.href = url;

        [weakSelf.lock lock];
        if ([PicContentModel queryTableWhere:[NSString stringWithFormat:@"where href = \"%@\"", url]].count == 0) {

            [contentModel insertTable];
        }
        [weakSelf.lock unlock];


        NSError *error = nil;
        NSURL *baseURL = [NSURL URLWithString:sourceModel.HOST_URL];
        NSString *content = [NSString stringWithContentsOfURL:[NSURL URLWithString:url relativeToURL:baseURL] encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            NSLog(@"%@, 出现错误-1, %@", [NSURL URLWithString:url relativeToURL:baseURL].absoluteString, error);
        } else {
            NSLog(@"%@, 完成", [NSURL URLWithString:url relativeToURL:baseURL].absoluteString);

            NSString *title = [weakSelf dealWithHtmlData:content];
            contentModel.title = title;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            result(sourceModel, contentModel);
        });
    });
}

- (NSString *)dealWithHtmlData:(NSString *)htmlString {
    NSString *title = @"";
    if (htmlString.length > 0) {

        OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:htmlString];

        OCQueryObject *metaEs = document.Query(@"meta");
        for (OCGumboElement *metaEle in metaEs) {
            NSString *name = metaEle.attr(@"name");
            if ([name isEqualToString:@"keywords"]) {
                NSString *content = metaEle.attr(@"content");
                title = content;
                break;
            } else {
                continue;
            }
        }
    }

    return title;
}

- (void)sureToAdd:(UIBarButtonItem *)sender {
    if (self.contentTF.text.length > 0) {
        [self prepareSourceWithUrl:self.contentTF.text title:self.titleTF.text resultHandler:^(PicSourceModel *sourceModel, PicContentModel *contentModel) {
            DetailViewController *detailVC = [[DetailViewController alloc] init];
            detailVC.sourceModel = sourceModel;
            detailVC.contentModel = contentModel;
            [self.navigationController pushViewController:detailVC animated:YES];
        }];
    }
}

- (IBAction)downAction:(id)sender {
    if (self.contentTF.text.length > 0) {
        [self prepareSourceWithUrl:self.contentTF.text title:self.titleTF.text resultHandler:^(PicSourceModel *sourceModel, PicContentModel *contentModel) {
            [ContentParserManager tryToAddTaskWithSourceModel:sourceModel ContentModel:contentModel needDownload:YES operationTips:^(BOOL isSuccess, NSString * _Nonnull tips) {
                [MBProgressHUD showInfoOnView:self.view WithStatus:tips afterDelay:0.5];
            }];
        }];
    }
}

- (IBAction)multiDownAction:(id)sender {

    if (self.multiTextView.text.length > 0) {
        NSString *targetUrls = self.multiTextView.text;
        NSArray *urls = [targetUrls componentsSeparatedByString:@"\n"];
        for (NSString *url in urls) {
            [self prepareSourceWithUrl:url title:@"" resultHandler:^(PicSourceModel *sourceModel, PicContentModel *contentModel) {
                [ContentParserManager tryToAddTaskWithSourceModel:sourceModel ContentModel:contentModel needDownload:YES operationTips:^(BOOL isSuccess, NSString * _Nonnull tips) {
                    [MBProgressHUD showInfoOnView:self.view WithStatus:tips afterDelay:0.5];
                }];
            }];
        }
    }

}

@end
