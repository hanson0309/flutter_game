import 'dart:math';
import '../models/task.dart';
import '../models/player.dart';

class AITaskGenerator {
  static final Random _random = Random();
  
  // 任务模板数据库
  static const List<Map<String, dynamic>> _taskTemplates = [
    // 修炼类任务模板
    {
      'category': 'cultivation',
      'names': [
        '悟道修心', '炼气凝神', '吐纳练息', '静心冥想', '感悟天道',
        '修炼真元', '凝练灵气', '突破瓶颈', '洗髓伐骨', '炼体强身'
      ],
      'descriptions': [
        '通过专注修炼来提升自身的修为境界',
        '感悟天地灵气，凝练体内真元',
        '静心冥想，领悟修仙之道的奥秘',
        '通过不断修炼来突破当前境界的限制',
        '炼化天地灵气，强化自身根基'
      ],
      'conditions': ['cultivation_count'],
      'rewards': ['spiritStones', 'experience']
    },
    
    // 战斗类任务模板
    {
      'category': 'battle',
      'names': [
        '征战四方', '历练红尘', '斩妖除魔', '试炼之路', '武道争锋',
        '血战沙场', '降妖伏魔', '闯荡江湖', '挑战强敌', '磨砺武技'
      ],
      'descriptions': [
        '通过战斗来磨砺自己的武技和意志',
        '在战斗中寻求突破，提升实战经验',
        '与强敌交手，验证自己的修炼成果',
        '通过不断的战斗来完善自己的武道',
        '在生死搏杀中领悟更高层次的武学'
      ],
      'conditions': ['battle_count'],
      'rewards': ['spiritStones', 'experience']
    },
    
    // 探索类任务模板
    {
      'category': 'exploration',
      'names': [
        '寻宝探秘', '洞府探险', '秘境寻踪', '遗迹考古', '奇遇寻缘',
        '山川游历', '古迹探寻', '宝藏猎人', '秘密发现', '机缘巧合'
      ],
      'descriptions': [
        '探索未知的秘境，寻找珍贵的修炼资源',
        '深入古老的洞府，发掘前人留下的宝藏',
        '游历名山大川，寻找修炼的机缘',
        '探寻古代遗迹，获得失传的修炼秘法',
        '在探索中遇到奇遇，获得意外的收获'
      ],
      'conditions': ['exploration_count'],
      'rewards': ['spiritStones', 'equipment', 'technique']
    },
    
    // 成长类任务模板
    {
      'category': 'growth',
      'names': [
        '境界提升', '实力增长', '修为精进', '能力觉醒', '潜力开发',
        '天赋觉醒', '根基稳固', '修为大进', '实力飞跃', '境界突破'
      ],
      'descriptions': [
        '通过不懈努力达到更高的修炼境界',
        '稳固根基，为将来的突破做好准备',
        '在修炼中觉醒更强大的潜在能力',
        '通过系统性的修炼来全面提升实力',
        '突破当前境界，迈向更高的修炼层次'
      ],
      'conditions': ['level_reach'],
      'rewards': ['spiritStones', 'experience', 'technique']
    }
  ];

  // 难度等级配置
  static const Map<String, Map<String, dynamic>> _difficultyLevels = {
    'easy': {
      'multiplier': 1.0,
      'targetRange': [5, 15],
      'rewardMultiplier': 1.0,
      'prefix': '初级',
    },
    'medium': {
      'multiplier': 1.5,
      'targetRange': [15, 30],
      'rewardMultiplier': 1.5,
      'prefix': '中级',
    },
    'hard': {
      'multiplier': 2.0,
      'targetRange': [30, 50],
      'rewardMultiplier': 2.0,
      'prefix': '高级',
    },
    'expert': {
      'multiplier': 3.0,
      'targetRange': [50, 100],
      'rewardMultiplier': 3.0,
      'prefix': '专家级',
    }
  };

  /// 生成个性化任务
  static Task generatePersonalizedTask(Player player) {
    // 根据玩家等级选择合适的难度
    final difficulty = _selectDifficulty(player.level);
    final difficultyConfig = _difficultyLevels[difficulty]!;
    
    // 根据玩家偏好选择任务类型
    final category = _selectTaskCategory(player);
    final template = _taskTemplates.firstWhere(
      (t) => t['category'] == category,
      orElse: () => _taskTemplates[_random.nextInt(_taskTemplates.length)],
    );
    
    // 生成任务内容
    final taskId = 'ai_generated_${DateTime.now().millisecondsSinceEpoch}';
    final name = _generateTaskName(template, difficultyConfig);
    final description = _generateTaskDescription(template, player);
    final conditions = _generateTaskConditions(template, difficultyConfig, player);
    final rewards = _generateTaskRewards(template, difficultyConfig, player);
    
    return Task(
      id: taskId,
      name: name,
      description: description,
      type: TaskType.daily, // AI生成的任务默认为日常任务
      priority: _random.nextInt(10) + 1,
      conditions: conditions,
      rewards: rewards,
      timeLimit: _generateTimeLimit(difficulty),
      repeatable: _random.nextBool(),
    );
  }

