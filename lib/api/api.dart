import 'package:board_front/api/image.dart';
import 'package:dio/dio.dart';

import 'attachment.dart';

class Api {
  late Dio dio = Dio();
  Api();

  ImageService get image => ImageService(dio);
  AttachmentService get attachment => AttachmentService(dio);
}
