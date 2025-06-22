import 'dart:io';

import 'package:catatan_keuangan/constants/message_custom.dart';
import 'package:catatan_keuangan/core/model/saving_plan_checkout_model.dart';
import 'package:catatan_keuangan/core/model/saving_plan_model.dart';
import 'package:catatan_keuangan/customClass/custom_exception.dart';
import 'package:catatan_keuangan/init/network/dio_manager.dart';
import 'package:dio/dio.dart';

class SavingPlanService {
  final DioManager dioManager;
  SavingPlanService(this.dioManager);

  Future<List<SavingPlanModel>> getAllSavingPlan() async {
    try {
      var res = await dioManager.dio.get('saving-plan');
      List data = res.data['data'];

      return data.map((e) => SavingPlanModel.fromJson(e)).toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw CustomExceptionForPost(0, MessageCustom.serverNotActive);
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw CustomExceptionForPost(0, MessageCustom.serverNotActive);
      }
      if (e.response?.statusCode == HttpStatus.unauthorized) {
        throw Exception('unauthorized');
      }
      if (e.response?.statusCode == HttpStatus.tooManyRequests) {
        throw CustomExceptionForPost(429, e.response?.data['message']);
      }
      throw Exception(e.message);
    } catch (err) {
      // print(err);
      throw Exception(err);
    }
  }

  Future<String?> saveSavingPlan(SavingPlanModel data) async {
    try {
      var res = await dioManager.dio.post(
        'saving-plan/create',
        data: data.toJsonSave(),
      );
      Map resData = res.data;
      if (resData.containsKey('result') == false) {
        return null;
      }
      Map dataSaved = resData['result'];
      if (dataSaved.containsKey('id') == false) {
        // print(dataSaved);
        return null;
      }
      if (dataSaved['id'] is String) {
        return dataSaved['id'] as String;
      }
      return null;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw CustomExceptionForPost(0, MessageCustom.serverNotActive);
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw CustomExceptionForPost(0, MessageCustom.serverNotActive);
      }
      if (e.response?.statusCode == HttpStatus.unauthorized) {
        throw Exception('unauthorized');
      }
      if (e.response?.statusCode == HttpStatus.badRequest) {
        // print(e.response?.data);
        throw CustomExceptionForPost(400, e.response?.data['message']);
      }
      if (e.response?.statusCode == HttpStatus.tooManyRequests) {
        throw CustomExceptionForPost(429, e.response?.data['message']);
      }
      throw Exception(e.message);
    } catch (err) {
      // print(err);
      throw Exception(err);
    }
  }

  Future<void> updateSavingPlan(Map<String, dynamic> data) async {
    try {
      await dioManager.dio.put(
        'saving-plan/update',
        data: data,
      );
      // List data = res.data['data'];
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw CustomExceptionForPost(0, MessageCustom.serverNotActive);
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw CustomExceptionForPost(0, MessageCustom.serverNotActive);
      }
      if (e.response?.statusCode == HttpStatus.unauthorized) {
        throw Exception('unauthorized');
      }
      if (e.response?.statusCode == HttpStatus.tooManyRequests) {
        throw CustomExceptionForPost(429, e.response?.data['message']);
      }
      if (e.response?.statusCode == HttpStatus.unprocessableEntity) {
        throw CustomExceptionForPost(429, e.response?.data['message']);
      }
      throw Exception(e.message);
    } catch (err) {
      throw Exception(err);
    }
  }

  Future<void> deleteSavingPlan(String id) async {
    try {
      // print(data.toJsonUpdate());
      await dioManager.dio.delete(
        'saving-plan/delete/$id',
        // data: data.toJsonUpdate(),
      );
      // print(res);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw CustomExceptionForPost(0, MessageCustom.serverNotActive);
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw CustomExceptionForPost(0, MessageCustom.serverNotActive);
      }
      if (e.response?.statusCode == HttpStatus.unauthorized) {
        throw Exception('unauthorized');
      }
      if (e.response?.statusCode == HttpStatus.badRequest) {
        // print(e.response?.data);
        throw CustomExceptionForPost(400, e.response?.data['message']);
      }
      if (e.response?.statusCode == HttpStatus.tooManyRequests) {
        throw CustomExceptionForPost(429, e.response?.data['message']);
      }
      throw Exception(e.message);
    } catch (err) {
      throw Exception(err);
    }
  }

  Future<List<SavingPlanCheckoutModel>> getListCheckout(String id) async {
    try {
      var res = await dioManager.dio.get(
        'saving-plan/checkout/$id',
      );
      // print(res.data.toString() + '||' + id);
      List data = res.data['data'];
      return data.map((e) => SavingPlanCheckoutModel.fromJson(e)).toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw CustomExceptionForPost(0, MessageCustom.serverNotActive);
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw CustomExceptionForPost(0, MessageCustom.serverNotActive);
      }
      if (e.response?.statusCode == HttpStatus.unauthorized) {
        throw Exception('unauthorized');
      }
      if (e.response?.statusCode == HttpStatus.badRequest) {
        // print(e.response?.data);
        throw CustomExceptionForPost(400, e.response?.data['message']);
      }
      if (e.response?.statusCode == HttpStatus.tooManyRequests) {
        throw CustomExceptionForPost(429, e.response?.data['message']);
      }
      throw Exception(e.message);
    } catch (err) {
      throw Exception(err);
    }
  }

  Future<int?> savingStore(
    SavingPlanCheckoutModel data,
    String idSavingPlan,
  ) async {
    var saving = data.toJsonSave();
    saving['id_saving_plan'] = idSavingPlan;
    try {
      var res = await dioManager.dio.post(
        'saving-plan/checkout/create',
        data: saving,
      );
      // print(res.data['result']['id']);
      if (res.data is Map && (res.data as Map).containsKey('result')) {
        if ((res.data['result'] as Map).containsKey('id') &&
            res.data['result']['id'] is int) {
          return res.data['result']['id'] as int;
        }
      }
      return null;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw CustomExceptionForPost(0, MessageCustom.serverNotActive);
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw CustomExceptionForPost(0, MessageCustom.serverNotActive);
      }
      if (e.response?.statusCode == HttpStatus.unauthorized) {
        throw Exception('unauthorized');
      }
      if (e.response?.statusCode == HttpStatus.badRequest) {
        // print(e.response?.data);
        throw CustomExceptionForPost(400, e.response?.data['message']);
      }
      if (e.response?.statusCode == HttpStatus.tooManyRequests) {
        throw CustomExceptionForPost(429, e.response?.data['message']);
      }
      throw Exception(e.message);
    } catch (err) {
      // print('errsaving:$err');
      throw Exception(err);
    }
  }

  Future<void> deleteStore(int id) async {
    try {
      await dioManager.dio.delete(
        'saving-plan/checkout/delete/$id',
        // data: saving,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw CustomExceptionForPost(0, MessageCustom.serverNotActive);
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw CustomExceptionForPost(0, MessageCustom.serverNotActive);
      }
      if (e.response?.statusCode == HttpStatus.unauthorized) {
        throw Exception('unauthorized');
      }
      if (e.response?.statusCode == HttpStatus.badRequest) {
        // print(e.response?.data);
        throw CustomExceptionForPost(400, e.response?.data['message']);
      }
      if (e.response?.statusCode == HttpStatus.tooManyRequests) {
        throw CustomExceptionForPost(429, e.response?.data['message']);
      }
      throw Exception(e.message);
    } catch (err) {
      throw Exception(err);
    }
  }
  // Future<
}
