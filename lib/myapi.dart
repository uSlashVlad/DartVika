import 'dart:io';

import 'package:dio/dio.dart';

class MyApiHelper {
  MyApiHelper() {
    dio = Dio();
  }

  Dio dio;

  Future<String> getDanceGifUrl() async {
    final url = 'http://debils.tech/api/fun/gif/dance';
    Response response = await dio.get(
      url,
      options: Options(headers: {
        HttpHeaders.contentTypeHeader: ContentType.json,
      }),
    );
    String result = response.data['file'];
    print(result);
    return result;
  }
}
