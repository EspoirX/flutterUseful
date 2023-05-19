import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutteruseful/download/DownloadPro.dart';
import 'package:path_provider/path_provider.dart';

typedef ProgressCallback = void Function(int count, int total);
typedef SuccessCallback = void Function(String path);
typedef FailCallback = void Function(int code, String msg);

class DownloadOptions {
  DownloadPro downloadPro = DownloadPro();
  Dio? client;
  File? file;
  String childDir;
  String fileName;
  bool deleteOnCancel;
  SuccessCallback? onSuccess;
  FailCallback? onFail;
  ProgressCallback? progress;

  DownloadOptions({
    this.client,
    required this.childDir,
    required this.fileName,
    this.deleteOnCancel = false,
    this.onSuccess,
    this.onFail,
    this.progress,
  });

  Future<File> getSandboxFile(String child, String name) async {
    var path = await _getSandboxPath(child);
    return File("$path/$name");
  }

  Future<String> _getSandboxPath(String child) async {
    var dir = await getExternalStorageDirectory();
    var path = "${dir?.path}/download";
    var file = Directory(path);
    if (!await file.exists()) {
      file.create();
    }
    file = Directory("$path/$child");
    return file.path;
  }
}
