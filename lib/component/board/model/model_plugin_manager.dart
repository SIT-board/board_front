import 'package:board_front/component/board/model/model_plugin_interface.dart';

/// 构造出模型对应的 Widget
class BoardModelPluginManager {
  final Map<String, BoardModelPluginInterface> _plugins = {};

  BoardModelPluginManager({
    List<BoardModelPluginInterface> initialPlugins = const [],
  }) {
    initialPlugins.forEach(registerPlugin);
  }

  void registerPlugin(BoardModelPluginInterface plugin) {
    String typeName = plugin.modelTypeName;
    if (_plugins.containsKey(typeName)) {
      // 同一个插件重复注册
      if (_plugins[typeName] == plugin) return;
      // 不同插件但是类型名称相同，抛异常
      throw Exception('Board model plugin has been registered $typeName');
    }
    _plugins[typeName] = plugin;
  }

  BoardModelPluginInterface getPluginByModelType(String modelType) {
    if (!_plugins.containsKey(modelType)) {
      throw Exception('Plugin name: $modelType not be registered');
    }
    return _plugins[modelType]!;
  }

  List<String> getPluginNameList() => _plugins.keys.toList();
}
