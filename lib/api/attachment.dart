import 'package:dio/dio.dart';

class AttachmentService {
  Dio dio;
  AttachmentService(this.dio);

  /// 上传附件
  Future<String> upload(MultipartFile file) async {
    final response = await dio.post(
      '/file/upload',
      data: FormData.fromMap({'file': file}),
    );
    return response.data;
  }
}
