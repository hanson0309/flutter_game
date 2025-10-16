// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_synthesis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SynthesisMaterial _$SynthesisMaterialFromJson(Map<String, dynamic> json) =>
    SynthesisMaterial(
      itemId: json['itemId'] as String,
      name: json['name'] as String,
      requiredQuantity: (json['requiredQuantity'] as num).toInt(),
      description: json['description'] as String,
    );

Map<String, dynamic> _$SynthesisMaterialToJson(SynthesisMaterial instance) =>
    <String, dynamic>{
      'itemId': instance.itemId,
      'name': instance.name,
      'requiredQuantity': instance.requiredQuantity,
      'description': instance.description,
    };

SynthesisRecipe _$SynthesisRecipeFromJson(Map<String, dynamic> json) =>
    SynthesisRecipe(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      resultEquipmentId: json['resultEquipmentId'] as String,
      materials: (json['materials'] as List<dynamic>)
          .map((e) => SynthesisMaterial.fromJson(e as Map<String, dynamic>))
          .toList(),
      spiritStoneCost: (json['spiritStoneCost'] as num?)?.toInt() ?? 0,
      requiredLevel: (json['requiredLevel'] as num?)?.toInt() ?? 1,
      successRate: (json['successRate'] as num?)?.toDouble() ?? 1.0,
      unlocked: json['unlocked'] as bool? ?? true,
    );

Map<String, dynamic> _$SynthesisRecipeToJson(SynthesisRecipe instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'resultEquipmentId': instance.resultEquipmentId,
      'materials': instance.materials,
      'spiritStoneCost': instance.spiritStoneCost,
      'requiredLevel': instance.requiredLevel,
      'successRate': instance.successRate,
      'unlocked': instance.unlocked,
    };
