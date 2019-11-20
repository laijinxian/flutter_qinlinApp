# flutter app

## Flutter 实际开发常用工具类（全局提示，请求封装，常用窗帘动画及布局）

###### 1. Flutter 是什么？
    Flutter 是 Google 开源的 UI 工具包，帮助开发者通过一套代码库高效构建多平台精美应用，
        支持移动、Web ([early access][])、桌面和嵌入式平台。
    Flutter 旨在帮助开发者创作媲美原生的高性能应用，并遵从了各个平台不同的滚动行为、
        排版布局、图标样式等。
    这是一个名为 Gallery 的示例应用， Gallery 是一个在安装完 Flutter 并配置好环境后可以立即运行的 
        Flutter 示例应用集合。Shrine 有高质量的滚动图片、交互式卡片、按钮、下拉列表以及一个购物车页面。
    开始开发之前无需移动开发经验。应用使用 Dart 开发，如果你曾使用过 Java 或者 JavaScript 语言，
        那么 Dart 看上去会很熟悉。面向对象编程的经验对开发毫无疑问会有帮助，但即便不是程序员也可以制作 Flutter 应用！
###### 2. 为什么使用 Flutter？
    Flutter 的优势是什么？它能够帮你：
    高效率
    在应用运行时尝试修改代码并重载（通过热重载）
    修复崩溃并从应用停止的地方开始继续调试
    利用单一代码库开发 iOS 与 Android 应用
    即便在单一操作系统上，也可以通过使用现代、富有表现力的语言以及声明式方法，写更少代码做更多事
    原型与轻松迭代
    生成美观、高度定制化的用户体验
    受益于用 Flutter 框架构建的丰富的 Material Design 以及 Cupertino （iOS 风格） widget
    实现定制、美观、品牌驱动的设计，不受 OEM widget 集合的限制

##### 学习方法： 基本都是靠谷歌加百度，百度不到换种姿势继续百度，找到为止。但查看文档定也是必不可少的。              我开发常用到文档有： 
 1. [一位大神总结的电子书，常用的Widget布局使用及方法和属性都有](https://book.flutterchina.club/chapter1/mobile_development_intro.html)
 2. [中文文档，也是开发必不可少的](https://flutterchina.club/widgets/basics/)
 3. [Flutter for Web开发者, 从事前端开发入坑flutter必不可少的文档](https://flutterchina.club/web-analogs/)
 4. [flutter demo学习的差不多就照着上面的例子撸一遍，然后就差不多进入实际开发了](https://codelabs.flutter-io.cn/#codelabs)

##### 项目部分功能介绍：
 1.  [下拉刷新，上拉加载 --> flutter_easyrefresh](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/README_EN.md)
 2.  [全局提示，及loading加载 --> bot_toast](https://github.com/MMMzq/bot_toast/blob/master/README_zh.md)
 3.  [列表动画 --> flutter_staggered_animations](https://github.com/mobiten/flutter_staggered_animations)
 4.  [Dio请求封装（请求拦截，接口前缀、token统一添加、请求体格式转换、响应拦截](https://github.com/flutterchina/dio)
 
##### 功能部分组成
![](https://user-gold-cdn.xitu.io/2019/11/20/16e86c98655a16c7?w=200&h=414&f=gif&s=1227969)
![](https://user-gold-cdn.xitu.io/2019/11/20/16e86c9b0054f281?w=200&h=414&f=gif&s=813476)
![](https://user-gold-cdn.xitu.io/2019/11/20/16e86c6f77e0f8da?w=200&h=414&f=gif&s=1192672)
![](https://user-gold-cdn.xitu.io/2019/11/20/16e86c744d847c79?w=200&h=414&f=gif&s=842363)
