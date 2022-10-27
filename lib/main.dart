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
  final models = {
    1: Model(
      id: 1,
      type: ModelType.text,
      data: TextModelData(content: 'HeelloWorld'),
      common: CommonModelData(),
    ),
    2: Model(
      id: 2,
      type: ModelType.image,
      data: ImageModelData('https://api.jikipedia.com/upload/7b732b18afcbe8dfe776937fab2ae01b_scaled.jpg'),
      common: CommonModelData(),
    ),
    3: Model(
      id: 3,
      type: ModelType.rect,
      data: RectModelData(
        fillColor: Colors.red,
        borderColor: Colors.blue,
        borderWidth: 10,
      ),
      common: CommonModelData(),
    ),
  };
  @override
  void initState() {
    super.initState();
  }

  final controller = TransformationController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('test'),
        actions: [
          IconButton(
              onPressed: () {
                controller.value = Matrix4.identity();
              },
              icon: Icon(Icons.ac_unit))
        ],
      ),
      body: CanvasViewModelWidget(
        // 视口变换控制器
        controller: controller,
        viewModel: CanvasViewModel(models: models),
        onChanged: (List<dynamic> value) {
          print(value);
        },
      ),
    );
  }
}
