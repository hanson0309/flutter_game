import 'package:json_annotation/json_annotation.dart';

part 'enemy.g.dart';

enum EnemyType {
  beast,     // 妖兽
  demon,     // 魔族
  cultivator, // 修炼者
  spirit,    // 灵体
}

@JsonSerializable()
class Enemy {
  final String id;
  final String name;
  final String description;
  final EnemyType type;
  final int level;
  final double baseAttack;
  final double baseDefense;
  final double baseHealth;
  final double baseMana;
  final List<String> skills;
  final Map<String, double> dropRates; // 掉落物品概率
  final int expReward;
  final int spiritStoneReward;

  const Enemy({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.level,
    required this.baseAttack,
    required this.baseDefense,
    required this.baseHealth,
    required this.baseMana,
    this.skills = const [],
    this.dropRates = const {},
    required this.expReward,
    required this.spiritStoneReward,
  });

  factory Enemy.fromJson(Map<String, dynamic> json) => _$EnemyFromJson(json);
  Map<String, dynamic> toJson() => _$EnemyToJson(this);

  static const List<Enemy> availableEnemies = [
    // 练气期敌人
    Enemy(
      id: 'wild_rabbit',
      name: '野兔',
      description: '森林中常见的小动物，虽然弱小但动作敏捷',
      type: EnemyType.beast,
      level: 0,
      baseAttack: 8.0,
      baseDefense: 5.0,
      baseHealth: 30.0,
      baseMana: 10.0,
      expReward: 5,
      spiritStoneReward: 1,
      dropRates: {
        'wooden_sword': 0.1,
      },
    ),

    Enemy(
      id: 'forest_wolf',
      name: '森林狼',
      description: '凶猛的狼群首领，拥有锋利的爪牙',
      type: EnemyType.beast,
      level: 1,
      baseAttack: 25.0,
      baseDefense: 15.0,
      baseHealth: 80.0,
      baseMana: 20.0,
      skills: ['bite', 'howl'],
      expReward: 15,
      spiritStoneReward: 3,
      dropRates: {
        'iron_sword': 0.15,
        'leather_armor': 0.2,
      },
    ),

    Enemy(
      id: 'shadow_cat',
      name: '影猫',
      description: '神秘的暗影生物，擅长隐身和偷袭',
      type: EnemyType.spirit,
      level: 1,
      baseAttack: 30.0,
      baseDefense: 10.0,
      baseHealth: 60.0,
      baseMana: 40.0,
      skills: ['stealth', 'shadow_strike'],
      expReward: 20,
      spiritStoneReward: 5,
      dropRates: {
        'jade_pendant': 0.25,
      },
    ),

    Enemy(
      id: 'swamp_crocodile',
      name: '沼泽鳄鱼',
      description: '凶猛的沼泽霸主，拥有强大的咬合力和厚实的鳞甲',
      type: EnemyType.beast,
      level: 1,
      baseAttack: 35.0,
      baseDefense: 25.0,
      baseHealth: 100.0,
      baseMana: 15.0,
      skills: ['death_roll', 'tail_whip'],
      expReward: 25,
      spiritStoneReward: 6,
      dropRates: {
        'crocodile_scale': 0.3,
        'leather_armor': 0.15,
      },
    ),

    // 筑基期敌人
    Enemy(
      id: 'iron_golem',
      name: '铁傀儡',
      description: '用精铁打造的战斗傀儡，防御力惊人',
      type: EnemyType.spirit,
      level: 2,
      baseAttack: 45.0,
      baseDefense: 60.0,
      baseHealth: 200.0,
      baseMana: 50.0,
      skills: ['iron_fist', 'defensive_stance'],
      expReward: 50,
      spiritStoneReward: 10,
      dropRates: {
        'spirit_sword': 0.1,
        'spirit_armor': 0.15,
      },
    ),

    Enemy(
      id: 'fire_spirit',
      name: '火灵',
      description: '由纯粹火焰凝聚而成的灵体，攻击带有灼烧效果',
      type: EnemyType.spirit,
      level: 2,
      baseAttack: 70.0,
      baseDefense: 30.0,
      baseHealth: 120.0,
      baseMana: 100.0,
      skills: ['fireball', 'flame_burst', 'burn'],
      expReward: 60,
      spiritStoneReward: 12,
      dropRates: {
        'spirit_orb': 0.2,
      },
    ),

    Enemy(
      id: 'rogue_cultivator',
      name: '邪修',
      description: '误入歧途的修炼者，使用邪恶的功法',
      type: EnemyType.cultivator,
      level: 2,
      baseAttack: 55.0,
      baseDefense: 40.0,
      baseHealth: 150.0,
      baseMana: 80.0,
      skills: ['dark_bolt', 'life_drain', 'curse'],
      expReward: 70,
      spiritStoneReward: 15,
      dropRates: {
        'spirit_ring': 0.08,
      },
    ),

    // 金丹期敌人
    Enemy(
      id: 'ancient_dragon',
      name: '远古巨龙',
      description: '传说中的强大生物，拥有毁天灭地的力量',
      type: EnemyType.beast,
      level: 3,
      baseAttack: 150.0,
      baseDefense: 100.0,
      baseHealth: 500.0,
      baseMana: 200.0,
      skills: ['dragon_breath', 'tail_sweep', 'roar', 'dragon_claw'],
      expReward: 200,
      spiritStoneReward: 50,
      dropRates: {
        'dragon_blade': 0.05,
        'phoenix_robe': 0.03,
      },
    ),

    Enemy(
      id: 'demon_lord',
      name: '魔王',
      description: '来自魔界的强大存在，掌控着黑暗力量',
      type: EnemyType.demon,
      level: 4,
      baseAttack: 200.0,
      baseDefense: 120.0,
      baseHealth: 800.0,
      baseMana: 300.0,
      skills: ['dark_magic', 'soul_burn', 'demon_summon', 'hell_fire'],
      expReward: 400,
      spiritStoneReward: 100,
      dropRates: {
        'immortal_gourd': 0.02,
      },
    ),
  ];

