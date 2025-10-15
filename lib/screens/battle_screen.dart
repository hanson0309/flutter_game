import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/battle.dart';
import '../models/player.dart';
import '../models/inventory.dart';
import '../services/battle_service.dart';
import '../services/audio_service.dart';
import '../services/inventory_service.dart';
import '../providers/game_provider.dart';
import '../widgets/battle_effects.dart';
import '../widgets/swipe_back_wrapper.dart';

class BattleScreen extends StatefulWidget {
  final List<String> enemyIds;
  
  const BattleScreen({
    super.key,
    required this.enemyIds,
  });

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> with TickerProviderStateMixin {
  late AnimationController _playerShakeController;
  late AnimationController _enemyShakeController;
  late Animation<double> _playerShakeAnimation;
  late Animation<double> _enemyShakeAnimation;
  
  // 特效管理
  final List<Widget> _activeEffects = [];
  final GlobalKey _playerAreaKey = GlobalKey();
  final GlobalKey _enemyAreaKey = GlobalKey();
  
  // 自动战斗相关
  Timer? _autoBattleTimer;
  bool _isAutoBattleEnabled = true;
  
  @override
  void initState() {
    super.initState();
    
    // 玩家震动动画
    _playerShakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _playerShakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _playerShakeController, curve: Curves.elasticIn),
    );
    
