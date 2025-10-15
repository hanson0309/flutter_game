import 'package:json_annotation/json_annotation.dart';

part 'achievement.g.dart';

enum AchievementType {
  cultivation,  // 修炼相关
  combat,      // 战斗相关
  equipment,   // 装备相关
  technique,   // 功法相关
  general,     // 通用成就
}

enum AchievementRarity {
  common,      // 普通
  rare,        // 稀有
  epic,        // 史诗
  legendary,   // 传说
}

@JsonSerializable()
class Achievement {
  final String id;
  final String name;
  final String description;
  final AchievementType type;
  final AchievementRarity rarity;
  final int targetValue;
  final Map<String, dynamic> rewards;
  final String iconPath;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.rarity,
    required this.targetValue,
    required this.rewards,
    required this.iconPath,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) => _$AchievementFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementToJson(this);

  // 预定义的成就列表
  static const List<Achievement> allAchievements = [
    // 修炼成就
    Achievement(
      id: 'first_breakthrough',
      name: '初窥门径',
      description: '首次突破到练气期',
      type: AchievementType.cultivation,
      rarity: AchievementRarity.common,
      targetValue: 1,
      rewards: {'spiritStones': 100, 'cultivationPoints': 50},
      iconPath: 'assets/images/achievements/first_breakthrough.png',
    ),
    Achievement(
      id: 'foundation_builder',
      name: '筑基修士',
      description: '突破到筑基期',
      type: AchievementType.cultivation,
      rarity: AchievementRarity.rare,
      targetValue: 2,
      rewards: {'spiritStones': 500, 'cultivationPoints': 200},
      iconPath: 'assets/images/achievements/foundation_builder.png',
    ),
    Achievement(
      id: 'golden_core',
      name: '金丹大道',
      description: '凝结金丹，踏入金丹期',
      type: AchievementType.cultivation,
      rarity: AchievementRarity.epic,
      targetValue: 3,
      rewards: {'spiritStones': 2000, 'cultivationPoints': 500},
      iconPath: 'assets/images/achievements/golden_core.png',
    ),
    Achievement(
      id: 'nascent_soul',
      name: '元婴之境',
      description: '元婴出窍，超凡脱俗',
      type: AchievementType.cultivation,
      rarity: AchievementRarity.legendary,
      targetValue: 4,
      rewards: {'spiritStones': 5000, 'cultivationPoints': 1000},
      iconPath: 'assets/images/achievements/nascent_soul.png',
    ),
    Achievement(
      id: 'immortal_ascension',
      name: '飞升仙界',
      description: '突破到飞升期，成为真正的仙人',
      type: AchievementType.cultivation,
      rarity: AchievementRarity.legendary,
      targetValue: 10,
      rewards: {'spiritStones': 20000, 'cultivationPoints': 5000},
      iconPath: 'assets/images/achievements/immortal_ascension.png',
    ),

    // 修炼次数成就
    Achievement(
      id: 'diligent_cultivator',
      name: '勤修苦练',
      description: '累计修炼1000次',
      type: AchievementType.cultivation,
      rarity: AchievementRarity.common,
      targetValue: 1000,
      rewards: {'spiritStones': 200, 'expMultiplier': 0.05},
      iconPath: 'assets/images/achievements/diligent_cultivator.png',
    ),
    Achievement(
      id: 'cultivation_master',
      name: '修炼大师',
      description: '累计修炼10000次',
      type: AchievementType.cultivation,
      rarity: AchievementRarity.rare,
      targetValue: 10000,
      rewards: {'spiritStones': 1000, 'expMultiplier': 0.1},
      iconPath: 'assets/images/achievements/cultivation_master.png',
    ),

    // 战斗成就
    Achievement(
      id: 'first_victory',
      name: '初战告捷',
      description: '赢得第一场战斗',
      type: AchievementType.combat,
      rarity: AchievementRarity.common,
      targetValue: 1,
      rewards: {'spiritStones': 50, 'cultivationPoints': 25},
      iconPath: 'assets/images/achievements/first_victory.png',
    ),
    Achievement(
      id: 'warrior',
      name: '百战勇士',
      description: '赢得100场战斗',
      type: AchievementType.combat,
      rarity: AchievementRarity.rare,
      targetValue: 100,
      rewards: {'spiritStones': 800, 'attackBonus': 10},
      iconPath: 'assets/images/achievements/warrior.png',
    ),
    Achievement(
      id: 'battle_legend',
      name: '战斗传说',
      description: '赢得1000场战斗',
      type: AchievementType.combat,
      rarity: AchievementRarity.legendary,
      targetValue: 1000,
      rewards: {'spiritStones': 5000, 'attackBonus': 50},
      iconPath: 'assets/images/achievements/battle_legend.png',
    ),

    // 功法成就
    Achievement(
      id: 'technique_learner',
      name: '功法入门',
      description: '学会第一个功法',
      type: AchievementType.technique,
      rarity: AchievementRarity.common,
      targetValue: 1,
      rewards: {'spiritStones': 100, 'cultivationPoints': 100},
      iconPath: 'assets/images/achievements/technique_learner.png',
    ),
    Achievement(
      id: 'technique_master',
      name: '功法大师',
      description: '学会5个不同的功法',
      type: AchievementType.technique,
      rarity: AchievementRarity.epic,
      targetValue: 5,
      rewards: {'spiritStones': 2000, 'cultivationPoints': 1000},
      iconPath: 'assets/images/achievements/technique_master.png',
    ),

    // 装备成就
    Achievement(
      id: 'first_equipment',
      name: '初次装备',
      description: '装备第一件装备',
      type: AchievementType.equipment,
      rarity: AchievementRarity.common,
      targetValue: 1,
      rewards: {'spiritStones': 50},
      iconPath: 'assets/images/achievements/first_equipment.png',
    ),
    Achievement(
      id: 'equipment_enhancer',
      name: '强化大师',
      description: '强化装备50次',
      type: AchievementType.equipment,
      rarity: AchievementRarity.rare,
      targetValue: 50,
      rewards: {'spiritStones': 1000, 'enhanceSuccessRate': 0.1},
      iconPath: 'assets/images/achievements/equipment_enhancer.png',
    ),

    // 通用成就
    Achievement(
      id: 'spirit_collector',
      name: '灵石收集者',
      description: '累计获得10000灵石',
      type: AchievementType.general,
      rarity: AchievementRarity.rare,
      targetValue: 10000,
      rewards: {'spiritStones': 500, 'spiritStoneMultiplier': 0.05},
      iconPath: 'assets/images/achievements/spirit_collector.png',
    ),
    Achievement(
      id: 'persistent_cultivator',
      name: '修仙之路',
      description: '连续登录7天',
      type: AchievementType.general,
      rarity: AchievementRarity.rare,
      targetValue: 7,
      rewards: {'spiritStones': 1000, 'cultivationPoints': 500},
      iconPath: 'assets/images/achievements/persistent_cultivator.png',
    ),
  ];

  // 根据ID获取成就
  static Achievement? getAchievementById(String id) {
    try {
      return allAchievements.firstWhere((achievement) => achievement.id == id);
    } catch (e) {
      return null;
    }
  }

  // 根据类型获取成就
  static List<Achievement> getAchievementsByType(AchievementType type) {
    return allAchievements.where((achievement) => achievement.type == type).toList();
  }

  // 根据稀有度获取成就
  static List<Achievement> getAchievementsByRarity(AchievementRarity rarity) {
    return allAchievements.where((achievement) => achievement.rarity == rarity).toList();
  }
}