  static List<Enemy> getEnemiesByLevel(int playerLevel) {
    return availableEnemies.where((enemy) {
      return enemy.level <= playerLevel + 1 && enemy.level >= (playerLevel - 1).clamp(0, 10);
    }).toList();
  }

  static Enemy? getEnemyById(String id) {
    try {
      return availableEnemies.firstWhere((enemy) => enemy.id == id);
    } catch (e) {
      return null;
    }
  }
}

@JsonSerializable()
class BattleResult {
  final bool victory;
  final int expGained;
  final int spiritStonesGained;
  final List<String> itemsDropped;
  final int damageDealt;
  final int damageTaken;
  final int turnCount;

  const BattleResult({
    required this.victory,
    required this.expGained,
    required this.spiritStonesGained,
    required this.itemsDropped,
    required this.damageDealt,
    required this.damageTaken,
    required this.turnCount,
  });

  factory BattleResult.fromJson(Map<String, dynamic> json) => _$BattleResultFromJson(json);
  Map<String, dynamic> toJson() => _$BattleResultToJson(this);
}

@JsonSerializable()
class BattleState {
  final Enemy enemy;
  double enemyCurrentHealth;
  double enemyCurrentMana;
  double playerCurrentHealth;
  double playerCurrentMana;
  int turnCount;
  List<String> battleLog;
  bool isPlayerTurn;
  Map<String, int> statusEffects; // 状态效果，如燃烧、中毒等

  BattleState({
    required this.enemy,
    required this.enemyCurrentHealth,
    required this.enemyCurrentMana,
    required this.playerCurrentHealth,
    required this.playerCurrentMana,
    this.turnCount = 0,
    List<String>? battleLog,
    this.isPlayerTurn = true,
    Map<String, int>? statusEffects,
  }) : battleLog = battleLog ?? [],
       statusEffects = statusEffects ?? {};

  factory BattleState.fromJson(Map<String, dynamic> json) => _$BattleStateFromJson(json);
  Map<String, dynamic> toJson() => _$BattleStateToJson(this);

  bool get isEnemyDefeated => enemyCurrentHealth <= 0;
  bool get isPlayerDefeated => playerCurrentHealth <= 0;
  bool get isBattleOver => isEnemyDefeated || isPlayerDefeated;

  void addLog(String message) {
    battleLog.add(message);
    if (battleLog.length > 20) {
      battleLog.removeAt(0); // 保持日志长度不超过20条
    }
  }

  void nextTurn() {
    turnCount++;
    isPlayerTurn = !isPlayerTurn;
  }
}
