import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/battle.dart';
import '../models/player.dart';
import 'audio_service.dart';

class BattleService extends ChangeNotifier {
  BattleData? _currentBattle;
  final List<BattleSkill> _playerSkills = [];
  final List<Enemy> _enemyTemplates = [];
  
  // 敌人动作回调
  Function(BattleAction)? onEnemyAction;
  
  // 玩家动作回调
  Function(BattleAction)? onPlayerAction;
  
  // 战斗胜利回调
  Function()? onBattleWon;

  BattleData? get currentBattle => _currentBattle;
  List<BattleSkill> get playerSkills => _playerSkills;
  bool get isInBattle => _currentBattle != null && !_currentBattle!.isBattleOver;

  // 初始化战斗系统
  void initializeBattleSystem() {
    debugPrint('⚔️ 开始初始化战斗系统...');
    _initializePlayerSkills();
    _initializeEnemyTemplates();
    debugPrint('⚔️ 战斗系统初始化完成');
  }

  // 初始化玩家技能
  void _initializePlayerSkills() {
    _playerSkills.addAll([
      // 基础攻击技能
      BattleSkill(
        id: 'basic_attack',
        name: '基础攻击',
        description: '使用武器进行普通攻击',
        type: SkillType.attack,
        damage: 100,
        manaCost: 0,
        accuracy: 0.95,
      ),
      
      // 修仙技能
      BattleSkill(
        id: 'spirit_strike',
        name: '灵气冲击',
        description: '凝聚灵气进行强力攻击',
        type: SkillType.attack,
        damage: 150,
        manaCost: 20,
        cooldown: 2,
        accuracy: 0.9,
      ),
      
      BattleSkill(
        id: 'healing_light',
        name: '回春术',
        description: '使用灵气恢复生命值',
        type: SkillType.heal,
        healing: 80,
        manaCost: 15,
        cooldown: 3,
        accuracy: 1.0,
      ),
      
      BattleSkill(
        id: 'iron_defense',
        name: '金刚护体',
        description: '提升防御力，减少受到的伤害',
        type: SkillType.defense,
        manaCost: 25,
        cooldown: 4,
        accuracy: 1.0,
        effects: ['defense_boost'],
      ),
      
      BattleSkill(
        id: 'lightning_strike',
        name: '雷霆一击',
        description: '召唤雷电进行毁灭性攻击',
        type: SkillType.attack,
        damage: 200,
        manaCost: 35,
        cooldown: 5,
        accuracy: 0.85,
      ),
    ]);
  }

  // 初始化敌人模板
  void _initializeEnemyTemplates() {
    _enemyTemplates.addAll([
      // 低级敌人
      Enemy(
        id: 'wild_wolf',
        name: '野狼',
        description: '凶猛的野生狼群',
        type: EnemyType.beast,
        level: 1,
        maxHealth: 80,
        maxMana: 20,
        attack: 25,
        defense: 10,
        speed: 15,
        skillIds: ['bite', 'howl'],
        rewards: {'exp': 15, 'spiritStones': 5},
        dropItems: ['wolf_fang', 'wolf_pelt', 'cloth_boots', 'cloth_gloves', 'bronze_ring'],
      ),
      
      Enemy(
        id: 'forest_goblin',
        name: '森林哥布林',
        description: '狡猾的绿皮小怪物',
        type: EnemyType.demon,
        level: 2,
        maxHealth: 100,
        maxMana: 30,
        attack: 30,
        defense: 15,
        speed: 20,
        skillIds: ['stab', 'poison_dart'],
        rewards: {'exp': 25, 'spiritStones': 8},
        dropItems: ['goblin_dagger', 'poison_sac', 'leather_belt', 'cloth_hat', 'jade_necklace'],
      ),
      
      // 中级敌人
      Enemy(
        id: 'stone_golem',
        name: '石头傀儡',
        description: '由岩石构成的强大守护者',
        type: EnemyType.spirit,
        level: 5,
        maxHealth: 250,
        maxMana: 50,
        attack: 45,
        defense: 35,
        speed: 8,
        skillIds: ['rock_throw', 'stone_armor'],
        rewards: {'exp': 60, 'spiritStones': 20},
        dropItems: ['stone_core', 'earth_crystal', 'iron_gauntlets', 'iron_helmet', 'wind_boots'],
      ),
      
      Enemy(
        id: 'shadow_assassin',
        name: '暗影刺客',
        description: '来自阴影中的致命杀手',
        type: EnemyType.undead,
        level: 7,
        maxHealth: 180,
        maxMana: 80,
        attack: 65,
        defense: 20,
        speed: 35,
        skillIds: ['shadow_strike', 'vanish', 'poison_blade'],
        rewards: {'exp': 100, 'spiritStones': 35},
        dropItems: ['shadow_essence', 'cursed_blade', 'spirit_ring', 'ruby_gem', 'power_rune'],
      ),
      
      // 高级敌人
      Enemy(
        id: 'fire_dragon',
        name: '火焰巨龙',
        description: '传说中的强大龙族',
        type: EnemyType.beast,
        level: 15,
        maxHealth: 800,
        maxMana: 200,
        attack: 120,
        defense: 60,
        speed: 25,
        skillIds: ['fire_breath', 'dragon_roar', 'flame_shield'],
        rewards: {'exp': 500, 'spiritStones': 200},
        dropItems: ['dragon_scale', 'fire_crystal', 'dragon_heart', 'dragon_ring', 'phoenix_necklace', 'dragon_crown', 'sapphire_gem'],
      ),
    ]);
  }

