import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'player.dart';

part 'battle.g.dart';

// 敌人类型枚举
enum EnemyType {
  beast,      // 妖兽
  demon,      // 魔族
  cultivator, // 修士
  spirit,     // 灵体
  undead,     // 不死族
}

// 战斗技能类型
enum SkillType {
  attack,     // 攻击技能
  defense,    // 防御技能
  heal,       // 治疗技能
  buff,       // 增益技能
  debuff,     // 减益技能
}

// 战斗技能
@JsonSerializable()
class BattleSkill {
  final String id;
  final String name;
  final String description;
  final SkillType type;
  final int damage;        // 伤害值
  final int healing;       // 治疗值
  final int manaCost;      // 法力消耗
  final int cooldown;      // 冷却时间
  final double accuracy;   // 命中率
  final List<String> effects; // 特殊效果

  BattleSkill({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.damage = 0,
    this.healing = 0,
    this.manaCost = 0,
    this.cooldown = 0,
    this.accuracy = 1.0,
    this.effects = const [],
  });

  factory BattleSkill.fromJson(Map<String, dynamic> json) => _$BattleSkillFromJson(json);
  Map<String, dynamic> toJson() => _$BattleSkillToJson(this);

  // 获取技能图标
  IconData get icon {
    switch (type) {
      case SkillType.attack:
        return Icons.flash_on;
      case SkillType.defense:
        return Icons.shield;
      case SkillType.heal:
        return Icons.healing;
      case SkillType.buff:
        return Icons.trending_up;
      case SkillType.debuff:
        return Icons.trending_down;
    }
  }

  // 获取技能颜色
  Color get color {
    switch (type) {
      case SkillType.attack:
        return Colors.red;
      case SkillType.defense:
        return Colors.blue;
      case SkillType.heal:
        return Colors.green;
      case SkillType.buff:
        return Colors.orange;
      case SkillType.debuff:
        return Colors.purple;
    }
  }
}

// 敌人模型
@JsonSerializable()
class Enemy {
  final String id;
  final String name;
  final String description;
  final EnemyType type;
  final int level;
  final int maxHealth;
  final int maxMana;
  final int attack;
  final int defense;
  final int speed;
  final List<String> skillIds;
  final Map<String, int> rewards; // 奖励：经验值、灵石等
  final List<String> dropItems;   // 掉落物品ID列表
  final String? imagePath;

  // 战斗中的动态属性
  int currentHealth;
  int currentMana;
  Map<String, int> buffs;     // 增益效果
  Map<String, int> debuffs;   // 减益效果
  Map<String, int> skillCooldowns; // 技能冷却

  Enemy({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.level,
    required this.maxHealth,
    required this.maxMana,
    required this.attack,
    required this.defense,
    required this.speed,
    this.skillIds = const [],
    this.rewards = const {},
    this.dropItems = const [],
    this.imagePath,
  }) : currentHealth = maxHealth,
       currentMana = maxMana,
       buffs = {},
       debuffs = {},
       skillCooldowns = {};

  factory Enemy.fromJson(Map<String, dynamic> json) => _$EnemyFromJson(json);
  Map<String, dynamic> toJson() => _$EnemyToJson(this);

  // 获取敌人类型颜色
  Color get typeColor {
    switch (type) {
      case EnemyType.beast:
        return Colors.brown;
      case EnemyType.demon:
        return Colors.red;
      case EnemyType.cultivator:
        return Colors.blue;
      case EnemyType.spirit:
        return Colors.cyan;
      case EnemyType.undead:
        return Colors.grey;
    }
  }

  // 获取敌人类型名称
  String get typeName {
    switch (type) {
      case EnemyType.beast:
        return '妖兽';
      case EnemyType.demon:
        return '魔族';
      case EnemyType.cultivator:
        return '修士';
      case EnemyType.spirit:
        return '灵体';
      case EnemyType.undead:
        return '不死族';
    }
  }

  // 计算实际攻击力（包含buff/debuff）
  int get actualAttack {
    int finalAttack = attack;
    buffs.forEach((key, value) {
      if (key == 'attack_boost') finalAttack += value;
    });
    debuffs.forEach((key, value) {
      if (key == 'attack_reduce') finalAttack -= value;
    });
    return finalAttack.clamp(1, 999999);
  }

  // 计算实际防御力
  int get actualDefense {
    int finalDefense = defense;
    buffs.forEach((key, value) {
      if (key == 'defense_boost') finalDefense += value;
    });
    debuffs.forEach((key, value) {
      if (key == 'defense_reduce') finalDefense -= value;
    });
    return finalDefense.clamp(0, 999999);
  }

  // 是否存活
  bool get isAlive => currentHealth > 0;

  // 血量百分比
  double get healthPercentage => currentHealth / maxHealth;

  // 法力百分比
  double get manaPercentage => maxMana > 0 ? currentMana / maxMana : 0.0;

  // 受到伤害
  int takeDamage(int damage) {
    final actualDamage = (damage - actualDefense).clamp(1, damage);
    currentHealth = (currentHealth - actualDamage).clamp(0, maxHealth);
    return actualDamage;
  }

