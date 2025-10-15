import 'package:json_annotation/json_annotation.dart';

part 'technique.g.dart';

enum TechniqueType {
  cultivation, // 修炼功法
  combat,      // 战斗技能
  support,     // 辅助技能
}

enum TechniqueRarity {
  common,    // 普通
  rare,      // 稀有
  epic,      // 史诗
  legendary, // 传说
  mythic,    // 神话
}

@JsonSerializable()
class Technique {
  final String id;
  final String name;
  final String description;
  final TechniqueType type;
  final TechniqueRarity rarity;
  final int maxLevel;
  final Map<String, double> baseEffects;
  final Map<String, double> levelMultipliers;
  final int baseCost;
  final int levelCostMultiplier;

  const Technique({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.rarity,
    required this.maxLevel,
    required this.baseEffects,
    required this.levelMultipliers,
    required this.baseCost,
    required this.levelCostMultiplier,
  });

  factory Technique.fromJson(Map<String, dynamic> json) => _$TechniqueFromJson(json);
  Map<String, dynamic> toJson() => _$TechniqueToJson(this);

  // 获取指定等级的效果值
  double getEffectAtLevel(String effectKey, int level) {
    final baseEffect = baseEffects[effectKey] ?? 0.0;
    final multiplier = levelMultipliers[effectKey] ?? 1.0;
    return baseEffect * (1 + (level - 1) * multiplier);
  }

  // 获取升级到指定等级的花费
  int getCostToLevel(int targetLevel) {
    if (targetLevel <= 1) return 0;
    int totalCost = 0;
    for (int i = 2; i <= targetLevel; i++) {
      totalCost += baseCost * (levelCostMultiplier * (i - 1));
    }
    return totalCost;
  }

  static const List<Technique> availableTechniques = [
    // 修炼功法
    Technique(
      id: 'basic_cultivation',
      name: '基础吐纳术',
      description: '最基础的修炼功法，提升修炼效率',
      type: TechniqueType.cultivation,
      rarity: TechniqueRarity.common,
      maxLevel: 10,
      baseEffects: {
        'cultivation_speed': 1.1,
        'exp_bonus': 0.05,
      },
      levelMultipliers: {
        'cultivation_speed': 0.1,
        'exp_bonus': 0.02,
      },
      baseCost: 50,
      levelCostMultiplier: 2,
    ),
    
    Technique(
      id: 'qi_gathering',
      name: '聚气诀',
      description: '聚集天地灵气，大幅提升修炼速度',
      type: TechniqueType.cultivation,
      rarity: TechniqueRarity.rare,
      maxLevel: 15,
      baseEffects: {
        'cultivation_speed': 1.3,
        'exp_bonus': 0.1,
        'mana_regen': 1.2,
      },
      levelMultipliers: {
        'cultivation_speed': 0.15,
        'exp_bonus': 0.03,
        'mana_regen': 0.1,
      },
      baseCost: 200,
      levelCostMultiplier: 3,
    ),

    // 战斗技能
    Technique(
      id: 'spirit_strike',
      name: '灵力冲击',
      description: '凝聚灵力进行攻击',
      type: TechniqueType.combat,
      rarity: TechniqueRarity.common,
      maxLevel: 20,
      baseEffects: {
        'damage_multiplier': 1.5,
        'mana_cost': 10.0,
      },
      levelMultipliers: {
        'damage_multiplier': 0.1,
        'mana_cost': 0.5,
      },
      baseCost: 100,
      levelCostMultiplier: 2,
    ),

    Technique(
      id: 'flame_burst',
      name: '烈焰爆发',
      description: '释放强大的火焰攻击',
      type: TechniqueType.combat,
      rarity: TechniqueRarity.epic,
      maxLevel: 25,
      baseEffects: {
        'damage_multiplier': 2.0,
        'burn_damage': 0.1,
        'mana_cost': 25.0,
      },
      levelMultipliers: {
        'damage_multiplier': 0.15,
        'burn_damage': 0.02,
        'mana_cost': 1.0,
      },
      baseCost: 500,
      levelCostMultiplier: 4,
    ),

    // 辅助技能
    Technique(
      id: 'meditation',
      name: '冥想术',
      description: '通过冥想恢复法力值',
      type: TechniqueType.support,
      rarity: TechniqueRarity.common,
      maxLevel: 15,
      baseEffects: {
        'mana_regen': 1.5,
        'health_regen': 1.2,
      },
      levelMultipliers: {
        'mana_regen': 0.2,
        'health_regen': 0.1,
      },
      baseCost: 80,
      levelCostMultiplier: 2,
    ),

    Technique(
      id: 'iron_body',
      name: '金刚不坏身',
      description: '强化身体，提升防御力',
      type: TechniqueType.support,
      rarity: TechniqueRarity.legendary,
      maxLevel: 30,
      baseEffects: {
        'defense_multiplier': 1.3,
        'health_multiplier': 1.2,
        'damage_reduction': 0.05,
      },
      levelMultipliers: {
        'defense_multiplier': 0.1,
        'health_multiplier': 0.05,
        'damage_reduction': 0.01,
      },
      baseCost: 1000,
      levelCostMultiplier: 5,
    ),
  ];

  static Technique? getTechniqueById(String id) {
    try {
      return availableTechniques.firstWhere((tech) => tech.id == id);
    } catch (e) {
      return null;
    }
  }
}

@JsonSerializable()
class LearnedTechnique {
  final String techniqueId;
  int level;
  int experience;

  LearnedTechnique({
    required this.techniqueId,
    this.level = 1,
    this.experience = 0,
  });

  factory LearnedTechnique.fromJson(Map<String, dynamic> json) => _$LearnedTechniqueFromJson(json);
  Map<String, dynamic> toJson() => _$LearnedTechniqueToJson(this);

  Technique? get technique => Technique.getTechniqueById(techniqueId);

  // 获取升级到下一级所需经验
  int get expToNextLevel {
    if (technique == null || level >= technique!.maxLevel) return 0;
    return technique!.baseCost * (technique!.levelCostMultiplier * level);
  }

  // 获取升级进度
  double get levelProgress {
    if (expToNextLevel == 0) return 1.0;
    return experience / expToNextLevel;
  }

  // 添加经验值
  bool addExperience(int exp) {
    if (technique == null || level >= technique!.maxLevel) return false;
    
    experience += exp;
    bool leveledUp = false;
    
    while (experience >= expToNextLevel && level < technique!.maxLevel) {
      experience -= expToNextLevel;
      level++;
      leveledUp = true;
    }
    
    return leveledUp;
  }

  // 获取当前等级的效果
  Map<String, double> getCurrentEffects() {
    if (technique == null) return {};
    
    Map<String, double> effects = {};
    for (String key in technique!.baseEffects.keys) {
      effects[key] = technique!.getEffectAtLevel(key, level);
    }
    return effects;
  }
}
