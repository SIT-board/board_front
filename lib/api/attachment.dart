import 'package:dio/dio.dart';

class AttachmentService {
  Dio dio;
  AttachmentService(this.dio);

  /// 上传附件
  Future<String> upload(MultipartFile imageFile) async {
    final response = await dio.post(
      '/attachment/upload',
      data: FormData.fromMap({'attachment': imageFile}),
    );
    return response.data;
  }
}