  // 开始战斗
  BattleData startBattle(Player player, List<String> enemyIds) {
    final enemies = <Enemy>[];
    
    for (final enemyId in enemyIds) {
      final template = _enemyTemplates.firstWhere(
        (e) => e.id == enemyId,
        orElse: () => _enemyTemplates.first,
      );
      
      // 创建敌人副本
      enemies.add(Enemy(
        id: template.id,
        name: template.name,
        description: template.description,
        type: template.type,
        level: template.level,
        maxHealth: template.maxHealth,
        maxMana: template.maxMana,
        attack: template.attack,
        defense: template.defense,
        speed: template.speed,
        skillIds: template.skillIds,
        rewards: template.rewards,
        dropItems: template.dropItems,
        imagePath: template.imagePath,
      ));
    }
    
    _currentBattle = BattleData(
      battleId: DateTime.now().millisecondsSinceEpoch.toString(),
      player: player,
      enemies: enemies,
      state: BattleState.playerTurn,
    );
    
    _currentBattle!.addLog('战斗开始！');
    _currentBattle!.addLog('面对敌人: ${enemies.map((e) => e.name).join(', ')}');
    
    // 只有在用户已经交互过的情况下才播放战斗音乐
    final audioService = AudioService();
    if (audioService.hasUserInteracted) {
      audioService.playBattleMusic();
    }
    audioService.playClickSound();
    
    notifyListeners();
    debugPrint('⚔️ 战斗开始: ${enemies.length} 个敌人');
    
    return _currentBattle!;
  }

  // 执行玩家动作
  void executePlayerAction(BattleAction action) {
    if (_currentBattle == null || _currentBattle!.state != BattleState.playerTurn) {
      return;
    }
    
    final battle = _currentBattle!;
    final player = battle.player;
    
    switch (action.type) {
      case BattleActionType.attack:
        _executePlayerAttack(player, action.targetId!);
        break;
      case BattleActionType.skill:
        _executePlayerSkill(player, action.skillId!, action.targetId);
        break;
      case BattleActionType.defend:
        _executePlayerDefend(player);
        break;
      case BattleActionType.item:
        _executePlayerItem(player, action.itemId!, action.targetId);
        break;
      case BattleActionType.escape:
        _executePlayerEscape();
        break;
    }
    
    // 检查战斗结果
    if (_checkBattleEnd()) {
      return;
    }
    
    // 切换到敌人回合
    battle.state = BattleState.enemyTurn;
    battle.currentTurn++;
    debugPrint('⚔️ 切换到敌人回合，回合数: ${battle.currentTurn}');
    
    // 延迟执行敌人回合
    Future.delayed(const Duration(milliseconds: 1000), () {
      debugPrint('⚔️ 开始执行敌人回合');
      _executeEnemyTurn();
    });
    
    notifyListeners();
  }

