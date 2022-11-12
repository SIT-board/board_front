import 'package:dio/dio.dart';

class ImageService {
  Dio dio;
  ImageService(this.dio);

  /// 上传图片
  Future<String> upload(MultipartFile imageFile) async {
    final response = await dio.post(
      '/image/upload',
      data: FormData.fromMap({'image': imageFile}),
    );
    return response.data;
  }
}
