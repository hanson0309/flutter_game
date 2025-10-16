import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/equipment_synthesis.dart';
import '../models/equipment.dart';
import '../models/player.dart';
import '../services/equipment_synthesis_service.dart';
import '../providers/game_provider.dart';
import '../widgets/swipe_back_wrapper.dart';

class EquipmentSynthesisScreen extends StatefulWidget {
  const EquipmentSynthesisScreen({super.key});

  @override
  State<EquipmentSynthesisScreen> createState() => _EquipmentSynthesisScreenState();
}

class _EquipmentSynthesisScreenState extends State<EquipmentSynthesisScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  SynthesisRecipe? _selectedRecipe;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: EquipmentType.values.length + 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SwipeBackScaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        title: const Text(
          '装备合成',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1a1a1a),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: _showHelpDialog,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'test_materials') {
                _addTestMaterials();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'test_materials',
                child: Text('添加测试材料'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFe94560),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          isScrollable: true,
          tabs: [
            const Tab(text: '全部'),
            ...EquipmentType.values.map((type) => Tab(text: _getEquipmentTypeName(type))),
          ],
        ),
      ),
      body: Consumer2<EquipmentSynthesisService, GameProvider>(
        builder: (context, synthesisService, gameProvider, child) {
          final player = gameProvider.player;
          if (player == null) {
            return const Center(
              child: Text(
                '玩家数据加载中...',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return Row(
            children: [
              // 左侧配方列表
              Expanded(
                flex: 1,
                child: _buildRecipeList(synthesisService, player),
              ),
              
              // 右侧详情面板
              Expanded(
                flex: 1,
                child: _buildDetailPanel(synthesisService, player),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecipeList(EquipmentSynthesisService synthesisService, Player player) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        border: Border(
          right: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
      ),
      child: Column(
        children: [
          // 标题栏
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2a2a2a),
              border: Border(
                bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
            ),
            child: const Text(
              '合成配方',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // 配方列表
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRecipeGrid(synthesisService.getAvailableRecipes(player.level), synthesisService, player),
                ...EquipmentType.values.map((type) => 
                  _buildRecipeGrid(synthesisService.getRecipesByEquipmentType(type, player.level), synthesisService, player)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeGrid(List<SynthesisRecipe> recipes, EquipmentSynthesisService synthesisService, Player player) {
    if (recipes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '暂无可用配方',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        final canSynthesize = synthesisService.canSynthesize(recipe, player);
        final isSelected = _selectedRecipe?.id == recipe.id;

        return Card(
          color: isSelected ? const Color(0xFF3a3a3a) : const Color(0xFF2a2a2a),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: _buildEquipmentIcon(recipe.resultEquipment),
            title: Text(
              recipe.name,
              style: TextStyle(
                color: canSynthesize ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.resultEquipment?.name ?? '未知装备',
                  style: TextStyle(
                    color: recipe.resultEquipment?.qualityColor ?? Colors.grey,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '成功率: ${(recipe.successRate * 100).round()}%',
                  style: const TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  canSynthesize ? Icons.check_circle : Icons.cancel,
                  color: canSynthesize ? Colors.green : Colors.red,
                  size: 20,
                ),
                Text(
                  '${recipe.spiritStoneCost}灵石',
                  style: const TextStyle(color: Colors.yellow, fontSize: 10),
                ),
              ],
            ),
            onTap: () {
              setState(() {
                _selectedRecipe = recipe;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildDetailPanel(EquipmentSynthesisService synthesisService, Player player) {
    if (_selectedRecipe == null) {
      return Container(
        color: const Color(0xFF0a0a0a),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                '选择一个配方查看详情',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    final recipe = _selectedRecipe!;
    final canSynthesize = synthesisService.canSynthesize(recipe, player);
    final missingMaterials = synthesisService.getMissingMaterials(recipe);

    return Container(
      color: const Color(0xFF0a0a0a),
      child: Column(
        children: [
          // 装备信息
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a1a),
              border: Border(
                bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
            ),
            child: _buildEquipmentInfo(recipe.resultEquipment),
          ),
          
          // 材料需求
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '所需材料:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  ...recipe.materials.map((material) => 
                    _buildMaterialRequirement(material, synthesisService, missingMaterials)
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 灵石需求
                  if (recipe.spiritStoneCost > 0) ...[
                    _buildSpiritStoneRequirement(recipe.spiritStoneCost, player.spiritStones),
                    const SizedBox(height: 16),
                  ],
                  
                  // 等级需求
                  _buildLevelRequirement(recipe.requiredLevel, player.level),
                  const SizedBox(height: 16),
                  
                  // 成功率
                  _buildSuccessRate(recipe.successRate),
                  const SizedBox(height: 24),
                  
                  // 合成按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: canSynthesize ? () => _synthesizeEquipment(recipe, synthesisService, player) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFe94560),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        canSynthesize ? '开始合成' : '条件不足',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentInfo(Equipment? equipment) {
    if (equipment == null) {
      return const Text(
        '装备信息加载失败',
        style: TextStyle(color: Colors.red),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildEquipmentIcon(equipment),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    equipment.name,
                    style: TextStyle(
                      color: equipment.qualityColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getEquipmentRarityName(equipment.rarity),
                    style: TextStyle(
                      color: equipment.qualityColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          equipment.description,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 12),
        
        // 装备属性
        const Text(
          '装备属性:',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...equipment.baseStats.entries.map((entry) => 
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getStatName(entry.key),
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                Text(
                  entry.value.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialRequirement(SynthesisMaterial material, EquipmentSynthesisService synthesisService, Map<String, int> missingMaterials) {
    final hasEnough = !missingMaterials.containsKey(material.itemId);
    final currentAmount = hasEnough ? material.requiredQuantity : (material.requiredQuantity - missingMaterials[material.itemId]!);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasEnough ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.category,
            color: hasEnough ? Colors.green : Colors.red,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  material.description,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$currentAmount/${material.requiredQuantity}',
                style: TextStyle(
                  color: hasEnough ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!hasEnough)
                Text(
                  '缺少 ${missingMaterials[material.itemId]}',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpiritStoneRequirement(int required, int current) {
    final hasEnough = current >= required;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasEnough ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.monetization_on,
            color: hasEnough ? Colors.yellow : Colors.red,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              '灵石消耗',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            '$current/$required',
            style: TextStyle(
              color: hasEnough ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelRequirement(int required, int current) {
    final hasEnough = current >= required;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasEnough ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.star,
            color: hasEnough ? Colors.blue : Colors.red,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              '等级需求',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            '$current/$required',
            style: TextStyle(
              color: hasEnough ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessRate(double rate) {
    final percentage = (rate * 100).round();
    Color color = Colors.green;
    if (percentage < 50) {
      color = Colors.red;
    } else if (percentage < 80) {
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.percent, color: color, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              '成功率',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            '$percentage%',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentIcon(Equipment? equipment) {
    if (equipment == null) {
      return const Icon(Icons.help, color: Colors.grey, size: 48);
    }

    IconData icon;
    switch (equipment.type) {
      case EquipmentType.weapon:
        icon = Icons.sports_martial_arts;
        break;
      case EquipmentType.armor:
        icon = Icons.shield;
        break;
      case EquipmentType.accessory:
      case EquipmentType.ring:
      case EquipmentType.necklace:
        icon = Icons.diamond;
        break;
      case EquipmentType.boots:
        icon = Icons.directions_walk;
        break;
      case EquipmentType.helmet:
        icon = Icons.security;
        break;
      case EquipmentType.gloves:
        icon = Icons.back_hand;
        break;
      case EquipmentType.belt:
        icon = Icons.fitness_center;
        break;
      default:
        icon = Icons.category;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: equipment.qualityColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: equipment.qualityColor),
      ),
      child: Icon(icon, color: equipment.qualityColor, size: 24),
    );
  }

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

  String _getEquipmentRarityName(EquipmentRarity rarity) {
    switch (rarity) {
      case EquipmentRarity.common:
        return '普通';
      case EquipmentRarity.uncommon:
        return '不凡';
      case EquipmentRarity.rare:
        return '稀有';
      case EquipmentRarity.epic:
        return '史诗';
      case EquipmentRarity.legendary:
        return '传说';
      case EquipmentRarity.mythic:
        return '神话';
    }
  }

  String _getStatName(String stat) {
    switch (stat) {
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
      case 'health_regen':
        return '生命回复';
      case 'mana_regen':
        return '法力回复';
      default:
        return stat;
    }
  }

  void _synthesizeEquipment(SynthesisRecipe recipe, EquipmentSynthesisService synthesisService, Player player) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Text(
          '确认合成',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '确定要合成 ${recipe.name} 吗？',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              '成功率: ${(recipe.successRate * 100).round()}%',
              style: const TextStyle(color: Colors.orange),
            ),
            Text(
              '灵石消耗: ${recipe.spiritStoneCost}',
              style: const TextStyle(color: Colors.yellow),
            ),
            const SizedBox(height: 8),
            const Text(
              '注意：失败时材料将会消失！',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
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
            onPressed: () {
              Navigator.of(context).pop();
              _performSynthesis(recipe, synthesisService, player);
            },
            child: const Text(
              '确认',
              style: TextStyle(color: Color(0xFFe94560)),
            ),
          ),
        ],
      ),
    );
  }

  void _performSynthesis(SynthesisRecipe recipe, EquipmentSynthesisService synthesisService, Player player) async {
    // 显示合成进度
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        backgroundColor: Color(0xFF1a1a1a),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFFe94560)),
            SizedBox(height: 16),
            Text(
              '正在合成中...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );

    // 等待一段时间增加紧张感
    await Future.delayed(const Duration(seconds: 2));

    final result = await synthesisService.synthesizeEquipment(recipe, player);

    if (mounted) {
      Navigator.of(context).pop(); // 关闭进度对话框
      _showSynthesisResult(result);
      setState(() {}); // 刷新界面
    }
  }

  void _showSynthesisResult(SynthesisResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: Row(
          children: [
            Icon(
              result.success ? Icons.check_circle : Icons.error,
              color: result.success ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              result.success ? '合成成功！' : '合成失败！',
              style: TextStyle(
                color: result.success ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.message,
              style: const TextStyle(color: Colors.white),
            ),
            if (result.equipment != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildEquipmentIcon(result.equipment),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.equipment!.name,
                          style: TextStyle(
                            color: result.equipment!.qualityColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          result.equipment!.description,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '确定',
              style: TextStyle(color: Color(0xFFe94560)),
            ),
          ),
        ],
      ),
    );
  }

  void _addTestMaterials() {
    final synthesisService = Provider.of<EquipmentSynthesisService>(context, listen: false);
    synthesisService.addTestMaterials();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已添加测试材料到背包'),
        backgroundColor: Color(0xFFe94560),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Text(
          '合成帮助',
          style: TextStyle(color: Colors.white),
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '装备合成系统说明：',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '1. 选择想要合成的装备配方',
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                '2. 准备足够的材料和金币',
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                '3. 满足等级要求',
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                '4. 点击合成按钮开始合成',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 12),
              Text(
                '注意事项：',
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                '• 合成有一定失败率',
                style: TextStyle(color: Colors.red),
              ),
              Text(
                '• 失败时材料会消失',
                style: TextStyle(color: Colors.red),
              ),
              Text(
                '• 高级装备成功率较低',
                style: TextStyle(color: Colors.red),
              ),
              Text(
                '• 材料可通过战斗获得',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '知道了',
              style: TextStyle(color: Color(0xFFe94560)),
            ),
          ),
        ],
      ),
    );
  }
}
