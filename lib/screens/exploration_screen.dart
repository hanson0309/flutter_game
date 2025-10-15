import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/battle.dart';
import '../services/battle_service.dart';
import '../providers/game_provider.dart';
import '../widgets/swipe_back_wrapper.dart';
import 'battle_screen.dart';

class ExplorationScreen extends StatelessWidget {
  const ExplorationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SwipeBackScaffold(
      appBar: AppBar(
        title: const Text('探索'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E7D32),
              Color(0xFF388E3C),
              Color(0xFF4CAF50),
            ],
          ),
        ),
        child: Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            final player = gameProvider.player;
            if (player == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 玩家信息卡片
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            player.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('境界: ${player.currentRealm.name}'),
                          Text('等级: ${player.level}'),
                          Text('战力: ${player.totalPower}'),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 探索区域
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildExplorationCard(
                          '新手村',
                          '适合初学者的安全区域\n敌人等级: 1-2',
                          Icons.home,
                          Colors.green,
                          () => _startBattle(context, 'newbie_village'),
                        ),
                        _buildExplorationCard(
                          '幽暗森林',
                          '危险的森林，有丰富的资源\n敌人等级: 2-5',
                          Icons.forest,
                          Colors.brown,
                          () => _startBattle(context, 'dark_forest'),
                        ),
                        _buildExplorationCard(
                          '灵石矿洞',
                          '可以挖掘灵石的神秘洞穴\n敌人等级: 5-10',
                          Icons.diamond,
                          Colors.blue,
                          () => _startBattle(context, 'spirit_cave'),
                        ),
                        _buildExplorationCard(
                          '古老遗迹',
                          '充满宝藏的远古遗迹\n敌人等级: 10+',
                          Icons.account_balance,
                          Colors.purple,
                          () => _startBattle(context, 'ancient_ruins'),
                        ),
                      ],
                    ),
                  ),
                  
                  // 快速修炼按钮
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        gameProvider.manualTrain();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('修炼完成！获得经验值'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        '快速修炼',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildExplorationCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startBattle(BuildContext context, String areaId) {
    final battleService = Provider.of<BattleService>(context, listen: false);
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final player = gameProvider.player;
    
    if (player == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('玩家数据未加载')),
      );
      return;
    }
    
    // 获取该区域的敌人
    final enemies = battleService.getEnemiesByArea(areaId);
    if (enemies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('该区域暂无敌人')),
      );
      return;
    }
    
    // 随机选择1-2个敌人
    final random = enemies..shuffle();
    final selectedEnemies = random.take(1 + (player.level > 5 ? 1 : 0)).toList();
    final enemyIds = selectedEnemies.map((e) => e.id).toList();
    
    // 显示战斗确认对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: Text(
          _getAreaName(areaId),
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '即将遭遇敌人:',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...selectedEnemies.map((enemy) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    _getEnemyTypeIcon(enemy.type),
                    color: enemy.typeColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${enemy.name} (Lv.${enemy.level})',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            )).toList(),
            const SizedBox(height: 16),
            const Text(
              '确定要开始战斗吗？',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BattleScreen(enemyIds: enemyIds),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFe94560),
              foregroundColor: Colors.white,
            ),
            child: const Text('开始战斗'),
          ),
        ],
      ),
    );
  }

  String _getAreaName(String areaId) {
    switch (areaId) {
      case 'newbie_village':
        return '新手村探索';
      case 'dark_forest':
        return '幽暗森林探索';
      case 'spirit_cave':
        return '灵石矿洞探索';
      case 'ancient_ruins':
        return '古老遗迹探索';
      default:
        return '未知区域';
    }
  }

  IconData _getEnemyTypeIcon(EnemyType type) {
    switch (type) {
      case EnemyType.beast:
        return Icons.pets;
      case EnemyType.demon:
        return Icons.whatshot;
      case EnemyType.cultivator:
        return Icons.person;
      case EnemyType.spirit:
        return Icons.blur_on;
      case EnemyType.undead:
        return Icons.dangerous;
    }
  }
}
