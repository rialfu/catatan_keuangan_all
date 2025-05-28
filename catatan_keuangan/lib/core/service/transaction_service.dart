import 'dart:io';

import 'package:catatan_keuangan/core/model/category_model.dart';
import 'package:catatan_keuangan/core/model/transaction_bulk_model.dart';
import 'package:catatan_keuangan/core/model/transaction_daily_model.dart';
import 'package:catatan_keuangan/customClass/custom_exception.dart';
import 'package:catatan_keuangan/init/network/dio_manager.dart';
import 'package:dio/dio.dart';

class TransactionService {
  final DioManager dioManager;
  TransactionService(this.dioManager);

  Future<List<CategoryModel>> getAllCategory() async {
    try {
      var res = await dioManager.dio.get('category');
      List data = res.data['data'];
      // print(data);
      return data.map((e) => CategoryModel.fromJson(e)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == HttpStatus.unauthorized) {
        throw Exception('unauthorized');
      }
      throw Exception(e.message);
    } catch (err) {
      throw Exception(err);
    }
  }

  Future<int?> saveCategory(CategoryModel data) async {
    try {
      // print('save cat');
      var res = await dioManager.dio.post(
        'category/create',
        data: data.toJsonSave(),
      );
      // print(res.data['result']);
      // if (res.data is Map) {
      Map resData = res.data;
      if (resData.containsKey('result') == false) {
        // print(resData);
        return null;
      }
      Map dataSaved = resData['result'];
      if (dataSaved.containsKey('id') == false) {
        // print(dataSaved);
        return null;
      }
      if (dataSaved['id'] is int) {
        return dataSaved['id'] as int;
      } else if (dataSaved['id'] is String) {
        return int.parse((dataSaved['id'] as String));
      }
      return null;
      // }
      // List data = res.data['data'];
    } on DioException catch (e) {
      // print(e.response?.data);
      if (e.response?.statusCode == HttpStatus.unauthorized) {
        throw Exception('unauthorized');
      }
      if (e.response?.statusCode == HttpStatus.badRequest) {
        // print(e.response?.data);
        throw CustomExceptionForPost(400, e.response?.data['message']);
      }
      throw Exception(e.message);
    } catch (err) {
      // print(err);
      throw Exception(err);
    }
  }

  Future<void> updateCategory(CategoryModel data) async {
    try {
      await dioManager.dio.put(
        'category/update',
        data: data.toJsonUpdate(),
      );
      // List data = res.data['data'];
    } on DioException catch (e) {
      if (e.response?.statusCode == HttpStatus.unauthorized) {
        throw Exception('unauthorized');
      }
      throw Exception(e.message);
    } catch (err) {
      throw Exception(err);
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      // print(data.toJsonUpdate());
      await dioManager.dio.delete(
        'category/delete/$id',
        // data: data.toJsonUpdate(),
      );
      // print(res);
    } on DioException catch (e) {
      // print(e.response?.statusCode);
      if (e.response?.statusCode == HttpStatus.unauthorized) {
        throw Exception('unauthorized');
      }
      if (e.response?.statusCode == HttpStatus.badRequest) {
        // print(e.response?.data);
        throw CustomExceptionForPost(400, e.response?.data['message']);
      }
      throw Exception(e.message);
    }
  }

  Future<List<TransactionDailyModel>> getTransaction(
      {required String dateData}) async {
    try {
      var res = await dioManager.dio
          .get('transaction', queryParameters: {'date': dateData});

      // if(res.data['data'] !=)
      List data = res.data['data'];
      return data.map((e) => TransactionDailyModel.fromJson(e)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == HttpStatus.unauthorized) {
        throw Exception('unauthorized');
      }
      if (e.response?.statusCode == HttpStatus.tooManyRequests) {
        throw CustomExceptionForPost(
          429,
          e.response?.data['message'] ?? e.message,
        );
      }
      throw Exception(e.message);
    }
  }

