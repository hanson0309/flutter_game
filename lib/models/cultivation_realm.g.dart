// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cultivation_realm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CultivationRealm _$CultivationRealmFromJson(Map<String, dynamic> json) =>
    CultivationRealm(
      name: json['name'] as String,
      level: (json['level'] as num).toInt(),
      maxExp: (json['maxExp'] as num).toInt(),
      description: json['description'] as String,
      attributeMultipliers:
          (json['attributeMultipliers'] as Map<String, dynamic>).map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ),
    );

Map<String, dynamic> _$CultivationRealmToJson(CultivationRealm instance) =>
    <String, dynamic>{
      'name': instance.name,
      'level': instance.level,
      'maxExp': instance.maxExp,
      'description': instance.description,
      'attributeMultipliers': instance.attributeMultipliers,
    };
