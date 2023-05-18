import 'package:flutter/widgets.dart';
import 'package:flutteruseful/ext/StringExt.dart';

/// 自适应大小的Container
class WrapText extends StatelessWidget {
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final String? bgColor;
  final Border? border;
  final BorderRadius? radius;
  final AlignmentGeometry alignment;
  final String text;
  final String textColor;
  final double textSize;
  final GestureTapCallback? onTap;
  final Widget? child;

  const WrapText(
      {Key? key,
      this.width,
      this.height,
      this.margin,
      this.padding,
      this.bgColor,
      this.border,
      this.radius,
      this.onTap,
      this.child,
      this.alignment = Alignment.center,
      this.text = "",
      this.textColor = "#000000",
      this.textSize = 14})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          height: height,
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(color: bgColor?.parseColor(), border: border, borderRadius: radius),
          child: Align(
              alignment: alignment,
              child: child ??
                  Text(
                    text,
                    style: TextStyle(color: textColor.parseColor(), fontSize: textSize),
                  )),
        ),
      ),
    );
  }
}
