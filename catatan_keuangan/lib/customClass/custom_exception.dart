import 'dart:io';

import 'package:catatan_keuangan/constants/message_custom.dart';
import 'package:dio/dio.dart';

class CustomExceptionForPost implements Exception {
  int codeError;
  var cause;

  CustomExceptionForPost(this.codeError, this.cause);
}

class CustomResponseError {
  static buildThrowResponseFromServer(DioException e) {
    if (e.type == DioExceptionType.connectionError) {
      throw CustomExceptionForPost(0, MessageCustom.internetOff);
    }
    if (e.type == DioExceptionType.connectionTimeout) {
      throw CustomExceptionForPost(0, MessageCustom.serverNotActive);
    }
    if (e.response?.statusCode == 400 &&
        (e.response?.headers.value('content-type')?.contains('text/html') ??
            false)) {
      throw CustomExceptionForPost(0, MessageCustom.serverNotActive);
    }
    if (e.response?.statusCode == HttpStatus.unauthorized) {
      throw Exception('unauthorized');
    }
    if((e.response?.data.toString() ?? '').contains('ERR_NGROK')){
      throw CustomExceptionForPost(0, MessageCustom.serverNotActive);
    }
    if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
      Map<String, dynamic> res = e.response?.data;
      if (res.containsKey('message')) {
        List<String> message = [];
        if (res['message'] is List) {
          message = (res['message'] as List).map((e) => e.toString()).toList();
        } else if (res['message'] is String) {
          message = [res['message']];
        } else {
          message = [res['message'].toString()];
        }
        throw CustomExceptionForPost(e.response?.statusCode ?? 0, message);
      }
    }
    throw Exception(e.message);
  }

  static List<String> buildResponseFromServer(DioException e) {
    List<String> message = [MessageCustom.appError];
    if (e.type == DioExceptionType.connectionError) {
      message = [MessageCustom.internetOff];
    }
    if (e.type == DioExceptionType.connectionTimeout) {
      message = [MessageCustom.serverNotActive];
    }
    if (e.response?.statusCode == 400 &&
        (e.response?.headers.value('content-type')?.contains('text/html') ??
            false)) {
      message = [MessageCustom.serverNotActive];
    }
    if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
      Map<String, dynamic> res = e.response?.data;
      if (res.containsKey('message')) {
        if (res['message'] is List) {
          message = (res['message'] as List).map((e) => e.toString()).toList();
        } else if (res['message'] is String) {
          message = [res['message']];
        } else {
          message = [res['message'].toString()];
        }
      } else {
        message = [res.toString()];
      }
    }
    return message;
  }
}
