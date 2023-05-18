extension ObjExt<T> on T {
  ///```
  /// String? name;
  /// name?.let((it) => showToast(it));
  /// ```
  /// name 为null时，不会执行showToast，不为空时才会执行
  ///
  R let<R>(R Function(T it) block) {
    return block(this);
  }

  void run(void Function(T it) block) {
    block(this);
  }

  /// TalentInfo talent = TalentInfo.create().apply((it){
  ///   it.talentId = info.talentId;
  /// });
  T apply(void Function(T it) block) {
    block(this);
    return this;
  }

  ///```
  /// String name = "";
  /// String age = "";
  /// name = "123".also((it) => age = it);
  /// showToast(age);
  /// ```
  /// age 为 123
  ///
  T also(dynamic Function(T it) block) {
    block(this);
    return this;
  }

  ///```
  ///   final x = a < b ? a : a == b ? 0 : b;
  ///   final x = iff(a < b, () {
  ///     return a;
  ///   }).elseIf(a == b, () {
  ///     return 0;
  ///   }).orElse(() {
  ///     return b;
  ///   });
  /// ```
  T? iff<T>(bool statement, T Function() branch) {
    if (statement) {
      return branch();
    }
    return null;
  }

  T? elseIf(bool statement, T Function() branch) {
    return this ?? iff(statement, branch);
  }

  T orElse(T Function() branch) {
    return this ?? branch();
  }

  ///```
  /// final number = Random().nextInt(10);
  /// final evenOrNull = number.takeIf((it) => it % 2 == 0);
  /// print('even: $evenOrNull');
  ///```
  T? takeIf(bool Function(T it) block) {
    if (this != null && block(this!)) {
      return this;
    }
    return null;
  }

  ///```
  /// final number = Random().nextInt(10);
  /// final oddOrNull = number.takeUnless((it) => it % 2 == 0);
  /// print('odd: $oddOrNull');
  /// ```
  T? takeUnless(bool Function(T it) block) {
    if (this != null && !block(this!)) {
      return this;
    }
    return null;
  }
}

typedef WhenCheck = bool Function<T>(T value);

///
/// ```dart
/// when(x, {
///   1: () => print('x == 1'),
///   2: () => print('x == 2'),
/// }).orElse(() => print('x is neither 1 nor 2'));
/// ```
///
/// ```dart
/// when(x, {
///   [0, 1]: () => print('x == 0 or x == 1'),
/// }).orElse(() => print('otherwise'));
/// ```
///
/// ```dart
/// when(x, {
///   int.parse(s): () => print('s encodes x'),
/// }).orElse(() => print('s does not encode x'));
/// ```
///
/// ```dart
/// when(x, {
///   isIn(range(0, to: 10)): () => print('x is in the range'),
///   isIn(validNumbers): () => print('x is valid'),
///   isNotIn(range(10, to: 20)): () => print('x is outside the range'),
/// }).orElse(() => print('none of the above'));
/// ```
///
/// ```dart
/// bool hasPrefix(dynamic x) {
///   return when(x, {
///     isType<String>(): () => x.startsWith('prefix'),
///   }).orElse(() => false);
/// }
/// ```
V? when<T, V>(T value, Map<T, V Function()> branches) {
  assert(branches.isNotEmpty);

  for (var key in branches.keys) {
    if ((key == value) || (key is List && key.contains(value)) || (key is WhenCheck && key(value))) {
      final branch = branches[key];
      if (branch != null) {
        return branch();
      }
    }
  }
  return null;
}

WhenCheck isIn<T>(Iterable<T> list) => <T>(value) => list.contains(value);

WhenCheck isNotIn<T>(Iterable<T> list) => <T>(value) => !list.contains(value);

WhenCheck isType<V>() => <T>(value) => value is V;

WhenCheck isNotType<V>() => <T>(value) => value is! V;
