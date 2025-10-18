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
import '../services/battle_service.dart';

class GameProvider extends ChangeNotifier {
  Player? _player;
  Timer? _autoTrainingTimer;
  Timer? _gameTickTimer;
  AchievementService? _achievementService;
  TaskService? _taskService;
  BattleService? _battleService;
  int _cultivationCount = 0; // 修炼次数计数器
  
  // 全局装备背包
  List<EquipmentItem> _globalInventory = [];
  
  // 装备栏数据 - 8个槽位
  List<EquipmentItem?> _equippedItems = List.filled(8, null);
  
  Player? get player => _player;
  bool get isGameStarted => _player != null;
  List<EquipmentItem> get globalInventory => _globalInventory;
  List<EquipmentItem?> get equippedItems => _equippedItems;
  
  // 设置成就服务
  void setAchievementService(AchievementService achievementService) {
    _achievementService = achievementService;
  }

  // 设置任务服务
  void setTaskService(TaskService taskService) {
    _taskService = taskService;
  }

  // 设置战斗服务
  void setBattleService(BattleService battleService) {
    _battleService = battleService;
    // 设置战斗胜利回调
    _battleService!.onBattleWon = _onBattleWon;
  }

  // 战斗胜利回调
  void _onBattleWon() {
    if (_player == null) return;
    
    debugPrint('🏆 战斗胜利！更新成就和任务进度');
    
    // 更新成就进度
    _achievementService?.onBattleWon();
    _achievementService?.checkAndUpdateAchievements(_player!);
    
    // 更新任务进度
    _taskService?.addTaskProgress('battle_count', 1);
  }