  // 执行玩家攻击
  void _executePlayerAttack(Player player, String targetId) {
    final target = _findEnemyById(targetId);
    if (target == null || !target.isAlive) return;
    
    final damage = _calculateDamage(player.actualAttack.round(), target.actualDefense);
    final actualDamage = target.takeDamage(damage);
    
    _currentBattle!.addLog('${player.name} 攻击 ${target.name}，造成 $actualDamage 点伤害');
    
    // 通知界面玩家执行了攻击
    if (onPlayerAction != null) {
      debugPrint('🎬 BattleService: 通知界面玩家攻击，伤害: $actualDamage');
      onPlayerAction!(BattleAction.attack(target.id, damage: actualDamage));
    }
    
    if (!target.isAlive) {
      _currentBattle!.addLog('${target.name} 被击败了！');
      AudioService().playVictorySound();
    }
  }

  // 执行玩家技能
  void _executePlayerSkill(Player player, String skillId, String? targetId) {
    final skill = _playerSkills.firstWhere(
      (s) => s.id == skillId,
      orElse: () => _playerSkills.first,
    );
    
    // 检查法力值
    if (player.currentMana < skill.manaCost) {
      _currentBattle!.addLog('法力值不足，无法使用 ${skill.name}');
      return;
    }
    
    // 消耗法力值
    player.currentMana -= skill.manaCost;
    
    switch (skill.type) {
      case SkillType.attack:
        if (targetId != null) {
          final target = _findEnemyById(targetId);
          if (target != null && target.isAlive) {
            final damage = _calculateSkillDamage(skill.damage, player.actualAttack.round(), target.actualDefense);
            final actualDamage = target.takeDamage(damage);
            _currentBattle!.addLog('${player.name} 使用 ${skill.name}，对 ${target.name} 造成 $actualDamage 点伤害');
            
            // 通知界面玩家使用了攻击技能
            if (onPlayerAction != null) {
              debugPrint('🎬 BattleService: 通知界面玩家使用技能，伤害: $actualDamage');
              onPlayerAction!(BattleAction.skill(skillId, target.id, damage: actualDamage));
            }
            
            if (!target.isAlive) {
              _currentBattle!.addLog('${target.name} 被击败了！');
              AudioService().playVictorySound();
            }
          }
        }
        break;
        
      case SkillType.heal:
        final healAmount = player.heal(skill.healing);
        _currentBattle!.addLog('${player.name} 使用 ${skill.name}，恢复了 $healAmount 点生命值');
        break;
        
      case SkillType.defense:
        // TODO: 实现防御技能效果
        _currentBattle!.addLog('${player.name} 使用 ${skill.name}，提升了防御力');
        break;
        
      default:
        _currentBattle!.addLog('${player.name} 使用了 ${skill.name}');
        break;
    }
  }

  // 执行玩家防御
  void _executePlayerDefend(Player player) {
    _currentBattle!.addLog('${player.name} 进入防御姿态');
    // TODO: 实现防御效果
  }

  // 执行玩家使用物品
  void _executePlayerItem(Player player, String itemId, String? targetId) {
    _currentBattle!.addLog('${player.name} 使用了物品');
    // TODO: 实现物品使用逻辑
  }

  // 执行玩家逃跑
  void _executePlayerEscape() {
    final escapeChance = Random().nextDouble();
    if (escapeChance > 0.3) { // 70%逃跑成功率
      _currentBattle!.state = BattleState.escaped;
      _currentBattle!.addLog('成功逃脱了战斗！');
      _endBattle();
    } else {
      _currentBattle!.addLog('逃跑失败！');
    }
  }

  // 执行敌人回合
  void _executeEnemyTurn() {
    if (_currentBattle == null || _currentBattle!.state != BattleState.enemyTurn) {
      debugPrint('⚔️ 敌人回合执行失败: 战斗状态不正确');
      return;
    }
    
    final battle = _currentBattle!;
    final aliveEnemies = battle.aliveEnemies;
    debugPrint('⚔️ 敌人回合开始，存活敌人数: ${aliveEnemies.length}');
    
    for (final enemy in aliveEnemies) {
      if (!battle.player.isAlive) break;
      
      debugPrint('⚔️ 敌人 ${enemy.name} 开始行动');
      
      // 更新技能冷却
      enemy.updateCooldowns();
      
      // AI选择动作
      _executeEnemyAI(enemy, battle.player);
    }
    
    // 检查战斗结果
    if (_checkBattleEnd()) {
      return;
    }
    
    // 切换回玩家回合
    battle.state = BattleState.playerTurn;
    notifyListeners();
  }

