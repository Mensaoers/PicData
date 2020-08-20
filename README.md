# PicData(先看, 先看, 先看)

## 介绍
网页图片批量下载

简单的爬取图片网站(暂时只支持一个网站)的图片, 资源内置

可以用电脑运行模拟器, 然后简单的数据都保存在电脑上

后期考虑手机上做个图片预览功能, 但是手机上效果肯定没有电脑上好, 毕竟屏幕差异

## 配置

<span id="jump"></span>
### 本地下载目录配置

点击首页上的设置按钮进行下载目录的设置, 默认是app的`document/PicDownload`目录, 可以设置mac上的地址, 比如`/Users/***/Downloads/PicDownloads`

也可以在`PDDownloadManager.m`的`- (NSString *)defaultDownloadPath`方法中新写一个地址

设置之后, 下载的图片即可保存到这个地址, 按照分类和标题创建文件夹

(注意: 下载之前配置, 下载之前配置, 下载之前配置, 假如下载中配置, 下载到不同的目录下, 找都找不到)

### 资源列表
资源保存在`PicSource.json`里面, 如果想要添加, 照着原有的json格式添加即可, 然后重新运行

注意: 

* PC地址会有很多资源不显示, 访问体验还不如手机端呢
* 而且该平台分移动端资源和pc端区分处理, 本项目只访问移动网站
* sourceType分析: 该平台网页样式有所不同, 出现两个页面标签不一样的情况, 故而设置sourceType字段区分解析方式
* 研究了下`PicSource.json `地址之后猜测, 所有tag标签(形如`https://***/tag/***.html`)sourceType都写2, 最上面的分类写的1, 所以网络分类那块, sourceType我都写的2
* 如果出现网页解析不行了, 试着修改该资源的sourceType并在`ContentViewController.m`的`parserContentListHtmlData`方法中提供新的解析方法

### 运行方式
* 拉取代码最新版, 然后进入到本地目录配置处, 配置mac[下载地址](#jump)
* 然后就是正常的项目运行了, 你可以选择一个模拟器, 然后运行项目
* Finder打开到下载目录, 试着在app内部点击分类项, 弹出各种套图
* 如果喜欢某个套图, 你可以点击旁边的下载按钮, 或者点击套图查看详情页面顶部的下载按钮
* 套图详情页面下方有网页资源提供的推荐, 你一样可以点击跳转, 很方便, 然后继续下载套图
* 下载工具已经很强大了, 但是为了避免不必要的隐患, 建议不要太快添加任务, 注意观察输出日志, 或者下载目录文件变化, 尽量一次下载四个以下套图, 当然你也可以试试挑战下程序性能, 好像点8个也能下, 不过任务会很多, 时间会很长而已, 内存貌似最多200M, 模拟器是iPhone 11 Pro Max

自己研究吧

### 加载失败/解析失败
部分页面会不定时更新页面标签, 导致页面加载失败的情况, 这边建议联系开发者或者自己有能力的话, 自己解析

* 详情页面底部的推荐栏, 是网页资源提供的, 该部分经常容易出现解析不出来的情况, 大体原因是移动端和桌面版资源异常, 部分资源访问不到(移动端页面出现了本该是桌面端才有的资源地址, 不影响使用, 如果实在介意, 解决思路是仿照资源分类, 写一个新的解析方法, 然后处理资源的正确地址, 方才可以显示, 不过本人尝试了一下, 发现仅仅改变网址的host还不行, 待研究)

### 欠缺
* 数据还不够自动化, 假如遇到网页改版, 就可能需要修改代码
* <del>下载目录不能本地配置, 后期考虑设置本地路径, 下载到手机里面或者电脑上的一个目录下</del> 已完成
* 进度查看, 目前还不支持查看进度, 只是xcode输入日志, 后期考虑加上一个全局浮窗, 查看当前任务并刷新进度, 不过单个图片的进度就不显示了, 没必要, 就显示下套图进度好了(数据库写入遇到问题, 没有找到合适的数据库三方, 需要存储套图是否开始, 套图中的图片是否下载完成)
* 详情页面推荐栏显示不出图片
* <del>详情页面不能记住历史, 点击返回就整个导航返回了</del>已经添加上一页功能

说再多不如下载运行一下, xcode版本应该没有限制, 正常即可

# 如有任何问题, 建议联系开发者本人

## 更新日志(也有可能忘了写日志, 将就看看)
```
2020年08月20日13:59:41
添加几个小页面, 貌似调整了下内存问题
```
```
2020年08月02日20:23:36
详情页面添加上一页功能
```
```
2020年07月19日16:08:33
添加设置下载地址的功能, 在模拟器就可以设置了
```
```
2020年07月18日15:25:12 
添加网络分类, 当本地分类满足不了你的时候, 试试网络分类
```
