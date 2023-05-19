import 'package:flutter/material.dart';
import 'package:flutteruseful/ext/StringExt.dart';

class SwitchWidget extends StatefulWidget {
  final String activeCloseColor; //圆形颜色
  final String trackCloseColor; //滑块颜色
  final String activeOpenColor; //圆形颜色
  final String trackOpenColor; //滑块颜色
  final double width;
  final double height;
  final ValueChanged<bool>? onChanged;
  final EdgeInsets? margin;
  bool isOpen;

  SwitchWidget({
    Key? key,
    required this.isOpen,
    this.width = 63,
    this.height = 28,
    this.activeCloseColor = "#CACACA",
    this.trackCloseColor = "#F5F5F5",
    this.activeOpenColor = "#FFFFFF",
    this.trackOpenColor = "#8668FF",
    this.margin,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SwitchWidgetState();
  }
}

class SwitchWidgetState extends State<SwitchWidget> {
  Color _activeColor = "#CACACA".parseColor();
  Color _trackColor = "#F5F5F5".parseColor();
  double _margin = 2.0;

  @override
  Widget build(BuildContext context) {
    var diameter = widget.height - 4;
    _setDefaultValue(false);
    return Container(
      margin: widget.margin,
      child: InkWell(
        onTap: () {
          _setDefaultValue(true);
        },
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                width: widget.width,
                height: widget.height,
                decoration:
                    BoxDecoration(color: _trackColor, borderRadius: const BorderRadius.all(Radius.circular(15))),
                duration: const Duration(milliseconds: 200),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                width: diameter,
                height: diameter,
                margin: EdgeInsets.only(left: _margin),
                decoration:
                    BoxDecoration(color: _activeColor, borderRadius: const BorderRadius.all(Radius.circular(15))),
                duration: const Duration(milliseconds: 200),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _setDefaultValue(bool isRefresh) {
    var diameter = widget.height - 4;
    if (widget.isOpen) {
      _activeColor = widget.activeOpenColor.parseColor();
      _trackColor = widget.trackOpenColor.parseColor();
      _margin = widget.width - diameter - 2.0;
    } else {
      _activeColor = widget.activeCloseColor.parseColor();
      _trackColor = widget.trackCloseColor.parseColor();
      _margin = 2.0;
    }
    if (isRefresh) {
      widget.onChanged!(widget.isOpen);
    }
  }
}
