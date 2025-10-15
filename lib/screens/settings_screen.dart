import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../providers/game_provider.dart';
import '../widgets/swipe_back_wrapper.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SwipeBackScaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        title: const Text(
          '游戏设置',
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
      body: Consumer<AudioService>(
        builder: (context, audioService, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 音效设置卡片
                _buildSettingsCard(
                  '音效设置',
                  Icons.volume_up,
                  [
                    _buildSwitchTile(
                      '背景音乐',
                      '开启/关闭背景音乐',
                      Icons.music_note,
                      audioService.isMusicEnabled,
                      (value) => audioService.setMusicEnabled(value),
                    ),
                    _buildSliderTile(
                      '音乐音量',
                      '调节背景音乐音量',
                      Icons.volume_down,
                      audioService.musicVolume,
                      audioService.isMusicEnabled,
                      (value) => audioService.setMusicVolume(value),
                    ),
                    const Divider(color: Color(0xFF333333)),
                    _buildSwitchTile(
                      '音效',
                      '开启/关闭游戏音效',
                      Icons.volume_up,
                      audioService.isSfxEnabled,
                      (value) => audioService.setSfxEnabled(value),
                    ),
                    _buildSliderTile(
                      '音效音量',
                      '调节游戏音效音量',
                      Icons.volume_down,
                      audioService.sfxVolume,
                      audioService.isSfxEnabled,
                      (value) => audioService.setSfxVolume(value),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTestButton('测试音效', () => audioService.playClickSound()),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildTestButton('测试音乐', () => audioService.playGameplayMusic()),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 游戏设置卡片
                _buildSettingsCard(
                  '游戏设置',
                  Icons.gamepad,
                  [
                    _buildActionTile(
                      '重置游戏数据',
                      '清除所有游戏进度和数据',
                      Icons.refresh,
                      Colors.red,
                      () => _showResetGameDialog(context),
                    ),
                    _buildActionTile(
                      '导出存档',
                      '导出游戏存档数据',
                      Icons.file_download,
                      Colors.blue,
                      () => _showComingSoon(context, '导出存档'),
                    ),
                    _buildActionTile(
                      '导入存档',
                      '导入游戏存档数据',
                      Icons.file_upload,
                      Colors.green,
                      () => _showComingSoon(context, '导入存档'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 关于游戏卡片
                _buildSettingsCard(
                  '关于游戏',
                  Icons.info,
                  [
                    _buildInfoTile('游戏名称', '修仙之路'),
                    _buildInfoTile('版本', '1.0.0'),
                    _buildInfoTile('开发者', 'Hanson'),
                    _buildInfoTile('引擎', 'Flutter 3.9.2'),
                    const SizedBox(height: 16),
                    _buildActionTile(
                      '检查更新',
                      '检查是否有新版本',
                      Icons.system_update,
                      Colors.orange,
                      () => _showComingSoon(context, '检查更新'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsCard(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFe94560), size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.grey, size: 20),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFFe94560),
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    String subtitle,
    IconData icon,
    double value,
    bool enabled,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: Colors.grey, size: 20),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          trailing: Text(
            '${(value * 100).round()}%',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        Slider(
          value: value,
          onChanged: enabled ? onChanged : null,
          activeColor: const Color(0xFFe94560),
          inactiveColor: Colors.grey,
          divisions: 10,
        ),
      ],
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor, size: 20),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFe94560),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(text),
      ),
    );
  }

  void _showResetGameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Text(
          '⚠️ 重置游戏',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '确定要重置所有游戏数据吗？此操作不可撤销！',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '取消',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // 重置游戏数据
              final gameProvider = Provider.of<GameProvider>(context, listen: false);
              await gameProvider.resetGame();
              
              // 显示重置成功提示
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('游戏数据已重置'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text(
              '确定',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature 功能即将推出'),
        backgroundColor: const Color(0xFFe94560),
      ),
    );
  }
}
