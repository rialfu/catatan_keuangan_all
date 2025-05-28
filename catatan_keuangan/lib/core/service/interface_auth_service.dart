import 'package:catatan_keuangan/core/model/auth_model.dart';

import '../../init/network/dio_manager.dart';

abstract class IAuthService {
  final DioManager dioManager;

  IAuthService(this.dioManager);

  Future<AuthModel?> login({
    required String email,
    required String password,
  });
  Future<String?> getStatus();
}
