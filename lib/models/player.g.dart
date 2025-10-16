// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) => Player(
  name: json['name'] as String,
  level: (json['level'] as num?)?.toInt() ?? 0,
  currentExp: (json['currentExp'] as num?)?.toInt() ?? 0,
  totalExp: (json['totalExp'] as num?)?.toInt() ?? 0,
  baseAttack: (json['baseAttack'] as num?)?.toDouble() ?? 10.0,
  baseDefense: (json['baseDefense'] as num?)?.toDouble() ?? 8.0,
  baseHealth: (json['baseHealth'] as num?)?.toDouble() ?? 100.0,
  baseMana: (json['baseMana'] as num?)?.toDouble() ?? 50.0,
  currentHealth: (json['currentHealth'] as num?)?.toDouble(),
  currentMana: (json['currentMana'] as num?)?.toDouble(),
  isAutoTraining: json['isAutoTraining'] as bool? ?? false,
  lastTrainingTime: json['lastTrainingTime'] == null
      ? null
      : DateTime.parse(json['lastTrainingTime'] as String),
  spiritStones: (json['spiritStones'] as num?)?.toInt() ?? 1000,
  cultivationPoints: (json['cultivationPoints'] as num?)?.toInt() ?? 0,
  learnedTechniques: (json['learnedTechniques'] as List<dynamic>?)
      ?.map((e) => LearnedTechnique.fromJson(e as Map<String, dynamic>))
      .toList(),
  equippedItems: (json['equippedItems'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(
      k,
      e == null ? null : EquippedItem.fromJson(e as Map<String, dynamic>),
    ),
  ),
  inventory: (json['inventory'] as List<dynamic>?)
      ?.map((e) => EquippedItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
  'name': instance.name,
  'level': instance.level,
  'currentExp': instance.currentExp,
  'totalExp': instance.totalExp,
  'baseAttack': instance.baseAttack,
  'baseDefense': instance.baseDefense,
  'baseHealth': instance.baseHealth,
  'baseMana': instance.baseMana,
  'currentHealth': instance.currentHealth,
  'currentMana': instance.currentMana,
  'isAutoTraining': instance.isAutoTraining,
  'lastTrainingTime': instance.lastTrainingTime?.toIso8601String(),
  'spiritStones': instance.spiritStones,
  'cultivationPoints': instance.cultivationPoints,
  'learnedTechniques': instance.learnedTechniques,
  'equippedItems': instance.equippedItems,
  'inventory': instance.inventory,
};