  Future<int?> saveTransaction(TransactionDailyModel data) async {
    try {
      // print(data.toJsonSave());
      var res = await dioManager.dio.post(
        'transaction/create',
        data: data.toJsonSave(),
      );
      if ((res.data as Map).containsKey('result')) {
        Map dataRes = (res.data as Map)['result'];
        if (dataRes.containsKey('id') == false) return null;
        if (dataRes['id'] is String) {
          return int.tryParse(dataRes['id'] as String) ?? 0;
        } else if (dataRes['id'] is int) {
          return dataRes['id'] as int;
        } else {
          return null;
        }
        // int id = dataRes['id'] as int;
        // return data.addId(id);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == HttpStatus.unauthorized) {
        throw Exception('unauthorized');
      }
      if (e.response?.statusCode == HttpStatus.badRequest) {
        // print(e.response?.data);
        throw CustomExceptionForPost(400, e.response?.data['message']);
      }
      if (e.response?.statusCode == HttpStatus.tooManyRequests) {
        throw CustomExceptionForPost(
          429,
          e.response?.data['message'] ?? e.message,
        );
      }
      throw Exception(e.message);
    } catch (err) {
      throw Exception(err);
    }
    return null;
  }

  Future<void> updateTransaction(TransactionDailyModel data) async {
    try {
      await dioManager.dio.put(
        'transaction/update',
        data: data.toJsonUpdate(),
      );
    } on DioException catch (e) {
      // print(e.response?.statusCode);
      if (e.response?.statusCode == HttpStatus.unauthorized) {
        throw Exception('unauthorized');
      }
      if (e.response?.statusCode == HttpStatus.badRequest) {
        throw CustomExceptionForPost(400, e.response?.data['message']);
      }
      if (e.response?.statusCode == HttpStatus.tooManyRequests) {
        throw CustomExceptionForPost(
          429,
          e.response?.data['message'] ?? e.message,
        );
      }
      throw Exception(e.message);
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      // print(data.toJsonUpdate());
      await dioManager.dio.delete(
        'transaction/delete/$id',
        // data: data.toJsonUpdate(),
      );
      // print(res);
    } on DioException catch (e) {
      // print(e.response?.statusCode);
      if (e.response?.statusCode == HttpStatus.unauthorized) {
        throw Exception('unauthorized');
      }
      if (e.response?.statusCode == HttpStatus.badRequest) {
        throw CustomExceptionForPost(400, e.response?.data['message']);
      }
      if (e.response?.statusCode == HttpStatus.tooManyRequests) {
        throw CustomExceptionForPost(
          429,
          e.response?.data['message'] ?? e.message,
        );
      }
      throw Exception(e.message);
    }
  }

  Future<List<TransactionBulkModel>> monthlyTransaction(String data) async {
    try {
      var res = await dioManager.dio
          .get('transaction/accumulation_month', queryParameters: {'date': data}
              // data: data.toJsonUpdate(),
              );
      List sementara = (res.data['data'] as List);
      List<TransactionBulkModel> finalData = [];
      String name = '';
      for (int i = 1; i < 13; i++) {
        name = '$data-${(i.toString().padLeft(2, '0'))}';
        // name = data + '-' + (i.toString().padLeft(2, '0'));
        TransactionBulkModel cache = TransactionBulkModel(name: name);
        double inMoney = sementara
            .fold(
                0.0,
                (p, c) =>
                    p +
                    ((name == c['tanggal'] && c['debcre'] == 'debit')
                        ? double.tryParse(c['total']) ?? 0
                        : 0))
            .toDouble();
        double outMoney = sementara
            .fold(
                0.0,
                (p, c) =>
                    p +
                    ((name == c['tanggal'] && c['debcre'] == 'credit')
                        ? double.tryParse(c['total']) ?? 0
                        : 0))
            .toDouble();
        cache = cache.addIn(inMoney);
        cache = cache.addOut(outMoney);
        finalData.add(cache);
      }
      return finalData;
    } on DioException catch (e) {
      // print(e.response?.statusCode);
      if (e.response?.statusCode == HttpStatus.unauthorized) {
        throw Exception('unauthorized');
      }
      if (e.response?.statusCode == HttpStatus.badRequest) {
        // print(e.response?.data);
        throw CustomExceptionForPost(400, e.response?.data['message']);
      }
      if (e.response?.statusCode == HttpStatus.tooManyRequests) {
        throw CustomExceptionForPost(
          429,
          e.response?.data['message'] ?? e.message,
        );
      }
      throw Exception(e);
    }
  }
}
