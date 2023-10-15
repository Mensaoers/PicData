# 为什么会有PPCatalystTool

> iOS开发用的是`UIKit`, Mac端开发用的是`APPKit`

开发`Maccatalyst`时不可避免会有`Mac`代码, `iOS`项目不能直接调用, 通常我们是创建一个`bundle`, 然后把`Mac`代码在`bundle`中实现, 为了方便下次使用, 我们可以简单的写一个小工具, 封装一下执行方法

# 基本步骤

## 新建bundle
创建一个`bundle`(两个方法

1. 单独创建一个`bundle`项目(目前采用1)
2. 在`framework`中快速关联`bundle`, 不用单独打包`bundle`

) 

## Framework开发
`framework`里面主要是封装一下如何执行`bundle`中的方法, 具体看代码

# 项目拆分
目前代码较少, 统一存放在一个仓库中, 后期如果功能丰富, 考虑将`bundle`和`framework`分开两个项目

# 使用(主要就是bundle文件和封装的类)
1. 推荐使用pods
    `pod 'PPCatalystTool'`
2. 将`PPCatalystTool`和`PPCatalystPlugin`目录下的`Products`里面的`xcframework`和`bundle`都拖到项目中
3. 将`bundle`和`PPCatalystTool`中的`PPCatalystHandle`类拖到项目中

> 具体使用参照`Example`代码
