import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'model.dart';
import 'model_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Offset origin = Offset(0, 0);
  Offset cur = Offset(0, 0);
  final controller = TransformationController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('test'),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.ac_unit))],
      ),
      body: CanvasViewModelWidget(
        // 视口变换控制器
        controller: controller,
        viewModel: CanvasViewModel(
          models: [
            Model(id: 1, type: ModelType.text, data: TextModelData(content: 'HeelloWorld')),
            Model(
              id: 2,
              type: ModelType.image,
              size: const Size(100, 100),
              transform: Matrix4.translationValues(100, 200, 0),
              data: ImageModelData('https://api.jikipedia.com/upload/7b732b18afcbe8dfe776937fab2ae01b_scaled.jpg'),
            ),
            Model(
              id: 3,
              type: ModelType.rect,
              size: const Size(100, 100),
              // 模型变换矩阵
              transform: Matrix4.translationValues(100, 100, 0),
              data: RectModelData(
                fillColor: Colors.red,
                borderColor: Colors.blue,
                borderWidth: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
