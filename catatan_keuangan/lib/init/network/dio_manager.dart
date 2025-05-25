import 'package:dio/dio.dart';

class DioManager {
  static DioManager? _instance;

  static DioManager get instance {
    if (_instance != null) return _instance!;
    _instance = DioManager._init();
    return _instance!;
  }

  // final String _baseUrl = 'http://192.168.1.100:3000/';
  final String _baseUrl = 'https://wildcat-vital-broadly.ngrok-free.app/';
  late final Dio dio;

  DioManager._init() {
    dio = Dio(
      BaseOptions(
        connectTimeout: Duration(seconds: 5),
        baseUrl: _baseUrl,
        followRedirects: true,
      ),
    );
  }
}
