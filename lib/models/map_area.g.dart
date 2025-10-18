// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_area.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapPosition _$MapPositionFromJson(Map<String, dynamic> json) => MapPosition(
  x: (json['x'] as num).toDouble(),
  y: (json['y'] as num).toDouble(),
);

Map<String, dynamic> _$MapPositionToJson(MapPosition instance) =>
    <String, dynamic>{'x': instance.x, 'y': instance.y};

MapEnemy _$MapEnemyFromJson(Map<String, dynamic> json) => MapEnemy(
  id: json['id'] as String,
  enemyId: json['enemyId'] as String,
  position: MapPosition.fromJson(json['position'] as Map<String, dynamic>),
  level: (json['level'] as num).toInt(),
  type: json['type'] as String,
  isAlive: json['isAlive'] as bool? ?? true,
  lastRespawnTime: json['lastRespawnTime'] == null
      ? null
      : DateTime.parse(json['lastRespawnTime'] as String),
);

Map<String, dynamic> _$MapEnemyToJson(MapEnemy instance) => <String, dynamic>{
  'id': instance.id,
  'enemyId': instance.enemyId,
  'position': instance.position,
  'level': instance.level,
  'type': instance.type,
  'isAlive': instance.isAlive,
  'lastRespawnTime': instance.lastRespawnTime?.toIso8601String(),
};

MapArea _$MapAreaFromJson(Map<String, dynamic> json) => MapArea(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  width: (json['width'] as num).toDouble(),
  height: (json['height'] as num).toDouble(),
  minEnemyLevel: (json['minEnemyLevel'] as num).toInt(),
  maxEnemyLevel: (json['maxEnemyLevel'] as num).toInt(),
  maxEnemyCount: (json['maxEnemyCount'] as num).toInt(),
  enemyDetectionRange:
      (json['enemyDetectionRange'] as num?)?.toDouble() ?? 50.0,
  enemyTypes: (json['enemyTypes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  backgroundImage: json['backgroundImage'] as String,
);

Map<String, dynamic> _$MapAreaToJson(MapArea instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'width': instance.width,
  'height': instance.height,
  'minEnemyLevel': instance.minEnemyLevel,
  'maxEnemyLevel': instance.maxEnemyLevel,
  'maxEnemyCount': instance.maxEnemyCount,
  'enemyDetectionRange': instance.enemyDetectionRange,
  'enemyTypes': instance.enemyTypes,
  'backgroundImage': instance.backgroundImage,
};

MapState _$MapStateFromJson(Map<String, dynamic> json) => MapState(
  currentAreaId: json['currentAreaId'] as String,
  playerPosition: MapPosition.fromJson(
    json['playerPosition'] as Map<String, dynamic>,
  ),
  enemies: (json['enemies'] as List<dynamic>)
      .map((e) => MapEnemy.fromJson(e as Map<String, dynamic>))
      .toList(),
  lastUpdate: DateTime.parse(json['lastUpdate'] as String),
);

Map<String, dynamic> _$MapStateToJson(MapState instance) => <String, dynamic>{
  'currentAreaId': instance.currentAreaId,
  'playerPosition': instance.playerPosition,
  'enemies': instance.enemies,
  'lastUpdate': instance.lastUpdate.toIso8601String(),
};
