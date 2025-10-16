import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'equipment.g.dart';

enum EquipmentType {
  weapon,    // 武器
  armor,     // 护甲
  accessory, // 饰品
  treasure,  // 法宝
  ring,      // 戒指
  necklace,  // 项链
  boots,     // 靴子
  belt,      // 腰带
  gloves,    // 手套
  helmet,    // 头盔
  rune,      // 符文
  gem,       // 宝石
}

enum EquipmentRarity {
  common,    // 普通 (白色)
  uncommon,  // 不凡 (绿色)
  rare,      // 稀有 (蓝色)
  epic,      // 史诗 (紫色)
  legendary, // 传说 (橙色)
  mythic,    // 神话 (红色)
}

@JsonSerializable()
class Equipment {
  final String id;
  final String name;
  final String description;
  final EquipmentType type;
  final EquipmentRarity rarity;
  final int requiredLevel;
  final Map<String, double> baseStats;
  final int maxEnhanceLevel;
  final double enhanceStatMultiplier;

  const Equipment({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.rarity,
    required this.requiredLevel,
    required this.baseStats,
    this.maxEnhanceLevel = 10,
    this.enhanceStatMultiplier = 0.1,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) => _$EquipmentFromJson(json);
  Map<String, dynamic> toJson() => _$EquipmentToJson(this);

  // 获取装备品质颜色
  Color get qualityColor {
    switch (rarity) {
      case EquipmentRarity.common:
        return const Color(0xFF9E9E9E); // 灰色
      case EquipmentRarity.uncommon:
        return const Color(0xFF4CAF50); // 绿色
      case EquipmentRarity.rare:
        return const Color(0xFF2196F3); // 蓝色
      case EquipmentRarity.epic:
        return const Color(0xFF9C27B0); // 紫色
      case EquipmentRarity.legendary:
        return const Color(0xFFFF9800); // 橙色
      case EquipmentRarity.mythic:
        return const Color(0xFFF44336); // 红色
    }
  }

  // 获取指定强化等级的属性
  Map<String, double> getStatsAtLevel(int enhanceLevel) {
    Map<String, double> stats = {};
    for (var entry in baseStats.entries) {
      stats[entry.key] = entry.value * (1 + enhanceLevel * enhanceStatMultiplier);
    }
    return stats;
  }

  // 获取强化到指定等级的花费
  int getEnhanceCost(int targetLevel) {
    if (targetLevel <= 0) return 0;
    int baseCost = _getRarityBaseCost();
    return baseCost * targetLevel * targetLevel;
  }

  int _getRarityBaseCost() {
    switch (rarity) {
      case EquipmentRarity.common:
        return 10;
      case EquipmentRarity.uncommon:
        return 25;
      case EquipmentRarity.rare:
        return 50;
      case EquipmentRarity.epic:
        return 100;
      case EquipmentRarity.legendary:
        return 200;
      case EquipmentRarity.mythic:
        return 500;
    }
  }

  static const List<Equipment> availableEquipment = [
    // 武器
    Equipment(
      id: 'wooden_sword',
      name: '木剑',
      description: '最基础的修仙武器，虽然简陋但胜在轻便',
      type: EquipmentType.weapon,
      rarity: EquipmentRarity.common,
      requiredLevel: 0,
      baseStats: {
        'attack': 15.0,
        'critical_rate': 0.05,
      },
    ),

    Equipment(
      id: 'iron_sword',
      name: '铁剑',
      description: '用精铁打造的长剑，锋利且坚固',
      type: EquipmentType.weapon,
      rarity: EquipmentRarity.uncommon,
      requiredLevel: 1,
      baseStats: {
        'attack': 35.0,
        'critical_rate': 0.08,
        'critical_damage': 0.1,
      },
    ),

    Equipment(
      id: 'spirit_sword',
      name: '灵剑',
      description: '蕴含灵气的宝剑，能够增强修炼者的法力',
      type: EquipmentType.weapon,
      rarity: EquipmentRarity.rare,
      requiredLevel: 2,
      baseStats: {
        'attack': 80.0,
        'mana': 50.0,
        'critical_rate': 0.12,
        'critical_damage': 0.2,
      },
    ),

    Equipment(
      id: 'dragon_blade',
      name: '龙鳞剑',
      description: '传说中用龙鳞锻造的神兵，威力无穷',
      type: EquipmentType.weapon,
      rarity: EquipmentRarity.legendary,
      requiredLevel: 4,
      baseStats: {
        'attack': 200.0,
        'mana': 100.0,
        'critical_rate': 0.20,
        'critical_damage': 0.5,
        'skill_damage': 0.3,
      },
    ),

    // 护甲
    Equipment(
      id: 'cloth_robe',
      name: '布袍',
      description: '简单的修炼服装，能够提供基础防护',
      type: EquipmentType.armor,
      rarity: EquipmentRarity.common,
      requiredLevel: 0,
      baseStats: {
        'defense': 10.0,
        'health': 30.0,
      },
    ),

    Equipment(
      id: 'leather_armor',
      name: '皮甲',
      description: '用妖兽皮革制作的护甲，防护力不错',
      type: EquipmentType.armor,
      rarity: EquipmentRarity.uncommon,
      requiredLevel: 1,
      baseStats: {
        'defense': 25.0,
        'health': 80.0,
        'dodge_rate': 0.05,
      },
    ),

    Equipment(
      id: 'spirit_armor',
      name: '灵甲',
      description: '注入灵气的护甲，能够自动恢复伤势',
      type: EquipmentType.armor,
      rarity: EquipmentRarity.rare,
      requiredLevel: 2,
      baseStats: {
        'defense': 60.0,
        'health': 150.0,
        'health_regen': 1.2,
        'dodge_rate': 0.08,
      },
    ),

    Equipment(
      id: 'phoenix_robe',
      name: '凤凰法袍',
      description: '传说中凤凰羽毛编织的法袍，拥有涅槃之力',
      type: EquipmentType.armor,
      rarity: EquipmentRarity.legendary,
      requiredLevel: 4,
      baseStats: {
        'defense': 150.0,
        'health': 400.0,
        'mana': 200.0,
        'health_regen': 2.0,
        'mana_regen': 1.5,
        'damage_reduction': 0.15,
      },
    ),

    // 饰品
    Equipment(
      id: 'jade_pendant',
      name: '玉佩',
      description: '温润的玉石饰品，能够平静心神',
      type: EquipmentType.accessory,
      rarity: EquipmentRarity.uncommon,
      requiredLevel: 1,
      baseStats: {
        'mana': 40.0,
        'mana_regen': 1.1,
        'cultivation_speed': 1.05,
      },
    ),

    Equipment(
      id: 'spirit_ring',
      name: '灵戒',
      description: '蕴含强大灵力的戒指，能够增强各种能力',
      type: EquipmentType.accessory,
      rarity: EquipmentRarity.epic,
      requiredLevel: 3,
      baseStats: {
        'attack': 50.0,
        'defense': 30.0,
        'mana': 100.0,
        'cultivation_speed': 1.15,
        'exp_bonus': 0.1,
      },
    ),

    // 法宝
    Equipment(
      id: 'spirit_orb',
      name: '灵珠',
      description: '凝聚天地精华的宝珠，修炼必备之物',
      type: EquipmentType.treasure,
      rarity: EquipmentRarity.rare,
      requiredLevel: 2,
      baseStats: {
        'mana': 120.0,
        'cultivation_speed': 1.25,
        'exp_bonus': 0.15,
        'skill_cooldown': 0.9,
      },
    ),

    Equipment(
      id: 'immortal_gourd',
      name: '仙葫芦',
      description: '传说中仙人使用的宝葫芦，拥有神奇的力量',
      type: EquipmentType.treasure,
      rarity: EquipmentRarity.mythic,
      requiredLevel: 5,
      baseStats: {
        'attack': 100.0,
        'defense': 80.0,
        'health': 300.0,
        'mana': 300.0,
        'cultivation_speed': 1.5,
        'exp_bonus': 0.3,
        'all_damage': 0.25,
        'damage_reduction': 0.2,
      },
    ),

    // 戒指类装备
    Equipment(
      id: 'bronze_ring',
      name: '青铜戒指',
      description: '简单的青铜戒指，能够提供基础的法力增强',
      type: EquipmentType.ring,
      rarity: EquipmentRarity.common,
      requiredLevel: 0,
      baseStats: {
        'mana': 20.0,
        'mana_regen': 0.5,
      },
    ),

    Equipment(
      id: 'spirit_ring',
      name: '灵力戒指',
      description: '蕴含灵力的戒指，能够增强修炼效果',
      type: EquipmentType.ring,
      rarity: EquipmentRarity.rare,
      requiredLevel: 2,
      baseStats: {
        'mana': 60.0,
        'cultivation_speed': 1.1,
        'exp_bonus': 0.05,
      },
    ),

    Equipment(
      id: 'dragon_ring',
      name: '龙鳞戒指',
      description: '用龙鳞制作的神秘戒指，拥有强大的力量',
      type: EquipmentType.ring,
      rarity: EquipmentRarity.legendary,
      requiredLevel: 4,
      baseStats: {
        'attack': 40.0,
        'mana': 100.0,
        'critical_rate': 0.1,
        'cultivation_speed': 1.2,
      },
    ),

    // 项链类装备
    Equipment(
      id: 'jade_necklace',
      name: '玉石项链',
      description: '温润的玉石项链，能够平静心神，增强防御',
      type: EquipmentType.necklace,
      rarity: EquipmentRarity.uncommon,
      requiredLevel: 1,
      baseStats: {
        'defense': 15.0,
        'health': 40.0,
        'mana_regen': 0.8,
      },
    ),

    Equipment(
      id: 'phoenix_necklace',
      name: '凤凰项链',
      description: '凤凰羽毛制成的项链，拥有涅槃重生的力量',
      type: EquipmentType.necklace,
      rarity: EquipmentRarity.epic,
      requiredLevel: 3,
      baseStats: {
        'health': 120.0,
        'health_regen': 1.5,
        'damage_reduction': 0.1,
        'exp_bonus': 0.08,
      },
    ),

    // 靴子类装备
    Equipment(
      id: 'cloth_boots',
      name: '布靴',
      description: '简单的布制靴子，轻便舒适',
      type: EquipmentType.boots,
      rarity: EquipmentRarity.common,
      requiredLevel: 0,
      baseStats: {
        'defense': 5.0,
        'dodge_rate': 0.02,
      },
    ),

    Equipment(
      id: 'wind_boots',
      name: '疾风靴',
      description: '蕴含风之力的靴子，能够提升移动和闪避能力',
      type: EquipmentType.boots,
      rarity: EquipmentRarity.rare,
      requiredLevel: 2,
      baseStats: {
        'defense': 25.0,
        'dodge_rate': 0.08,
        'critical_rate': 0.05,
      },
    ),

    // 腰带类装备
    Equipment(
      id: 'leather_belt',
      name: '皮革腰带',
      description: '坚韧的皮革腰带，能够提供额外的防护',
      type: EquipmentType.belt,
      rarity: EquipmentRarity.common,
      requiredLevel: 0,
      baseStats: {
        'defense': 8.0,
        'health': 25.0,
      },
    ),

    Equipment(
      id: 'spirit_belt',
      name: '灵力腰带',
      description: '注入灵力的腰带，能够增强各项能力',
      type: EquipmentType.belt,
      rarity: EquipmentRarity.uncommon,
      requiredLevel: 1,
      baseStats: {
        'defense': 20.0,
        'health': 50.0,
        'mana': 30.0,
      },
    ),

    // 手套类装备
    Equipment(
      id: 'cloth_gloves',
      name: '布手套',
      description: '简单的布制手套，能够保护双手',
      type: EquipmentType.gloves,
      rarity: EquipmentRarity.common,
      requiredLevel: 0,
      baseStats: {
        'attack': 5.0,
        'defense': 3.0,
      },
    ),

    Equipment(
      id: 'iron_gauntlets',
      name: '铁制护手',
      description: '坚固的铁制护手，能够大幅提升攻击和防御',
      type: EquipmentType.gloves,
      rarity: EquipmentRarity.uncommon,
      requiredLevel: 1,
      baseStats: {
        'attack': 18.0,
        'defense': 12.0,
        'critical_damage': 0.05,
      },
    ),

    // 头盔类装备
    Equipment(
      id: 'cloth_hat',
      name: '布帽',
      description: '简单的布制帽子，能够提供基础防护',
      type: EquipmentType.helmet,
      rarity: EquipmentRarity.common,
      requiredLevel: 0,
      baseStats: {
        'defense': 6.0,
        'health': 20.0,
      },
    ),

    Equipment(
      id: 'iron_helmet',
      name: '铁盔',
      description: '坚固的铁制头盔，能够有效保护头部',
      type: EquipmentType.helmet,
      rarity: EquipmentRarity.uncommon,
      requiredLevel: 1,
      baseStats: {
        'defense': 22.0,
        'health': 60.0,
        'damage_reduction': 0.05,
      },
    ),

    Equipment(
      id: 'dragon_crown',
      name: '龙鳞头冠',
      description: '龙鳞制成的华丽头冠，象征着至高无上的地位',
      type: EquipmentType.helmet,
      rarity: EquipmentRarity.legendary,
      requiredLevel: 4,
      baseStats: {
        'defense': 60.0,
        'health': 150.0,
        'mana': 80.0,
        'damage_reduction': 0.15,
        'cultivation_speed': 1.15,
      },
    ),

    // 符文类装备
    Equipment(
      id: 'power_rune',
      name: '力量符文',
      description: '蕴含力量之源的神秘符文，能够大幅提升攻击力',
      type: EquipmentType.rune,
      rarity: EquipmentRarity.rare,
      requiredLevel: 2,
      baseStats: {
        'attack': 45.0,
        'critical_rate': 0.08,
        'skill_damage': 0.1,
      },
    ),

    Equipment(
      id: 'wisdom_rune',
      name: '智慧符文',
      description: '蕴含古老智慧的符文，能够加速修炼进程',
      type: EquipmentType.rune,
      rarity: EquipmentRarity.epic,
      requiredLevel: 3,
      baseStats: {
        'mana': 80.0,
        'cultivation_speed': 1.25,
        'exp_bonus': 0.15,
        'skill_cooldown': 0.9,
      },
    ),

    // 宝石类装备
    Equipment(
      id: 'ruby_gem',
      name: '红宝石',
      description: '炽热的红宝石，能够增强攻击力和暴击',
      type: EquipmentType.gem,
      rarity: EquipmentRarity.rare,
      requiredLevel: 2,
      baseStats: {
        'attack': 35.0,
        'critical_rate': 0.12,
        'critical_damage': 0.15,
      },
    ),

    Equipment(
      id: 'sapphire_gem',
      name: '蓝宝石',
      description: '深邃的蓝宝石，能够增强法力和防御',
      type: EquipmentType.gem,
      rarity: EquipmentRarity.rare,
      requiredLevel: 2,
      baseStats: {
        'defense': 30.0,
        'mana': 70.0,
        'mana_regen': 1.2,
      },
    ),

    Equipment(
      id: 'diamond_gem',
      name: '钻石',
      description: '最珍贵的钻石，拥有完美的能量平衡',
      type: EquipmentType.gem,
      rarity: EquipmentRarity.mythic,
      requiredLevel: 5,
      baseStats: {
        'attack': 50.0,
        'defense': 50.0,
        'health': 100.0,
        'mana': 100.0,
        'critical_rate': 0.15,
        'damage_reduction': 0.1,
      },
    ),
  ];

  static Equipment? getEquipmentById(String id) {
    try {
      return availableEquipment.firstWhere((eq) => eq.id == id);
    } catch (e) {
      return null;
    }
  }
}

@JsonSerializable()
class EquippedItem {
  final String equipmentId;
  int enhanceLevel;
  final DateTime obtainedAt;

  EquippedItem({
    required this.equipmentId,
    this.enhanceLevel = 0,
    DateTime? obtainedAt,
  }) : obtainedAt = obtainedAt ?? DateTime.now();

  factory EquippedItem.fromJson(Map<String, dynamic> json) => _$EquippedItemFromJson(json);
  Map<String, dynamic> toJson() => _$EquippedItemToJson(this);

  Equipment? get equipment => Equipment.getEquipmentById(equipmentId);

  // 获取当前强化等级的属性
  Map<String, double> getCurrentStats() {
    return equipment?.getStatsAtLevel(enhanceLevel) ?? {};
  }

  // 获取下一级强化的花费
  int getNextEnhanceCost() {
    if (equipment == null || enhanceLevel >= equipment!.maxEnhanceLevel) return 0;
    return equipment!.getEnhanceCost(enhanceLevel + 1) - equipment!.getEnhanceCost(enhanceLevel);
  }

  // 强化装备
  bool enhance() {
    if (equipment == null || enhanceLevel >= equipment!.maxEnhanceLevel) return false;
    enhanceLevel++;
    return true;
  }
}
