import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'model.dart';
import 'model_widget.dart';
import 'mqtt.dart';

final node = BoardNode(
  roomId: 'roomId',
  nodeId: 'nodeId',
);

void main() async {
  await node.connect();
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
  // final models = {
  //   '1': Model({})
  //     ..id = '1'
  //     ..type = ModelType.text
  //     ..data = (TextModelData({})..content = 'HeelloWorld')
  //     ..common = CommonModelData({}),
  //   '2': Model({})
  //     ..id = '2'
  //     ..type = ModelType.image
  //     ..data =
  //         (ImageModelData({})..url = 'https://api.jikipedia.com/upload/7b732b18afcbe8dfe776937fab2ae01b_scaled.jpg')
  //     ..common = CommonModelData({}),
  //   '3': Model({})
  //     ..id = '3'
  //     ..type = ModelType.rect
  //     ..data = (RectModelData({})
  //       ..fillColor = Colors.red
  //       ..borderColor = Colors.blue
  //       ..borderWidth = 10)
  //     ..common = CommonModelData({}),
  // };

  final controller = TransformationController();

  late final vm = CanvasViewModel(jsonDecode(
      '{"models":{"1":{"id":"1","type":0,"data":{"content":"HeelloWorld"},"common":{"position":[295.0,386.0]}},"2":{"id":"2","type":2,"data":{"url":"https://api.jikipedia.com/upload/7b732b18afcbe8dfe776937fab2ae01b_scaled.jpg"},"common":{"position":[435.0,153.0]}},"3":{"id":"3","type":1,"data":{"fillColor":4294198070,"borderColor":4280391411,"borderWidth":10.0},"common":{"position":[152.0,200.0]}}},"viewerTransform":[1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0,0.0,-26.02085883618155,0.35288159568733235,0.0,1.0]}'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('test'),
        actions: [
          IconButton(
              onPressed: () {
                print(jsonEncode(vm.map));
              },
              icon: Icon(Icons.ac_unit))
        ],
      ),
      body: CanvasViewModelWidget(
        // 视口变换控制器
        controller: controller,
        viewModel: vm,
        onChanged: (List<String> path, dynamic value) {
          node.broadcast('canvas', jsonEncode([path, value]));
        },
      ),
    );
  }
}
