import 'dart:async';


import 'DownloadOptions.dart';
import 'Flowder.dart';

bool isDownloading = false;

class DownloadController {
  late StreamSubscription? _inner;
  late final DownloadOptions _options;
  late final String _url;
  bool isCancelled = false;

  DownloadController(StreamSubscription? inner, DownloadOptions options, String url)
      : _inner = inner,
        _options = options,
        _url = url;

  Future<void> pause() async {
    _isActive();
    await _inner?.cancel();
    isDownloading = false;
  }

  Future<void> resume() async {
    _isActive();
    if (isDownloading) return;
    _inner = await Flowder.initDownload(_url, _options);
  }

  Future<void> cancel() async {
    _isActive();
    await _inner?.cancel();
    await _options.downloadPro.resetProgress(_url);
    if (_options.deleteOnCancel) {
      await _options.file?.delete();
    }
    isCancelled = true;
    isDownloading = false;
  }

  void _isActive() {
    if (isCancelled) throw StateError('Already cancelled');
  }

  Future<DownloadController> download(String url, DownloadOptions options) async {
    try {
      final subscription = await Flowder.initDownload(url, options);
      return DownloadController(subscription, options, url);
    } catch (e) {
      rethrow;
    }
  }
}
