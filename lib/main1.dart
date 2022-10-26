import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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

class Stack2 extends Stack {
  Stack2({
    super.key,
    super.alignment = AlignmentDirectional.topStart,
    super.textDirection,
    super.fit = StackFit.loose,
    super.clipBehavior = Clip.hardEdge,
    super.children = const <Widget>[],
  });
  @override
  RenderStack createRenderObject(BuildContext context) {
    return RenderStack2(
      alignment: alignment,
      textDirection: textDirection ?? Directionality.maybeOf(context),
      fit: fit,
      clipBehavior: clipBehavior,
    );
  }
}

class RenderStack2 extends RenderStack {
  RenderStack2({
    super.children,
    super.alignment = AlignmentDirectional.topStart,
    super.textDirection,
    super.fit = StackFit.loose,
    super.clipBehavior = Clip.hardEdge,
  });

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (hitTestChildren(result, position: position) || hitTestSelf(position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }
}

class _HomeState extends State<Home> {
  Offset origin = Offset(0, 0);
  Offset cur = Offset(0, 0);
  @override
  Widget build(BuildContext context) {
    TransformationController controller = TransformationController();
    controller.addListener(() {
      print(controller.value.getTranslation());
    });
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
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (d) {
          setState(() => origin += d.delta);
        },
        child: InteractiveViewer(
          transformationController: controller,
          boundaryMargin: EdgeInsets.all(double.infinity),
          child: Stack2(
            clipBehavior: Clip.none,
            children: [
              // Positioned(top: 0, left: 0, child: Container()),
              ...Iterable.generate(2, (i) {
                return Positioned(
                    top: 0,
                    left: 0,
                    // offset: Offset(-100, -100 * i.toDouble()),
                    child: Transform(
                      transform: () {
                        var m = Matrix4.identity();

                        m.translate(-100.0 * i.toDouble(), -100);
                        m.rotateZ(pi / 3);

                        return m;
                      }(),
                      child: SizedBox(
                        width: 50,
                        height: 100,
                        child: ElevatedButton(onPressed: () {}, child: Text('Hello $i')),
                      ),
                    ));
              }),
              Positioned(
                top: 200,
                left: 0,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(color: Colors.blue, border: Border.all()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
