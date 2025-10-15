// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskReward _$TaskRewardFromJson(Map<String, dynamic> json) => TaskReward(
  type: $enumDecode(_$RewardTypeEnumMap, json['type']),
  amount: (json['amount'] as num).toInt(),
  itemId: json['itemId'] as String?,
);

Map<String, dynamic> _$TaskRewardToJson(TaskReward instance) =>
    <String, dynamic>{
      'type': _$RewardTypeEnumMap[instance.type]!,
      'amount': instance.amount,
      'itemId': instance.itemId,
    };

const _$RewardTypeEnumMap = {
  RewardType.spiritStones: 'spiritStones',
  RewardType.experience: 'experience',
  RewardType.equipment: 'equipment',
  RewardType.technique: 'technique',
};

TaskCondition _$TaskConditionFromJson(Map<String, dynamic> json) =>
    TaskCondition(
      type: json['type'] as String,
      targetValue: (json['targetValue'] as num).toInt(),
      parameter: json['parameter'] as String?,
    );

Map<String, dynamic> _$TaskConditionToJson(TaskCondition instance) =>
    <String, dynamic>{
      'type': instance.type,
      'targetValue': instance.targetValue,
      'parameter': instance.parameter,
    };

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$TaskTypeEnumMap, json['type']),
  priority: (json['priority'] as num).toInt(),
  conditions: (json['conditions'] as List<dynamic>)
      .map((e) => TaskCondition.fromJson(e as Map<String, dynamic>))
      .toList(),
  rewards: (json['rewards'] as List<dynamic>)
      .map((e) => TaskReward.fromJson(e as Map<String, dynamic>))
      .toList(),
  prerequisites:
      (json['prerequisites'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  timeLimit: (json['timeLimit'] as num?)?.toInt(),
  repeatable: json['repeatable'] as bool? ?? false,
  playerLevelRequired: (json['playerLevelRequired'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'type': _$TaskTypeEnumMap[instance.type]!,
  'priority': instance.priority,
  'conditions': instance.conditions,
  'rewards': instance.rewards,
  'prerequisites': instance.prerequisites,
  'timeLimit': instance.timeLimit,
  'repeatable': instance.repeatable,
  'playerLevelRequired': instance.playerLevelRequired,
};

const _$TaskTypeEnumMap = {
  TaskType.daily: 'daily',
  TaskType.main: 'main',
  TaskType.weekly: 'weekly',
  TaskType.achievement: 'achievement',
};

PlayerTask _$PlayerTaskFromJson(Map<String, dynamic> json) => PlayerTask(
  taskId: json['taskId'] as String,
  status:
      $enumDecodeNullable(_$TaskStatusEnumMap, json['status']) ??
      TaskStatus.active,
  progress:
      (json['progress'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  startTime: json['startTime'] == null
      ? null
      : DateTime.parse(json['startTime'] as String),
  completedTime: json['completedTime'] == null
      ? null
      : DateTime.parse(json['completedTime'] as String),
  claimedTime: json['claimedTime'] == null
      ? null
      : DateTime.parse(json['claimedTime'] as String),
);

Map<String, dynamic> _$PlayerTaskToJson(PlayerTask instance) =>
    <String, dynamic>{
      'taskId': instance.taskId,
      'status': _$TaskStatusEnumMap[instance.status]!,
      'progress': instance.progress,
      'startTime': instance.startTime?.toIso8601String(),
      'completedTime': instance.completedTime?.toIso8601String(),
      'claimedTime': instance.claimedTime?.toIso8601String(),
    };

const _$TaskStatusEnumMap = {
  TaskStatus.active: 'active',
  TaskStatus.completed: 'completed',
  TaskStatus.claimed: 'claimed',
  TaskStatus.locked: 'locked',
};
