import 'package:board_front/global.dart';
import 'package:dio/dio.dart';

class UploadResponse {
  final String url;
  UploadResponse({required this.url});

  factory UploadResponse.fromJson(Map<String, dynamic> json) {
    return UploadResponse(url: json['url']);
  }
}

class AttachmentService {
  Dio dio;
  AttachmentService(this.dio);

  /// 上传附件
  Future<UploadResponse> upload(MultipartFile file) async {
    final url = GlobalObjects.storage.server.fileUpload;
    final response = await dio.post(url, data: FormData.fromMap({'file': file}));
    return UploadResponse.fromJson((response.data as Map).cast<String, dynamic>());
  }
}
