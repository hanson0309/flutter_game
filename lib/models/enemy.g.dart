// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enemy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Enemy _$EnemyFromJson(Map<String, dynamic> json) => Enemy(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$EnemyTypeEnumMap, json['type']),
  level: (json['level'] as num).toInt(),
  baseAttack: (json['baseAttack'] as num).toDouble(),
  baseDefense: (json['baseDefense'] as num).toDouble(),
  baseHealth: (json['baseHealth'] as num).toDouble(),
  baseMana: (json['baseMana'] as num).toDouble(),
  skills:
      (json['skills'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  dropRates:
      (json['dropRates'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ) ??
      const {},
  expReward: (json['expReward'] as num).toInt(),
  spiritStoneReward: (json['spiritStoneReward'] as num).toInt(),
);

Map<String, dynamic> _$EnemyToJson(Enemy instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'type': _$EnemyTypeEnumMap[instance.type]!,
  'level': instance.level,
  'baseAttack': instance.baseAttack,
  'baseDefense': instance.baseDefense,
  'baseHealth': instance.baseHealth,
  'baseMana': instance.baseMana,
  'skills': instance.skills,
  'dropRates': instance.dropRates,
  'expReward': instance.expReward,
  'spiritStoneReward': instance.spiritStoneReward,
};

const _$EnemyTypeEnumMap = {
  EnemyType.beast: 'beast',
  EnemyType.demon: 'demon',
  EnemyType.cultivator: 'cultivator',
  EnemyType.spirit: 'spirit',
};

BattleResult _$BattleResultFromJson(Map<String, dynamic> json) => BattleResult(
  victory: json['victory'] as bool,
  expGained: (json['expGained'] as num).toInt(),
  spiritStonesGained: (json['spiritStonesGained'] as num).toInt(),
  itemsDropped: (json['itemsDropped'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  damageDealt: (json['damageDealt'] as num).toInt(),
  damageTaken: (json['damageTaken'] as num).toInt(),
  turnCount: (json['turnCount'] as num).toInt(),
);

Map<String, dynamic> _$BattleResultToJson(BattleResult instance) =>
    <String, dynamic>{
      'victory': instance.victory,
      'expGained': instance.expGained,
      'spiritStonesGained': instance.spiritStonesGained,
      'itemsDropped': instance.itemsDropped,
      'damageDealt': instance.damageDealt,
      'damageTaken': instance.damageTaken,
      'turnCount': instance.turnCount,
    };

BattleState _$BattleStateFromJson(Map<String, dynamic> json) => BattleState(
  enemy: Enemy.fromJson(json['enemy'] as Map<String, dynamic>),
  enemyCurrentHealth: (json['enemyCurrentHealth'] as num).toDouble(),
  enemyCurrentMana: (json['enemyCurrentMana'] as num).toDouble(),
  playerCurrentHealth: (json['playerCurrentHealth'] as num).toDouble(),
  playerCurrentMana: (json['playerCurrentMana'] as num).toDouble(),
  turnCount: (json['turnCount'] as num?)?.toInt() ?? 0,
  battleLog: (json['battleLog'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  isPlayerTurn: json['isPlayerTurn'] as bool? ?? true,
  statusEffects: (json['statusEffects'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toInt()),
  ),
);

Map<String, dynamic> _$BattleStateToJson(BattleState instance) =>
    <String, dynamic>{
      'enemy': instance.enemy,
      'enemyCurrentHealth': instance.enemyCurrentHealth,
      'enemyCurrentMana': instance.enemyCurrentMana,
      'playerCurrentHealth': instance.playerCurrentHealth,
      'playerCurrentMana': instance.playerCurrentMana,
      'turnCount': instance.turnCount,
      'battleLog': instance.battleLog,
      'isPlayerTurn': instance.isPlayerTurn,
      'statusEffects': instance.statusEffects,
    };
