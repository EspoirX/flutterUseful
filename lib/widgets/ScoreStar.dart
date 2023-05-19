import 'dart:math';

import 'package:flutter/widgets.dart';

class ScoreStar extends LeafRenderObjectWidget {
  final Color backgroundColor;
  final Color foregroundColor;
  final double score;

  ScoreStar(this.backgroundColor, this.foregroundColor, this.score, {super.key});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderScoreStar(backgroundColor, foregroundColor, score);
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderScoreStar renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..backgroundColor = backgroundColor
      ..foregroundColor = foregroundColor
      ..score = score;
  }
}

class RenderScoreStar extends RenderBox {
  Color _backgroundColor;
  Color _foregroundColor;
  double _score;

  RenderScoreStar(this._backgroundColor, this._foregroundColor, this._score);

  Color get backgroundColor => _backgroundColor;

  set backgroundColor(Color color) {
    _backgroundColor = color;
    markNeedsPaint();
  }

  Color get foregroundColor => _foregroundColor;

  set foregroundColor(Color color) {
    _foregroundColor = color;
    markNeedsPaint();
  }

  double get score => _score;

  set score(double score) {
    _score = score;
    markNeedsPaint();
  }

  @override
  bool get sizedByParent => false;

  @override
  void performLayout() {
    double height = min(constraints.biggest.height, constraints.biggest.width / 5);
    height = max(height, constraints.smallest.height);
    size = Size(constraints.biggest.width, height);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return constraints.biggest.width;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    double height = min(constraints.biggest.height, constraints.biggest.width / 5);
    height = max(height, constraints.smallest.height);
    return height;
  }

  @override
  bool hitTestSelf(Offset position) {
    return true;
  }

  void _backgroundStarPainter(PaintingContext context, Offset offset) {
    _starPainter(context, offset, backgroundColor);
  }

  void _foregroundStarPainter(PaintingContext context, Offset offset) {
    _starPainter(context, offset, foregroundColor);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    _backgroundStarPainter(context, offset);
    context.pushClipRect(
        needsCompositing, offset, Rect.fromLTRB(0, 0, size.width * score / 5, size.height), _foregroundStarPainter);
  }

  void _starPainter(PaintingContext context, Offset offset, Color color) {
    Paint paint = Paint();
    paint.color = color;
    paint.style = PaintingStyle.fill;

    double radius = min(size.height / 2, size.width / (2 * 5));

    Path path = Path();
    _addStarLine(radius, path);
    for (int i = 0; i < 4; i++) {
      path = path.shift(Offset(radius * 2, 0.0));
      _addStarLine(radius, path);
    }

    path = path.shift(offset);
    path.close();

    context.canvas.drawPath(path, paint);
  }

  void _addStarLine(double radius, Path path) {
    double radian = (pi * 36) / 180;

    double sinRadian = sin(radian);
    double sinHalfRadian = sin(radian / 2);

    double cosRadian = cos(radian);
    double cosHalfRadian = cos(radian / 2);

    double innerRadius = (radius * sinHalfRadian / cosRadian);

    path.moveTo((radius * cosHalfRadian), 0.0);
    path.lineTo((radius * cosHalfRadian + innerRadius * sinRadian), (radius - radius * sinHalfRadian));
    path.lineTo((radius * cosHalfRadian * 2), (radius - radius * sinHalfRadian));
    path.lineTo((radius * cosHalfRadian + innerRadius * cosHalfRadian), (radius + innerRadius * sinHalfRadian));
    path.lineTo((radius * cosHalfRadian + radius * sinRadian), (radius + radius * cosRadian));
    path.lineTo((radius * cosHalfRadian), (radius + innerRadius));
    path.lineTo((radius * cosHalfRadian - radius * sinRadian), (radius + radius * cosRadian));
    path.lineTo((radius * cosHalfRadian - innerRadius * cosHalfRadian), (radius + innerRadius * sinHalfRadian));
    path.lineTo(0.0, (radius - radius * sinHalfRadian));
    path.lineTo((radius * cosHalfRadian - innerRadius * sinRadian), (radius - radius * sinHalfRadian));
  }
}
