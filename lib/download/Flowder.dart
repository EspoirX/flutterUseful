import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'DownloadController.dart';
import 'DownloadOptions.dart';

/// 下载文件
class Flowder {
  static Future<DownloadController> download(String url, DownloadOptions options) async {
    try {
      final subscription = await initDownload(url, options);
      return DownloadController(subscription, options, url);
    } catch (e) {
      rethrow;
    }
  }

  static Future<StreamSubscription?> initDownload(String url, DownloadOptions options) async {
    var lastProgress = await options.downloadPro.getProgress(url);
    final client = options.client ?? Dio(BaseOptions(sendTimeout: const Duration(seconds: 60)));
    StreamSubscription? subscription;
    try {
      isDownloading = true;
      var file = options.file ?? await options.getSandboxFile(options.childDir, options.fileName);
      if (await file.exists()) {
        String path = file.path;
        options.onSuccess?.call(path);
        return null;
      }
      options.file = file;
      file = await file.create(recursive: true);
      final response = await client.get(
        url,
        options: Options(responseType: ResponseType.stream, headers: {HttpHeaders.rangeHeader: 'bytes=$lastProgress-'}),
      );
      final total = int.tryParse(response.headers.value(HttpHeaders.contentLengthHeader)!) ?? 0;
      final sink = await file.open(mode: FileMode.writeOnlyAppend);
      subscription = response.data.stream.listen(
        (Uint8List data) async {
          subscription?.pause();
          await sink.writeFrom(data);
          final currentProgress = lastProgress + data.length;
          await options.downloadPro.setProgress(url, currentProgress.toInt());
          options.progress?.call(currentProgress, total);
          lastProgress = currentProgress;
          subscription?.resume();
        },
        onDone: () async {
          String path = file.path;
          options.onSuccess?.call(path);
          await sink.close();
          client.close();
        },
        onError: (error) async {
          subscription?.pause();
          options.onFail?.call(-1, error);
        },
      );
      return subscription;
    } catch (e) {
      options.onFail?.call(-1, e.toString());
    }
    return null;
  }
}
