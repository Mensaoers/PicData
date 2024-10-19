# 发布podspec常用步骤

## 常规教程
[https://www.jianshu.com/p/a832740aa491](https://www.jianshu.com/p/a832740aa491)

## 验证podspec
#### 1. 本地验证
> pod lib lint --allow-warnings --verbose --no-clean

#### 2. 在线验证
> pod spec lint PicDataSDK.podspec --allow-warnings --use-libraries --verbose

## 发布到trunk 推送spec文件
> pod trunk push PicDataSDK.podspec --allow-warnings --verbose

## 或创建私有库spec
github新建仓库用于放置专门的私有库spec

* 如果要发布, 不要用上面的发布到trunk, 用

> pod repo push pengpengSpecs PicDataSDK.podspec --allow-warnings

* 或者不发布, SDK仓库只需要正常提交代码, 打tag, 然后更新pengpengSpecs.git, 更新最新的podspec

## 检测
有些时候你发布完成后pod search发现什么也没有，这并不一定表示你的项目没有上传成功，有可能会有延时。可以进行下面的操作进行尝试：

* pod setup : 初始化
* pod repo update : 更新仓库
* pod search PicDataSDK

## 删除提交的库
[组件化cocoapods仓库删除（填坑）](https://blog.csdn.net/u014651417/article/details/121990318)

> pod trunk delete 版本号


## 可能用到
    spec.user_target_xcconfig = {
            'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
        }
    
    spec.pod_target_xcconfig = {
        'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
    }


# 使用

## search
pod search PicDataSDK

## Podfile
在Podfile前面用source指定三方地址如

```
source 'https://github.com/Garenge/pengpengSpecs.git'
source 'https://github.com/CocoaPods/Specs.git'
```
这就表示, PicDataSDK去pengpengSpecs.git查找, 剩下的库去CocoaPods查找. 

### 示例
```
platform :ios, '9.0'

source 'https://github.com/Garenge/pengpengSpecs.git'
source 'https://github.com/CocoaPods/Specs.git'

target 'Example' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Example
  # pod 'PicDataSDK'#, :path => '../'
  pod 'PicDataSDK'

end
```

好处: 

1. 别人搜不到你的库, 保护了隐私
2. cocoapods发布需要时间同步
3. 解决了验证不通过等问题

<!--### 更新索引
> 先添加
pod repo add PicDataSDKFramework https://github.com/Garenge/PicDataSDKFramework.git

> 将版本信息库的更新推送到索引库的远端
pod repo push PicDataSDK PicDataSDK.podspec --allow-warnings --verbose-->
