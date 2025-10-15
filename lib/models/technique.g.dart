// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'technique.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Technique _$TechniqueFromJson(Map<String, dynamic> json) => Technique(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$TechniqueTypeEnumMap, json['type']),
  rarity: $enumDecode(_$TechniqueRarityEnumMap, json['rarity']),
  maxLevel: (json['maxLevel'] as num).toInt(),
  baseEffects: (json['baseEffects'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  levelMultipliers: (json['levelMultipliers'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  baseCost: (json['baseCost'] as num).toInt(),
  levelCostMultiplier: (json['levelCostMultiplier'] as num).toInt(),
);

Map<String, dynamic> _$TechniqueToJson(Technique instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'type': _$TechniqueTypeEnumMap[instance.type]!,
  'rarity': _$TechniqueRarityEnumMap[instance.rarity]!,
  'maxLevel': instance.maxLevel,
  'baseEffects': instance.baseEffects,
  'levelMultipliers': instance.levelMultipliers,
  'baseCost': instance.baseCost,
  'levelCostMultiplier': instance.levelCostMultiplier,
};

const _$TechniqueTypeEnumMap = {
  TechniqueType.cultivation: 'cultivation',
  TechniqueType.combat: 'combat',
  TechniqueType.support: 'support',
};

const _$TechniqueRarityEnumMap = {
  TechniqueRarity.common: 'common',
  TechniqueRarity.rare: 'rare',
  TechniqueRarity.epic: 'epic',
  TechniqueRarity.legendary: 'legendary',
  TechniqueRarity.mythic: 'mythic',
};

LearnedTechnique _$LearnedTechniqueFromJson(Map<String, dynamic> json) =>
    LearnedTechnique(
      techniqueId: json['techniqueId'] as String,
      level: (json['level'] as num?)?.toInt() ?? 1,
      experience: (json['experience'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$LearnedTechniqueToJson(LearnedTechnique instance) =>
    <String, dynamic>{
      'techniqueId': instance.techniqueId,
      'level': instance.level,
      'experience': instance.experience,
    };