  // 恢复生命值
  int heal(int amount) {
    final oldHealth = currentHealth;
    currentHealth = (currentHealth + amount).clamp(0, maxHealth);
    return currentHealth - oldHealth;
  }

  // 恢复法力值
  int restoreMana(int amount) {
    final oldMana = currentMana;
    currentMana = (currentMana + amount).clamp(0, maxMana);
    return currentMana - oldMana;
  }

  // 消耗法力值
  bool consumeMana(int amount) {
    if (currentMana >= amount) {
      currentMana -= amount;
      return true;
    }
    return false;
  }

  // 添加增益效果
  void addBuff(String buffType, int value, int duration) {
    buffs[buffType] = value;
    // TODO: 实现持续时间逻辑
  }

  // 添加减益效果
  void addDebuff(String debuffType, int value, int duration) {
    debuffs[debuffType] = value;
    // TODO: 实现持续时间逻辑
  }

  // 更新技能冷却
  void updateCooldowns() {
    skillCooldowns.updateAll((key, value) => (value - 1).clamp(0, 999));
    skillCooldowns.removeWhere((key, value) => value <= 0);
  }

  // 检查技能是否可用
  bool canUseSkill(String skillId) {
    return !skillCooldowns.containsKey(skillId) || skillCooldowns[skillId]! <= 0;
  }

  // 使用技能后设置冷却
  void setSkillCooldown(String skillId, int cooldown) {
    if (cooldown > 0) {
      skillCooldowns[skillId] = cooldown;
    }
  }
}

// 战斗动作类型
enum BattleActionType {
  attack,       // 普通攻击
  skill,        // 使用技能
  defend,       // 防御
  item,         // 使用物品
  escape,       // 逃跑
}

// 战斗动作
@JsonSerializable()
class BattleAction {
  final BattleActionType type;
  final String? skillId;
  final String? itemId;
  final String? targetId;
  final int? damage; // 添加伤害数值

  BattleAction({
    required this.type,
    this.skillId,
    this.itemId,
    this.targetId,
    this.damage,
  });

  factory BattleAction.fromJson(Map<String, dynamic> json) => _$BattleActionFromJson(json);
  Map<String, dynamic> toJson() => _$BattleActionToJson(this);

  // 创建攻击动作
  static BattleAction attack(String targetId, {int? damage}) {
    return BattleAction(type: BattleActionType.attack, targetId: targetId, damage: damage);
  }

  // 创建技能动作
  static BattleAction skill(String skillId, String targetId, {int? damage}) {
    return BattleAction(type: BattleActionType.skill, skillId: skillId, targetId: targetId, damage: damage);
  }

  // 创建防御动作
  static BattleAction defend() {
    return BattleAction(type: BattleActionType.defend);
  }

  // 创建使用物品动作
  static BattleAction useItem(String itemId, String? targetId) {
    return BattleAction(type: BattleActionType.item, itemId: itemId, targetId: targetId);
  }

  // 创建逃跑动作
  static BattleAction escape() {
    return BattleAction(type: BattleActionType.escape);
  }
}

// 战斗结果
@JsonSerializable()
class BattleResult {
  final bool victory;
  final int expGained;
  final int spiritStonesGained;
  final List<String> itemsDropped;
  final Map<String, dynamic> statistics;

  BattleResult({
    required this.victory,
    this.expGained = 0,
    this.spiritStonesGained = 0,
    this.itemsDropped = const [],
    this.statistics = const {},
  });

  factory BattleResult.fromJson(Map<String, dynamic> json) => _$BattleResultFromJson(json);
  Map<String, dynamic> toJson() => _$BattleResultToJson(this);
}

// 战斗状态
enum BattleState {
  preparing,    // 准备中
  playerTurn,   // 玩家回合
  enemyTurn,    // 敌人回合
  victory,      // 胜利
  defeat,       // 失败
  escaped,      // 逃跑
}

// 战斗数据
@JsonSerializable()
class BattleData {
  final String battleId;
  final Player player;
  final List<Enemy> enemies;
  BattleState state;
  int currentTurn;
  List<String> battleLog;
  BattleResult? result;

  BattleData({
    required this.battleId,
    required this.player,
    required this.enemies,
    this.state = BattleState.preparing,
    this.currentTurn = 0,
    this.battleLog = const [],
    this.result,
  });

  factory BattleData.fromJson(Map<String, dynamic> json) => _$BattleDataFromJson(json);
  Map<String, dynamic> toJson() => _$BattleDataToJson(this);

  // 获取存活的敌人
  List<Enemy> get aliveEnemies => enemies.where((e) => e.isAlive).toList();

  // 检查战斗是否结束
  bool get isBattleOver => 
      state == BattleState.victory || 
      state == BattleState.defeat || 
      state == BattleState.escaped;

  // 添加战斗日志
  void addLog(String message) {
    battleLog = List.from(battleLog)..add(message);
  }

  // 检查胜利条件
  bool checkVictory() {
    return aliveEnemies.isEmpty;
  }

  // 检查失败条件
  bool checkDefeat() {
    return player.currentHealth <= 0;
  }
}