    // 敌人震动动画
    _enemyShakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _enemyShakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _enemyShakeController, curve: Curves.elasticIn),
    );
    
    // 开始战斗
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final battleService = Provider.of<BattleService>(context, listen: false);
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      final audioService = Provider.of<AudioService>(context, listen: false);
      
      // 设置动作回调（在战斗开始前设置）
      battleService.onEnemyAction = _onEnemyAction;
      battleService.onPlayerAction = _onPlayerAction;
      debugPrint('🎬 玩家和敌人动画回调已设置');
      
      // 只有在用户已经交互过的情况下才播放战斗音乐
      if (audioService.hasUserInteracted) {
        audioService.playBattleMusic();
        debugPrint('🎵 播放战斗音乐');
      } else {
        debugPrint('🎵 等待用户交互后播放战斗音乐');
      }
      
      if (gameProvider.player != null) {
        battleService.startBattle(gameProvider.player!, widget.enemyIds);
        // 启动自动战斗
        _startAutoBattle(battleService);
      }
    });
  }

  @override
  void dispose() {
    _playerShakeController.dispose();
    _enemyShakeController.dispose();
    _autoBattleTimer?.cancel();
    
    // 战斗结束时恢复游戏音乐
    final audioService = Provider.of<AudioService>(context, listen: false);
    audioService.playGameplayMusic();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SwipeBackScaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      body: Consumer2<BattleService, GameProvider>(
        builder: (context, battleService, gameProvider, child) {
          final battle = battleService.currentBattle;
          
          if (battle == null) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return Stack(
            children: [
              // 背景
              _buildBackground(),
              
              // 主要战斗界面
              Column(
                children: [
                  // 顶部状态栏
                  _buildTopBar(battle),
                  
                  // 战斗区域
                  Expanded(
                    flex: 3,
                    child: _buildBattleArea(battle),
                  ),
                  
                  // 战斗日志
                  Expanded(
                    flex: 1,
                    child: _buildBattleLog(battle),
                  ),
                  
                  // 底部操作区
                  _buildActionArea(battle, battleService),
                ],
              ),
              
              // 特效层
              ..._activeEffects,
              
              // 战斗结果弹窗
              if (battle.isBattleOver)
                _buildBattleResultOverlay(battle, battleService, context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1a1a2e),
            Color(0xFF16213e),
            Color(0xFF0f3460),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BattleData battle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: () => _showExitConfirmation(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text(
              '战斗回合: ${battle.currentTurn}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getBattleStateColor(battle.state),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getBattleStateText(battle.state),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBattleArea(BattleData battle) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 玩家区域
          Expanded(
            child: _buildPlayerArea(battle.player),
          ),
          
          // VS 标识
          Container(
            width: 60,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flash_on, color: Colors.red, size: 32),
                Text(
                  'VS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // 敌人区域
          Expanded(
            child: _buildEnemiesArea(battle.aliveEnemies),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerArea(Player player) {
    return AnimatedBuilder(
      animation: _playerShakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_playerShakeAnimation.value, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 玩家头像
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue, width: 3),
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.cyan],
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 玩家名称
              Text(
                player.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // 玩家等级
              Text(
                '${player.currentRealm.name} ${player.level}级',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 生命值条
              _buildHealthBar(
                player.currentHealth.round(),
                player.actualMaxHealth.round(),
                Colors.green,
                '生命值',
              ),
              
              const SizedBox(height: 4),
              
              // 法力值条
              _buildHealthBar(
                player.currentMana.round(),
                player.actualMaxMana.round(),
                Colors.blue,
                '法力值',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnemiesArea(List<Enemy> enemies) {
    if (enemies.isEmpty) {
      return const Center(
        child: Text(
          '所有敌人已被击败！',
          style: TextStyle(color: Colors.green, fontSize: 16),
        ),
      );
    }
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: enemies.map((enemy) => _buildEnemyCard(enemy)).toList(),
    );
  }

  Widget _buildEnemyCard(Enemy enemy) {
    return AnimatedBuilder(
      animation: _enemyShakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(-_enemyShakeAnimation.value, 0), // 敌人向左震动
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 敌人头像（和玩家一样的大小和样式）
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: enemy.typeColor, width: 3),
                  gradient: LinearGradient(
                    colors: [enemy.typeColor, enemy.typeColor.withOpacity(0.7)],
                  ),
                ),
                child: Icon(
                  _getEnemyIcon(enemy.type),
                  size: 50,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 敌人名称
              Text(
                enemy.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // 敌人等级
              Text(
                '${enemy.typeName} Lv.${enemy.level}',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 敌人生命值条
              _buildHealthBar(
                enemy.currentHealth,
                enemy.maxHealth,
                Colors.red,
                '生命值',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHealthBar(int current, int max, Color color, String? label) {
    final percentage = max > 0 ? current / max : 0.0;
    
    return Column(
      children: [
        if (label != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
              Text(
                '$current/$max',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        const SizedBox(height: 2),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBattleLog(BattleData battle) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '战斗日志',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: battle.battleLog.length,
              itemBuilder: (context, index) {
                final logIndex = battle.battleLog.length - 1 - index;
                final log = battle.battleLog[logIndex];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    log,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionArea(BattleData battle, BattleService battleService) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.autorenew,
              color: Colors.green,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              _getBattleStatusText(battle.state),
              style: TextStyle(
                color: _getBattleStateColor(battle.state),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '自动战斗中...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          child: Icon(icon, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBattleResultOverlay(BattleData battle, BattleService battleService, BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a1a),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: battle.state == BattleState.victory ? Colors.green : Colors.red,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                battle.state == BattleState.victory ? Icons.emoji_events : Icons.close,
                size: 64,
                color: battle.state == BattleState.victory ? Colors.yellow : Colors.red,
              ),
              
              const SizedBox(height: 16),
              
              Text(
                _getBattleResultTitle(battle.state),
                style: TextStyle(
                  color: battle.state == BattleState.victory ? Colors.green : Colors.red,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              if (battle.result != null && battle.state == BattleState.victory) ...[
                Text(
                  '获得奖励:',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '经验值: ${battle.result!.expGained}',
                  style: const TextStyle(color: Colors.yellow, fontSize: 14),
                ),
                Text(
                  '灵石: ${battle.result!.spiritStonesGained}',
                  style: const TextStyle(color: Colors.blue, fontSize: 14),
                ),
                if (battle.result!.itemsDropped.isNotEmpty)
                  Text(
                    '物品: ${battle.result!.itemsDropped.map((itemId) => _getItemDisplayName(itemId)).join(', ')}',
                    style: const TextStyle(color: Colors.green, fontSize: 14),
                  ),
                const SizedBox(height: 16),
              ],
              
              ElevatedButton(
                onPressed: () {
                  // 如果战斗胜利且有掉落物品，添加到背包
                  if (battle.result != null && battle.state == BattleState.victory && battle.result!.itemsDropped.isNotEmpty) {
                    _addItemsToInventory(battle.result!.itemsDropped, context);
                  }
                  battleService.clearBattle();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFe94560),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 启动自动战斗
  void _startAutoBattle(BattleService battleService) {
    if (!_isAutoBattleEnabled) return;
    
    _autoBattleTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      final battle = battleService.currentBattle;
      if (battle == null || battle.isBattleOver) {
        timer.cancel();
        return;
      }
      
      // 只在玩家回合时执行自动动作
      if (battle.state == BattleState.playerTurn) {
        _executeAutoAction(battleService);
      }
    });
  }
  
  // 执行自动战斗动作
  void _executeAutoAction(BattleService battleService) {
    final battle = battleService.currentBattle;
    if (battle == null || battle.isBattleOver) return;
    
    final aliveEnemies = battle.aliveEnemies;
    if (aliveEnemies.isEmpty) return;
    
    // 简单的AI逻辑：
    // 1. 如果血量低于30%，使用治疗技能
    // 2. 如果法力充足，30%概率使用技能
    // 3. 否则普通攻击
    
    final player = battle.player;
    final healthPercentage = player.currentHealth / player.actualMaxHealth;
    
    if (healthPercentage < 0.3) {
      // 尝试使用治疗技能
      final healSkills = battleService.playerSkills.where((skill) => 
        skill.type == SkillType.heal && player.currentMana >= skill.manaCost).toList();
      
      if (healSkills.isNotEmpty) {
        final healSkill = healSkills.first;
        final action = BattleAction.skill(healSkill.id, 'player');
        battleService.executePlayerAction(action);
        _triggerBattleEffect(action); // 添加动画效果
        // 添加玩家震动效果
        if (action.type == BattleActionType.attack || action.type == BattleActionType.skill) {
          _playerShakeController.forward().then((_) => _playerShakeController.reverse());
        }
        return;
      }
    }
    
    // 30%概率使用攻击技能
    if (player.currentMana > 20 && DateTime.now().millisecond % 10 < 3) {
      final attackSkills = battleService.playerSkills.where((skill) => 
        skill.type == SkillType.attack && player.currentMana >= skill.manaCost).toList();
      
      if (attackSkills.isNotEmpty) {
        final skill = attackSkills.first;
        final target = aliveEnemies.first;
        final action = BattleAction.skill(skill.id, target.id);
        battleService.executePlayerAction(action);
        _triggerBattleEffect(action); // 添加动画效果
        // 添加玩家震动效果
        if (action.type == BattleActionType.attack || action.type == BattleActionType.skill) {
          _playerShakeController.forward().then((_) => _playerShakeController.reverse());
        }
        return;
      }
    }
    
    // 默认普通攻击
    final target = aliveEnemies.first;
    final action = BattleAction.attack(target.id);
    battleService.executePlayerAction(action);
    _triggerBattleEffect(action); // 添加动画效果
    // 添加玩家震动效果
    if (action.type == BattleActionType.attack || action.type == BattleActionType.skill) {
      _playerShakeController.forward().then((_) => _playerShakeController.reverse());
    }
  }

  // 将掉落物品添加到背包
  void _addItemsToInventory(List<String> itemIds, BuildContext context) {
    try {
      // 获取背包服务实例
      final inventoryService = Provider.of<InventoryService>(context, listen: false);
      
      for (final itemId in itemIds) {
        // 创建背包物品
        final inventoryItem = InventoryItem(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '_' + itemId,
          itemId: itemId,
          name: _getItemDisplayName(itemId),
          description: _getItemDescription(itemId),
          type: _getItemType(itemId),
          iconPath: _getItemIconPath(itemId),
          itemData: _getItemData(itemId),
          quantity: 1,
          stackable: _isStackableItem(itemId),
          maxStack: _isStackableItem(itemId) ? 99 : 1,
          obtainedAt: DateTime.now(),
          source: '战斗掉落',
        );
        
        // 添加到背包
        final success = inventoryService.inventory.addItem(inventoryItem);
        if (success) {
          debugPrint('🎒 战斗掉落物品已添加到背包: ${inventoryItem.name}');
        } else {
          debugPrint('🎒 背包空间不足，无法添加物品: ${inventoryItem.name}');
        }
      }
      
      // 背包服务会自动通知更新，无需手动调用
    } catch (e) {
      debugPrint('🎒 添加战斗掉落物品到背包失败: $e');
    }
  }

  // 获取物品类型
  InventoryItemType _getItemType(String itemId) {
    const itemTypes = {
      // 纯材料类（不可直接使用）
      'wolf_fang': InventoryItemType.material,
      'wolf_pelt': InventoryItemType.material,
      
      // 装备类
      'goblin_dagger': InventoryItemType.equipment,
      'cursed_blade': InventoryItemType.equipment,
      'dragon_scale': InventoryItemType.equipment,
      
      // 可消耗使用的物品
      'poison_sac': InventoryItemType.consumable,
      'stone_core': InventoryItemType.consumable,
      'earth_crystal': InventoryItemType.consumable,
      'shadow_essence': InventoryItemType.consumable,
      'fire_crystal': InventoryItemType.consumable,
      'dragon_heart': InventoryItemType.consumable,
    };
    
    return itemTypes[itemId] ?? InventoryItemType.material;
  }

  // 判断物品是否可堆叠
  bool _isStackableItem(String itemId) {
    const stackableItems = {
      'wolf_fang', 'wolf_pelt', 'poison_sac', 'stone_core', 
      'earth_crystal', 'shadow_essence', 'dragon_scale', 
      'fire_crystal', 'dragon_heart'
    };
    
    return stackableItems.contains(itemId);
  }

  // 获取物品描述
  String _getItemDescription(String itemId) {
    const itemDescriptions = {
      'wolf_fang': '野狼的尖锐牙齿，可用于制作武器或药剂',
      'wolf_pelt': '野狼的毛皮，柔软且坚韧，是制作护甲的好材料',
      'goblin_dagger': '哥布林使用的粗制匕首，虽然简陋但依然锋利',
      'poison_sac': '含有剧毒的囊袋，可用于制作毒药或解毒剂',
      'stone_core': '蕴含大地之力的石核，可用于炼制丹药',
      'earth_crystal': '纯净的土系水晶，蕴含浓郁的土元素力量',
      'shadow_essence': '暗影的精华，神秘而危险的炼金材料',
      'cursed_blade': '被诅咒的刀刃，散发着不祥的气息',
      'dragon_scale': '巨龙的鳞片，坚硬无比，是顶级的防具材料',
      'fire_crystal': '火系水晶，内含炽热的火元素能量',
      'dragon_heart': '巨龙的心脏，蕴含强大的龙族力量',
    };
    
    return itemDescriptions[itemId] ?? '战斗中获得的物品';
  }

  // 获取物品数据（属性和效果）
  Map<String, dynamic> _getItemData(String itemId) {
    const itemDataMap = {
      // 材料类物品 - 主要用于制作，部分可直接使用
      'wolf_fang': {
        'rarity': 'common',
        'sellPrice': 10,
      },
      'wolf_pelt': {
        'rarity': 'common', 
        'sellPrice': 15,
      },
      'poison_sac': {
        'rarity': 'uncommon',
        'sellPrice': 25,
        'heal': -20, // 毒囊使用后会减血（危险物品）
      },
      'stone_core': {
        'rarity': 'uncommon',
        'sellPrice': 30,
        'mana': 20, // 石核可以恢复少量法力
      },
      'earth_crystal': {
        'rarity': 'rare',
        'sellPrice': 50,
        'mana': 40,
      },
      'shadow_essence': {
        'rarity': 'rare',
        'sellPrice': 80,
        'exp': 50, // 暗影精华可以提供经验
      },
      'fire_crystal': {
        'rarity': 'rare',
        'sellPrice': 60,
        'heal': 30, // 火系水晶可以恢复生命
      },
      'dragon_heart': {
        'rarity': 'epic',
        'sellPrice': 500,
        'heal': 100,
        'mana': 100,
        'exp': 200, // 龙心是强力的恢复物品
      },
      
      // 装备类物品
      'goblin_dagger': {
        'rarity': 'common',
        'attack': 15,
        'durability': 100,
        'sellPrice': 40,
      },
      'cursed_blade': {
        'rarity': 'rare',
        'attack': 45,
        'durability': 150,
        'sellPrice': 200,
        'curse': true, // 诅咒效果
      },
      'dragon_scale': {
        'rarity': 'epic',
        'defense': 30,
        'durability': 300,
        'sellPrice': 300,
      },
    };
    
    return Map<String, dynamic>.from(itemDataMap[itemId] ?? {});
  }

  // 获取物品图标路径
  String? _getItemIconPath(String itemId) {
    // 暂时返回null，避免404错误
    // 后续可以添加实际的图标文件
    return null;
  }

  // 获取物品显示名称
  String _getItemDisplayName(String itemId) {
    const itemNames = {
      // 战斗掉落物品
      'wolf_fang': '狼牙',
      'wolf_pelt': '狼皮',
      'goblin_dagger': '哥布林匕首',
      'poison_sac': '毒囊',
      'stone_core': '石核',
      'earth_crystal': '土系水晶',
      'shadow_essence': '暗影精华',
      'cursed_blade': '诅咒之刃',
      'dragon_scale': '龙鳞',
      'fire_crystal': '火系水晶',
      'dragon_heart': '龙心',
      
      // 商店物品
      'wooden_sword': '木剑',
      'iron_sword': '铁剑',
      'steel_armor': '钢甲',
      'basic_cultivation_manual': '基础修炼手册',
      'advanced_sword_technique': '高级剑法',
      'healing_pill': '疗伤丹',
      'spirit_pill': '回灵丹',
      'exp_pill': '经验丹',
      'lucky_charm': '幸运符',
      
      // 其他可能的物品
      'goblin_ear': '哥布林耳朵',
      'healing_potion': '治疗药水',
      'mana_potion': '法力药水',
      'iron_ore': '铁矿石',
      'spirit_herb': '灵草',
      'beast_claw': '野兽爪',
      'magic_crystal': '魔法水晶',
      'ancient_bone': '古老骨头',
      'fire_essence': '火焰精华',
      'ice_shard': '冰晶碎片',
      'slime_gel': '史莱姆胶',
      'spider_silk': '蜘蛛丝',
      'bat_wing': '蝙蝠翅膀',
    };
    
    return itemNames[itemId] ?? itemId;
  }

  // 辅助方法
  Color _getBattleStateColor(BattleState state) {
    switch (state) {
      case BattleState.playerTurn:
        return Colors.green;
      case BattleState.enemyTurn:
        return Colors.orange;
      case BattleState.victory:
        return Colors.blue;
      case BattleState.defeat:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getBattleStatusText(BattleState state) {
    switch (state) {
      case BattleState.playerTurn:
        return '正在行动...';
      case BattleState.enemyTurn:
        return '敌人回合';
      case BattleState.victory:
        return '战斗胜利！';
      case BattleState.defeat:
        return '战斗失败';
      default:
        return '战斗中';
    }
  }

  String _getBattleStateText(BattleState state) {
    switch (state) {
      case BattleState.playerTurn:
        return '你的回合';
      case BattleState.enemyTurn:
        return '敌人回合';
      case BattleState.victory:
        return '胜利';
      case BattleState.defeat:
        return '失败';
      case BattleState.escaped:
        return '逃脱';
      default:
        return '准备中';
    }
  }

  String _getBattleResultTitle(BattleState state) {
    switch (state) {
      case BattleState.victory:
        return '战斗胜利！';
      case BattleState.defeat:
        return '战斗失败';
      case BattleState.escaped:
        return '成功逃脱';
      default:
        return '战斗结束';
    }
  }

  IconData _getEnemyIcon(EnemyType type) {
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

  // 玩家动作回调
  void _onPlayerAction(BattleAction action) {
    debugPrint('🎬 玩家执行动作: ${action.type}, 技能ID: ${action.skillId}, 伤害: ${action.damage}');
    
    // 触发玩家攻击特效（立即显示伤害）
    _triggerPlayerBattleEffect(action);
    
    // 触发玩家震动效果
    if (action.type == BattleActionType.attack || action.type == BattleActionType.skill) {
      _playerShakeController.forward().then((_) => _playerShakeController.reverse());
      debugPrint('🎬 玩家攻击震动效果已触发');
    }
  }

  // 敌人动作回调
  void _onEnemyAction(BattleAction action) {
    debugPrint('🎬 敌人执行动作: ${action.type}, 技能ID: ${action.skillId}');
    
    // 触发敌人攻击特效（从右侧向左侧）
    _triggerEnemyBattleEffect(action);
    
    // 触发敌人震动效果
    if (action.type == BattleActionType.attack || action.type == BattleActionType.skill) {
      _enemyShakeController.forward().then((_) => _enemyShakeController.reverse());
      debugPrint('🎬 敌人攻击震动效果已触发');
    }
  }

  // 触发玩家战斗特效
  void _triggerPlayerBattleEffect(BattleAction action) {
    final screenSize = MediaQuery.of(context).size;
    
    switch (action.type) {
      case BattleActionType.attack:
        // 玩家攻击冲击波（从左向右）
        _addEffect(AttackWave(
          position: Offset(screenSize.width * 0.7, screenSize.height * 0.4),
        ));
        
        // 伤害数字（在敌人位置，使用真实伤害）
        Future.delayed(const Duration(milliseconds: 200), () {
          final damage = action.damage ?? 25; // 使用真实伤害数值
          _addDamageNumber(damage, Colors.red, 
            Offset(screenSize.width * 0.7, screenSize.height * 0.35));
        });
        break;
        
      case BattleActionType.skill:
        if (action.skillId != null) {
          // 玩家技能特效
          _addEffect(SkillEffect(
            skillType: action.skillId!,
            position: Offset(screenSize.width * 0.5, screenSize.height * 0.4),
          ));
          
          // 玩家技能粒子效果
          _addEffect(ParticleEffect(
            position: Offset(screenSize.width * 0.7, screenSize.height * 0.4),
            color: _getSkillColor(action.skillId!),
          ));
          
          // 技能伤害数字
          Future.delayed(const Duration(milliseconds: 200), () {
            final damage = action.damage ?? 30; // 使用真实技能伤害数值
            _addDamageNumber(damage, _getSkillColor(action.skillId!), 
              Offset(screenSize.width * 0.7, screenSize.height * 0.35));
          });
        }
        break;
        
      default:
        break;
    }
  }

  // 触发敌人战斗特效
  void _triggerEnemyBattleEffect(BattleAction action) {
    final screenSize = MediaQuery.of(context).size;
    
    switch (action.type) {
      case BattleActionType.attack:
        // 敌人攻击冲击波（从右向左）
        _addEffect(AttackWave(
          position: Offset(screenSize.width * 0.3, screenSize.height * 0.4),
        ));
        
        // 伤害数字（在玩家位置，使用真实伤害）
        Future.delayed(const Duration(milliseconds: 200), () {
          final damage = action.damage ?? 10; // 使用真实伤害数值
          _addDamageNumber(damage, Colors.red, 
            Offset(screenSize.width * 0.3, screenSize.height * 0.35));
        });
        break;
        
      case BattleActionType.skill:
        if (action.skillId != null) {
          // 敌人技能特效
          _addEffect(SkillEffect(
            skillType: action.skillId!,
            position: Offset(screenSize.width * 0.5, screenSize.height * 0.4),
          ));
          
          // 敌人技能粒子效果
          _addEffect(ParticleEffect(
            position: Offset(screenSize.width * 0.3, screenSize.height * 0.4),
            color: _getEnemySkillColor(action.skillId!),
          ));
          
          // 技能伤害数字
          Future.delayed(const Duration(milliseconds: 200), () {
            final damage = action.damage ?? 15; // 使用真实技能伤害数值
            _addDamageNumber(damage, _getEnemySkillColor(action.skillId!), 
              Offset(screenSize.width * 0.3, screenSize.height * 0.35));
          });
        }
        break;
        
      default:
        break;
    }
  }

  // 获取敌人技能颜色
  Color _getEnemySkillColor(String skillId) {
    switch (skillId) {
      case 'bite':
        return Colors.red;
      case 'fire_breath':
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  // 事件处理方法
  void _executeAction(BattleService battleService, BattleAction action) {
    AudioService().playClickSound();
    battleService.executePlayerAction(action);
    
    // 触发特效
    _triggerBattleEffect(action);
    
    // 如果是攻击动作，播放玩家震动效果
    if (action.type == BattleActionType.attack || action.type == BattleActionType.skill) {
      _playerShakeController.forward().then((_) => _playerShakeController.reverse());
    }
  }

  // 触发战斗特效
  void _triggerBattleEffect(BattleAction action) {
    final screenSize = MediaQuery.of(context).size;
    
    switch (action.type) {
      case BattleActionType.attack:
        // 攻击冲击波（旧的手动攻击，现在通过回调处理伤害）
        _addEffect(AttackWave(
          position: Offset(screenSize.width * 0.7, screenSize.height * 0.4),
        ));
        // 注意：伤害数字现在通过玩家动作回调显示
        break;
        
      case BattleActionType.skill:
        if (action.skillId != null) {
          // 技能特效
          _addEffect(SkillEffect(
            skillType: action.skillId!,
            position: Offset(screenSize.width * 0.5, screenSize.height * 0.4),
          ));
          
          // 粒子效果
          _addEffect(ParticleEffect(
            position: Offset(screenSize.width * 0.5, screenSize.height * 0.4),
            color: _getSkillColor(action.skillId!),
          ));
        }
        break;
        
      default:
        break;
    }
  }

  // 添加特效
  void _addEffect(Widget effect) {
    setState(() {
      _activeEffects.add(effect);
    });
    
    // 自动清理特效
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _activeEffects.remove(effect);
        });
      }
    });
  }

  // 添加伤害数字
  void _addDamageNumber(int damage, Color color, Offset position) {
    final damageWidget = DamageNumber(
      damage: damage,
      color: color,
      startPosition: position,
    );
    
    _addEffect(damageWidget);
  }

  // 获取技能颜色
  Color _getSkillColor(String skillId) {
    switch (skillId) {
      case 'spirit_strike':
        return Colors.cyan;
      case 'lightning_strike':
        return Colors.yellow;
      case 'healing_light':
        return Colors.green;
      case 'iron_defense':
        return Colors.blue;
      default:
        return Colors.red;
    }
  }

  void _showTargetSelection(BuildContext context, BattleService battleService, BattleActionType actionType) {
    final battle = battleService.currentBattle;
    if (battle == null) return;
    
    final aliveEnemies = battle.aliveEnemies;
    if (aliveEnemies.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Text('选择目标', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: aliveEnemies.map((enemy) => ListTile(
            leading: Icon(_getEnemyIcon(enemy.type), color: enemy.typeColor),
            title: Text(enemy.name, style: const TextStyle(color: Colors.white)),
            subtitle: Text('生命值: ${enemy.currentHealth}/${enemy.maxHealth}', 
                         style: const TextStyle(color: Colors.grey)),
            onTap: () {
              Navigator.of(context).pop();
              _executeAction(battleService, BattleAction.attack(enemy.id));
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showSkillSelection(BuildContext context, BattleService battleService) {
    final skills = battleService.playerSkills;
    final battle = battleService.currentBattle;
    if (battle == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Text('选择技能', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: skills.length,
            itemBuilder: (context, index) {
              final skill = skills[index];
              final canUse = battle.player.currentMana >= skill.manaCost;
              
              return ListTile(
                enabled: canUse,
                leading: Icon(skill.icon, color: canUse ? skill.color : Colors.grey),
                title: Text(
                  skill.name,
                  style: TextStyle(color: canUse ? Colors.white : Colors.grey),
                ),
                subtitle: Text(
                  '${skill.description}\n法力消耗: ${skill.manaCost}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                onTap: canUse ? () {
                  Navigator.of(context).pop();
                  if (skill.type == SkillType.heal) {
                    _executeAction(battleService, BattleAction.skill(skill.id, 'player'));
                  } else {
                    _showTargetSelection(context, battleService, BattleActionType.skill);
                  }
                } : null,
              );
            },
          ),
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Text('确认退出', style: TextStyle(color: Colors.white)),
        content: const Text(
          '确定要退出战斗吗？退出将视为逃跑。',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final battleService = Provider.of<BattleService>(context, listen: false);
              battleService.clearBattle();
              Navigator.of(context).pop();
            },
            child: const Text('确定', style: TextStyle(color: Color(0xFFe94560))),
          ),
        ],
      ),
    );
  }
}
