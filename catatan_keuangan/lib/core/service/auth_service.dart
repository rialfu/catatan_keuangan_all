import 'dart:io';

import 'package:catatan_keuangan/core/model/login_sso_model.dart';
import 'package:catatan_keuangan/customClass/custom_exception.dart';
import 'package:catatan_keuangan/init/network/firebase_message.dart';
import 'package:dio/dio.dart';
import '../../core/enum/network_enum.dart';
import '../../core/model/auth_model.dart';
import '../../core/model/login_model.dart';
import '../../core/service/interface_auth_service.dart';

class AuthService extends IAuthService {
  AuthService(super.dioManager);

  @override
  Future<AuthModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      var data = LoginModel(
        email: email,
        password: password,
      ).toJson();
      if (FirebaseMsg.fcmToken != '') {
        data['fcm_token'] = FirebaseMsg.fcmToken;
      }
      var response = await dioManager.dio.post(
        NetworkEnums.loginurl.path,
        data: data,
      );
      return AuthModel.fromJson(response.data);
    } on DioException catch (err) {
      CustomResponseError.buildThrowResponseFromServer(err);
    } catch (err) {
      print(err);
      throw Exception(err);
    }
  }

  @override
  Future<String?> getStatus() async {
    var res = await dioManager.dio.get('user');
    if (res.statusCode == HttpStatus.ok) {
      Map<String, dynamic> rawData = res.data;

      if (rawData.containsKey('data')) {
        Map<String, dynamic> data = rawData['data'];
        if (data.containsKey('name')) {
          return data['name'] as String;
        }
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> verifyPassword(String password) async {
    Map<String, dynamic> data = {};
    try {
      var res = await dioManager.dio
          .post('auth/verify_password', data: {'password': password});
      data = res.data as Map<String, dynamic>;

      // return data;
    } on DioException catch (err) {
      CustomResponseError.buildThrowResponseFromServer(err);
    } catch (err) {
      throw CustomExceptionForPost(
        0,
        'Feature has problem',
      );
    }
    if (!data.containsKey('email')) {
      throw CustomExceptionForPost(
          0, 'The server has problem, please call administrator');
    }
    return data;
  }

  Future<Map<String, dynamic>> signInSSO(LoginSSOModel inp) async {
    Map<String, dynamic> data = inp.toJson();
    try {
      var res =
          await dioManager.dio.post(NetworkEnums.loginssourl.path, data: data);
      data = res.data as Map<String, dynamic>;

      return data;
    } on DioException catch (err) {
      CustomResponseError.buildThrowResponseFromServer(err);
      return {};
    } catch (err) {
      throw CustomExceptionForPost(
        0,
        'Feature has problem',
      );
    }
  }

  Future<AuthModel?> registerSSO(LoginSSOModel inp) async {
    Map<String, dynamic> data = inp.toJson();
    try {
      var res = await dioManager.dio
          .post(NetworkEnums.registerssourl.path, data: data);
      data = res.data as Map<String, dynamic>;

      return AuthModel.fromJson(res.data);
    } on DioException catch (err) {
      print("register sso err" + err.toString());
      CustomResponseError.buildThrowResponseFromServer(err);
      return null;
    } catch (err) {
      print("register sso err1" + err.toString());
      throw CustomExceptionForPost(
        0,
        'Feature has problem',
      );
    }
  }
}
