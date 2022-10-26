import 'package:flutter/material.dart';

class ResizableDraggableWidget extends StatefulWidget {
  const ResizableDraggableWidget({
    Key? key,
    this.initWidth,
    this.initHeight,
    required this.builder,
  }) : super(key: key);

  ///初始宽度
  final double? initWidth;

  ///初始高度
  final double? initHeight;

  ///子节点
  final WidgetBuilder builder;

  @override
  State<ResizableDraggableWidget> createState() => _ResizableDraggableWidgetState();
}

class _ResizableDraggableWidgetState extends State<ResizableDraggableWidget> {
  double _dynamicH = 0;
  double _dynamicW = 0;

  double _dynamicSH = 0;
  double _dynamicSW = 0;

  double trH = 0;
  double trW = 0;

  double trLastH = 0;
  double trLastW = 0;

  bool _lockH = false;
  bool _lockW = false;

  @override
  void initState() {
    super.initState();
    _dynamicH = widget.initHeight == null || widget.initHeight == 0 ? 200 : widget.initHeight!;
    _dynamicW = widget.initWidth == null || widget.initHeight == 0 ? 200 : widget.initWidth!;
    _dynamicSW = _dynamicW;
    _dynamicSH = _dynamicH;
  }

  refreshW(Alignment dir, double dx) {
    if (_dynamicW < 40 && _panIntervalOffset.dx > 0) {
      _lockW = true;
      _dynamicW = 40;
    }
    if (_panIntervalOffset.dx < 0) {
      _lockW = false;
    }

    if (!_lockW) {
      setState(() {
        _dynamicW = _dynamicSW - dx;
        if (dir == Alignment.centerLeft || dir == Alignment.topLeft || dir == Alignment.bottomLeft) {
          trW = dx + trLastW;
        }
      });
    }
  }

  refreshH(Alignment dir, double dy) {
    if (_dynamicH < 40 && _panIntervalOffset.dy > 0) {
      _lockH = true;
      _dynamicH = 40;
    }
    if (_panIntervalOffset.dy < 0) {
      _lockH = false;
    }

    if (!_lockH) {
      setState(() {
        _dynamicH = _dynamicSH - dy;
        if (dir == Alignment.topCenter || dir == Alignment.topLeft || dir == Alignment.topRight) {
          trH = dy + trLastH;
        }
      });
    }
  }

  Offset _panStartOffset = const Offset(0, 0);
  Offset _panUpdateOffset = const Offset(0, 0);
  Offset _panIntervalOffset = const Offset(0, 0);
  panResizeSquare(Alignment dir) {
    return GestureDetector(
      onPanStart: (details) {
        _panStartOffset = details.localPosition;
        _dynamicSW = _dynamicW;
        _dynamicSH = _dynamicH;
      },
      onPanUpdate: (details) {
        _panUpdateOffset = details.localPosition;
        if (dir == Alignment.centerRight || dir == Alignment.centerLeft) {
          if (dir == Alignment.centerRight) {
            _panIntervalOffset = -_panUpdateOffset + _panStartOffset;
          } else if (dir == Alignment.centerLeft) {
            _panIntervalOffset = _panUpdateOffset - _panStartOffset;
          }
          refreshW(dir, _panIntervalOffset.dx);
        } else if (dir == Alignment.bottomCenter || dir == Alignment.topCenter) {
          if (dir == Alignment.bottomCenter) {
            _panIntervalOffset = -_panUpdateOffset + _panStartOffset;
          } else if (dir == Alignment.topCenter) {
            _panIntervalOffset = _panUpdateOffset - _panStartOffset;
          }
          refreshH(dir, _panIntervalOffset.dy);
        } else {
          if (dir == Alignment.bottomRight) {
            _panIntervalOffset = -_panUpdateOffset + _panStartOffset;
            refreshW(dir, _panIntervalOffset.dx);
            refreshH(dir, _panIntervalOffset.dy);
          } else if (dir == Alignment.topRight) {
            _panIntervalOffset = _panUpdateOffset - _panStartOffset;
            refreshW(dir, -_panIntervalOffset.dx);
            refreshH(dir, _panIntervalOffset.dy);
          } else if (dir == Alignment.bottomLeft) {
            _panIntervalOffset = -_panUpdateOffset + _panStartOffset;
            refreshW(dir, -_panIntervalOffset.dx);
            refreshH(dir, _panIntervalOffset.dy);
          } else if (dir == Alignment.topLeft) {
            _panIntervalOffset = _panUpdateOffset - _panStartOffset;
            refreshW(dir, _panIntervalOffset.dx);
            refreshH(dir, _panIntervalOffset.dy);
          }
        }
        // if (widget.changed != null) {
        //   if (widget.changed != null) {
        //     widget.changed!(_dynamicW, _dynamicH, updateMoveOffset + Offset(trW, trH));
        //   }
        // }
      },
      onPanEnd: ((details) {
        trLastH = trH;
        _lockH = false;
        trLastW = trW;
        _lockW = false;
      }),
      child: Icon(
        color: Colors.black,
        size: 10,
        Icons.circle_outlined,
      ),
    );
  }

  Widget getResizeable() {
    return Container(
      width: _dynamicW <= 0 ? 1 : _dynamicW,
      height: _dynamicH <= 0 ? 1 : _dynamicH,
      child: Stack(alignment: Alignment.center, children: [
        widget.builder(context),
        Positioned(
          left: 0,
          top: 0,
          child: panResizeSquare(Alignment.topLeft),
        ),
        Positioned(
          left: _dynamicW / 2 - 10,
          top: 0,
          child: panResizeSquare(Alignment.topCenter),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: panResizeSquare(Alignment.topRight),
        ),
        Positioned(
          left: 0,
          bottom: 0,
          child: panResizeSquare(Alignment.bottomLeft),
        ),
        Positioned(
          left: _dynamicW / 2 - 10,
          bottom: 0,
          child: panResizeSquare(Alignment.bottomCenter),
        ),
        Positioned(
          left: 0,
          top: _dynamicH / 2 - 10,
          child: panResizeSquare(Alignment.centerLeft),
        ),
        Positioned(
          right: 0,
          top: _dynamicH / 2 - 10,
          child: panResizeSquare(Alignment.centerRight),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: panResizeSquare(Alignment.bottomRight),
        )
      ]),
    );
  }

  Offset startMoveOffset = const Offset(0, 0);
  Offset endMoveOffset = const Offset(0, 0);
  Offset updateMoveOffset = const Offset(0, 0);
  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: updateMoveOffset + Offset(trW, trH),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: getResizeable(),
        onPanStart: (details) {
          startMoveOffset = details.localPosition;
        },
        onPanUpdate: (details) {
          Offset intervalOffset = details.localPosition - startMoveOffset + endMoveOffset;
          setState(() {
            updateMoveOffset = intervalOffset;
          });
          // if (widget.changed != null) {
          //   widget.changed!(_dynamicW, _dynamicH, updateMoveOffset + Offset(trW, trH));
          // }
        },
        onPanEnd: (details) {
          endMoveOffset = updateMoveOffset;
        },
      ),
    );
  }
}
