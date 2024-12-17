import 'package:flutter/material.dart';
import '../widgets/result_card.dart';
import '../widgets/tutorial_card.dart';
import 'package:dio/dio.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  String? videoTitle;
  String? coverUrl;
  String? videoUrl;
  String? authorName;
  bool _isLoading = false;
  String? _error;

  String? _extractDouyinUrl(String rawUrl) {
    final RegExp douyinUrlRegExp = RegExp(
      r'https?://(?:[-\w]+\.)?douyin\.com/\w+/?',
      caseSensitive: false,
    );

    final Match? match = douyinUrlRegExp.firstMatch(rawUrl);
    if (match == null) {
      throw '未找到有效的抖音视频链接';
    }
    return match.group(0);
  }

  String _extractVideoId(String url) {
    final videoIdMatch = RegExp(r'video/(\d+)').firstMatch(url);
    if (videoIdMatch == null) {
      throw '无法提取视频ID';
    }
    return videoIdMatch.group(1)!;
  }

  Dio _createDioInstance() {
    return Dio()
      ..options.headers = {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': '*/*',
        'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
        'Accept-Encoding': 'gzip, deflate',
        'Connection': 'keep-alive',
      }
      ..options.followRedirects = true
      ..options.maxRedirects = 5
      ..options.validateStatus = (status) => true;
  }

  Future<String> _getRedirectUrl(Dio dio, String url) async {
    final response = await dio.get(
      url,
      options: Options(
        followRedirects: true,
        maxRedirects: 5,
        validateStatus: (status) => true,
      ),
    );
    return response.realUri.toString();
  }

  Future<void> _parseVideo() async {
    if (_urlController.text.trim().isEmpty) {
      setState(() => _error = '请输入视频链接');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      videoTitle = null;
      coverUrl = null;
      videoUrl = null;
      authorName = null;
    });

    try {
      final url = _extractDouyinUrl(_urlController.text.trim());
      if (url == null) return;

      print('原始链接: ${_urlController.text.trim()}');
      print('提取的抖音链接: $url');

      final dio = _createDioInstance();

      print('正在获取重定向链接...');
      final finalUrl = await _getRedirectUrl(dio, url);
      print('重定向后的链接: $finalUrl');

      final videoId = _extractVideoId(finalUrl);
      print('提取到的视频ID: $videoId');

      final uidMatch = RegExp(r'user/(\d+)').firstMatch(finalUrl);
      final uid = uidMatch?.group(1);
      print('提取到的用户ID: $uid');

      print('正在请求API...');
      final response = await dio.get(
        'https://apis.jxcxin.cn/api/douyin',
        queryParameters: {
          'url': url,
          'video_id': videoId,
          if (uid != null) 'uid': uid,
        },
        options: Options(
          validateStatus: (status) => true,
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      print('API响应状态码: ${response.statusCode}');
      print('API响应数据: ${response.data}');

      if (response.statusCode != 200) {
        throw '请求失败: HTTP ${response.statusCode}';
      }

      final data = response.data;
      if (data == null) {
        throw 'API返回数据为空';
      }

      if (data['code'] != 200) {
        throw data['msg'] ?? '解析失败: ${data['code']}';
      }

      final videoData = data['data'];
      if (videoData == null) {
        throw '未找到视频数据';
      }

      if (videoData['url'] == null || videoData['url'].toString().isEmpty) {
        throw '无法获取视频地址';
      }

      setState(() {
        videoTitle = videoData['title'] ?? '未知标题';
        coverUrl = videoData['cover'] ?? '';
        videoUrl = videoData['url'] ?? '';
        authorName = videoData['author'] ?? '未知作者';
        _error = null;
      });
    } catch (e) {
      print('解析错误: $e');
      setState(() {
        _error = '视频解析失败: ${e.toString()}';
        videoTitle = null;
        coverUrl = null;
        videoUrl = null;
        authorName = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 16),
            Text('杰杰去水印'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(38),
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.75,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Card(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: const Text('杰杰去水印支持在线抖音去水印，同时支持手机和电脑在线下载无水印视频',
                            style: TextStyle(color: Colors.white, fontSize: 22),
                            textAlign: TextAlign.left),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(30, 60, 1, 40),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _urlController,
                                decoration: const InputDecoration(
                                  hintText: '请输入视频链接',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _parseVideo,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(100, 60),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : const Text('解析'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const TutorialCard(),
                const SizedBox(height: 16),
                if (videoTitle != null && coverUrl != null && videoUrl != null)
                  ResultCard(
                    title: videoTitle!,
                    coverUrl: coverUrl!,
                    videoUrl: videoUrl!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
