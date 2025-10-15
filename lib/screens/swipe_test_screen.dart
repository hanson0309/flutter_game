import 'package:flutter/material.dart';
import '../widgets/swipe_back_wrapper.dart';

/// 右滑返回功能测试页面
class SwipeTestScreen extends StatelessWidget {
  const SwipeTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SwipeBackScaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        title: const Text(
          '右滑返回测试',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1a1a1a),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.swipe,
              size: 80,
              color: Color(0xFFe94560),
            ),
            const SizedBox(height: 32),
            const Text(
              '🎉 右滑返回功能已启用！',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              '📱 在手机上：从屏幕左边缘（50像素内）向右滑动返回\n💻 在桌面上：可以用鼠标从左边缘拖拽测试',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a1a),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF333333)),
              ),
              child: const Column(
                children: [
                  Text(
                    '✅ 已更新的页面：',
                    style: TextStyle(
                      color: Color(0xFFe94560),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '• 设置页面\n• 成就页面\n• 战斗页面\n• 探索页面\n• 背包页面\n• 商店页面\n• 统计页面\n• 任务页面',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SwipeTestScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('打开另一个测试页面'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFe94560),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('普通返回（按钮）'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFe94560)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
