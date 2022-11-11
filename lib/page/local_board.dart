import 'package:board_front/component/board_page/board.dart';
import 'package:board_front/component/board_page/data.dart';
import 'package:flutter/material.dart';

class LocalBoard extends StatelessWidget {
  const LocalBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BoardPage(pageSetViewModel: BoardPageSetViewModel.createNew());
  }
}
