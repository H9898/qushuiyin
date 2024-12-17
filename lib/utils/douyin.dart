import 'dart:math';

class DouyinUtils {
  static final Random _random = Random();

  static const String userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

  static String generateRandomStr(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(_random.nextInt(chars.length)),
      ),
    );
  }

  static String generateTTWID() {
    const chars = '0123456789abcdef';
    final parts = [
      String.fromCharCodes(
        Iterable.generate(
            8, (_) => chars.codeUnitAt(_random.nextInt(chars.length))),
      ),
      String.fromCharCodes(
        Iterable.generate(
            4, (_) => chars.codeUnitAt(_random.nextInt(chars.length))),
      ),
      String.fromCharCodes(
        Iterable.generate(
            4, (_) => chars.codeUnitAt(_random.nextInt(chars.length))),
      ),
      String.fromCharCodes(
        Iterable.generate(
            4, (_) => chars.codeUnitAt(_random.nextInt(chars.length))),
      ),
      String.fromCharCodes(
        Iterable.generate(
            12, (_) => chars.codeUnitAt(_random.nextInt(chars.length))),
      ),
    ];
    return parts.join('-');
  }

  static Map<String, String> getHeaders() {
    final msToken = generateRandomStr(107);
    final ttwid = generateTTWID();
    const odinTt =
        '324fb4ea4a89c0c05827e18a1ed9cf9bf8a17f7705fcc793fec935b637867e2a5a9b8168c885554d029919117a18ba69';
    const csrfToken = 'f61602fc63757ae0e4fd9d6bdcee4810';

    return {
      'User-Agent': userAgent,
      'referer': 'https://www.douyin.com/',
      'accept-encoding': 'identity',
      'Cookie':
          'msToken=$msToken; ttwid=$ttwid; odin_tt=$odinTt; passport_csrf_token=$csrfToken;',
    };
  }

  static String getCookieString() {
    final msToken = generateRandomStr(107);
    final ttwid = generateTTWID();
    const odinTt =
        '324fb4ea4a89c0c05827e18a1ed9cf9bf8a17f7705fcc793fec935b637867e2a5a9b8168c885554d029919117a18ba69';
    const csrfToken = 'f61602fc63757ae0e4fd9d6bdcee4810';

    return 'msToken=$msToken; ttwid=$ttwid; odin_tt=$odinTt; passport_csrf_token=$csrfToken;';
  }
}
