// import '../../constants/enums/network_enums.dart';
import '../network/dio_manager.dart';
import 'cache_manager.dart';

class AuthCacheManager {
  Future<bool> isFirstEntry() async {
    return !(await CacheManager.getBool('introOff') ?? false);
  }

  Future<bool> isLoggedIn() async {
    return (await CacheManager.getBool('login')) ?? false;
  }

  Future<void> savePassword() async {}
  Future<void> signOut() async {
    await CacheManager.setBool('login', false);
    await CacheManager.remove('token');
    await CacheManager.remove('refresh_token');
    // await CacheManager.clearAll();
  }

  Future<void> updateFirstEntry() async {
    await CacheManager.setBool('introOff', true);
  }

  Future<void> updateLoggedIn(bool isLoggedIn) async {
    await CacheManager.setBool('login', isLoggedIn);
  }

  Future<void> setAuth(Map<String, dynamic> data) async {
    await CacheManager.setMap('auth', data);
  }

  Future<Map<String, dynamic>?> getAuth() async {
    return await CacheManager.getMap('auth');
  }

  Future<void> clearAuth() async {
    await CacheManager.remove('auth');
  }

  Future<void> setEmail(String email) async {
    await CacheManager.setString('email', email);
  }

  Future<String?> getEmail() async {
    return await CacheManager.getString('email');
  }

  Future<void> updateToken(String? token, {String? refreshToken}) async {
    if (token != null) {
      await CacheManager.setString('token', token);
      if (refreshToken != null) {
        await CacheManager.setString('refresh_token', refreshToken);
      }

      DioManager.instance.dio.options.headers['Authorization'] =
          'Bearer $token';
      // DioManager.instance.dio.options
      //     .headers[(MapEntry('Authorization', 'token $token'))];

      /// Actually, we will not need it for this application.
      /// But I've included it here for instructive purposes.
    } else {
      if (await CacheManager.containsKey('token')) {
        await CacheManager.remove('token');
        DioManager.instance.dio.options.headers.clear();
      }
    }
  }

  Future<void> updateTokenFromStorage() async {
    if (await CacheManager.containsKey('token')) {
      final token = await CacheManager.getString('token');
      if (token != null) {
        DioManager.instance.dio.options.headers['Authorization'] =
            'Bearer $token';
        // DioManager.instance.dio.options
        //     .headers[(MapEntry('Authorization', 'token $token'))];

        /// Actually, we will not need it for this application.
        /// But I've included it here for instructive purposes.
      }
    }
  }
}
