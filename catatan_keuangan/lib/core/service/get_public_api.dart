import 'package:dio/dio.dart';

class GetPublicApi {
  final dio = Dio();
  // final DioManager dioManager;
  // GetPublicApi(this.dioManager);

  Future<void> getDataGold() async {
    final res = await dio.get(
        'https://api.bareksa.com/internal/v1/public/gold/chart/buy?product_code=EMASPEGADAIAN&period=1w');
    final response = res.data;
    if (response is Map && response.containsKey('data')) {
      final data = response['data'];
      print(data);
    }
    // this.dioManager.dio.getUri(uri)
  }
}
