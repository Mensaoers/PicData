//
//  HomeViewController.m
//  PicData
//
//  Created by 鹏鹏 on 2021/9/12.
//  Copyright © 2021 garenge. All rights reserved.
//

#import "HomeViewController.h"
#import "ContentViewController.h"

@interface HomeViewController ()

@property (nonatomic, strong) NSString *addressUrl;

@property (nonatomic, strong) UILabel *addressLabel;

@property (nonatomic, strong) PicSourceModel *sourceModel;

@property (nonatomic, strong) UITextField *searchTF;
@property (nonatomic, strong) UIButton *searchBtn;

@end

@implementation HomeViewController

- (PicSourceModel *)sourceModel {
    if (nil == _sourceModel) {
        _sourceModel = [[PicSourceModel alloc] init];
    }
    return _sourceModel;
}

- (NSString *)addressUrl {
    if (nil == _addressUrl) {
        _addressUrl = @"https://v.zflfb.vip:9527/fb.html";
//        _addressUrl = @"https://w12.qqv16.vip:5561/index.html";
    }
    return _addressUrl;
}

- (void)loadNavigationItem {
    self.navigationItem.title = @"地址发布页";

    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新地址" style:UIBarButtonItemStyleDone target:self action:@selector(loadCurrentAddresses)];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)loadMainView {
    [super loadMainView];
    UILabel *addressLabel = [[UILabel alloc] init];
    addressLabel.numberOfLines = 0;
    addressLabel.textColor = [UIColor darkTextColor];
    [self.view addSubview:addressLabel];
    self.addressLabel = addressLabel;

    [addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.top.mas_equalTo(12);
        make.right.mas_equalTo(-12);
    }];

    addressLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toViewDetails)];
    [addressLabel addGestureRecognizer:tap];

    UITextField *searchTF = [[UITextField alloc] init];
    searchTF.font = [UIFont systemFontOfSize:17];
    searchTF.placeholder = @"请输入关键字";
    [self.view addSubview:searchTF];
    self.searchTF = searchTF;

    [searchTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(addressLabel);
        make.top.equalTo(addressLabel.mas_bottom).with.offset(12);
        make.height.mas_equalTo(35);
    }];

    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(searchBtnClickedAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchBtn];
    self.searchBtn = searchBtn;

    [searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(searchTF.mas_right).with.offset(8);
        make.centerY.height.equalTo(searchTF);
        make.right.equalTo(addressLabel);
        make.width.mas_equalTo(70);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadCurrentAddresses];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.searchTF.text = @"";
}

- (void)loadCurrentAddresses {
    MJWeakSelf
    [MBProgressHUD showHUDAddedTo:self.view WithStatus:@"正在获取地址"];
    [PDRequest getWithURL:[NSURL URLWithString:self.addressUrl] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        });

        if (nil == error) {
            NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            // 解析html
            [weakSelf paraseHtmlString_address:htmlString];
        }
    }];
}

- (void)paraseHtmlString_address:(NSString *)htmlString {

    if (htmlString.length == 0) { return; }

    OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:htmlString];

    OCGumboElement *methodDivE = document.QueryClass(@"method").firstObject;
    OCGumboElement *aE = document.QueryClass(@"panel").firstObject;
    if (methodDivE == nil || aE == nil) {
        return;
    }
    NSString *text = methodDivE.QueryElement(@"span").first().text();
    NSString *url = aE.attr(@"href");
    NSString *host = aE.text();

    MJWeakSelf
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.addressLabel.text = [NSString stringWithFormat:@"%@\n%@", text, url];
        [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"已获取最新地址"];
        weakSelf.sourceModel.title = text;
        weakSelf.sourceModel.HOST_URL = host;
        weakSelf.sourceModel.sourceType = 4;
        weakSelf.sourceModel.url = url;
        [weakSelf.sourceModel insertTable];
//        [weakSelf loadIndexData:url];
    });

}

- (void)loadIndexData: (NSString *)address {

    MJWeakSelf
    [PDRequest getWithURL:[NSURL URLWithString:address] isPhone: NO completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (nil == error) {
//            NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *htmlString;
            NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            htmlString = [[NSString alloc] initWithData:data encoding:enc];
            // 解析html
            [weakSelf paraseHtmlString_list:htmlString];
        }
    }];
}

- (NSArray <PicContentModel *>*)paraseHtmlString_list:(NSString *)htmlString {

    if (htmlString.length == 0) { return @[]; }

    OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:htmlString];

    OCQueryObject *articleEs = document.QueryElement(@"article");

    NSMutableArray *articleContents = [NSMutableArray array];
    for (OCGumboElement *articleE in articleEs) {

        OCGumboElement *headerE = articleE.QueryElement(@"header").firstObject;
        NSString *type = headerE.QueryElement(@"a").first().text();
        OCGumboElement *h2E = headerE.QueryElement(@"h2").firstObject;
        OCGumboElement *h2aE = h2E.QueryElement(@"a").firstObject;
        NSString *title = h2aE.text();
        NSString *href = h2aE.attr(@"href");
        NSString *thumbnailUrl = articleE.QueryClass(@"thumb-span").first().QueryElement(@"img").first().attr(@"src");

        PicContentModel *contentModel = [[PicContentModel alloc] init];
        contentModel.href = href;
        contentModel.sourceTitle = self.sourceModel.title;
        contentModel.HOST_URL = self.sourceModel.HOST_URL;
        contentModel.title = title;
        contentModel.thumbnailUrl = thumbnailUrl;
        [articleContents addObject:contentModel];
    }

    NSLog(@"123");
    return [articleContents copy];
}

- (void)toViewDetails {
    ContentViewController *contentVC = [[ContentViewController alloc] initWithSourceModel:self.sourceModel];
    [self.navigationController pushViewController:contentVC animated:YES];
}

- (void)searchBtnClickedAction:(UIButton *)sender {

    [self.view endEditing:YES];

    if (self.searchTF.text.length == 0) {
        [self toViewDetails];
        return;
    }
    MJWeakSelf
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *url = [NSString stringWithFormat:@"https://so.azs2019.com/serch.php?keyword=%@", self.searchTF.text];
    url = [url stringByAddingPercentEscapesUsingEncoding:enc];
    [MBProgressHUD showHUDAddedTo:self.view WithStatus:@"搜索中"];
    [PDRequest getWithURL:[NSURL URLWithString:url] isPhone: NO completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        });
        if (nil == error) {
            //            NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *htmlString;

            htmlString = [[NSString alloc] initWithData:data encoding:enc];
            // 解析html
            NSArray *contentModels = [weakSelf paraseHtmlString_list:htmlString];

            dispatch_async(dispatch_get_main_queue(), ^{
                ContentViewController *contentVC = [[ContentViewController alloc] initWithSourceModel:self.sourceModel];
                contentVC.loadDataBlock = ^NSArray<PicContentModel *> * _Nonnull{
                    return contentModels;
                };
                [weakSelf.navigationController pushViewController:contentVC animated:YES];
            });
        }
    }];
}

@end
