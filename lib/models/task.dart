import 'package:json_annotation/json_annotation.dart';

part 'task.g.dart';

// 任务类型枚举
enum TaskType {
  daily,    // 日常任务
  main,     // 主线任务
  weekly,   // 周常任务
  achievement, // 成就任务
}

// 任务状态枚举
enum TaskStatus {
  active,     // 进行中
  completed,  // 已完成
  claimed,    // 已领取奖励
  locked,     // 未解锁
}

// 任务奖励类型
enum RewardType {
  spiritStones, // 灵石
  experience,   // 经验值
  equipment,    // 装备
  technique,    // 功法
}

// 任务奖励
@JsonSerializable()
class TaskReward {
  final RewardType type;
  final int amount;
  final String? itemId; // 用于装备或功法的ID

  TaskReward({
    required this.type,
    required this.amount,
    this.itemId,
  });

  factory TaskReward.fromJson(Map<String, dynamic> json) => _$TaskRewardFromJson(json);
  Map<String, dynamic> toJson() => _$TaskRewardToJson(this);

  String get displayText {
    switch (type) {
      case RewardType.spiritStones:
        return '$amount 灵石';
      case RewardType.experience:
        return '$amount 经验值';
      case RewardType.equipment:
        return '装备: ${itemId ?? "未知"}';
      case RewardType.technique:
        return '功法: ${itemId ?? "未知"}';
    }
  }
}

// 任务条件
@JsonSerializable()
class TaskCondition {
  final String type; // 条件类型：cultivation_count, battle_count, level_reach等
  final int targetValue; // 目标值
  final String? parameter; // 额外参数

  TaskCondition({
    required this.type,
    required this.targetValue,
    this.parameter,
  });

  factory TaskCondition.fromJson(Map<String, dynamic> json) => _$TaskConditionFromJson(json);
  Map<String, dynamic> toJson() => _$TaskConditionToJson(this);
}

// 任务模板
@JsonSerializable()
class Task {
  final String id;
  final String name;
  final String description;
  final TaskType type;
  final int priority; // 优先级，用于排序
  final List<TaskCondition> conditions;
  final List<TaskReward> rewards;
  final List<String> prerequisites; // 前置任务ID列表
  final int? timeLimit; // 时间限制（秒），null表示无限制
  final bool repeatable; // 是否可重复
  final int playerLevelRequired; // 需要的玩家等级

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.priority,
    required this.conditions,
    required this.rewards,
    this.prerequisites = const [],
    this.timeLimit,
    this.repeatable = false,
    this.playerLevelRequired = 0,
  });

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);
}

// 玩家任务进度
@JsonSerializable()
class PlayerTask {
  final String taskId;
  TaskStatus status;
  Map<String, int> progress; // 条件ID -> 当前进度
  DateTime? startTime;
  DateTime? completedTime;
  DateTime? claimedTime;

  PlayerTask({
    required this.taskId,
    this.status = TaskStatus.active,
    this.progress = const {},
    this.startTime,
    this.completedTime,
    this.claimedTime,
  });

  factory PlayerTask.fromJson(Map<String, dynamic> json) => _$PlayerTaskFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerTaskToJson(this);

  // 检查任务是否完成
  bool isCompleted(Task task) {
    for (int i = 0; i < task.conditions.length; i++) {
      final condition = task.conditions[i];
      final currentProgress = progress[condition.type] ?? 0;
      if (currentProgress < condition.targetValue) {
        return false;
      }
    }
    return true;
  }

  // 更新进度
  bool updateProgress(String conditionType, int value, Task task) {
    progress = Map.from(progress);
    progress[conditionType] = value;
    
    // 检查是否刚完成
    if (status == TaskStatus.active && isCompleted(task)) {
      status = TaskStatus.completed;
      completedTime = DateTime.now();
      return true; // 返回true表示任务刚完成
    }
    
    return false;
  }

  // 增加进度
  bool addProgress(String conditionType, int amount, Task task) {
    final currentProgress = progress[conditionType] ?? 0;
    return updateProgress(conditionType, currentProgress + amount, task);
  }

  // 获取进度百分比
  double getProgressPercentage(Task task) {
    if (task.conditions.isEmpty) return 1.0;
    
    double totalProgress = 0.0;
    for (final condition in task.conditions) {
      final currentProgress = progress[condition.type] ?? 0;
      final conditionProgress = (currentProgress / condition.targetValue).clamp(0.0, 1.0);
      totalProgress += conditionProgress;
    }
    
    return totalProgress / task.conditions.length;
  }

  // 获取进度文本
  String getProgressText(Task task) {
    if (task.conditions.length == 1) {
      final condition = task.conditions.first;
      final currentProgress = progress[condition.type] ?? 0;
      return '$currentProgress/${condition.targetValue}';
    } else {
      final percentage = (getProgressPercentage(task) * 100).round();
      return '$percentage%';
    }
  }

  // 检查是否过期
  bool isExpired(Task task) {
    if (task.timeLimit == null || startTime == null) return false;
    final now = DateTime.now();
    final deadline = startTime!.add(Duration(seconds: task.timeLimit!));
    return now.isAfter(deadline);
  }

  // 获取剩余时间
  Duration? getRemainingTime(Task task) {
    if (task.timeLimit == null || startTime == null) return null;
    final now = DateTime.now();
    final deadline = startTime!.add(Duration(seconds: task.timeLimit!));
    if (now.isAfter(deadline)) return Duration.zero;
    return deadline.difference(now);
  }
}
