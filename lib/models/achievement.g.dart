// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Achievement _$AchievementFromJson(Map<String, dynamic> json) => Achievement(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$AchievementTypeEnumMap, json['type']),
  rarity: $enumDecode(_$AchievementRarityEnumMap, json['rarity']),
  targetValue: (json['targetValue'] as num).toInt(),
  rewards: json['rewards'] as Map<String, dynamic>,
  iconPath: json['iconPath'] as String,
);

Map<String, dynamic> _$AchievementToJson(Achievement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$AchievementTypeEnumMap[instance.type]!,
      'rarity': _$AchievementRarityEnumMap[instance.rarity]!,
      'targetValue': instance.targetValue,
      'rewards': instance.rewards,
      'iconPath': instance.iconPath,
    };

const _$AchievementTypeEnumMap = {
  AchievementType.cultivation: 'cultivation',
  AchievementType.combat: 'combat',
  AchievementType.equipment: 'equipment',
  AchievementType.technique: 'technique',
  AchievementType.general: 'general',
};

const _$AchievementRarityEnumMap = {
  AchievementRarity.common: 'common',
  AchievementRarity.rare: 'rare',
  AchievementRarity.epic: 'epic',
  AchievementRarity.legendary: 'legendary',
};

PlayerAchievement _$PlayerAchievementFromJson(Map<String, dynamic> json) =>
    PlayerAchievement(
      achievementId: json['achievementId'] as String,
      currentProgress: (json['currentProgress'] as num?)?.toInt() ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      isRewardClaimed: json['isRewardClaimed'] as bool? ?? false,
    );

Map<String, dynamic> _$PlayerAchievementToJson(PlayerAchievement instance) =>
    <String, dynamic>{
      'achievementId': instance.achievementId,
      'currentProgress': instance.currentProgress,
      'isCompleted': instance.isCompleted,
      'completedAt': instance.completedAt?.toIso8601String(),
      'isRewardClaimed': instance.isRewardClaimed,
    };
