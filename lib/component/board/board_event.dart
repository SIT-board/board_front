enum BoardEventName {
  /// 当视口发生改变, 参数Matrix4
  onViewportChanged,

  /// 当画板背景被点击
  onBoardTap,

  /// 当画板背景被右击
  onBoardMenu,

  /// 当某个模型被点击
  onModelTap,

  /// 当某个模型被长按或右击
  onModelMenu,

  /// 当某个模型被移动中
  onModelMoving,

  /// 当某个模型移动完毕
  onModelMoved,

  /// 当某个模型置顶
  onModelBringToFront,

  /// 当某个模型置底
  onModelBringToBack,

  /// 当某个模型缩放中
  onModelResizing,

  /// 当某个模型缩放完毕
  onModelResized,

  /// 当某个模型旋转中
  onModelRotating,

  /// 当某个模型旋转完毕
  onModelRotated,

  /// 当某个模型被删除
  onModelDeleted,

  /// 刷新视图
  refreshBoard,
}
