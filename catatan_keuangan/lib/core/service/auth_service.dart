import 'dart:io';

import 'package:catatan_keuangan/init/network/firebase_message.dart';

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
    print('AuthService:start1 $email $password');
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
    print(response.data);
    if (response.statusCode == HttpStatus.ok) {
      return AuthModel.fromJson(response.data);
    } else {
      return throw Exception('error');
    }
  }

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
}
