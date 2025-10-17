import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';
import '../models/technique.dart';
import '../models/equipment_item.dart';
import '../services/achievement_service.dart';
import '../services/audio_service.dart';
import '../services/task_service.dart';

class GameProvider extends ChangeNotifier {
  Player? _player;
  Timer? _autoTrainingTimer;
  Timer? _gameTickTimer;
  AchievementService? _achievementService;
  TaskService? _taskService;
  
  // 全局装备背包
  List<EquipmentItem> _globalInventory = [];
  
  Player? get player => _player;
  bool get isGameStarted => _player != null;
  List<EquipmentItem> get globalInventory => _globalInventory;
  
  // 设置成就服务
  void setAchievementService(AchievementService achievementService) {
    _achievementService = achievementService;
  }

  // 设置任务服务
  void setTaskService(TaskService taskService) {
    _taskService = taskService;
  }

  // 初始化游戏
  Future<void> initializeGame() async {
    try {
      debugPrint('🎮 开始初始化游戏...');
      await _loadGameData();
      debugPrint('🎮 游戏数据加载完成，玩家: ${_player?.name}');
      _startGameTick();
      _startAutoTraining(); // 自动开始修炼
      debugPrint('🎮 游戏初始化完成');
    } catch (e) {
      debugPrint('🎮 游戏初始化失败: $e');
      // 如果初始化失败，创建默认玩家
      await createNewPlayer('修仙者');
    }
  }

  // 创建新角色
  Future<void> createNewPlayer(String name) async {
    _player = Player(name: name);
    
    // 添加一些初始装备到背包
    _globalInventory = [
      EquipmentItem('新手剑', '攻击力 +10', Icons.flash_on, Colors.green, 1, attackBonus: 10),
      EquipmentItem('布甲', '防御力 +8', Icons.shield, Colors.blue, 2, defenseBonus: 8),
      EquipmentItem('法师帽', '法力值 +15', Icons.auto_awesome, Colors.purple, 3, manaBonus: 15),
    ];
    
    await _saveGameData();
    notifyListeners();
  }

  // 开始/停止自动修炼
  void toggleAutoTraining() {
    if (_player == null) return;

    _player!.isAutoTraining = !_player!.isAutoTraining;
    
    if (_player!.isAutoTraining) {
      _startAutoTraining();
    } else {
      _stopAutoTraining();
    }
    
    _saveGameData();
    notifyListeners();
  }

  // 手动修炼一次
  void manualTrain() {
    if (_player == null) return;
    
    final oldLevel = _player!.level;
    final baseExpGained = _player!.trainOnce();
    // 应用功法加成
    final actualExpGained = (baseExpGained * _player!.expBonusMultiplier).round();
    
    // 检查是否升级了
    if (_player!.level > oldLevel) {
      // 播放升级音效
      AudioService().playLevelUpSound();
      debugPrint('🎉 境界突破！当前境界: ${_player!.currentRealm.name}');
    }
    
    // 给功法增加经验
    for (final learnedTech in _player!.learnedTechniques) {
      if (learnedTech.technique?.type == TechniqueType.cultivation) {
        learnedTech.addExperience(1);
      }
    }
    
    // 更新成就进度
    _achievementService?.checkAndUpdateAchievements(_player!);
    
    // 更新任务进度
    _taskService?.addTaskProgress('cultivation_count', 1);
    _taskService?.updateTaskProgress('level_reach', _player!.level);
    
    _saveGameData();
    notifyListeners();
    
    debugPrint('修炼获得 $actualExpGained 经验值 (基础: $baseExpGained, 加成: ${(_player!.expBonusMultiplier * 100).toInt()}%)');
  }

