import 'package:board_front/component/board/board.dart';
import 'package:flutter/material.dart';

class BoardPage extends StatefulWidget {
  final String roomId;
  final String nodeId;

  const BoardPage({
    Key? key,
    required this.roomId,
    required this.nodeId,
  }) : super(key: key);

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  final controller = TransformationController();

  var vm = BoardViewModel({
    "models": {
      "1": {
        "id": "1",
        "type": 0,
        "data": {"content": "HeelloWorld"},
        "common": {
          "position": [295.0, 386.0]
        }
      },
      "2": {
        "id": "2",
        "type": 2,
        "data": {"url": "https://api.jikipedia.com/upload/7b732b18afcbe8dfe776937fab2ae01b_scaled.jpg"},
        "common": {
          "position": [435.0, 153.0]
        }
      },
      "3": {
        "id": "3",
        "type": 1,
        "data": {"fillColor": 4294198070, "borderColor": 4280391411, "borderWidth": 10.0},
        "common": {
          "position": [152.0, 200.0]
        }
      }
    },
    "viewerTransform": [
      1.0,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0,
      -26.02085883618155,
      0.35288159568733235,
      0.0,
      1.0
    ]
  });

  @override
  void initState() {
    super.initState();
  }

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
        viewModel: vm,
        onChanged: (List<String> path, dynamic value) {
          // node.broadcast('cmd', jsonEncode([path, value]));
          // node.broadcastBoard(vm);
        },
      ),
    );
  }
}
