import 'dart:convert';

class DouyinResult {
  final bool success;
  final String? message;
  final dynamic data;

  DouyinResult({
    required this.success,
    this.message,
    this.data,
  });

  factory DouyinResult.fromJson(Map<String, dynamic> json) {
    print('解析 API 响应: $json');
    return DouyinResult(
      success: json['status'] == 'success',
      message: json['message'],
      data: json['data'],
    );
  }

  VideoInfo? get videoInfo {
    if (data == null) return null;
    try {
      print('处理视频数据类型: ${data.runtimeType}');

      if (data is String) {
        try {
          final jsonData = json.decode(data);
          return VideoInfo.fromJson(jsonData as Map<String, dynamic>);
        } catch (e) {
          print('JSON 解析失败: $e');
          return null;
        }
      }

      if (data is List) {
        print('数据是列表，长度: ${data.length}');
        if (data.isEmpty) return null;
        return VideoInfo.fromJson(data[0] as Map<String, dynamic>);
      }

      if (data is Map<String, dynamic>) {
        print('数据是 Map');
        return VideoInfo.fromJson(data);
      }

      print('未知的数据类型');
      return null;
    } catch (e, stackTrace) {
      print('视频信息解析失败: $e');
      print('堆栈跟踪: $stackTrace');
      print('原始数据: $data');
      return null;
    }
  }
}

class VideoInfo {
  final String title;
  final String cover;
  final String videoUrl;
  final String? desc;
  final String? author;
  final int? likeCount;
  final int? commentCount;
  final int? shareCount;

  VideoInfo({
    required this.title,
    required this.cover,
    required this.videoUrl,
    this.desc,
    this.author,
    this.likeCount,
    this.commentCount,
    this.shareCount,
  });

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    print('正在解析视频信息: $json');

    try {
      if (json.containsKey('item_list') && json['item_list'] is List) {
        final itemList = json['item_list'] as List;
        if (itemList.isNotEmpty) {
          json = itemList[0] as Map<String, dynamic>;
        }
      }

      return VideoInfo(
        title: _getString(json, ['title', 'desc']) ?? '未知标题',
        cover: _getString(json, ['cover', 'thumbnail', 'cover_url']) ?? '',
        videoUrl:
            _getString(json, ['nwm_video_url', 'video_url', 'play_url']) ?? '',
        desc: _getString(json, ['desc', 'description']),
        author: _getNestedString(json, 'author', ['nickname', 'name']),
        likeCount:
            _getNestedInt(json, 'statistics', ['digg_count', 'like_count']),
        commentCount: _getNestedInt(json, 'statistics', 'comment_count'),
        shareCount: _getNestedInt(json, 'statistics', 'share_count'),
      );
    } catch (e, stackTrace) {
      print('VideoInfo 解析错误: $e');
      print('堆栈跟踪: $stackTrace');
      print('JSON 数据: $json');
      rethrow;
    }
  }

  static String? _getString(Map<String, dynamic> json, dynamic keys) {
    if (keys is String) {
      return json[keys]?.toString();
    }
    if (keys is List) {
      for (var key in keys) {
        final value = json[key];
        if (value != null) return value.toString();
      }
    }
    return null;
  }

  static String? _getNestedString(
    Map<String, dynamic> json,
    String topKey,
    dynamic keys,
  ) {
    final nested = json[topKey];
    if (nested is! Map<String, dynamic>) return null;
    return _getString(nested, keys);
  }

  static int? _getNestedInt(
    Map<String, dynamic> json,
    String topKey,
    dynamic keys,
  ) {
    final nested = json[topKey];
    if (nested is! Map<String, dynamic>) return null;
    final strValue = _getString(nested, keys);
    if (strValue == null) return null;
    return int.tryParse(strValue);
  }
}