  // 敌人AI逻辑
  void _executeEnemyAI(Enemy enemy, Player player) {
    final random = Random();
    
    // 简单AI：70%概率攻击，30%概率使用技能
    if (random.nextDouble() < 0.7 || enemy.skillIds.isEmpty) {
      // 普通攻击
      final damage = _calculateDamage(enemy.actualAttack, player.actualDefense.round());
      final actualDamage = player.takeDamage(damage);
      _currentBattle!.addLog('${enemy.name} 攻击 ${player.name}，造成 $actualDamage 点伤害');
      
      // 通知界面敌人执行了攻击
      if (onEnemyAction != null) {
        debugPrint('🎬 BattleService: 通知界面敌人攻击，伤害: $actualDamage');
        onEnemyAction!(BattleAction.attack(player.name, damage: actualDamage));
      } else {
        debugPrint('🎬 BattleService: 敌人动作回调为空');
      }
    } else {
      // 使用技能
      final availableSkills = enemy.skillIds.where((skillId) => enemy.canUseSkill(skillId)).toList();
      if (availableSkills.isNotEmpty) {
        final skillId = availableSkills[random.nextInt(availableSkills.length)];
        _executeEnemySkill(enemy, skillId, player);
      } else {
        // 没有可用技能，普通攻击
        final damage = _calculateDamage(enemy.actualAttack, player.actualDefense.round());
        final actualDamage = player.takeDamage(damage);
        _currentBattle!.addLog('${enemy.name} 攻击 ${player.name}，造成 $actualDamage 点伤害');
        
        // 通知界面敌人执行了攻击
        if (onEnemyAction != null) {
          onEnemyAction!(BattleAction.attack(player.name, damage: actualDamage));
        }
      }
    }
  }

  // 执行敌人技能
  void _executeEnemySkill(Enemy enemy, String skillId, Player player) {
    // 简化的敌人技能系统
    switch (skillId) {
      case 'bite':
        final damage = _calculateDamage(enemy.actualAttack + 10, player.actualDefense.round());
        final actualDamage = player.takeDamage(damage);
        _currentBattle!.addLog('${enemy.name} 使用撕咬，对 ${player.name} 造成 $actualDamage 点伤害');
        enemy.setSkillCooldown(skillId, 2);
        
        // 通知界面敌人使用了技能
        if (onEnemyAction != null) {
          onEnemyAction!(BattleAction.skill(skillId, player.name, damage: actualDamage));
        }
        break;
        
      case 'fire_breath':
        final damage = _calculateDamage(enemy.actualAttack * 2, player.actualDefense.round());
        final actualDamage = player.takeDamage(damage);
        _currentBattle!.addLog('${enemy.name} 喷出火焰，对 ${player.name} 造成 $actualDamage 点火焰伤害');
        enemy.setSkillCooldown(skillId, 3);
        
        // 通知界面敌人使用了技能
        if (onEnemyAction != null) {
          onEnemyAction!(BattleAction.skill(skillId, player.name, damage: actualDamage));
        }
        break;
        
      default:
        final damage = _calculateDamage(enemy.actualAttack, player.actualDefense.round());
        final actualDamage = player.takeDamage(damage);
        _currentBattle!.addLog('${enemy.name} 使用特殊攻击，对 ${player.name} 造成 $actualDamage 点伤害');
        break;
    }
  }

  // 计算伤害
  int _calculateDamage(int attack, int defense) {
    final baseDamage = attack - defense;
    final randomFactor = 0.8 + (Random().nextDouble() * 0.4); // 80%-120%随机
    return ((baseDamage * randomFactor).round()).clamp(1, attack);
  }

  // 计算技能伤害
  int _calculateSkillDamage(int skillDamage, int attack, int defense) {
    final totalAttack = (attack * 0.5 + skillDamage).round();
    return _calculateDamage(totalAttack, defense);
  }

