enum BoardEventName {
  /// 当视口发生改变, 参数Matrix4
  onViewportChanged,

  /// 改变视口矩阵，参数Matrix4
  changeViewport,

  /// 当画板背景被点击
  onBoardTap,

  /// 当画板背景被右击
  onBoardMenu,

  /// 当某个模型被点击, modelId
  onModelTap,

  /// 当某个模型被长按或右击, int modelId, Offset boardLocalPosition
  onModelMenu,

  /// 当某个模型被移动中
  onModelMoving,

  /// 当某个模型移动完毕
  onModelMoved,

  /// 当某个模型置顶, modelId
  onModelBringToFront,

  /// 当某个模型置底, modelId
  onModelBringToBack,

  /// 当某个模型缩放中, modelId
  onModelResizing,

  /// 当某个模型缩放完毕, modelId
  onModelResized,

  /// 当某个模型旋转中, modelId
  onModelRotating,

  /// 当某个模型旋转完毕, modelId
  onModelRotated,

  /// 当某个模型被删除, modelId
  onModelDeleted,

  /// 刷新视图
  refreshBoard,

  /// 刷新某模型视图, modelId
  refreshModel,

  /// 当需要保存状态时
  saveState,
}