  // 开始自动修炼
  void _startAutoTraining() {
    _stopAutoTraining(); // 先停止之前的定时器
    
    if (_player != null) {
      _player!.isAutoTraining = true; // 确保自动修炼开启
    }
    
    _autoTrainingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_player != null) {
        final expGained = _player!.trainOnce();
        notifyListeners();
        debugPrint('自动修炼获得 $expGained 经验值');
      } else {
        timer.cancel();
      }
    });
  }

  // 停止自动修炼
  void _stopAutoTraining() {
    _autoTrainingTimer?.cancel();
    _autoTrainingTimer = null;
  }

  // 开始游戏主循环
  void _startGameTick() {
    _gameTickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_player != null) {
        // 这里可以添加游戏的持续逻辑，比如：
        // - 自动恢复生命值和法力值
        // - 检查离线收益
        // - 更新游戏状态等
        
        // 自动恢复少量生命值和法力值
        if (_player!.currentHealth < _player!.actualMaxHealth) {
          _player!.restoreHealth(_player!.actualMaxHealth * 0.01);
        }
        if (_player!.currentMana < _player!.actualMaxMana) {
          _player!.restoreMana(_player!.actualMaxMana * 0.02);
        }
        
        notifyListeners();
      }
    });
  }

  // 计算离线收益
  void _calculateOfflineRewards() {
    if (_player == null || _player!.lastTrainingTime == null) return;
    
    final now = DateTime.now();
    final offlineTime = now.difference(_player!.lastTrainingTime!);
    
    if (offlineTime.inMinutes > 5 && _player!.isAutoTraining) {
      // 离线超过5分钟且开启了自动修炼，给予离线收益
      final offlineMinutes = offlineTime.inMinutes.clamp(0, 480); // 最多8小时离线收益
      final offlineTrainings = (offlineMinutes / 2).floor(); // 每2分钟一次修炼
      
      if (offlineTrainings > 0) {
        int totalExpGained = 0;
        for (int i = 0; i < offlineTrainings; i++) {
          totalExpGained += _player!.trainOnce();
        }
        
        debugPrint('离线修炼 $offlineMinutes 分钟，获得 $totalExpGained 经验值');
      }
    }
    
    _player!.lastTrainingTime = now;
  }

  // 保存游戏数据
  Future<void> saveGameData() async {
    await _saveGameData();
  }

  // 私有保存方法
  Future<void> _saveGameData() async {
    if (_player == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final playerJson = jsonEncode(_player!.toJson());
    await prefs.setString('player_data', playerJson);
    
    // 保存装备数据
    final equipmentJson = jsonEncode(_globalInventory.map((e) => e.toJson()).toList());
    await prefs.setString('equipment_data', equipmentJson);
  }

  // 加载游戏数据
  Future<void> _loadGameData() async {
    final prefs = await SharedPreferences.getInstance();
    final playerJson = prefs.getString('player_data');
    
    if (playerJson != null) {
      try {
        final playerData = jsonDecode(playerJson);
        _player = Player.fromJson(playerData);
        
        // 加载装备数据
        final equipmentJson = prefs.getString('equipment_data');
        if (equipmentJson != null) {
          final equipmentList = jsonDecode(equipmentJson) as List;
          _globalInventory = equipmentList.map((e) => EquipmentItem.fromJson(e)).toList();
        } else {
          _globalInventory = [];
        }
        
        _calculateOfflineRewards();
        
        // 如果之前开启了自动修炼，重新开始
        if (_player!.isAutoTraining) {
          _startAutoTraining();
        }
        
        notifyListeners();
      } catch (e) {
        debugPrint('加载游戏数据失败: $e');
        // 如果加载失败，创建新玩家
        await createNewPlayer('修仙者');
      }
    } else {
      // 如果没有保存的数据，创建新玩家
      await createNewPlayer('修仙者');
    }
  }

  // 重置游戏数据
  Future<void> resetGame() async {
    _stopAutoTraining();
    _player = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('player_data');
    
    notifyListeners();
  }

  // 添加装备到全局背包
  void addEquipmentToInventory(EquipmentItem equipment) {
    _globalInventory.add(equipment);
    debugPrint('📦 装备添加成功: ${equipment.name}');
    _saveGameData();
    notifyListeners();
  }

  // 从全局背包移除装备
  void removeEquipmentFromInventory(EquipmentItem equipment) {
    _globalInventory.remove(equipment);
    _saveGameData();
    notifyListeners();
  }

  // 从商店购买装备
  void purchaseEquipmentFromShop(String itemName, String description, int itemId) {
    final equipment = EquipmentItem.fromShopItem(itemName, description, itemId);
    addEquipmentToInventory(equipment);
    debugPrint('🎒 装备已添加到背包: ${equipment.name}, 攻击+${equipment.attackBonus}, 防御+${equipment.defenseBonus}');
    debugPrint('🎒 当前背包装备数量: ${_globalInventory.length}');
  }

  @override
  void dispose() {
    _autoTrainingTimer?.cancel();
    _gameTickTimer?.cancel();
    super.dispose();
  }
}
