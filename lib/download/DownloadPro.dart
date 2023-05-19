class DownloadPro {
  final Map<String, int> _inner = {};

  Future<int> getProgress(String url) async {
    return _inner[url] ?? 0;
  }

  Future<void> setProgress(String url, int received) async {
    _inner[url] = received;
  }

  Future<void> resetProgress(String url) async {
    await setProgress(url, 0);
  }
}
