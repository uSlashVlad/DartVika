import 'dart:io';

import 'package:dio/dio.dart';

import 'package:DartVika/constants.dart';
import 'package:DartVika/logger.dart';

enum AnimalType { Cat, Dog }

class DogCatHelper {
  DogCatHelper(this.apiKey) {
    dio = Dio();
  }
  final apiKey;
  Dio dio;

  static Map<String, String> getApiParams(AnimalType type) {
    String url;
    String typeEN;
    String typeRU;

    switch (type) {
      case AnimalType.Cat:
        url = kCatApiUrl;
        typeEN = 'cat';
        typeRU = 'котик';
        break;
      case AnimalType.Dog:
        url = kDogApiUrl;
        typeEN = 'dog';
        typeRU = 'пёсик';
        break;
      default:
        print('Animal type error!');
        return null;
    }

    return {
      'url': url,
      'typeEN': typeEN,
      'typeRU': typeRU,
    };
  }

  Future<Response> loadDataFromAPI(String apiUrl, Map<String, dynamic> body) async {
    final url = '$apiUrl/v1/images/search?$body';
    Response response = await dio.get(
      url,
      options: Options(headers: {
        HttpHeaders.contentTypeHeader: ContentType.json,
        'x-api-key': apiKey,
      }),
    );
    return response;
  }

  Future<Response> voteWithAPI(String apiUrl, Map<String, dynamic> body) async {
    final url = '$apiUrl/v1/votes';
    Response response = await dio.post(
      url,
      options: Options(headers: {
        HttpHeaders.contentTypeHeader: ContentType.json,
        'x-api-key': apiKey,
      }),
      data: body,
    );
    return response;
  }
}
