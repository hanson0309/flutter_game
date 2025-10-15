import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/player.dart';
import 'audio_service.dart';
import 'ai_task_generator.dart';

class TaskService extends ChangeNotifier {
  List<Task> _allTasks = [];
  List<PlayerTask> _playerTasks = [];
  List<String> _newlyCompletedTasks = [];

  List<Task> get allTasks => _allTasks;
  List<PlayerTask> get playerTasks => _playerTasks;
  List<String> get newlyCompletedTasks => _newlyCompletedTasks;

  // 获取可用任务（已解锁且未完成）
  List<Task> get availableTasks {
    return _allTasks.where((task) {
      final playerTask = getPlayerTask(task.id);
      if (playerTask == null) return _canUnlockTask(task);
      return playerTask.status == TaskStatus.active && !playerTask.isExpired(task);
    }).toList();
  }

  // 获取已完成任务
  List<Task> get completedTasks {
    return _allTasks.where((task) {
      final playerTask = getPlayerTask(task.id);
      return playerTask?.status == TaskStatus.completed;
    }).toList();
  }

  // 获取可领取奖励的任务
  List<Task> get claimableTasks {
    return completedTasks.where((task) {
      final playerTask = getPlayerTask(task.id);
      return playerTask?.status == TaskStatus.completed;
    }).toList();
  }

  // 初始化任务系统
  Future<void> initializeTasks() async {
    try {
      debugPrint('🎯 开始初始化任务系统...');
      _initializeTaskTemplates();
      await _loadPlayerTasks();
      _refreshDailyTasks();
      debugPrint('🎯 任务系统初始化完成，共 ${_allTasks.length} 个任务');
    } catch (e) {
      debugPrint('🎯 任务系统初始化失败: $e');
    }
  }

  // 初始化任务模板
  void _initializeTaskTemplates() {
    _allTasks = [
      // 日常任务
      Task(
        id: 'daily_cultivation_10',
        name: '日常修炼',
        description: '进行10次修炼',
        type: TaskType.daily,
        priority: 1,
        conditions: [
          TaskCondition(type: 'cultivation_count', targetValue: 10),
        ],
        rewards: [
          TaskReward(type: RewardType.spiritStones, amount: 100),
          TaskReward(type: RewardType.experience, amount: 50),
        ],
        repeatable: true,
        timeLimit: 86400, // 24小时
      ),
      
      Task(
        id: 'daily_battle_5',
        name: '日常战斗',
        description: '进行5次战斗',
        type: TaskType.daily,
        priority: 2,
        conditions: [
          TaskCondition(type: 'battle_count', targetValue: 5),
        ],
        rewards: [
          TaskReward(type: RewardType.spiritStones, amount: 150),
        ],
        repeatable: true,
        timeLimit: 86400,
      ),

      // 主线任务
      Task(
        id: 'main_reach_level_5',
        name: '初入修仙',
        description: '达到筑基期境界',
        type: TaskType.main,
        priority: 1,
        conditions: [
          TaskCondition(type: 'level_reach', targetValue: 2),
        ],
        rewards: [
          TaskReward(type: RewardType.spiritStones, amount: 500),
          TaskReward(type: RewardType.experience, amount: 200),
        ],
      ),

      Task(
        id: 'main_learn_technique',
        name: '功法入门',
        description: '学会第一个功法',
        type: TaskType.main,
        priority: 2,
        conditions: [
          TaskCondition(type: 'technique_count', targetValue: 1),
        ],
        rewards: [
          TaskReward(type: RewardType.spiritStones, amount: 300),
        ],
        prerequisites: ['main_reach_level_5'],
      ),

      Task(
        id: 'main_reach_level_10',
        name: '修仙有成',
        description: '达到金丹期境界',
        type: TaskType.main,
        priority: 3,
        conditions: [
          TaskCondition(type: 'level_reach', targetValue: 3),
        ],
        rewards: [
          TaskReward(type: RewardType.spiritStones, amount: 1000),
          TaskReward(type: RewardType.experience, amount: 500),
        ],
        prerequisites: ['main_learn_technique'],
      ),

      Task(
        id: 'main_equip_weapon',
        name: '装备精良',
        description: '装备一件武器',
        type: TaskType.main,
        priority: 4,
        conditions: [
          TaskCondition(type: 'weapon_equipped', targetValue: 1),
        ],
        rewards: [
          TaskReward(type: RewardType.spiritStones, amount: 800),
        ],
      ),

      // 周常任务
      Task(
        id: 'weekly_cultivation_50',
        name: '勤修苦练',
        description: '本周进行50次修炼',
        type: TaskType.weekly,
        priority: 1,
        conditions: [
          TaskCondition(type: 'cultivation_count', targetValue: 50),
        ],
        rewards: [
          TaskReward(type: RewardType.spiritStones, amount: 1000),
          TaskReward(type: RewardType.experience, amount: 300),
        ],
        repeatable: true,
        timeLimit: 604800, // 7天
      ),

      Task(
        id: 'weekly_battle_20',
        name: '征战四方',
        description: '本周进行20次战斗',
        type: TaskType.weekly,
        priority: 2,
        conditions: [
          TaskCondition(type: 'battle_count', targetValue: 20),
        ],
        rewards: [
          TaskReward(type: RewardType.spiritStones, amount: 1500),
        ],
        repeatable: true,
        timeLimit: 604800,
      ),
    ];
  }