  // 学习功法
  bool learnTechnique(String techniqueId) {
    if (_player == null) return false;
    
    final success = _player!.learnTechnique(techniqueId);
    if (success) {
      debugPrint('📚 学习功法成功: $techniqueId');
      
      // 更新成就和任务进度
      _achievementService?.checkAndUpdateAchievements(_player!);
      _taskService?.updateTaskProgress('technique_count', _player!.learnedTechniques.length);
      
      _saveGameData();
      notifyListeners();
    }
    
    return success;
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
        final oldLevel = _player!.level;
        final expGained = _player!.trainOnce();
        
        // 检查是否升级了
        if (_player!.level > oldLevel) {
          // 播放升级音效
          AudioService().playLevelUpSound();
          debugPrint('🎉 自动修炼境界突破！当前境界: ${_player!.currentRealm.name}');
          
          // 更新成就和任务进度（升级时）
          _achievementService?.checkAndUpdateAchievements(_player!);
          _taskService?.updateTaskProgress('level_reach', _player!.level);
        }
        
        // 定期更新修炼次数相关的成就和任务（每10次修炼更新一次，避免过于频繁）
        _cultivationCount++;
        if (_cultivationCount % 10 == 0) {
          _achievementService?.checkAndUpdateAchievements(_player!);
          _taskService?.addTaskProgress('cultivation_count', 10);
        }
        
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
    int tickCount = 0; // 添加计数器
    _gameTickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_player != null) {
        tickCount++;
        // 这里可以添加游戏的持续逻辑，比如：
        // - 自动恢复生命值和法力值
        // - 检查离线收益
        // - 更新游戏状态等
        
        // 自动恢复少量生命值和法力值（包含装备加成）
        final totalMaxHealth = _player!.actualMaxHealth + equipmentHealthBonus;
        final totalMaxMana = _player!.actualMaxMana + equipmentManaBonus;
        
        // 添加安全检查，防止异常大的数值
        final safeMaxHealth = totalMaxHealth.clamp(1, 1000000); // 限制最大生命值范围
        final safeMaxMana = totalMaxMana.clamp(1, 1000000); // 限制最大法力值范围
        
        bool needsUpdate = false;
        
        if (_player!.currentHealth < safeMaxHealth) {
          final healthRestore = safeMaxHealth * 0.005; // 每秒恢复0.5%最大生命值
          final oldHealth = _player!.currentHealth;
          _player!.currentHealth = (_player!.currentHealth + healthRestore).clamp(0.0, safeMaxHealth).toDouble();
          needsUpdate = true;
          // 只在生命值显著变化时输出调试信息（每100点输出一次）
          if ((_player!.currentHealth - oldHealth) > 0 && (_player!.currentHealth.toInt() % 100 == 0 || _player!.currentHealth >= safeMaxHealth)) {
            debugPrint('🩸 自动回复生命值: ${_player!.currentHealth.toStringAsFixed(1)}/${safeMaxHealth.toStringAsFixed(1)}');
          }
        }
        if (_player!.currentMana < safeMaxMana) {
          final manaRestore = safeMaxMana * 0.01; // 每秒恢复1%最大法力值
          final oldMana = _player!.currentMana;
          _player!.currentMana = (_player!.currentMana + manaRestore).clamp(0.0, safeMaxMana).toDouble();
          needsUpdate = true;
          // 只在法力值显著变化时输出调试信息（每50点输出一次）
          if ((_player!.currentMana - oldMana) > 0 && (_player!.currentMana.toInt() % 50 == 0 || _player!.currentMana >= safeMaxMana)) {
            debugPrint('💙 自动回复法力值: ${_player!.currentMana.toStringAsFixed(1)}/${safeMaxMana.toStringAsFixed(1)}');
          }
        }
        
        // 只在有变化时才通知监听者
        if (needsUpdate) {
          notifyListeners();
          
          // 每2秒保存一次数据，确保生命值和法力值的变化被持久化
          if (tickCount % 2 == 0) {
            // 异步保存，避免阻塞UI
            _saveGameData().catchError((error) {
              debugPrint('💾 保存数据失败: $error');
            });
            // 减少日志输出频率，每10秒输出一次
            if (tickCount % 30 == 0) {
              debugPrint('💾 自动保存游戏数据 (生命值: ${_player!.currentHealth.toStringAsFixed(1)}, 法力值: ${_player!.currentMana.toStringAsFixed(1)})');
            }
          }
        }
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
    
    // 保存装备栏数据
    final equippedJson = jsonEncode(_equippedItems.map((e) => e?.toJson()).toList());
    await prefs.setString('equipped_data', equippedJson);
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
        
        // 加载装备栏数据
        final equippedJson = prefs.getString('equipped_data');
        if (equippedJson != null) {
          final equippedList = jsonDecode(equippedJson) as List;
          _equippedItems = equippedList.map((e) => e != null ? EquipmentItem.fromJson(e) : null).toList();
        } else {
          _equippedItems = List.filled(8, null);
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
    await prefs.remove('equipment_data');
    await prefs.remove('equipped_data');
    
    _globalInventory.clear();
    _equippedItems = List.filled(8, null);
    
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
    
    // 更新成就和任务进度
    if (_player != null) {
      _achievementService?.checkAndUpdateAchievements(_player!);
      // 可以添加购买装备相关的任务进度更新
      // _taskService?.addTaskProgress('equipment_purchase', 1);
    }
  }

  // 装备物品到指定槽位
  void equipItem(EquipmentItem item, int slotIndex) {
    if (slotIndex < 0 || slotIndex >= 8) return;
    
    // 如果槽位已有装备，先卸载到背包
    if (_equippedItems[slotIndex] != null) {
      final oldItem = _equippedItems[slotIndex]!;
      addEquipmentToInventory(oldItem);
    }
    
    // 装备新物品
    _equippedItems[slotIndex] = item;
    removeEquipmentFromInventory(item);
    
    debugPrint('⚔️ 装备成功: ${item.name} -> 槽位 ${slotIndex + 1}');
    
    // 更新成就和任务进度
    if (_player != null) {
      _achievementService?.checkAndUpdateAchievements(_player!);
      _taskService?.updateTaskProgress('weapon_equipped', _equippedItems.where((item) => item != null).length);
    }
    
    _saveGameData();
    notifyListeners();
  }

  // 卸载指定槽位的装备
  void unequipItem(int slotIndex) {
    if (slotIndex < 0 || slotIndex >= 8) return;
    
    final unequippedItem = _equippedItems[slotIndex];
    if (unequippedItem != null) {
      _equippedItems[slotIndex] = null;
      addEquipmentToInventory(unequippedItem);
      
      // 卸载装备后，调整当前生命值和法力值，确保不超过新的最大值
      _adjustHealthAndManaAfterUnequip();
      
      debugPrint('🎒 卸载装备: ${unequippedItem.name}');
      _saveGameData();
      notifyListeners();
    }
  }
  
  // 卸载装备后调整生命值和法力值
  void _adjustHealthAndManaAfterUnequip() {
    if (_player == null) return;
    
    final newMaxHealth = _player!.actualMaxHealth + equipmentHealthBonus;
    final newMaxMana = _player!.actualMaxMana + equipmentManaBonus;
    
    // 如果当前生命值超过新的最大值，调整为新的最大值
    if (_player!.currentHealth > newMaxHealth) {
      _player!.currentHealth = newMaxHealth;
      debugPrint('🩸 调整生命值: ${_player!.currentHealth}/${newMaxHealth}');
    }
    
    // 如果当前法力值超过新的最大值，调整为新的最大值
    if (_player!.currentMana > newMaxMana) {
      _player!.currentMana = newMaxMana;
      debugPrint('💙 调整法力值: ${_player!.currentMana}/${newMaxMana}');
    }
  }

  // 计算装备攻击加成
  double get equipmentAttackBonus {
    return _equippedItems
        .where((item) => item != null)
        .fold(0.0, (sum, item) => sum + item!.attackBonus);
  }

  // 计算装备防御加成
  double get equipmentDefenseBonus {
    return _equippedItems
        .where((item) => item != null)
        .fold(0.0, (sum, item) => sum + item!.defenseBonus);
  }

  // 计算装备生命加成
  double get equipmentHealthBonus {
    final bonus = _equippedItems
        .where((item) => item != null)
        .fold(0.0, (sum, item) => sum + item!.healthBonus);
    // 限制装备加成范围，防止异常值
    return bonus.clamp(0, 100000);
  }

  // 计算装备法力加成
  double get equipmentManaBonus {
    final bonus = _equippedItems
        .where((item) => item != null)
        .fold(0.0, (sum, item) => sum + item!.manaBonus);
    // 限制装备加成范围，防止异常值
    return bonus.clamp(0, 50000);
  }

  @override
  void dispose() {
    // 在销毁前保存最新的游戏数据
    _saveGameData();
    _autoTrainingTimer?.cancel();
    _gameTickTimer?.cancel();
    super.dispose();
  }
}
