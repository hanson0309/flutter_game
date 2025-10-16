// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Equipment _$EquipmentFromJson(Map<String, dynamic> json) => Equipment(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$EquipmentTypeEnumMap, json['type']),
  rarity: $enumDecode(_$EquipmentRarityEnumMap, json['rarity']),
  requiredLevel: (json['requiredLevel'] as num).toInt(),
  baseStats: (json['baseStats'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  maxEnhanceLevel: (json['maxEnhanceLevel'] as num?)?.toInt() ?? 10,
  enhanceStatMultiplier:
      (json['enhanceStatMultiplier'] as num?)?.toDouble() ?? 0.1,
);

Map<String, dynamic> _$EquipmentToJson(Equipment instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'type': _$EquipmentTypeEnumMap[instance.type]!,
  'rarity': _$EquipmentRarityEnumMap[instance.rarity]!,
  'requiredLevel': instance.requiredLevel,
  'baseStats': instance.baseStats,
  'maxEnhanceLevel': instance.maxEnhanceLevel,
  'enhanceStatMultiplier': instance.enhanceStatMultiplier,
};

const _$EquipmentTypeEnumMap = {
  EquipmentType.weapon: 'weapon',
  EquipmentType.armor: 'armor',
  EquipmentType.accessory: 'accessory',
  EquipmentType.treasure: 'treasure',
  EquipmentType.ring: 'ring',
  EquipmentType.necklace: 'necklace',
  EquipmentType.boots: 'boots',
  EquipmentType.belt: 'belt',
  EquipmentType.gloves: 'gloves',
  EquipmentType.helmet: 'helmet',
  EquipmentType.rune: 'rune',
  EquipmentType.gem: 'gem',
};

const _$EquipmentRarityEnumMap = {
  EquipmentRarity.common: 'common',
  EquipmentRarity.uncommon: 'uncommon',
  EquipmentRarity.rare: 'rare',
  EquipmentRarity.epic: 'epic',
  EquipmentRarity.legendary: 'legendary',
  EquipmentRarity.mythic: 'mythic',
};

EquippedItem _$EquippedItemFromJson(Map<String, dynamic> json) => EquippedItem(
  equipmentId: json['equipmentId'] as String,
  enhanceLevel: (json['enhanceLevel'] as num?)?.toInt() ?? 0,
  obtainedAt: json['obtainedAt'] == null
      ? null
      : DateTime.parse(json['obtainedAt'] as String),
);

Map<String, dynamic> _$EquippedItemToJson(EquippedItem instance) =>
    <String, dynamic>{
      'equipmentId': instance.equipmentId,
      'enhanceLevel': instance.enhanceLevel,
      'obtainedAt': instance.obtainedAt.toIso8601String(),
    };
