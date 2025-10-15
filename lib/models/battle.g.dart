// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'battle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BattleSkill _$BattleSkillFromJson(Map<String, dynamic> json) => BattleSkill(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$SkillTypeEnumMap, json['type']),
  damage: (json['damage'] as num?)?.toInt() ?? 0,
  healing: (json['healing'] as num?)?.toInt() ?? 0,
  manaCost: (json['manaCost'] as num?)?.toInt() ?? 0,
  cooldown: (json['cooldown'] as num?)?.toInt() ?? 0,
  accuracy: (json['accuracy'] as num?)?.toDouble() ?? 1.0,
  effects:
      (json['effects'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$BattleSkillToJson(BattleSkill instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$SkillTypeEnumMap[instance.type]!,
      'damage': instance.damage,
      'healing': instance.healing,
      'manaCost': instance.manaCost,
      'cooldown': instance.cooldown,
      'accuracy': instance.accuracy,
      'effects': instance.effects,
    };

const _$SkillTypeEnumMap = {
  SkillType.attack: 'attack',
  SkillType.defense: 'defense',
  SkillType.heal: 'heal',
  SkillType.buff: 'buff',
  SkillType.debuff: 'debuff',
};

Enemy _$EnemyFromJson(Map<String, dynamic> json) =>
    Enemy(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        type: $enumDecode(_$EnemyTypeEnumMap, json['type']),
        level: (json['level'] as num).toInt(),
        maxHealth: (json['maxHealth'] as num).toInt(),
        maxMana: (json['maxMana'] as num).toInt(),
        attack: (json['attack'] as num).toInt(),
        defense: (json['defense'] as num).toInt(),
        speed: (json['speed'] as num).toInt(),
        skillIds:
            (json['skillIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        rewards:
            (json['rewards'] as Map<String, dynamic>?)?.map(
              (k, e) => MapEntry(k, (e as num).toInt()),
            ) ??
            const {},
        dropItems:
            (json['dropItems'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        imagePath: json['imagePath'] as String?,
      )
      ..currentHealth = (json['currentHealth'] as num).toInt()
      ..currentMana = (json['currentMana'] as num).toInt()
      ..buffs = Map<String, int>.from(json['buffs'] as Map)
      ..debuffs = Map<String, int>.from(json['debuffs'] as Map)
      ..skillCooldowns = Map<String, int>.from(json['skillCooldowns'] as Map);

Map<String, dynamic> _$EnemyToJson(Enemy instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'type': _$EnemyTypeEnumMap[instance.type]!,
  'level': instance.level,
  'maxHealth': instance.maxHealth,
  'maxMana': instance.maxMana,
  'attack': instance.attack,
  'defense': instance.defense,
  'speed': instance.speed,
  'skillIds': instance.skillIds,
  'rewards': instance.rewards,
  'dropItems': instance.dropItems,
  'imagePath': instance.imagePath,
  'currentHealth': instance.currentHealth,
  'currentMana': instance.currentMana,
  'buffs': instance.buffs,
  'debuffs': instance.debuffs,
  'skillCooldowns': instance.skillCooldowns,
};

const _$EnemyTypeEnumMap = {
  EnemyType.beast: 'beast',
  EnemyType.demon: 'demon',
  EnemyType.cultivator: 'cultivator',
  EnemyType.spirit: 'spirit',
  EnemyType.undead: 'undead',
};

BattleAction _$BattleActionFromJson(Map<String, dynamic> json) => BattleAction(
  type: $enumDecode(_$BattleActionTypeEnumMap, json['type']),
  skillId: json['skillId'] as String?,
  itemId: json['itemId'] as String?,
  targetId: json['targetId'] as String?,
  damage: (json['damage'] as num?)?.toInt(),
);

Map<String, dynamic> _$BattleActionToJson(BattleAction instance) =>
    <String, dynamic>{
      'type': _$BattleActionTypeEnumMap[instance.type]!,
      'skillId': instance.skillId,
      'itemId': instance.itemId,
      'targetId': instance.targetId,
      'damage': instance.damage,
    };

const _$BattleActionTypeEnumMap = {
  BattleActionType.attack: 'attack',
  BattleActionType.skill: 'skill',
  BattleActionType.defend: 'defend',
  BattleActionType.item: 'item',
  BattleActionType.escape: 'escape',
};

BattleResult _$BattleResultFromJson(Map<String, dynamic> json) => BattleResult(
  victory: json['victory'] as bool,
  expGained: (json['expGained'] as num?)?.toInt() ?? 0,
  spiritStonesGained: (json['spiritStonesGained'] as num?)?.toInt() ?? 0,
  itemsDropped:
      (json['itemsDropped'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  statistics: json['statistics'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$BattleResultToJson(BattleResult instance) =>
    <String, dynamic>{
      'victory': instance.victory,
      'expGained': instance.expGained,
      'spiritStonesGained': instance.spiritStonesGained,
      'itemsDropped': instance.itemsDropped,
      'statistics': instance.statistics,
    };

BattleData _$BattleDataFromJson(Map<String, dynamic> json) => BattleData(
  battleId: json['battleId'] as String,
  player: Player.fromJson(json['player'] as Map<String, dynamic>),
  enemies: (json['enemies'] as List<dynamic>)
      .map((e) => Enemy.fromJson(e as Map<String, dynamic>))
      .toList(),
  state:
      $enumDecodeNullable(_$BattleStateEnumMap, json['state']) ??
      BattleState.preparing,
  currentTurn: (json['currentTurn'] as num?)?.toInt() ?? 0,
  battleLog:
      (json['battleLog'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  result: json['result'] == null
      ? null
      : BattleResult.fromJson(json['result'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BattleDataToJson(BattleData instance) =>
    <String, dynamic>{
      'battleId': instance.battleId,
      'player': instance.player,
      'enemies': instance.enemies,
      'state': _$BattleStateEnumMap[instance.state]!,
      'currentTurn': instance.currentTurn,
      'battleLog': instance.battleLog,
      'result': instance.result,
    };

const _$BattleStateEnumMap = {
  BattleState.preparing: 'preparing',
  BattleState.playerTurn: 'playerTurn',
  BattleState.enemyTurn: 'enemyTurn',
  BattleState.victory: 'victory',
  BattleState.defeat: 'defeat',
  BattleState.escaped: 'escaped',
};
