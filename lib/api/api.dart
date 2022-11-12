import 'package:board_front/api/image.dart';
import 'package:dio/dio.dart';

import 'attachment.dart';

class Api {
  Dio dio;
  Api(this.dio);

  ImageService get image => ImageService(dio);
  AttachmentService get attachment => AttachmentService(dio);
}
