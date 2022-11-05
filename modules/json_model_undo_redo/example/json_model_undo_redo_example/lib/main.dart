import 'package:flutter/material.dart';
import 'package:json_model_undo_redo/json_model_undo_redo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Undo Redo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyPage extends StatefulWidget {
  const MyPage({super.key, required this.title});
  final String title;

  @override
  State<MyPage> createState() => _MyPageState();
}

class MyPageState {
  final Map map;
  int get counter => map['counter'] ??= 0;
  set counter(int v) => map['counter'] = v;

  List<int> get list => ((map['list'] ??= []) as List).cast<int>();
  set list(List<int> v) => map['list'] = v;

  MyPageState(this.map);
}

class _MyPageState extends State<MyPage> {
  final map = {};
  late final state = MyPageState(map);
  late final undoRedoManager = UndoRedoManager(map);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              print('----------------------');
              undoRedoManager.history.forEach(print);
            },
            icon: Icon(Icons.add),
          ),
          IconButton(
            onPressed: !undoRedoManager.canUndo
                ? null
                : () {
                    setState(() {
                      undoRedoManager.undo();
                    });
                  },
            icon: Icon(Icons.undo),
          ),
          IconButton(
            onPressed: !undoRedoManager.canRedo
                ? null
                : () {
                    setState(() {
                      undoRedoManager.redo();
                    });
                  },
            icon: Icon(Icons.redo),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('${state.counter}'),
            Text('${state.list}'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            state.counter++;
            state.list = [...state.list, state.counter];
            undoRedoManager.store();
          });
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
