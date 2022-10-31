import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// 无限大的stack，支持负数positioned，越界依然可以显示，点击事件依旧生效
class InfinityStack extends Stack {
  InfinityStack({
    super.key,
    super.alignment = AlignmentDirectional.topStart,
    super.textDirection,
    super.fit = StackFit.loose,
    super.clipBehavior = Clip.none,
    super.children = const <Widget>[],
  });
  @override
  RenderStack createRenderObject(BuildContext context) {
    return InfinityRenderStack(
      alignment: alignment,
      textDirection: textDirection ?? Directionality.maybeOf(context),
      fit: fit,
      clipBehavior: clipBehavior,
    );
  }
}

class InfinityRenderStack extends RenderStack {
  InfinityRenderStack({
    super.children,
    super.alignment = AlignmentDirectional.topStart,
    super.textDirection,
    super.fit = StackFit.loose,
    super.clipBehavior = Clip.hardEdge,
  });

  /// 通过复写这里的点击检测代码解除stack越界触摸限制
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // 原本的RenderBox的点击判定的源码需要进行box边界裁剪
    // if (_size!.contains(position)) {
    //   if (hitTestChildren(result, position: position) || hitTestSelf(position)) {
    //     result.add(BoxHitTestEntry(this, position));
    //     return true;
    //   }
    // }
    // override一下删除边界裁剪函数
    if (hitTestChildren(result, position: position) || hitTestSelf(position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }
}