  /// 批量生成任务
  static List<Task> generateTaskBatch(Player player, int count) {
    final tasks = <Task>[];
    for (int i = 0; i < count; i++) {
      tasks.add(generatePersonalizedTask(player));
    }
    return tasks;
  }

  /// 根据玩家等级选择难度
  static String _selectDifficulty(int playerLevel) {
    if (playerLevel <= 2) return 'easy';
    if (playerLevel <= 5) return 'medium';
    if (playerLevel <= 10) return 'hard';
    return 'expert';
  }

  /// 根据玩家行为选择任务类型
  static String _selectTaskCategory(Player player) {
    // 简化的偏好分析，实际可以基于玩家历史行为
    final categories = ['cultivation', 'battle', 'exploration', 'growth'];
    
    // 根据玩家等级倾向选择
    if (player.level < 3) {
      return 'cultivation'; // 低等级偏向修炼
    } else if (player.level < 8) {
      return _random.nextBool() ? 'battle' : 'exploration'; // 中等级偏向战斗和探索
    } else {
      return categories[_random.nextInt(categories.length)]; // 高等级随机
    }
  }

  /// 生成任务名称
  static String _generateTaskName(Map<String, dynamic> template, Map<String, dynamic> difficultyConfig) {
    final names = template['names'] as List<String>;
    final baseName = names[_random.nextInt(names.length)];
    final prefix = difficultyConfig['prefix'] as String;
    
    // 随机决定是否添加前缀
    if (_random.nextDouble() < 0.7) {
      return '$prefix$baseName';
    }
    return baseName;
  }

  /// 生成任务描述
  static String _generateTaskDescription(Map<String, dynamic> template, Player player) {
    final descriptions = template['descriptions'] as List<String>;
    final baseDescription = descriptions[_random.nextInt(descriptions.length)];
    
    // 根据玩家境界个性化描述
    final realmName = _getRealmName(player.level);
    final personalizedElements = [
      '作为$realmName修士，',
      '在$realmName阶段，',
      '以你当前的$realmName修为，',
    ];
    
    if (_random.nextDouble() < 0.6) {
      final prefix = personalizedElements[_random.nextInt(personalizedElements.length)];
      return '$prefix$baseDescription。';
    }
    
    return '$baseDescription。';
  }

  /// 生成任务条件
  static List<TaskCondition> _generateTaskConditions(
    Map<String, dynamic> template, 
    Map<String, dynamic> difficultyConfig, 
    Player player
  ) {
    final conditionTypes = template['conditions'] as List<String>;
    final targetRange = difficultyConfig['targetRange'] as List<int>;
    final conditions = <TaskCondition>[];
    
    for (final conditionType in conditionTypes) {
      final baseTarget = targetRange[0] + _random.nextInt(targetRange[1] - targetRange[0]);
      final adjustedTarget = _adjustTargetForPlayer(baseTarget, conditionType, player);
      
      conditions.add(TaskCondition(
        type: conditionType,
        targetValue: adjustedTarget,
      ));
    }
    
    return conditions;
  }

  /// 生成任务奖励
  static List<TaskReward> _generateTaskRewards(
    Map<String, dynamic> template, 
    Map<String, dynamic> difficultyConfig, 
    Player player
  ) {
    final rewardTypes = template['rewards'] as List<String>;
    final rewardMultiplier = difficultyConfig['rewardMultiplier'] as double;
    final rewards = <TaskReward>[];
    
    for (final rewardType in rewardTypes) {
      final baseAmount = _getBaseRewardAmount(rewardType, player.level);
      final finalAmount = (baseAmount * rewardMultiplier).round();
      
      switch (rewardType) {
        case 'spiritStones':
          rewards.add(TaskReward(type: RewardType.spiritStones, amount: finalAmount));
          break;
        case 'experience':
          rewards.add(TaskReward(type: RewardType.experience, amount: finalAmount));
          break;
        case 'equipment':
          if (_random.nextDouble() < 0.3) { // 30%概率给装备
            rewards.add(TaskReward(type: RewardType.equipment, amount: 1, itemId: 'random_equipment'));
          }
          break;
        case 'technique':
          if (_random.nextDouble() < 0.2) { // 20%概率给功法
            rewards.add(TaskReward(type: RewardType.technique, amount: 1, itemId: 'random_technique'));
          }
          break;
      }
    }
    
    return rewards;
  }

