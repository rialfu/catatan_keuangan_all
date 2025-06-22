import 'dart:io';

import 'package:catatan_keuangan/constants/message_custom.dart';
import 'package:catatan_keuangan/customClass/custom_exception.dart';
import 'package:catatan_keuangan/init/network/firebase_message.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
      // if (response.statusCode == HttpStatus.ok) {
      return AuthModel.fromJson(response.data);
      // }
    } on DioException catch (err) {
      print((err.response?.data.toString() ?? '').contains('ERR_NGROK_3200'));
      CustomResponseError.buildThrowResponseFromServer(err);
      // print('err: ${err.response?.statusCode}');
      // if (err.type == DioExceptionType.connectionError) {
      //   throw CustomExceptionForPost(0, MessageCustom.serverNotActive);
      // }
      // if (err.type == DioExceptionType.connectionTimeout) {
      //   throw CustomExceptionForPost(0, MessageCustom.serverNotActive);
      // }
      // print('message');
      // print(err.response?.data);
      // if (err.response?.statusCode == 401) {
      //   throw CustomExceptionForPost(401, 'Email or Password is wrong');
      // }

      // // if (err.type == DioErrorType.CONNECT_TIMEOUT) {}
      // throw Exception(err);
    } catch (err) {
      print(err);
      throw Exception(err);
    }
  }

  @override
  Future<String?> getStatus() async {
    var res = await dioManager.dio.get('user');
    print(res.data);
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
      // if (err.type == DioExceptionType.connectionError) {
      //   throw CustomExceptionForPost(0, MessageCustom.serverNotActive);
      // }
      // if (err.type == DioExceptionType.connectionTimeout) {
      //   throw CustomExceptionForPost(0, MessageCustom.serverNotActive);
      // }
      // if (err.response?.statusCode == HttpStatus.unauthorized) {
      //   throw CustomExceptionForPost(401, 'unauthorized');
      // }
      // if (err.response?.statusCode == HttpStatus.badRequest) {
      //   // print(e.response?.data);
      //   throw CustomExceptionForPost(
      //       400,
      //       err.response?.data['message'] ??
      //           ['Bad Request, Please message to adminitrator']);
      // }
      // if (err.response?.statusCode == HttpStatus.tooManyRequests) {
      //   throw CustomExceptionForPost(
      //     429,
      //     err.response?.data['message'] ??
      //         ['Too Many Request, Please message to adminitrator'],
      //   );
      // }
      // if (err.response?.statusCode == HttpStatus.forbidden) {
      //   // print(e.response?.data);
      //   throw CustomExceptionForPost(
      //       403,
      //       err.response?.data['message'] ??
      //           ['Forbidden, Please message to adminitrator']);
      // }
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

  signInOrRegister() async {

  }
}
