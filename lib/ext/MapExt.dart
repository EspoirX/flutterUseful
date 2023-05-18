extension MapExt<K, V> on Map<K, V> {
  V getOrPut(K key, V Function(K value) defaultValue) {
    final value = this[key];
    if (value == null) {
      final answer = defaultValue(key);
      this[key] = answer;
      return answer;
    } else {
      return value;
    }
  }
}
