import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player.dart';
import '../models/equipment.dart';
import '../providers/game_provider.dart';
import '../widgets/swipe_back_wrapper.dart';

class CharacterInfoScreen extends StatefulWidget {
  const CharacterInfoScreen({super.key});

  @override
  State<CharacterInfoScreen> createState() => _CharacterInfoScreenState();
}

class _CharacterInfoScreenState extends State<CharacterInfoScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  // 格式化灵石显示
  String _formatSpiritStones(int spiritStones) {
    if (spiritStones >= 100000000) {
      return '${(spiritStones / 100000000).toStringAsFixed(2)}亿';
    } else if (spiritStones >= 10000) {
      return '${(spiritStones / 10000).toStringAsFixed(1)}万';
    } else {
      return spiritStones.toString();
    }
  }


  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _floatingAnimation = Tween<double>(begin: -3, end: 3).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SwipeBackScaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgrounds/info_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213e).withOpacity(0.8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            final player = gameProvider.player!;
            return Row(
              children: [
                // 左侧：境界和等级
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '${player.currentRealm.name} ${(player.levelProgress * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const Spacer(),
                // 右侧：资源
                Row(
                  children: [
                    const Icon(Icons.diamond, color: Colors.blue, size: 16),
                    Text(' ${_formatSpiritStones(player.spiritStones)}', 
                         style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          final player = gameProvider.player!;
          
          return Column(
            children: [
              // 主要游戏区域
              _buildMainGameArea(player, gameProvider),
              
              // 固定的气血真元条
              _buildHealthBarsContainer(player),
              
              // 可滚动的属性区域
              _buildScrollableAttributes(player),
            ],
          );
        },
      ),
        ),
      ),
    );
  }


  // 主要游戏区域
  Widget _buildMainGameArea(Player player, GameProvider gameProvider) {
    return Container(
      height: 600, // 增加人物装备区域的高度
      child: Stack(
        children: [
          // 背景人物图片（主页同款浮动效果）
          Positioned(
            left: 0, // 居中显示
            right: 100, // 给装备留适当空间
            top: 0, // 从顶部开始
            bottom: 0, // 到底部结束
            child: AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatingAnimation.value * 2), // 轻微浮动，和主页一样
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('images/characters/character_stand.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // 右侧装备网格
          Positioned(
            right: 16,
            top: 20,
            child: _buildRightEquipmentGrid(player, gameProvider),
          ),
        ],
      ),
    );
  }


  // 右侧装备网格 (12个装备槽位，充分利用空间)
  Widget _buildRightEquipmentGrid(Player player, GameProvider gameProvider) {
    return Container(
      width: 110, // 稍微增加宽度以适应更好的间距
      child: Column(
        children: [
          // 第一行
          Row(
            children: [
              _buildEquipmentGridSlot('武器', Colors.yellow, EquipmentType.weapon, player, gameProvider),
              const SizedBox(width: 8), // 增加间距
              _buildEquipmentGridSlot('护甲', Colors.purple, EquipmentType.armor, player, gameProvider),
            ],
          ),
          const SizedBox(height: 10), // 稍微减少行间距以容纳更多装备
          // 第二行
          Row(
            children: [
              _buildEquipmentGridSlot('饰品', Colors.green, EquipmentType.accessory, player, gameProvider),
              const SizedBox(width: 8),
              _buildEquipmentGridSlot('法宝', Colors.purple, EquipmentType.treasure, player, gameProvider),
            ],
          ),
          const SizedBox(height: 10),
          // 第三行
          Row(
            children: [
              _buildEquipmentGridSlot('戒指', Colors.yellow, EquipmentType.ring, player, gameProvider),
              const SizedBox(width: 8),
              _buildEquipmentGridSlot('项链', Colors.green, EquipmentType.necklace, player, gameProvider),
            ],
          ),
          const SizedBox(height: 10),
          // 第四行
          Row(
            children: [
              _buildEquipmentGridSlot('靴子', Colors.green, EquipmentType.boots, player, gameProvider),
              const SizedBox(width: 8),
              _buildEquipmentGridSlot('腰带', Colors.green, EquipmentType.belt, player, gameProvider),
            ],
          ),
          const SizedBox(height: 10),
          // 第五行
          Row(
            children: [
              _buildEquipmentGridSlot('手套', Colors.blue, EquipmentType.gloves, player, gameProvider),
              const SizedBox(width: 8),
              _buildEquipmentGridSlot('头盔', Colors.blue, EquipmentType.helmet, player, gameProvider),
            ],
          ),
          const SizedBox(height: 10),
          // 第六行
          Row(
            children: [
              _buildEquipmentGridSlot('符文', Colors.red, EquipmentType.rune, player, gameProvider),
              const SizedBox(width: 8),
              _buildEquipmentGridSlot('宝石', Colors.cyan, EquipmentType.gem, player, gameProvider),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentGridSlot(String name, Color borderColor, EquipmentType type, Player player, GameProvider gameProvider) {
    final equippedItem = player.equippedItems[type.name];
    
    return GestureDetector(
      onTap: () => _showEquipmentOptions(type, gameProvider),
      child: Container(
        width: 50, // 稍微增加尺寸以配合更好的间距
        height: 50,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: equippedItem != null ? borderColor : borderColor.withOpacity(0.5), 
            width: 2
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                _getEquipmentIcon(type),
                color: equippedItem != null ? borderColor : Colors.white70,
                size: 24,
              ),
            ),
            if (equippedItem != null && equippedItem.enhanceLevel > 0)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '+${equippedItem.enhanceLevel}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }


  // 固定的血条容器（透明，上移）
  Widget _buildHealthBarsContainer(Player player) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8), // 上移，去掉顶部padding
      child: _buildHealthBars(player),
    );
  }

  // 压缩的属性区域
  Widget _buildScrollableAttributes(Player player) {
    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8), // 减少padding
          child: Column(
            children: [
              // 压缩的属性显示
              _buildAttributePanel(player),
              const SizedBox(height: 8), // 减少间距
              
              // 压缩的角色信息
              _buildCharacterInfo(player),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthBars(Player player) {
    return Column(
      children: [
        // 气血区域
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 气血标签（在条形外面）
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Text(
                '气血',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // 气血条
            Container(
              height: 16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red, width: 1),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [Colors.red[800]!, Colors.red[400]!],
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      '${player.currentHealth}/${player.actualMaxHealth.round()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 真元区域
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 真元标签（在条形外面）
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Text(
                '真元',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // 真元条
            Container(
              height: 16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue, width: 1),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [Colors.blue[800]!, Colors.blue[400]!],
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      '${player.currentMana}/${player.actualMaxMana.round()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttributePanel(Player player) {
    return Container(
      padding: const EdgeInsets.all(8), // 减少padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.grey[900]!.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(12), // 减少圆角
        border: Border.all(
          color: Colors.grey[600]!.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4, // 减少阴影
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assessment, color: Colors.white, size: 16), // 减少图标大小
              const SizedBox(width: 6),
              const Text(
                '属性',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14, // 减少字体大小
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // 减少间距
          Row(
            children: [
              Expanded(
                child: _buildEnhancedStatItem('攻击', '${player.actualAttack.round()}', Icons.flash_on, Colors.red, Colors.red[100]!),
              ),
              const SizedBox(width: 8), // 减少间距
              Expanded(
                child: _buildEnhancedStatItem('防御', '${player.actualDefense.round()}', Icons.shield, Colors.blue, Colors.blue[100]!),
              ),
            ],
          ),
          const SizedBox(height: 8), // 减少间距
          Row(
            children: [
              Expanded(
                child: _buildEnhancedStatItem('生命', '${player.actualMaxHealth.round()}', Icons.favorite, Colors.red, Colors.red[100]!),
              ),
              const SizedBox(width: 8), // 减少间距
              Expanded(
                child: _buildEnhancedStatItem('法力', '${player.actualMaxMana.round()}', Icons.auto_awesome, Colors.blue, Colors.blue[100]!),
              ),
            ],
          ),
          const SizedBox(height: 8), // 减少间距
          Row(
            children: [
              Expanded(
                child: _buildEnhancedStatItem('修炼速度', '${(player.cultivationSpeedMultiplier * 100).toStringAsFixed(1)}%', Icons.trending_up, Colors.green, Colors.green[100]!),
              ),
              const SizedBox(width: 8), // 减少间距
              Expanded(
                child: _buildEnhancedStatItem('经验加成', '${(player.expBonusMultiplier * 100 - 100).toStringAsFixed(1)}%', Icons.star, Colors.orange, Colors.orange[100]!),
              ),
            ],
          ),
          const SizedBox(height: 8), // 减少间距
          Row(
            children: [
              Expanded(
                child: _buildEnhancedStatItem('暴击率', '${(player.criticalRate * 100).toStringAsFixed(1)}%', Icons.flash_auto, Colors.yellow, Colors.yellow[100]!),
              ),
              const SizedBox(width: 8), // 减少间距
              Expanded(
                child: _buildEnhancedStatItem('暴击伤害', '${(player.criticalDamage * 100).toStringAsFixed(1)}%', Icons.whatshot, Colors.red, Colors.red[100]!),
              ),
            ],
          ),
          const SizedBox(height: 8), // 减少间距
          Row(
            children: [
              Expanded(
                child: _buildEnhancedStatItem('伤害减免', '${(player.damageReduction * 100).toStringAsFixed(1)}%', Icons.security, Colors.purple, Colors.purple[100]!),
              ),
              const SizedBox(width: 8), // 减少间距
              Expanded(
                child: _buildEnhancedStatItem('闪避率', '${(player.dodgeRate * 100).toStringAsFixed(1)}%', Icons.speed, Colors.cyan, Colors.cyan[100]!),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterInfo(Player player) {
    return Container(
      padding: const EdgeInsets.all(8), // 减少padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blueGrey[800]!.withOpacity(0.7),
            Colors.black.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(12), // 减少圆角
        border: Border.all(
          color: Colors.blueGrey[600]!.withOpacity(0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 3, // 减少阴影
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildEnhancedInfoItem('等级', '${player.level}', Icons.star, Colors.yellow),
          ),
          Container(
            width: 1,
            height: 30, // 减少分隔线高度
            color: Colors.grey[600]!.withOpacity(0.5),
          ),
          Expanded(
            child: _buildEnhancedInfoItem('境界', player.currentRealm.name, Icons.trending_up, Colors.orange),
          ),
          Container(
            width: 1,
            height: 30, // 减少分隔线高度
            color: Colors.grey[600]!.withOpacity(0.5),
          ),
          Expanded(
            child: _buildEnhancedInfoItem('灵石', _formatSpiritStones(player.spiritStones), Icons.diamond, Colors.cyan),
          ),
        ],
      ),
    );
  }


  Widget _buildEnhancedStatItem(String label, String value, IconData icon, Color primaryColor, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.all(6), // 减少padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.2),
            primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(8), // 减少圆角
        border: Border.all(
          color: primaryColor.withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 2, // 减少阴影
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: primaryColor,
            size: 18, // 减少图标大小
          ),
          const SizedBox(height: 4), // 减少间距
          Text(
            label,
            style: TextStyle(
              color: primaryColor,
              fontSize: 10, // 减少字体大小
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2), // 减少间距
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12, // 减少字体大小
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedInfoItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 获取装备类型对应的图标
  IconData _getEquipmentIcon(EquipmentType type) {
    switch (type) {
      case EquipmentType.weapon:
        return Icons.flash_on;
      case EquipmentType.armor:
        return Icons.shield;
      case EquipmentType.accessory:
        return Icons.circle;
      case EquipmentType.treasure:
        return Icons.auto_awesome;
      case EquipmentType.ring:
        return Icons.radio_button_unchecked;
      case EquipmentType.necklace:
        return Icons.favorite;
      case EquipmentType.boots:
        return Icons.directions_walk;
      case EquipmentType.belt:
        return Icons.horizontal_rule;
      case EquipmentType.gloves:
        return Icons.back_hand;
      case EquipmentType.helmet:
        return Icons.security;
      case EquipmentType.rune:
        return Icons.auto_fix_high;
      case EquipmentType.gem:
        return Icons.diamond;
    }
  }

  // 显示装备选项对话框
  void _showEquipmentOptions(EquipmentType type, GameProvider gameProvider) {
    final player = gameProvider.player!;
    final equippedItem = player.equippedItems[type.name];
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2a2a3e),
          title: Text(
            '${_getEquipmentTypeName(type)}',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (equippedItem != null) ...[
                Text(
                  equippedItem.equipment!.name,
                  style: TextStyle(
                    color: _getItemRarityColor(equippedItem.equipment!.rarity),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  equippedItem.equipment!.description,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  '强化等级: +${equippedItem.enhanceLevel}',
                  style: const TextStyle(color: Color(0xFFe94560)),
                ),
                Text(
                  '攻击力: +${equippedItem.equipment!.baseStats['attack'] ?? 0}',
                  style: const TextStyle(color: Colors.green),
                ),
                Text(
                  '防御力: +${equippedItem.equipment!.baseStats['defense'] ?? 0}',
                  style: const TextStyle(color: Colors.blue),
                ),
              ] else ...[
                const Text(
                  '未装备',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  '可以在背包中选择装备',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ],
          ),
          actions: [
            if (equippedItem != null)
              TextButton(
                onPressed: () {
                  gameProvider.unequipItem(type);
                  Navigator.pop(context);
                },
                child: const Text('卸下', style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showEquipmentSelection(type, gameProvider);
              },
              child: const Text('装备', style: TextStyle(color: Colors.green)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // 获取装备类型名称
  String _getEquipmentTypeName(EquipmentType type) {
    switch (type) {
      case EquipmentType.weapon:
        return '武器';
      case EquipmentType.armor:
        return '护甲';
      case EquipmentType.accessory:
        return '饰品';
      case EquipmentType.treasure:
        return '法宝';
      case EquipmentType.ring:
        return '戒指';
      case EquipmentType.necklace:
        return '项链';
      case EquipmentType.boots:
        return '靴子';
      case EquipmentType.belt:
        return '腰带';
      case EquipmentType.gloves:
        return '手套';
      case EquipmentType.helmet:
        return '头盔';
      case EquipmentType.rune:
        return '符文';
      case EquipmentType.gem:
        return '宝石';
    }
  }

  // 获取物品稀有度颜色
  Color _getItemRarityColor(EquipmentRarity rarity) {
    switch (rarity) {
      case EquipmentRarity.common:
        return Colors.white;
      case EquipmentRarity.uncommon:
        return Colors.green;
      case EquipmentRarity.rare:
        return Colors.blue;
      case EquipmentRarity.epic:
        return Colors.purple;
      case EquipmentRarity.legendary:
        return Colors.orange;
      case EquipmentRarity.mythic:
        return Colors.red;
    }
  }

  // 显示装备选择对话框
  void _showEquipmentSelection(EquipmentType type, GameProvider gameProvider) {
    final player = gameProvider.player!;
    
    // 获取对应类型的装备（从所有可用装备中筛选）
    final availableEquipments = Equipment.availableEquipment
        .where((equipment) => equipment.type == type)
        .where((equipment) => player.level >= equipment.requiredLevel)
        .toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2a2a3e),
          title: Text(
            '选择${_getEquipmentTypeName(type)}',
            style: const TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: availableEquipments.isEmpty
                ? const Center(
                    child: Text(
                      '没有可装备的物品',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: availableEquipments.length,
                    itemBuilder: (context, index) {
                      final equipment = availableEquipments[index];
                      return Card(
                        color: const Color(0xFF3a3a4e),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Icon(
                            _getEquipmentIcon(equipment.type),
                            color: _getItemRarityColor(equipment.rarity),
                            size: 32,
                          ),
                          title: Text(
                            equipment.name,
                            style: TextStyle(
                              color: _getItemRarityColor(equipment.rarity),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                equipment.description,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '等级要求: ${equipment.requiredLevel}',
                                style: const TextStyle(color: Colors.orange),
                              ),
                              if (equipment.baseStats.isNotEmpty)
                                Text(
                                  '属性: ${equipment.baseStats.entries.map((e) => '${e.key}+${e.value}').join(', ')}',
                                  style: const TextStyle(color: Colors.green),
                                ),
                            ],
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white70,
                            size: 16,
                          ),
                          onTap: () {
                            // 创建装备物品并装备
                            final equippedItem = EquippedItem(
                              equipmentId: equipment.id,
                              enhanceLevel: 0,
                            );
                            
                            if (gameProvider.equipItem(equippedItem)) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('成功装备 ${equipment.name}'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('装备失败'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
