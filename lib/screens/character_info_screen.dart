import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player.dart';
import '../models/equipment_item.dart';
import '../providers/game_provider.dart';
import '../widgets/swipe_back_wrapper.dart';

class CharacterInfoScreen extends StatefulWidget {
  const CharacterInfoScreen({super.key});

  @override
  State<CharacterInfoScreen> createState() => _CharacterInfoScreenState();
}

class _CharacterInfoScreenState extends State<CharacterInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return SwipeBackScaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          final player = gameProvider.player!;
          
          return Stack(
            children: [
              // 背景渐变
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1a1a3a),
                      Color(0xFF0a0a1a),
                    ],
                  ),
                ),
              ),
              // 主要内容
              Column(
                children: [
                  // 顶部区域 - 返回按钮和等级
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // 返回按钮
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                          ),
                          const Spacer(),
                          // 背包按钮
                          IconButton(
                            onPressed: () => _showInventory(context),
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.amber.withOpacity(0.2),
                                border: Border.all(
                                  color: Colors.amber.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.backpack,
                                color: Colors.amber,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 等级信息
                          Text(
                            '${player.currentRealm.name} ${((player.currentExp / player.currentRealm.maxExp) * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Colors.cyan,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 人物区域 - 减少空间
                  Expanded(
                    flex: 8,
                    child: _buildCharacterArea(context, player),
                  ),
                  // 血条和蓝条
                  _buildHealthManaBar(context, player, gameProvider),
                  // 属性信息区域 - 增加空间
                  Expanded(
                    flex: 3,
                    child: _buildAttributesArea(context, player, gameProvider),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // 显示背包界面
  void _showInventory(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1a1a2e),
              title: const Text(
                '背包',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Container(
                width: double.maxFinite,
                height: 400,
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      // 标签栏
                      TabBar(
                        indicatorColor: Colors.amber,
                        labelColor: Colors.amber,
                        unselectedLabelColor: Colors.white70,
                        tabs: const [
                          Tab(text: '装备'),
                          Tab(text: '道具'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 标签内容
                      Expanded(
                        child: TabBarView(
                          children: [
                            // 装备标签
                            _buildEquipmentTab(context),
                            // 道具标签
                            _buildItemsTab(context),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    '关闭',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 装备标签内容
  Widget _buildEquipmentTab(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return ListView(
          children: gameProvider.globalInventory
              .map((item) => _buildInventoryEquipmentItem(context, item))
              .toList(),
        );
      },
    );
  }

  // 构建背包中的装备项
  Widget _buildInventoryEquipmentItem(BuildContext context, EquipmentItem item) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final isEquipped = gameProvider.equippedItems.contains(item);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white.withOpacity(0.05),
            border: Border.all(
              color: isEquipped ? Colors.green.withOpacity(0.5) : Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: item.color.withOpacity(0.2),
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            color: item.color,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isEquipped) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.green.withOpacity(0.2),
                            ),
                            child: const Text(
                              '已装备',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      item.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isEquipped)
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20,
                )
              else
                const Text(
                  'x1',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // 道具标签内容
  Widget _buildItemsTab(BuildContext context) {
    return ListView(
      children: [
        _buildInventoryItem(context, '回血丹', '恢复100点生命值', Icons.healing, Colors.red),
        _buildInventoryItem(context, '回蓝丹', '恢复80点法力值', Icons.water_drop, Colors.blue),
        _buildInventoryItem(context, '经验丹', '获得50点经验', Icons.star, Colors.yellow),
        _buildInventoryItem(context, '灵石', '修炼货币', Icons.diamond, Colors.amber),
        _buildInventoryItem(context, '功法卷轴', '学习新功法', Icons.article, Colors.purple),
      ],
    );
  }

  // 构建背包物品
  Widget _buildInventoryItem(BuildContext context, String name, String description, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: color.withOpacity(0.2),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'x1',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterArea(BuildContext context, Player player) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10), // 减少边距
      child: Stack(
        children: [
          // 人物图片 - 居中显示，占据更大空间
          Center(
            child: Image.asset(
              'assets/images/characters/character_stand.png',
              height: 500, // 设置更大的高度
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // 如果图片加载失败，显示默认图标
                return Icon(
                  Icons.person,
                  size: 400,
                  color: Colors.cyan.withOpacity(0.8),
                );
              },
            ),
          ),
          // 左侧装备槽位 - 绝对定位
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 80,
              child: _buildSideSlots(context, true),
            ),
          ),
          // 右侧装备槽位 - 绝对定位
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 80,
              child: _buildSideSlots(context, false),
            ),
          ),
          // 右侧一键装备按钮 - 独立定位
          Positioned(
            right: 7,
            bottom: 20,
            child: Container(
              width: 65,
              height: 30,
              child: Consumer<GameProvider>(
                builder: (context, gameProvider, child) {
                  return ElevatedButton(
                    onPressed: () => _autoEquipAll(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.withOpacity(0.8),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text(
                      '一键装备',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建左右两侧的装备槽位
  Widget _buildSideSlots(BuildContext context, bool isLeft) {
    List<Widget> children = List.generate(4, (index) {
      final slotIndex = isLeft ? index : index + 4;
      return Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          final equippedItem = gameProvider.equippedItems[slotIndex];
          
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: equippedItem != null 
                    ? equippedItem.color.withOpacity(0.6)
                    : Colors.white.withOpacity(0.3),
                width: 2,
              ),
              color: equippedItem != null 
                  ? equippedItem.color.withOpacity(0.1)
                  : Colors.black.withOpacity(0.2),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _handleSlotTap(context, slotIndex),
                child: Center(
                  child: equippedItem != null
                      ? Icon(
                          equippedItem.icon,
                          color: equippedItem.color,
                          size: 24,
                        )
                      : Icon(
                          Icons.add,
                          color: Colors.white.withOpacity(0.5),
                          size: 20,
                        ),
                ),
              ),
            ),
          );
        },
      );
    });


    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  // 处理装备槽位点击
  void _handleSlotTap(BuildContext context, int slotIndex) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final equippedItem = gameProvider.equippedItems[slotIndex];
    
    if (equippedItem != null) {
      // 如果已有装备，显示装备详情和卸载选项
      _showEquippedItemDialog(context, slotIndex, equippedItem);
    } else {
      // 如果没有装备，显示装备选择界面
      _showEquipmentSelection(context, slotIndex);
    }
  }

  // 显示已装备物品的详情对话框
  void _showEquippedItemDialog(BuildContext context, int slotIndex, EquipmentItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1a1a2e),
          title: Text(
            item.name,
            style: TextStyle(
              color: item.color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                color: item.color,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                item.description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                final gameProvider = Provider.of<GameProvider>(context, listen: false);
                gameProvider.unequipItem(slotIndex);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('装备已卸载'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              child: const Text(
                '卸载',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '取消',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        );
      },
    );
  }

  // 显示装备选择对话框
  void _showEquipmentSelection(BuildContext context, int slotIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1a1a2e),
              title: const Text(
                '选择装备',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Container(
                width: double.maxFinite,
                height: 300,
                child: Column(
                  children: [
                    Text(
                      '选择要装备的物品 - 槽位 ${slotIndex + 1}',
                      style: const TextStyle(
                        color: Colors.cyan,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        children: gameProvider.globalInventory
                            .where((item) => !gameProvider.equippedItems.contains(item))
                            .map((item) => _buildSelectableEquipmentItem(context, item, slotIndex))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    '取消',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 构建可选择的装备项
  Widget _buildSelectableEquipmentItem(BuildContext context, EquipmentItem item, int slotIndex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: item.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: item.color.withOpacity(0.2),
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    color: item.color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  item.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
              final gameProvider = Provider.of<GameProvider>(context, listen: false);
              gameProvider.equipItem(item, slotIndex);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已装备: ${item.name}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(
              Icons.add_circle,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthManaBar(BuildContext context, Player player, GameProvider gameProvider) {
    final totalMaxHealth = player.actualMaxHealth + gameProvider.equipmentHealthBonus;
    final totalMaxMana = player.actualMaxMana + gameProvider.equipmentManaBonus;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        children: [
          // 血条
          _buildBar(
            '生命值',
            player.currentHealth,
            totalMaxHealth,
            Colors.red,
            Colors.red.withOpacity(0.3),
            Icons.favorite,
          ),
          const SizedBox(height: 8),
          // 蓝条
          _buildBar(
            '法力值',
            player.currentMana,
            totalMaxMana,
            Colors.blue,
            Colors.blue.withOpacity(0.3),
            Icons.auto_awesome,
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double current, double max, Color color, Color backgroundColor, IconData icon) {
    final percentage = max > 0 ? current / max : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '${current.toStringAsFixed(0)}/${max.toStringAsFixed(0)}',
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: backgroundColor,
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttributesArea(BuildContext context, Player player, GameProvider gameProvider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildAttributesSection(player, gameProvider),
            const SizedBox(height: 16),
            _buildCultivationSection(player),
            const SizedBox(height: 16),
            _buildResourcesSection(player),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributesSection(Player player, GameProvider gameProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '属性',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildAttributeRow('总战力', (player.totalPower + gameProvider.equipmentAttackBonus + gameProvider.equipmentDefenseBonus).toStringAsFixed(0), Colors.amber, Icons.star),
          _buildEnhancedAttributeRow('攻击力', player.actualAttack, gameProvider.equipmentAttackBonus, Colors.red, Icons.flash_on),
          _buildEnhancedAttributeRow('防御力', player.actualDefense, gameProvider.equipmentDefenseBonus, Colors.blue, Icons.security),
        ],
      ),
    );
  }

  Widget _buildCultivationSection(Player player) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '修炼信息',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildAttributeRow('当前经验', '${player.currentExp}/${player.currentRealm.maxExp}', Colors.yellow, Icons.star),
          _buildAttributeRow('总经验', player.totalExp.toString(), Colors.orange, Icons.trending_up),
          _buildAttributeRow('修炼点', player.cultivationPoints.toString(), Colors.purple, Icons.auto_awesome),
          const SizedBox(height: 12),
          // 升级进度条
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '升级进度',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    '${(player.levelProgress * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(color: Colors.cyan, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Colors.grey.withOpacity(0.3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: player.levelProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: const LinearGradient(
                        colors: [Colors.cyan, Colors.blue],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesSection(Player player) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '资源',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildAttributeRow('灵石', player.spiritStones.toString(), Colors.amber, Icons.diamond),
          _buildAttributeRow('已学功法', player.learnedTechniques.length.toString(), Colors.purple, Icons.menu_book),
        ],
      ),
    );
  }

  Widget _buildAttributeRow(String label, String value, Color valueColor, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: valueColor, size: 16),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 增强属性行 - 显示基础属性和装备加成
  Widget _buildEnhancedAttributeRow(String label, double baseValue, double equipmentBonus, Color valueColor, IconData icon) {
    final totalValue = baseValue + equipmentBonus;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: valueColor, size: 16),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                totalValue.toStringAsFixed(1),
                style: TextStyle(
                  color: valueColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (equipmentBonus > 0)
                Text(
                  '${baseValue.toStringAsFixed(1)} + ${equipmentBonus.toStringAsFixed(1)}',
                  style: TextStyle(
                    color: Colors.green.withOpacity(0.8),
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // 一键装备所有可装备的装备
  void _autoEquipAll(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final player = gameProvider.player;
    
    if (player == null) return;
    
    int equippedCount = 0;
    List<String> equippedItems = [];
    
    // 遍历背包中的所有装备
    for (final item in List.from(gameProvider.globalInventory)) {
      // 检查是否已经装备了这个物品
      bool alreadyEquipped = gameProvider.equippedItems.any((equipped) => 
        equipped != null && equipped.id == item.id && equipped.name == item.name);
      
      if (alreadyEquipped) continue;
      
      // 根据装备类型找到合适的槽位
      int? targetSlot = _findBestSlotForItem(item, gameProvider);
      
      if (targetSlot != null) {
        // 装备物品
        gameProvider.equipItem(item, targetSlot);
        equippedCount++;
        equippedItems.add(item.name);
        
        // 限制一次最多装备8件（避免过多操作）
        if (equippedCount >= 8) break;
      }
    }
    
    // 显示装备结果
    if (equippedCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✨ 一键装备完成！装备了 $equippedCount 件装备'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('💡 没有找到可装备的装备'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  
  // 为装备找到最佳槽位
  int? _findBestSlotForItem(EquipmentItem item, GameProvider gameProvider) {
    // 根据装备名称和属性判断装备类型，然后分配到合适的槽位
    // 槽位分配：0-3左侧，4-7右侧
    
    // 武器类装备 - 优先右上角槽位
    if (item.name.contains('剑') || item.name.contains('刀') || item.name.contains('枪') || item.attackBonus > 0) {
      for (int slot in [4, 5, 6, 7]) {
        if (gameProvider.equippedItems[slot] == null) return slot;
      }
    }
    
    // 防具类装备 - 优先左侧槽位
    if (item.name.contains('甲') || item.name.contains('盾') || item.name.contains('护') || item.defenseBonus > 0) {
      for (int slot in [0, 1, 2, 3]) {
        if (gameProvider.equippedItems[slot] == null) return slot;
      }
    }
    
    // 法术类装备 - 优先右侧槽位
    if (item.name.contains('法') || item.name.contains('帽') || item.name.contains('冠') || item.manaBonus > 0) {
      for (int slot in [4, 5, 6, 7]) {
        if (gameProvider.equippedItems[slot] == null) return slot;
      }
    }
    
    // 饰品类装备 - 优先左侧槽位
    if (item.name.contains('项链') || item.name.contains('戒指') || item.name.contains('护符') || item.healthBonus > 0) {
      for (int slot in [0, 1, 2, 3]) {
        if (gameProvider.equippedItems[slot] == null) return slot;
      }
    }
    
    // 如果没有找到特定类型的槽位，找任意空槽位
    for (int slot = 0; slot < 8; slot++) {
      if (gameProvider.equippedItems[slot] == null) return slot;
    }
    
    return null; // 没有空槽位
  }
}
