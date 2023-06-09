# flutterUseful
记录日常开发中flutter相关的东西

## 目录
- [FlutterBoost 相关](#FlutterBoost相关)
  - [使用FlutterBoost由原生第一次打开flutter页面时出现短暂黑屏](#使用FlutterBoost由原生第一次打开flutter页面时出现短暂黑屏)
  - [原生转跳Flutter界面时大概率出现页面卡住问题](#原生转跳Flutter界面时大概率出现页面卡住问题)
- [日常自定义控件](#日常自定义控件)
  - [WrapText](#TagWidget)
  - [TagWidget](#TagWidget)
  - [SwitchWidget](#SwitchWidget)
- [悬浮输入框](#悬浮输入框)
- [Dio相关](#Dio相关)
  - [通过Dio把请求转发到原生端](#通过Dio把请求转发到原生端)
  - [Dio下载封装](#Dio下载封装)
- [自定义Widget相关](#自定义Widget相关)
  - [自定义Widget概述](#自定义Widget概述)
  - [一般开发步骤](#一般开发步骤)
  - [方法介绍](#方法介绍)
  - [MultiChildRenderObjectWidget](#MultiChildRenderObjectWidget)

## FlutterBoost相关
### 使用FlutterBoost由原生第一次打开flutter页面时出现短暂黑屏
解决方法：  
继承 FlutterBoostActivity ，重写 provideSplashScreen 方法。
```kotlin
class MyFlutterBoostActivity : FlutterBoostActivity() {
    override fun provideSplashScreen(): SplashScreen? {
        return ASplashScreen()
    }
}

class ASplashScreen : SplashScreen {
    var splashView: View? = null

    override fun createSplashView(context: Context, savedInstanceState: Bundle?): View? {
        splashView = LayoutInflater.from(context).inflate(R.layout.view_splash, null)
        return splashView
    }

    override fun transitionToFlutter(onTransitionComplete: Runnable) {
        splashView?.visibility = View.GONE
    }
}
```
```xml
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:background="@color/white"
    android:layout_height="match_parent">
</FrameLayout>
```
这样，第一次打开时就会显示白色界面，不会显示黑屏.

### 原生转跳Flutter界面时大概率出现页面卡住问题
解决方法：   
在 main.dart 中重写 WidgetsFlutterBinding
```dart
class CustomFlutterBinding extends WidgetsFlutterBinding with BoostFlutterBinding {
  bool _appLifecycleStateLocked = true;

  @override
  void initInstances() {
    super.initInstances();
    changeAppLifecycleState(AppLifecycleState.resumed);
  }

  @override
  void handleAppLifecycleStateChanged(AppLifecycleState state) {
    if (_appLifecycleStateLocked) {
      return;
    }
    super.handleAppLifecycleStateChanged(state);
  }

  @override
  void changeAppLifecycleState(AppLifecycleState state) {
    if (SchedulerBinding.instance.lifecycleState == state) {
      return;
    }
    _appLifecycleStateLocked = false;
    handleAppLifecycleStateChanged(state);
    _appLifecycleStateLocked = true;
  }
}
```
然后在 main 方法中调用一下
```dart
void main() {
  CustomFlutterBinding();
  runApp(const MyApp());
}
```
问题原因和方案来自：https://www.6hu.cc/archives/92444.html 简单来说就是生命周期问题

## 日常自定义控件

###  WrapText
开发中经常用到的效果就是 **一个文本，然后可以设置背景，边框圆角等等** 比如按钮什么的。通常就使用 Container 搭配 Text  
但是Container默认宽度是全屏，我只想让他自适应宽度，那么可以在外包一层 UnconstrainedBox
```dart
UnconstrainedBox(
  child: Container(
    child: Text(),
  )
);
```
那么包装一下就成了 [WrapText](https://github.com/EspoirX/flutterUseful/blob/main/lib/widgets/WrapText.dart)
```dart
  const WrapText(
    {Key? key,
    this.width,   //宽度，不填就自适应
    this.height,  //高度，不填就自适应
    this.margin,
    this.padding,
    this.bgColor, //背景色
    this.border,  //边框
    this.radius,  //圆角
    this.onTap,   //点击事件
    this.child,   //除了默认 Text 外，还可以自定义 child
    this.alignment = Alignment.center, //child的对齐方式
    this.text = "",  //文本
    this.textColor = "#000000", //文本颜色
    this.textSize = 14 //文本大小
    })  : super(key: key); 
```
可以轻松实现如下效果：
<img src="https://s2.loli.net/2023/05/19/UHbatM4GhWj2JLn.png" />

### TagWidget
Tag 控件的使用很常见，找了一些开源库，发现都写的挺复杂，其实我只想要基本的 tag 加上可以单选多选等功能就行，如果你也
只是要这些，不妨试试 [TagWidget](https://github.com/EspoirX/flutterUseful/blob/main/lib/widgets/TagWidget.dart)

为了将单选多选等封装进去，TagWidget要使用固定的 Bean TagInfo：
```dart
class TagInfo {
  final String title; //文案
  dynamic customData; //自定义内容
  int index = 0;      //下标
  bool isSelect = false; //是否选中
  TagInfo(this.title, {this.isSelect = false});
}
```
既然上面我们已经有了 WrapText，那么只要用 Wrap 包住它，tab 功能就实现了。  
基本思路就是传入一个数据 List，然后根据 List 循环实现 children，然后传给 Wrap。
可以轻松实现如下效果：
<img src="https://s2.loli.net/2023/05/19/SsGFZpmN8624X3e.png" />

### SwitchWidget
开关效果虽然有现成的控件，但是它不能自定义效果，找了开源库发现他们都是复制一份系统的然后自己修改，但是太复杂了，我看不懂，所以只能自己搞。  
如果你不需要滑动，只需要点击来控制开关的话，可以试试  [SwitchWidget](https://github.com/EspoirX/flutterUseful/blob/main/lib/widgets/SwitchWidget.dart)  
思路就是用 Stack 来包住 2 个 Widget，一个是底部滑块，一个是圆形按钮，然后通过 margin 控制按钮位置，再加上 AnimatedContainer 给点动画  
可以轻松实现如下效果：  
<img src="https://s2.loli.net/2023/05/19/Gcz8L1wtYjhvC2X.png" />


## 悬浮输入框
下面这个效果如何实现，是弹窗？是控制显示隐藏？：  
<img src="https://s2.loli.net/2023/05/19/ydNuGM6CEI9kDhJ.png" height=250 />

刚接触确实有点懵逼，但找了很久在一简书上找到了方法，链接忘了，所以这里记一下:  
思路是打开一个新的页面，但是这个页面的打开方式是通过 **PopupRoute**  
首先继承 PopupRoute 实现一些自定义效果，比如动画等，当然你也可以直接用：
```dart
class PopRoute extends PopupRoute {
  final Duration _duration = const Duration(milliseconds: 300);
  Widget child;
  PopRoute({required this.child});
  @override
  Color? get barrierColor => null;
  @override
  bool get barrierDismissible => true;
  @override
  String? get barrierLabel => null;
  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return child;
  }
  @override
  Duration get transitionDuration => _duration;
}
```

然后你自己写一个 StatefulWidget 实现好 UI 内容，注意的是，弹窗底部半透明背景也是需要自己实现的：
```dart
@override
Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0x99000000),
      body: Column(),
    );
}
```
然后通过 PopupRoute 显示出来即可：
```dart
Navigator.push(context, PopRoute(child: EditInputBottomWidget()));
```

## Dio相关
### 通过Dio把请求转发到原生端
Dio 里面有个 HttpClientAdapter，默认实现貌似是 IOHttpClientAdapter ，通过自定义实现它，即可实现请求转发：
```dart
class NativeRequestClientAdapter implements HttpClientAdapter {
  //...
  @override
  Future<ResponseBody> fetch(
      RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    Map params = {};
    params["requestUrl"] = options.path;
    params["requestType"] = options.method;
    params["params"] = options.queryParameters;
    final Map nativeResponse = await FlutterHydra().invokeMethod('sendHttpRequest', params);
    String resultJson = nativeResponse["resultJson"] ?? "{}";
    int statusCode = nativeResponse["statusCode"] ?? "-1";
    String statusMessage = nativeResponse["statusMessage"] ?? "statusMessage is null";
    return ResponseBody.fromString(resultJson, statusCode, statusMessage: statusMessage);
  }
  //...
}
```
实现 HttpClientAdapter 主要是实现 fetch 方法，在 RequestOptions 里面可以拿到请求url，
请求类型（get,post），请求参数等等  
然后就是通过 **MethodChannel** 和原生沟通了，然后得到请求结果。  
fetch 需要返回一个 ResponseBody 对象，刚好它提供了一个 fromString 方法，所以通过 ResponseBody.fromString 包装
一下结果就行。

然后就可以正常使用了：
```dart
Future<Response> get(String url, Map<String, dynamic>? queryParameters) async {
    Response response = await _dio.get(url, queryParameters: queryParameters);
    return response;
}

Future<Response> post(String url, Map<String, dynamic>? queryParameters) async {
    Response response = await _dio.post(url, queryParameters: queryParameters);
    return response;
}
```
请求结果都在 Response 里面。

**ResponseBody注意点**  
值得注意的是 ResponseBody 的 statusCode 不能够乱传，在初始化 Dio 时，如果你没自定义 BaseOptions，
内部会默认 new 一个，  
然后 BaseOptions 继承 _RequestConfig，在 _RequestConfig 里面，对于参数 validateStatus 有个默认实现：
```dart
this.validateStatus = validateStatus ??
    (int? status) {
      return status != null && status >= 200 && status < 300;
    };
```
意思是如果你的 statusCode 不在这个范围内，会认为是请求失败，抛出 DioError 异常  
如果你的请求是 0 代表成功的话，就需要自己实现一下 validateStatus 了：
```dart
  _dio = Dio(BaseOptions(validateStatus: (int? status) {
      return status != null && status >= 0; //认为大于0就成功，否则会抛 DioError
    }));
```


**除了 get，post 这些基本请求，如果我要发起 RPC 请求怎么封装？**  
dio 的 post，get等请求最后都会调用 request 方法：
```dart
  Future<Response<T>> request<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });
```
然后你会发现请求什么类型都是 Options 参数控制的，那么我们就可以自己搞一个：
```dart
  Future<Response<T>> _rpcRequest<T>(
    Map<String, dynamic>? queryParameters, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return _dio.request<T>(
      "",
      data: data,
      queryParameters: queryParameters,
      options: checkOptions('RPC', options),
      onReceiveProgress: onReceiveProgress,
      cancelToken: cancelToken,
    );
  }

  static Options checkOptions(String method, Options? options) {
    options ??= Options();
    options.method = method;
    return options;
  }
```

然后在 HttpClientAdapter 中，通过判断 options.method == "RPC" 去执行 RPC 相关操作就可以。    
随便一提，在和原生沟通的过程中 rpc 请求结果不能直接传对象，要传 byte（对于代码来说就是 dynamic 类型），
然后在接受后再组装成对象。

### Dio下载封装
找了个开源库 [flowder](https://github.com/Crdzbird/flowder)  ，感觉还行，然后自己修改了一下变得更好用，得到新的下载框架
[Flowder](https://github.com/EspoirX/flutterUseful/blob/main/lib/download/Flowder.dart)  
用法如下：
```dart
Flowder.download(
    "url",
    DownloadOptions(childDir: "img", fileName: "1.jpg")
      ..progress = (current, total) {
         //...
      }
      ..onSuccess = (path) {
        //...
      }
      ..onFail = (code, msg) {
        //...
      });
```
默认的下载路径是沙盒路径，保存路径是 沙盒/childDir/fileName  
所以只需要传入下载url，childDir 和 fileName 即可。如果要自定义路径，则传入参数 file，file随你定路径。  
下载多个文件可在 for 循环里面调用


## 自定义Widget相关

<img src="https://s2.loli.net/2023/05/19/GYxKpOFJubvd5aQ.png" />

### 自定义Widget概述
**Widget 三大类**  
1. 作为『 Widget Tree 』的叶节点，也是最小的 UI 表达单元，一般继承自 LeafRenderObjectWidget；  
2. 有一个子节点 ( Single Child )，一般继承自 SingleChildRenderObjectWidget；  
3. 有多个子节点 ( Multi Child )，一般继承自 MultiChildRenderObjectWidget。  

对于RenderBox系列来说，如果要自定义子类，根据自定义子类子节点模型的不同需要有不同的处理：

1. 自定义子类本身是『 Render Tree 』的叶子节点，一般直接继承自 **RenderBox**

2. 有一个子节点 (Single Child)，且子节点属于RenderBox系列：  
- 如果其自身的 size 完全 匹配 子节点的 size，则可以选择继承自RenderProxyBox(如：RenderOffstage)
- 如果其自身的 size 大于子节点的 size，则可以选择继承自RenderShiftedBox(如：RenderPadding)

3. 有一个子节点 (Single Child)，但子节点不属于RenderBox系列，自定义子类可以 with RenderObjectWithChildMixin，其提供了管理一个子节点的模型 

4. 有多个子节点 (Multi Child)，自定义子类可以 with ContainerRenderObjectMixin、RenderBoxContainerDefaultsMixin，前者提供了管理多个子节点的模型，后者提供了基于ContainerRenderObjectMixin的一些默认实现

自定义 Widget 就是重写 createRenderObject 方法。

### 一般开发步骤
1. 根据需要继承对应的 ObjectWidget 并重写 createRenderObject 方法
```dart
class ScoreStar extends LeafRenderObjectWidget {
  final Color backgroundColor;
  final Color foregroundColor;
  final double score;

  ScoreStar(this.backgroundColor, this.foregroundColor, this.score, {super.key});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderScoreStar(backgroundColor, foregroundColor, score);
  }
}
```

2. 继承 RenderObject , 一般会继承 RenderBox 作为 createRenderObject 方法的返回，同时传参进去
```dart
class RenderScoreStar extends RenderBox {}
```

3. 根据参数编写 get set 方法，并调用 markNeedsPaint
```dart
class RenderScoreStar extends RenderBox {
  Color _backgroundColor;
  //...
  RenderScoreStar(this._backgroundColor, this._foregroundColor, this._score);

  Color get backgroundColor => _backgroundColor;
  set backgroundColor(Color color) {
    _backgroundColor = color;
    markNeedsLayout();
  }
  //...
}
```
如果 不需要引起 layout 变化，则调用 markNeedsPaint，会引起 re-paint ，否则调用 markNeedsLayout

4. 重写 updateRenderObject 方法更新参数，其中参数 renderObject 改成自定义 RenderBox 的类型
```dart
  @override
  void updateRenderObject(BuildContext context, covariant RenderScoreStar renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..backgroundColor = backgroundColor
      ..foregroundColor = foregroundColor
      ..score = score;
  }
```

### 方法介绍

**sizedByParent**  
```dart
@override
  bool get sizedByParent => super.sizedByParent;
```

如果 RenderBox 的 size 完全由约束决定，则不需要重写（默认false），  
如果返回 true，则需求重写 **performResize** 方法来计算 size。  

但一般不会直接重写 performResize，而是重写 **computeDryLayout** 方法。  
因为 RenderBox 的 performResize 方法会调用 computeDryLayout ，并将返回结果作为当前组件的大小。
按照Flutter 框架约定，我们应该重写computeDryLayout 方法而不是 performResize 方法

若 sizedByParent 设为 false，则需要重写 performLayout，并在该方法中完成 size 的计算


**performLayout**  

若重写了performLayout方法，则进而需要重写以下四个方法：  
1. computeMaxIntrinsicWidth  用于计算一个**最小宽度**，在最终 size.width 超过该宽度时，也不会减少 size.height
2. computeMinIntrinsicWidth  排版需要的最小宽度，若小于这个宽度内容就会被裁剪；
3. computeMinIntrinsicHeight  //差不多
4. computeMaxIntrinsicHeight  //差不多

在一些特殊 RenderObject 排版时才会用到这些方法。其他根据 constraints 简单计算一下就行。

```dart
  @override
  double computeMaxIntrinsicWidth(double height) {
    return constraints.biggest.width;
  }
```

**hitTestSelf**  

如果需要响应用户事件，则需要重写 hitTestSelf 方法，并返回 true。
```dart
@override
bool hitTestSelf(Offset position) {
  return true;
}
```

### MultiChildRenderObjectWidget
ParentData 是在 layout 时使用的辅助定位信息。  
对于含有子节点的 RenderObject，一般都需要自定义自己的 ParentData 子类，用于辅助 layout。
```dart
class RichScoreParentData extends ContainerBoxParentData<RenderBox> {
  double scoreTextWidth;
}
```
继承 ContainerBoxParentData ，里面添加自己需要的字段.

实现 MultiChildRenderObjectWidget 时一般需要 with ContainerRenderObjectMixin 和 RenderBoxContainerDefaultsMixin
```dart
class RenderRichScore extends RenderBox with ContainerRenderObjectMixin<RenderBox, RichScoreParentData>,
    RenderBoxContainerDefaultsMixin<RenderBox, RichScoreParentData>,
    DebugOverflowIndicatorMixin {
  
}
```

MultiChildRenderObjectWidget 是有多个节点的，一般参数会有个 List<Widget> children，即 List<RenderBox> children  
在构造函数中，要调用 addAll 添加 children
```dart
  RenderRichScore({
    List<RenderBox> children,
  }) {
    addAll(children);
  }
```

之前自定义了 ContainerBoxParentData ，这时候一般需要重写 setupParentData 方法，为子节点设置 ParentData；
```dart
 @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! RichScoreParentData) {
      child.parentData = RichScoreParentData();
    }
  }
```

需要重写 computeDistanceToActualBaseline 计算 Baseline
```dart
  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToFirstActualBaseline(baseline);
  }
```