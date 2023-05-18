extension IterableExt<T> on Iterable<T> {

  /// 过滤null元素
  /// final list = [1, null, 2, 3, null];
  /// final filtered = list.filterNotNull();
  /// filtered结果是 1,2,3
  Iterable<T> filterNotNull() {
    return where((e) => e != null).cast();
  }

  /// 查找符合条件的第一个
  /// final list = [1, 3, 5, 2, 7, 10, 20];
  /// list.firstOrNull((e) => e > 30) => null
  /// list.firstOrNull((e) => e > 5) => 7
  /// list.firstOrNull() => 1
  T? firstOrNull([bool Function(T item)? predicate]) {
    predicate ??= (_) => true;
    for (final element in this) {
      if (predicate(element)) return element;
    }
    return null;
  }

  /// 查找符合条件的最后一个
  /// final list = [1, 3, 5, 2, 7, 10, 20];
  /// list.lastOrNull((e) => e > 30) => null
  /// list.lastOrNull((e) => e < 5) => 2
  /// list.lastOrNull() => 20
  T? lastOrNull([bool Function(T)? predicate]) {
    predicate ??= (_) => true;
    T? last;
    for (final element in this) {
      if (predicate(element)) {
        last = element;
      }
    }
    return last;
  }

  ///获取item或null
  T? getOrNull(int index) {
    if (index >= 0 && index < length) {
      return elementAt(index);
    }
    return null;
  }

  ///遍历带 index
  void forEachIndexed(Function(int index, T item) action) {
    var index = 0;
    for (T element in this) {
      action(index++, element);
    }
  }
}