  // 查找敌人
  Enemy? _findEnemyById(String enemyId) {
    try {
      return _currentBattle!.enemies.firstWhere((e) => e.id == enemyId && e.isAlive);
    } catch (e) {
      return null;
    }
  }

  // 检查战斗结束
  bool _checkBattleEnd() {
    if (_currentBattle == null) return true;
    
    final battle = _currentBattle!;
    
    // 检查胜利
    if (battle.checkVictory()) {
      battle.state = BattleState.victory;
      battle.addLog('战斗胜利！');
      _calculateBattleRewards();
      _endBattle();
      return true;
    }
    
    // 检查失败
    if (battle.checkDefeat()) {
      battle.state = BattleState.defeat;
      battle.addLog('战斗失败...');
      _endBattle();
      return true;
    }
    
    return false;
  }

  // 计算战斗奖励
  void _calculateBattleRewards() {
    if (_currentBattle == null) return;
    
    final battle = _currentBattle!;
    int totalExp = 0;
    int totalSpiritStones = 0;
    final droppedItems = <String>[];
    
    for (final enemy in battle.enemies) {
      if (!enemy.isAlive) {
        totalExp += enemy.rewards['exp'] ?? 0;
        totalSpiritStones += enemy.rewards['spiritStones'] ?? 0;
        
        // 计算掉落物品
        for (final itemId in enemy.dropItems) {
          if (Random().nextDouble() < 0.3) { // 30%掉落率
            droppedItems.add(itemId);
          }
        }
      }
    }
    
    // 应用奖励
    battle.player.addExp(totalExp);
    battle.player.spiritStones += totalSpiritStones;
    
    battle.result = BattleResult(
      victory: true,
      expGained: totalExp,
      spiritStonesGained: totalSpiritStones,
      itemsDropped: droppedItems,
    );
    
    battle.addLog('获得 $totalExp 经验值，$totalSpiritStones 灵石');
    if (droppedItems.isNotEmpty) {
      battle.addLog('获得物品: ${droppedItems.join(', ')}');
    }
  }

  // 结束战斗
  void _endBattle() {
    if (_currentBattle?.state == BattleState.victory) {
      AudioService().playVictorySound();
      // 调用战斗胜利回调
      onBattleWon?.call();
      debugPrint('🏆 战斗胜利，触发成就和任务更新');
    } else if (_currentBattle?.state == BattleState.defeat) {
      AudioService().playDefeatSound();
    }
    
    // 战斗结束后恢复游戏音乐（如果用户已交互）
    Future.delayed(const Duration(seconds: 2), () {
      final audioService = AudioService();
      if (audioService.hasUserInteracted) {
        audioService.playGameplayMusic();
        debugPrint('🎵 战斗结束，恢复游戏音乐');
      }
    });
    
    notifyListeners();
    debugPrint('⚔️ 战斗结束: ${_currentBattle?.state}');
  }

  // 获取可战斗的敌人列表
  List<Enemy> getAvailableEnemies(int playerLevel) {
    return _enemyTemplates.where((enemy) {
      final levelDiff = (enemy.level - playerLevel).abs();
      return levelDiff <= 3; // 等级差距不超过3级
    }).toList();
  }

  // 根据区域获取敌人
  List<Enemy> getEnemiesByArea(String areaId) {
    switch (areaId) {
      case 'newbie_village':
        return _enemyTemplates.where((e) => e.level <= 2).toList();
      case 'dark_forest':
        return _enemyTemplates.where((e) => e.level >= 2 && e.level <= 5).toList();
      case 'spirit_cave':
        return _enemyTemplates.where((e) => e.level >= 5 && e.level <= 10).toList();
      case 'ancient_ruins':
        return _enemyTemplates.where((e) => e.level >= 10).toList();
      default:
        return _enemyTemplates.take(3).toList();
    }
  }

  // 清除当前战斗
  void clearBattle() {
    _currentBattle = null;
    // 清除战斗时恢复游戏音乐（如果用户已交互）
    final audioService = AudioService();
    if (audioService.hasUserInteracted) {
      audioService.playGameplayMusic();
      debugPrint('🎵 清除战斗，恢复游戏音乐');
    }
    notifyListeners();
  }

}