  /// 调整目标值适应玩家
  static int _adjustTargetForPlayer(int baseTarget, String conditionType, Player player) {
    switch (conditionType) {
      case 'level_reach':
        return (player.level + 1 + _random.nextInt(3)).clamp(1, 23);
      case 'cultivation_count':
      case 'battle_count':
      case 'exploration_count':
        // 根据玩家等级调整
        final levelMultiplier = 1.0 + (player.level * 0.1);
        return (baseTarget * levelMultiplier).round();
      default:
        return baseTarget;
    }
  }

  /// 获取基础奖励数量
  static int _getBaseRewardAmount(String rewardType, int playerLevel) {
    final levelMultiplier = 1.0 + (playerLevel * 0.2);
    
    switch (rewardType) {
      case 'spiritStones':
        return (100 * levelMultiplier).round();
      case 'experience':
        return (50 * levelMultiplier).round();
      default:
        return 1;
    }
  }

  /// 生成时间限制
  static int _generateTimeLimit(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return 86400; // 24小时
      case 'medium':
        return 172800; // 48小时
      case 'hard':
        return 259200; // 72小时
      case 'expert':
        return 604800; // 7天
      default:
        return 86400;
    }
  }

  /// 获取境界名称
  static String _getRealmName(int level) {
    const realmNames = [
      '凡人', '练气期', '筑基期', '金丹期', '元婴期', '化神期',
      '炼虚期', '合体期', '大乘期', '渡劫期', '飞升期', '真仙',
      '玄仙', '金仙', '太乙真仙', '大罗金仙', '神君', '真神',
      '主神', '至高神', '混元道祖', '太初圣尊', '无上天尊', '永恒主宰'
    ];
    
    if (level < realmNames.length) {
      return realmNames[level];
    }
    return '未知境界';
  }

  /// 生成特殊事件任务
  static Task generateEventTask(String eventType, Player player) {
    switch (eventType) {
      case 'festival':
        return _generateFestivalTask(player);
      case 'emergency':
        return _generateEmergencyTask(player);
      case 'opportunity':
        return _generateOpportunityTask(player);
      default:
        return generatePersonalizedTask(player);
    }
  }

  /// 生成节日任务
  static Task _generateFestivalTask(Player player) {
    final festivalNames = ['仙界庆典', '修仙大会', '天道盛宴', '灵气节', '修炼节'];
    final festivalName = festivalNames[_random.nextInt(festivalNames.length)];
    
    return Task(
      id: 'festival_${DateTime.now().millisecondsSinceEpoch}',
      name: '$festivalName特别任务',
      description: '参与$festivalName，获得丰厚的节日奖励！',
      type: TaskType.daily,
      priority: 10,
      conditions: [
        TaskCondition(type: 'cultivation_count', targetValue: 20),
      ],
      rewards: [
        TaskReward(type: RewardType.spiritStones, amount: 500),
        TaskReward(type: RewardType.experience, amount: 300),
      ],
      timeLimit: 86400,
      repeatable: false,
    );
  }

  /// 生成紧急任务
  static Task _generateEmergencyTask(Player player) {
    final emergencyEvents = ['魔族入侵', '天劫降临', '秘境开启', '异象出现'];
    final eventName = emergencyEvents[_random.nextInt(emergencyEvents.length)];
    
    return Task(
      id: 'emergency_${DateTime.now().millisecondsSinceEpoch}',
      name: '紧急：$eventName',
      description: '$eventName！需要立即行动应对这个紧急情况。',
      type: TaskType.daily,
      priority: 15,
      conditions: [
        TaskCondition(type: 'battle_count', targetValue: 10),
      ],
      rewards: [
        TaskReward(type: RewardType.spiritStones, amount: 800),
        TaskReward(type: RewardType.experience, amount: 400),
      ],
      timeLimit: 43200, // 12小时
      repeatable: false,
    );
  }

  /// 生成机遇任务
  static Task _generateOpportunityTask(Player player) {
    final opportunities = ['仙缘巧遇', '宝藏发现', '高人指点', '天材地宝'];
    final opportunityName = opportunities[_random.nextInt(opportunities.length)];
    
    return Task(
      id: 'opportunity_${DateTime.now().millisecondsSinceEpoch}',
      name: '机遇：$opportunityName',
      description: '难得的修炼机遇出现了，把握住这个千载难逢的机会！',
      type: TaskType.daily,
      priority: 12,
      conditions: [
        TaskCondition(type: 'exploration_count', targetValue: 5),
      ],
      rewards: [
        TaskReward(type: RewardType.spiritStones, amount: 1000),
        TaskReward(type: RewardType.technique, amount: 1, itemId: 'rare_technique'),
      ],
      timeLimit: 172800, // 48小时
      repeatable: false,
    );
  }
}