@JsonSerializable()
class PlayerAchievement {
  final String achievementId;
  int currentProgress;
  bool isCompleted;
  DateTime? completedAt;
  bool isRewardClaimed;

  PlayerAchievement({
    required this.achievementId,
    this.currentProgress = 0,
    this.isCompleted = false,
    this.completedAt,
    this.isRewardClaimed = false,
  });

  factory PlayerAchievement.fromJson(Map<String, dynamic> json) => _$PlayerAchievementFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerAchievementToJson(this);

  // 获取成就信息
  Achievement? get achievement => Achievement.getAchievementById(achievementId);

  // 更新进度
  bool updateProgress(int value) {
    if (isCompleted) return false;
    
    currentProgress = value;
    final achievement = this.achievement;
    if (achievement != null && currentProgress >= achievement.targetValue) {
      isCompleted = true;
      completedAt = DateTime.now();
      return true; // 返回true表示成就刚完成
    }
    return false;
  }

  // 增加进度
  bool addProgress(int value) {
    return updateProgress(currentProgress + value);
  }

  // 获取进度百分比
  double get progressPercentage {
    final achievement = this.achievement;
    if (achievement == null) return 0.0;
    return (currentProgress / achievement.targetValue).clamp(0.0, 1.0);
  }

  // 领取奖励
  bool claimReward() {
    if (!isCompleted || isRewardClaimed) return false;
    isRewardClaimed = true;
    return true;
  }
}