  // 获取玩家任务
  PlayerTask? getPlayerTask(String taskId) {
    try {
      return _playerTasks.firstWhere((pt) => pt.taskId == taskId);
    } catch (e) {
      return null;
    }
  }

  // 获取任务模板
  Task? getTask(String taskId) {
    try {
      return _allTasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }

  // 检查任务是否可以解锁
  bool _canUnlockTask(Task task) {
    // 检查前置任务
    for (final prerequisiteId in task.prerequisites) {
      final prerequisitePlayerTask = getPlayerTask(prerequisiteId);
      if (prerequisitePlayerTask?.status != TaskStatus.claimed) {
        return false;
      }
    }
    return true;
  }

  // 激活任务
  void activateTask(String taskId) {
    final task = getTask(taskId);
    if (task == null || !_canUnlockTask(task)) return;

    final existingPlayerTask = getPlayerTask(taskId);
    if (existingPlayerTask != null) return;

    final playerTask = PlayerTask(
      taskId: taskId,
      status: TaskStatus.active,
      startTime: DateTime.now(),
      progress: {},
    );

    _playerTasks.add(playerTask);
    _savePlayerTasks();
    notifyListeners();
    debugPrint('🎯 激活任务: ${task.name}');
  }

  // 更新任务进度
  void updateTaskProgress(String conditionType, int value) {
    bool hasNewCompletion = false;

    for (final playerTask in _playerTasks) {
      if (playerTask.status != TaskStatus.active) continue;

      final task = getTask(playerTask.taskId);
      if (task == null) continue;

      // 检查任务是否包含此条件类型
      final hasCondition = task.conditions.any((c) => c.type == conditionType);
      if (!hasCondition) continue;

      // 更新进度
      final wasCompleted = playerTask.updateProgress(conditionType, value, task);
      if (wasCompleted) {
        hasNewCompletion = true;
        _newlyCompletedTasks.add(playerTask.taskId);
        // 播放任务完成音效
        AudioService().playAchievementSound();
        debugPrint('🎯 任务完成: ${task.name}');
      }
    }

    if (hasNewCompletion) {
      _savePlayerTasks();
      notifyListeners();
    }
  }

  // 增加任务进度
  void addTaskProgress(String conditionType, int amount) {
    bool hasNewCompletion = false;

    for (final playerTask in _playerTasks) {
      if (playerTask.status != TaskStatus.active) continue;

      final task = getTask(playerTask.taskId);
      if (task == null) continue;

      // 检查任务是否包含此条件类型
      final hasCondition = task.conditions.any((c) => c.type == conditionType);
      if (!hasCondition) continue;

      // 增加进度
      final wasCompleted = playerTask.addProgress(conditionType, amount, task);
      if (wasCompleted) {
        hasNewCompletion = true;
        _newlyCompletedTasks.add(playerTask.taskId);
        // 播放任务完成音效
        AudioService().playAchievementSound();
        debugPrint('🎯 任务完成: ${task.name}');
      }
    }

    if (hasNewCompletion) {
      _savePlayerTasks();
      notifyListeners();
    }
  }

  // 领取任务奖励
  Map<String, dynamic>? claimTaskReward(String taskId, Player player) {
    final playerTask = getPlayerTask(taskId);
    final task = getTask(taskId);
    
    if (playerTask == null || task == null || playerTask.status != TaskStatus.completed) {
      return null;
    }

    // 发放奖励
    Map<String, dynamic> rewards = {};
    for (final reward in task.rewards) {
      switch (reward.type) {
        case RewardType.spiritStones:
          player.spiritStones += reward.amount;
          rewards['spiritStones'] = reward.amount;
          break;
        case RewardType.experience:
          player.addExp(reward.amount);
          rewards['experience'] = reward.amount;
          break;
        case RewardType.equipment:
          // TODO: 实现装备奖励
          break;
        case RewardType.technique:
          // TODO: 实现功法奖励
          break;
      }
    }

    // 更新任务状态
    playerTask.status = TaskStatus.claimed;
    playerTask.claimedTime = DateTime.now();

    // 如果是可重复任务，重新激活
    if (task.repeatable) {
      _resetRepeatableTask(taskId);
    }

    _savePlayerTasks();
    notifyListeners();

    // 播放奖励音效
    AudioService().playCoinsSound();
    debugPrint('🎯 领取任务奖励: ${task.name}');

    return rewards;
  }

  // 重置可重复任务
  void _resetRepeatableTask(String taskId) {
    final task = getTask(taskId);
    if (task == null || !task.repeatable) return;

    // 移除旧的任务记录
    _playerTasks.removeWhere((pt) => pt.taskId == taskId);

    // 创建新的任务记录
    final newPlayerTask = PlayerTask(
      taskId: taskId,
      status: TaskStatus.active,
      startTime: DateTime.now(),
      progress: {},
    );

    _playerTasks.add(newPlayerTask);
  }

  // 刷新日常任务
  void _refreshDailyTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final task in _allTasks.where((t) => t.type == TaskType.daily)) {
      final playerTask = getPlayerTask(task.id);
      
      if (playerTask == null) {
        // 激活新的日常任务
        activateTask(task.id);
      } else if (playerTask.startTime != null) {
        final taskDate = DateTime(
          playerTask.startTime!.year,
          playerTask.startTime!.month,
          playerTask.startTime!.day,
        );
        
        // 如果任务不是今天的，重置任务
        if (taskDate.isBefore(today)) {
          _resetRepeatableTask(task.id);
        }
      }
    }
  }

  // 生成AI任务
  void generateAITasks(Player player, {int count = 3}) {
    try {
      debugPrint('🤖 开始生成AI任务...');
      final aiTasks = AITaskGenerator.generateTaskBatch(player, count);
      
      for (final task in aiTasks) {
        _allTasks.add(task);
        activateTask(task.id);
      }
      
      debugPrint('🤖 成功生成 ${aiTasks.length} 个AI任务');
      notifyListeners();
    } catch (e) {
      debugPrint('🤖 AI任务生成失败: $e');
    }
  }

  // 生成特殊事件任务
  void generateEventTask(String eventType, Player player) {
    try {
      final eventTask = AITaskGenerator.generateEventTask(eventType, player);
      _allTasks.add(eventTask);
      activateTask(eventTask.id);
      
      debugPrint('🤖 生成特殊事件任务: ${eventTask.name}');
      notifyListeners();
    } catch (e) {
      debugPrint('🤖 特殊事件任务生成失败: $e');
    }
  }

  // 智能任务推荐
  List<Task> getRecommendedTasks(Player player) {
    // 基于玩家当前状态推荐合适的任务
    final availableTasks = this.availableTasks;
    final recommendedTasks = <Task>[];
    
    // 优先推荐适合玩家等级的任务
    for (final task in availableTasks) {
      if (task.playerLevelRequired <= player.level) {
        recommendedTasks.add(task);
      }
    }
    
    // 按优先级排序
    recommendedTasks.sort((a, b) => b.priority.compareTo(a.priority));
    
    // 返回前5个推荐任务
    return recommendedTasks.take(5).toList();
  }

  // 清除新完成任务通知
  void clearNewlyCompletedTasks() {
    _newlyCompletedTasks.clear();
    notifyListeners();
  }

  // 保存玩家任务数据
  Future<void> _savePlayerTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = _playerTasks.map((task) => task.toJson()).toList();
      await prefs.setString('player_tasks', jsonEncode(tasksJson));
    } catch (e) {
      debugPrint('保存任务数据失败: $e');
    }
  }

  // 加载玩家任务数据
  Future<void> _loadPlayerTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString('player_tasks');
      
      if (tasksJson != null) {
        final tasksList = jsonDecode(tasksJson) as List;
        _playerTasks = tasksList.map((json) => PlayerTask.fromJson(json)).toList();
        
        // 清理过期或无效的任务
        _cleanupInvalidTasks();
      } else {
        _playerTasks = [];
        // 激活初始任务
        _activateInitialTasks();
      }
    } catch (e) {
      debugPrint('加载任务数据失败: $e');
      _playerTasks = [];
      _activateInitialTasks();
    }
  }

  // 激活初始任务
  void _activateInitialTasks() {
    // 激活第一个主线任务
    activateTask('main_reach_level_5');
    
    // 激活日常任务
    for (final task in _allTasks.where((t) => t.type == TaskType.daily)) {
      activateTask(task.id);
    }
  }

  // 清理无效任务
  void _cleanupInvalidTasks() {
    _playerTasks.removeWhere((playerTask) {
      final task = getTask(playerTask.taskId);
      if (task == null) return true;
      
      // 清理过期的任务
      if (playerTask.isExpired(task)) {
        debugPrint('🎯 清理过期任务: ${task.name}');
        return true;
      }
      
      return false;
    });
  }

  // 获取任务统计
  Map<String, int> getTaskStatistics() {
    return {
      'total': _allTasks.length,
      'active': availableTasks.length,
      'completed': completedTasks.length,
      'claimable': claimableTasks.length,
    };
  }
}
