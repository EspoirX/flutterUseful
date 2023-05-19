# flutterUseful
记录日常开发中flutter相关的东西

## FlutterBoost 相关
1. **使用 FlutterBoost 由原生第一次打开 flutter 页面时，会出现短暂黑屏**  
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

2. **原生转跳 Flutter 界面时大概率出现页面卡住问题**  
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

1. WrapText
开发中经常用到的效果就是 **一个文本，然后可以设置背景，边框圆角等等** 比如按钮什么的。通常就使用 Container 搭配 Text  
但是Container默认宽度是全屏，我只想让他自适应宽度，那么可以在外包一层 UnconstrainedBox
```dart
UnconstrainedBox(
  child: Container(
    child: Text(),
  )
);
```
那么包装一下就成了 WrapText
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
