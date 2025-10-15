import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/equipment.dart';
// import '../services/equipment_service.dart'; // 临时注释掉，文件不存在
import '../providers/game_provider.dart';
import '../widgets/swipe_back_wrapper.dart';
import '../widgets/inventory_item.dart';

class EquipmentScreen extends StatefulWidget {
  const EquipmentScreen({super.key});

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SwipeBackScaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text(
          '装备系统',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF16213e),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFe94560),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: '装备栏'),
            Tab(text: '背包'),
          ],
        ),
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          final player = gameProvider.player!;
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildEquipmentTab(player, gameProvider),
              _buildInventoryTab(player, gameProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEquipmentTab(player, GameProvider gameProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 战力显示
          Card(
            color: const Color(0xFF0f3460),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flash_on, color: Colors.amber, size: 32),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      const Text(
                        '总战力',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        player.totalPower.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 装备槽位
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    EquipmentSlot(
                      type: EquipmentType.weapon,
                      equippedItem: player.equippedItems['weapon'],
                      onTap: () => _showEquipmentDetails(
                        player.equippedItems['weapon'],
                        EquipmentType.weapon,
                        gameProvider,
                      ),
                    ),
                    const SizedBox(height: 16),
                    EquipmentSlot(
                      type: EquipmentType.armor,
                      equippedItem: player.equippedItems['armor'],
                      onTap: () => _showEquipmentDetails(
                        player.equippedItems['armor'],
                        EquipmentType.armor,
                        gameProvider,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    EquipmentSlot(
                      type: EquipmentType.accessory,
                      equippedItem: player.equippedItems['accessory'],
                      onTap: () => _showEquipmentDetails(
                        player.equippedItems['accessory'],
                        EquipmentType.accessory,
                        gameProvider,
                      ),
                    ),
                    const SizedBox(height: 16),
                    EquipmentSlot(
                      type: EquipmentType.treasure,
                      equippedItem: player.equippedItems['treasure'],
                      onTap: () => _showEquipmentDetails(
                        player.equippedItems['treasure'],
                        EquipmentType.treasure,
                        gameProvider,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 属性面板
          Card(
            color: const Color(0xFF0f3460),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '装备属性加成',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow('攻击力', '+${_getPlayerEquipmentStat(player, 'attack').toInt()}'),
                  _buildStatRow('防御力', '+${_getPlayerEquipmentStat(player, 'defense').toInt()}'),
                  _buildStatRow('生命值', '+${_getPlayerEquipmentStat(player, 'health').toInt()}'),
                  _buildStatRow('法力值', '+${_getPlayerEquipmentStat(player, 'mana').toInt()}'),
                  if (player.criticalRate > 0)
                    _buildStatRow('暴击率', '+${(player.criticalRate * 100).toStringAsFixed(1)}%'),
                  if (player.criticalDamage > 0)
                    _buildStatRow('暴击伤害', '+${(player.criticalDamage * 100).toStringAsFixed(1)}%'),
                  if (player.dodgeRate > 0)
                    _buildStatRow('闪避率', '+${(player.dodgeRate * 100).toStringAsFixed(1)}%'),
                  if (player.damageReduction > 0)
                    _buildStatRow('伤害减免', '+${(player.damageReduction * 100).toStringAsFixed(1)}%'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTab(player, GameProvider gameProvider) {
    if (player.inventory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.white54,
            ),
            const SizedBox(height: 16),
            const Text(
              '背包空空如也',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _giveStarterEquipment(gameProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFe94560),
                foregroundColor: Colors.white,
              ),
              child: const Text('获取新手装备'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: player.inventory.length,
      itemBuilder: (context, index) {
        final item = player.inventory[index];
        return InventoryItem(
          equippedItem: item,
          onTap: () => _showInventoryItemDetails(item, gameProvider),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  void _showEquipmentDetails(EquippedItem? equippedItem, EquipmentType type, GameProvider gameProvider) {
    if (equippedItem == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0f3460),
        title: Text(
          equippedItem.equipment?.name ?? '未知装备',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              equippedItem.equipment?.description ?? '',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Text(
              '强化等级: +${equippedItem.enhanceLevel}',
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '当前属性:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...equippedItem.getCurrentStats().entries.map(
              (entry) => Text(
                '${_getStatName(entry.key)}: +${entry.value.toStringAsFixed(1)}',
                style: const TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
          if (equippedItem.enhanceLevel < (equippedItem.equipment?.maxEnhanceLevel ?? 0))
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _enhanceEquipment(type, gameProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('强化 (${equippedItem.getNextEnhanceCost()} 灵石)'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _unequipItem(type, gameProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('卸下'),
          ),
        ],
      ),
    );
  }

  void _showInventoryItemDetails(EquippedItem item, GameProvider gameProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0f3460),
        title: Text(
          item.equipment?.name ?? '未知装备',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.equipment?.description ?? '',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Text(
              '需要等级: ${item.equipment?.requiredLevel ?? 0}',
              style: TextStyle(
                color: gameProvider.player!.level >= (item.equipment?.requiredLevel ?? 0)
                    ? Colors.green
                    : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '装备属性:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...item.getCurrentStats().entries.map(
              (entry) => Text(
                '${_getStatName(entry.key)}: +${entry.value.toStringAsFixed(1)}',
                style: const TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
          ElevatedButton(
            onPressed: gameProvider.player!.level >= (item.equipment?.requiredLevel ?? 0)
                ? () {
                    Navigator.of(context).pop();
                    _equipItem(item, gameProvider);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFe94560),
              foregroundColor: Colors.white,
            ),
            child: const Text('装备'),
          ),
        ],
      ),
    );
  }

  void _equipItem(EquippedItem item, GameProvider gameProvider) {
    if (gameProvider.player!.equipItem(item)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('成功装备 ${item.equipment?.name}'),
          backgroundColor: Colors.green,
        ),
      );
      gameProvider.saveGameData();
    }
  }

  void _unequipItem(EquipmentType type, GameProvider gameProvider) {
    if (gameProvider.player!.unequipItem(type)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('装备已卸下'),
          backgroundColor: Colors.blue,
        ),
      );
      gameProvider.saveGameData();
    }
  }

  void _enhanceEquipment(EquipmentType type, GameProvider gameProvider) {
    if (gameProvider.player!.enhanceEquipment(type)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('装备强化成功！'),
          backgroundColor: Colors.green,
        ),
      );
      gameProvider.saveGameData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('强化失败，灵石不足'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _giveStarterEquipment(GameProvider gameProvider) {
    final player = gameProvider.player!;
    
    // 给予新手装备
    player.addItemToInventory('wooden_sword');
    player.addItemToInventory('cloth_robe');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('获得新手装备：木剑、布袍'),
        backgroundColor: Colors.green,
      ),
    );
    
    gameProvider.saveGameData();
  }

  // 获取玩家装备属性加成的辅助方法
  double _getPlayerEquipmentStat(player, String statName) {
    double total = 0.0;
    for (final equippedItem in player.equippedItems.values) {
      if (equippedItem != null) {
        final stats = equippedItem.getCurrentStats();
        total += stats[statName] ?? 0.0;
      }
    }
    return total;
  }

  String _getStatName(String key) {
    switch (key) {
      case 'attack':
        return '攻击力';
      case 'defense':
        return '防御力';
      case 'health':
        return '生命值';
      case 'mana':
        return '法力值';
      case 'critical_rate':
        return '暴击率';
      case 'critical_damage':
        return '暴击伤害';
      case 'dodge_rate':
        return '闪避率';
      case 'damage_reduction':
        return '伤害减免';
      case 'skill_damage':
        return '技能伤害';
      case 'health_regen':
        return '生命恢复';
      case 'mana_regen':
        return '法力恢复';
      case 'cultivation_speed':
        return '修炼速度';
      case 'exp_bonus':
        return '经验加成';
      default:
        return key;
    }
  }
}
