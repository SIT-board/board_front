import 'package:board_front/global.dart';
import 'package:dio/dio.dart';

class AttachmentService {
  Dio dio;
  AttachmentService(this.dio);

  /// 上传附件
  Future<String> upload(MultipartFile file) async {
    final url = GlobalObjects.storage.server.fileUpload;
    final response = await dio.post(url, data: FormData.fromMap({'file': file}));
    return response.data;
  }
}
