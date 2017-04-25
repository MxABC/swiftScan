
# iOS 二维码、条形码 Swift 版本


### Objective-c版本: **[LBXScan](https://github.com/MxABC/LBXScan)**



## 介绍
**swift封装系统自带扫码及识别图片功能**
- 扫码界面效果封装
- 二维码和条形码识别及生成
- 相册获取图片后识别（测试效果不好...）

**模仿其他app**
- 模仿QQ扫码界面
- 支付宝扫码框效果
- 微信扫码框效果

**其他设置参数自定义效果**

- 扫码框周围区域背景色可设置
- 扫码框颜色可也设置
- 扫码框4个角的颜色可设置、大小可设置
- 可设置只识别扫码框内的图像区域
- 可设置扫码成功后，获取当前图片
- 根据扫码结果，截取码的部分图像(在模仿qq扫码界面，扫码成功后可看到)
- 动画效果选择:   线条上下移动、网格形式移动、中间线条不移动(一般扫码条形码的效果).




### CocoaPods安装



```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!
pod 'swiftScan', '~> 1.0.9'
```


### 手动安装 
下载后将Source文件夹copy到工程即可


### 版本
#### v1.0.9
swift3.0
#### v1.0.8
修改适应cocoapods安装后，编译报错bug


## 界面效果

(加载速度慢，可刷新网页)

![image](https://github.com/MxABC/swiftScan/blob/master/ScreenShots/page1.jpg)
![image](https://github.com/MxABC/swiftScan/blob/master/ScreenShots/page2.jpg)
![image](https://github.com/MxABC/swiftScan/blob/master/ScreenShots/page3.jpg)
![image](https://github.com/MxABC/swiftScan/blob/master/ScreenShots/page4.jpg)
![image](https://github.com/MxABC/swiftScan/blob/master/ScreenShots/page5.jpg)
![image](https://github.com/MxABC/swiftScan/blob/master/ScreenShots/page6.jpg)
![image](https://github.com/MxABC/swiftScan/blob/master/ScreenShots/page7.jpg)
![image](https://github.com/MxABC/swiftScan/blob/master/ScreenShots/page8.jpg)
![image](https://github.com/MxABC/swiftScan/blob/master/ScreenShots/page9.jpg)
![image](https://github.com/MxABC/swiftScan/blob/master/ScreenShots/page10.jpg)
![image](https://github.com/MxABC/swiftScan/blob/master/ScreenShots/page11.jpg)
