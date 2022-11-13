import 'package:dio/dio.dart';

class ImageService {
  Dio dio;
  ImageService(this.dio);

  Future<String> getThumbnail(String rawUrl) async {
    return '';
  }
}
