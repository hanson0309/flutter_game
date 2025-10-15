import 'package:flutter/material.dart';

/// 通用的右滑返回包装器
/// 包装任何页面内容，添加右滑返回功能
class SwipeBackWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeBack;
  final double swipeThreshold;
  final bool enabled;
  final double edgeWidth; // 边缘检测宽度

  const SwipeBackWrapper({
    Key? key,
    required this.child,
    this.onSwipeBack,
    this.swipeThreshold = 100.0, // 右滑速度阈值
    this.enabled = true,
    this.edgeWidth = 50.0, // 左边缘检测区域宽度
  }) : super(key: key);

  @override
  State<SwipeBackWrapper> createState() => _SwipeBackWrapperState();
}

class _SwipeBackWrapperState extends State<SwipeBackWrapper> {
  bool _isSwipeFromEdge = false;
  double _startX = 0.0;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return GestureDetector(
      onPanStart: (details) {
        // 记录开始位置
        _startX = details.globalPosition.dx;
        // 检查是否从左边缘开始滑动
        _isSwipeFromEdge = _startX <= widget.edgeWidth;
      },
      onPanUpdate: (details) {
        // 只有从边缘开始的滑动才处理
        if (_isSwipeFromEdge && details.delta.dx > 0) {
          // 可以在这里添加视觉反馈
        }
      },
      onPanEnd: (details) {
        // 只有从边缘开始的滑动才检测返回手势
        if (_isSwipeFromEdge) {
          final double distance = details.globalPosition.dx - _startX;
          final double velocity = details.velocity.pixelsPerSecond.dx;
          
          // 检查滑动距离和速度
          if (distance > 50 || velocity > widget.swipeThreshold) {
            _handleSwipeBack(context);
          }
        }
        _isSwipeFromEdge = false;
      },
      child: widget.child,
    );
  }

  void _handleSwipeBack(BuildContext context) {
    if (widget.onSwipeBack != null) {
      widget.onSwipeBack!();
    } else {
      // 默认行为：返回上一页
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }
}

/// 带有右滑返回功能的Scaffold包装器
class SwipeBackScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? backgroundColor;
  final VoidCallback? onSwipeBack;
  final bool enableSwipeBack;
  final double swipeThreshold;
  final double edgeWidth;

  const SwipeBackScaffold({
    Key? key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.onSwipeBack,
    this.enableSwipeBack = true,
    this.swipeThreshold = 100.0,
    this.edgeWidth = 50.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwipeBackWrapper(
      enabled: enableSwipeBack,
      onSwipeBack: onSwipeBack,
      swipeThreshold: swipeThreshold,
      edgeWidth: edgeWidth,
      child: Scaffold(
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
        drawer: drawer,
        endDrawer: endDrawer,
        backgroundColor: backgroundColor,
      ),
    );
  }
}
