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
  // 装备栏数据 - 8个槽位（左4个，右4个）
  List<EquipmentItem?> equippedItems = List.filled(8, null);
  

  // 计算装备加成
  double get equipmentAttackBonus {
    return equippedItems
        .where((item) => item != null)
        .fold(0.0, (sum, item) => sum + item!.attackBonus);
  }

  double get equipmentDefenseBonus {
    return equippedItems
        .where((item) => item != null)
        .fold(0.0, (sum, item) => sum + item!.defenseBonus);
  }

  double get equipmentHealthBonus {
    return equippedItems
        .where((item) => item != null)
        .fold(0.0, (sum, item) => sum + item!.healthBonus);
  }

  double get equipmentManaBonus {
    return equippedItems
        .where((item) => item != null)
        .fold(0.0, (sum, item) => sum + item!.manaBonus);
  }

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
                          Consumer<GameProvider>(
                            builder: (context, gameProvider, child) {
                              final player = gameProvider.player!;
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.cyan.withOpacity(0.2),
                                      Colors.blue.withOpacity(0.2),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: Colors.cyan.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  player.currentRealm.name,
                                  style: const TextStyle(
                                    color: Colors.cyan,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 人物区域 - 占据大部分页面
                  Expanded(
                    flex: 10,
                    child: _buildCharacterArea(context, player),
                  ),
                  // 血条和蓝条
                  _buildHealthManaBar(player),
                  // 属性信息区域
                  Expanded(
                    flex: 2,
                    child: _buildAttributesArea(player),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // 人物区域 - 占据大部分页面
  Widget _buildCharacterArea(BuildContext context, Player player) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // 左侧格子区域
          _buildSideSlots(context, true),
          // 人物区域
          Expanded(
            flex: 3,
            child: Container(
              child: Image.asset(
                'assets/images/characters/character_stand.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // 如果图片加载失败，显示默认图标
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.cyan.withOpacity(0.2),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 400,
                      color: Colors.cyan.withOpacity(0.8),
                    ),
                  );
                },
              ),
            ),
          ),
          // 右侧格子区域
          _buildSideSlots(context, false),
        ],
      ),
    );
  }

  // 构建左右两侧的格子
  Widget _buildSideSlots(BuildContext context, bool isLeft) {
    return Container(
      width: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          final slotIndex = isLeft ? index : index + 4;
          final equippedItem = equippedItems[slotIndex];
          
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
        }),
      ),
    );
  }

  // 处理装备槽位点击
  void _handleSlotTap(BuildContext context, int slotIndex) {
    final equippedItem = equippedItems[slotIndex];
    
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
                _unequipItem(slotIndex);
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
            final player = gameProvider.player!;
            
            return AlertDialog(
              backgroundColor: const Color(0xFF1a1a2e),
              title: Text(
                '选择装备',
                style: const TextStyle(
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
                      child: Consumer<GameProvider>(
                        builder: (context, gameProvider, child) {
                          return ListView(
                            children: gameProvider.globalInventory
                                .where((item) => !equippedItems.contains(item))
                                .map((item) => _buildSelectableEquipmentItem(context, item, slotIndex))
                                .toList(),
                          );
                        },
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

  // 显示背包界面
  void _showInventory(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            final player = gameProvider.player!;
            
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
    final isEquipped = equippedItems.contains(item);
    
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

  // 构建装备项
  Widget _buildEquipmentItem(BuildContext context, String name, String description) {
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
              color: Colors.amber.withOpacity(0.2),
            ),
            child: const Icon(
              Icons.shield,
              color: Colors.amber,
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
          IconButton(
            onPressed: () {
              // 这里处理装备选择逻辑
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已装备: $name'),
                  backgroundColor: Colors.green.withOpacity(0.8),
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

  // 血条和蓝条
  Widget _buildHealthManaBar(Player player) {
    final totalMaxHealth = player.actualMaxHealth + equipmentHealthBonus;
    final totalMaxMana = player.actualMaxMana + equipmentManaBonus;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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

  // 属性信息区域
  Widget _buildAttributesArea(Player player) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildAttributesSection(player),
            const SizedBox(height: 16),
            _buildCultivationSection(player),
            const SizedBox(height: 16),
            _buildResourcesSection(player),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributesSection(Player player) {
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
          _buildAttributeRow('总战力', (player.totalPower + equipmentAttackBonus + equipmentDefenseBonus).toStringAsFixed(0), Colors.amber, Icons.star),
          _buildEnhancedAttributeRow('攻击力', player.actualAttack, equipmentAttackBonus, Colors.red, Icons.flash_on),
          _buildEnhancedAttributeRow('防御力', player.actualDefense, equipmentDefenseBonus, Colors.blue, Icons.security),
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

  // 卸载装备
  void _unequipItem(int slotIndex) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    setState(() {
      final unequippedItem = equippedItems[slotIndex];
      if (unequippedItem != null) {
        equippedItems[slotIndex] = null;
        // 将装备放回全局背包
        gameProvider.addEquipmentToInventory(unequippedItem);
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('装备已卸载'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // 装备物品
  void _equipItem(EquipmentItem item, int slotIndex) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    setState(() {
      // 如果槽位已有装备，先卸载
      if (equippedItems[slotIndex] != null) {
        final oldItem = equippedItems[slotIndex]!;
        gameProvider.addEquipmentToInventory(oldItem);
      }
      
      // 装备新物品
      equippedItems[slotIndex] = item;
      gameProvider.removeEquipmentFromInventory(item);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已装备: ${item.name}'),
        backgroundColor: Colors.green,
      ),
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
              _equipItem(item, slotIndex);
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
}
