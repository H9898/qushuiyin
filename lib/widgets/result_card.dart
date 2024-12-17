import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

class ResultCard extends StatefulWidget {
  final String title;
  final String coverUrl;
  final String videoUrl;

  const ResultCard({
    super.key,
    required this.title,
    required this.coverUrl,
    required this.videoUrl,
  });

  @override
  State<ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard> {
  bool _isDownloading = false;
  double _downloadProgress = 0;

  Future<void> _download(String url) async {
    if (_isDownloading) return;

    final status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('需要存储权限来下载文件')),
      );
      return;
    }

    try {
      setState(() {
        _isDownloading = true;
        _downloadProgress = 0;
      });

      String? savePath;
      if (Platform.isAndroid) {
        final dir = await getExternalStorageDirectory();
        if (dir != null) {
          savePath = dir.path;
        }
      } else if (Platform.isIOS) {
        final dir = await getApplicationDocumentsDirectory();
        savePath = dir.path;
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final dir = await getDownloadsDirectory();
        if (dir != null) {
          savePath = dir.path;
        }
      }

      if (savePath == null) {
        throw '无法获取存储目录';
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${widget.title}_$timestamp.mp4';
      final fullPath = '$savePath/$fileName';

      print('开始下载视频...');
      print('保存路径: $fullPath');
      print('视频地址: $url');

      final dio = Dio()
        ..options.headers = {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Accept': '*/*',
          'Accept-Encoding': 'gzip, deflate',
          'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
          'Connection': 'keep-alive',
          'Range': 'bytes=0-',
          'Referer': 'https://www.douyin.com/',
          'Origin': 'https://www.douyin.com',
          'Sec-Fetch-Dest': 'video',
          'Sec-Fetch-Mode': 'cors',
          'Sec-Fetch-Site': 'cross-site',
        }
        ..options.followRedirects = true
        ..options.maxRedirects = 5
        ..options.receiveTimeout = const Duration(minutes: 5)
        ..options.validateStatus = (status) => true;

      print('正在获取视频真实地址...');
      final response = await dio.head(url);
      final realUrl = response.realUri.toString();
      print('视频真实地址: $realUrl');

      await dio.download(
        realUrl,
        fullPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
            print('下载进度: ${(_downloadProgress * 100).toStringAsFixed(1)}%');
          }
        },
        options: Options(
          followRedirects: true,
          maxRedirects: 5,
          receiveTimeout: const Duration(minutes: 5),
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Accept': '*/*',
            'Accept-Encoding': 'gzip, deflate',
            'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
            'Connection': 'keep-alive',
            'Range': 'bytes=0-',
            'Referer': 'https://www.douyin.com/',
            'Origin': 'https://www.douyin.com',
            'Sec-Fetch-Dest': 'video',
            'Sec-Fetch-Mode': 'cors',
            'Sec-Fetch-Site': 'cross-site',
          },
        ),
      );

      print('下载完成！');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('下载完成：$fullPath')),
        );
      }
    } catch (e) {
      print('下载错误: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('下载失败：${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已复制到剪贴板')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '解析结果',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildResultItem(
              context,
              '视频标题',
              widget.title,
              showDownload: false,
            ),
            _buildResultItem(
              context,
              '视频地址',
              widget.videoUrl,
              showDownload: true,
            ),
            if (_isDownloading)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '下载进度: ${(_downloadProgress * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(value: _downloadProgress),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(
    BuildContext context,
    String label,
    String value, {
    bool showDownload = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(color: Colors.blue),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () => _copyToClipboard(context, value),
            ),
            if (showDownload)
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () => _download(value),
              ),
          ],
        ),
        const Divider(),
      ],
    );
  }
}
