import 'package:flutter/material.dart';
import 'package:flutteruseful/widgets/WrapText.dart';
import 'package:flutteruseful/ext/StringExt.dart';

/// tag 布局
class TagWidget extends StatefulWidget {
  final TagWidgetBuilder? itemChildBuilder;
  final Widget? addChild;
  final List<String>? itemBgColor;
  final List<String>? itemFontColor;
  final List<String>? itemBorderColor;
  final Border? itemBorder;
  final double? itemWidth;
  final double? itemBorderWidth;
  final double itemHeight;
  final double? itemFontSize;
  final double? itemRadiusSize;
  final BorderRadius? itemRadius;
  final EdgeInsetsGeometry? itemMargin;
  final EdgeInsetsGeometry? itemPadding;
  final bool isRadio; //是否单选
  final List<TagInfo> list;
  final OnTagWidgetTap? onTap;
  final AlignmentGeometry itemAlignment;
  final OnTagClickEnable? onTagClickEnable;

  const TagWidget(
      {Key? key,
      required this.itemHeight,
      required this.list,
      this.itemChildBuilder,
      this.addChild,
      this.itemBgColor,
      this.itemFontColor,
      this.itemBorderColor,
      this.itemWidth,
      this.itemFontSize,
      this.isRadio = false,
      this.itemMargin,
      this.itemPadding,
      this.onTap,
      this.itemBorder,
      this.itemBorderWidth,
      this.itemRadius,
      this.itemRadiusSize,
      this.itemAlignment = Alignment.center,
      this.onTagClickEnable})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => TagWidgetState();
}

class TagWidgetState extends State<TagWidget> {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if (widget.addChild != null) {
      children.add(widget.addChild!);
    }
    for (var i = 0; i < widget.list.length; i++) {
      var info = widget.list[i];
      info.index = i;
      children.add(_buildItem(context, info, i));
    }
    return Wrap(children: children);
  }

  Widget _buildItem(BuildContext context, TagInfo info, int index) {
    String? itemBgColor;
    if (widget.itemBgColor != null && widget.itemBgColor!.isNotEmpty) {
      itemBgColor = widget.itemBgColor![0];
      if (widget.itemBgColor!.length > 1) {
        itemBgColor = info.isSelect ? widget.itemBgColor![1] : widget.itemBgColor![0];
      }
    }
    String? itemFontColor;
    if (widget.itemFontColor != null && widget.itemFontColor!.isNotEmpty) {
      itemFontColor = widget.itemFontColor![0];
      if (widget.itemFontColor!.length > 1) {
        itemFontColor = info.isSelect ? widget.itemFontColor![1] : widget.itemFontColor![0];
      }
    }
    String? itemBorderColor;
    if (widget.itemBorderColor != null && widget.itemBorderColor!.isNotEmpty) {
      itemBorderColor = widget.itemBorderColor![0];
      if (widget.itemBorderColor!.length > 1) {
        itemBorderColor = info.isSelect ? widget.itemBorderColor![1] : widget.itemBorderColor![0];
      }
    }
    final buildConfig = ItemBuildConfig(info, index, widget.itemFontColor, widget.itemFontSize);
    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) {
          var canClick = true;
          if (widget.onTagClickEnable != null) {
            canClick = widget.onTagClickEnable?.call(info) == true;
          }
          if (!canClick) {
            return;
          }
          setState(() {
            if (widget.isRadio) {
              for (var i = 0; i < widget.list.length; i++) {
                if (info.index == i) {
                  info.isSelect = info.isSelect ? false : true;
                } else {
                  widget.list[i].isSelect = false;
                }
              }
            } else {
              info.isSelect = info.isSelect ? false : true;
            }
            widget.onTap!(info);
          });
        }
      },
      child: WrapText(
        height: widget.itemHeight,
        alignment: widget.itemAlignment,
        text: info.title,
        bgColor: itemBgColor,
        textColor: itemFontColor ?? "#000000",
        textSize: widget.itemFontSize ?? 14,
        padding: widget.itemPadding,
        margin: widget.itemMargin,
        radius: widget.itemRadius ?? BorderRadius.all(Radius.circular(widget.itemRadiusSize ?? 0)),
        border:
            widget.itemBorder ?? Border.all(color: itemBorderColor?.parseColor(), width: widget.itemBorderWidth ?? 0),
        child: widget.itemChildBuilder?.call(context, buildConfig),
      ),
    );
  }
}

class TagInfo {
  final String title;

  dynamic customData;
  int index = 0;
  bool isSelect = false;

  TagInfo(this.title, {this.isSelect = false});

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TagInfo && runtimeType == other.runtimeType && title == other.title;

  @override
  int get hashCode => title.hashCode;
}

class ItemBuildConfig {
  final TagInfo info;
  final int index;
  final List<String>? itemFontColor;
  final double? itemFontSize;

  ItemBuildConfig(this.info, this.index, this.itemFontColor, this.itemFontSize);
}

typedef OnTagWidgetTap = void Function(TagInfo info);
typedef TagWidgetBuilder = Widget? Function(BuildContext context, ItemBuildConfig config);
typedef OnTagClickEnable = bool? Function(TagInfo info);
