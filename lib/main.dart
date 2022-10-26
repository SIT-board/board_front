import 'package:board_front/drawable.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('test'),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final v = ValueNotifier<Offset?>(null);
          return GestureDetector(
            onPanUpdate: (DragUpdateDetails d) {
              v.value = d.localPosition;
              // print(v.value);
            },
            child: ValueListenableBuilder<Offset?>(
              valueListenable: v,
              builder: (BuildContext context, Offset? value, Widget? child) {
                print(value);

                return CustomPaint(
                  painter: MyCustomPainter(RectDrawable(
                    transformState: TransformState(
                      position: value ?? Offset(0, 0),
                      rotation: 1,
                      scale: Size(100, 100),
                    ),
                    paint: Paint()..color = Colors.blue,
                  )),
                  size: constraints.biggest,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
