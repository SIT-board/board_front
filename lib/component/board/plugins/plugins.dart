import 'package:board_front/component/board/model/model_plugin_manager.dart';

import 'freestyle/plugin_impl.dart';
import 'html/plugin_impl.dart';
import 'image/plugin_impl.dart';
import 'line/plugin_impl.dart';
import 'markdown/plugin_impl.dart';
import 'oval/plugin_impl.dart';
import 'rect/plugin_impl.dart';

export 'freestyle/plugin_impl.dart';
export 'html/plugin_impl.dart';
export 'image/plugin_impl.dart';
export 'line/plugin_impl.dart';
export 'markdown/plugin_impl.dart';
export 'oval/plugin_impl.dart';
export 'rect/plugin_impl.dart';

final defaultModelPlugins = BoardModelPluginManager(
  initialPlugins: [
    RectModelPlugin(),
    LineModelPlugin(),
    OvalModelPlugin(),
    ImageModelPlugin(),
    FreeStyleModelPlugin(),
    HtmlModelPlugin(),
    MarkdownModelPlugin(),
  ],
);
