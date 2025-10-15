import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import '../models/player.dart';
import 'audio_service.dart';

class AchievementService extends ChangeNotifier {
  List<PlayerAchievement> _playerAchievements = [];
  List<String> _newlyCompletedAchievements = [];

  List<PlayerAchievement> get playerAchievements => _playerAchievements;
  List<String> get newlyCompletedAchievements => _newlyCompletedAchievements;

  // 获取已完成的成就
  List<PlayerAchievement> get completedAchievements =>
      _playerAchievements.where((pa) => pa.isCompleted).toList();

  // 获取未完成的成就
  List<PlayerAchievement> get incompleteAchievements =>
      _playerAchievements.where((pa) => !pa.isCompleted).toList();

  // 获取可领取奖励的成就
  List<PlayerAchievement> get claimableAchievements =>
      _playerAchievements.where((pa) => pa.isCompleted && !pa.isRewardClaimed).toList();

  // 初始化成就系统
  Future<void> initializeAchievements() async {
    await _loadAchievements();
    _initializeNewAchievements();
    notifyListeners();
  }

  // 初始化新成就（为所有预定义成就创建PlayerAchievement）
  void _initializeNewAchievements() {
    for (final achievement in Achievement.allAchievements) {
      if (!_playerAchievements.any((pa) => pa.achievementId == achievement.id)) {
        _playerAchievements.add(PlayerAchievement(achievementId: achievement.id));
      }
    }
  }

  // 更新成就进度
  void updateAchievementProgress(String achievementId, int newValue) {
    final playerAchievement = _getPlayerAchievement(achievementId);
    if (playerAchievement != null) {
      final wasJustCompleted = playerAchievement.updateProgress(newValue);
      if (wasJustCompleted) {
        _newlyCompletedAchievements.add(achievementId);
        // 播放成就完成音效
        AudioService().playAchievementSound();
        debugPrint('🏆 成就完成: ${playerAchievement.achievement?.name}');
      }
      _saveAchievements();
      notifyListeners();
    }
  }

  // 增加成就进度
  void addAchievementProgress(String achievementId, int value) {
    final playerAchievement = _getPlayerAchievement(achievementId);
    if (playerAchievement != null) {
      final wasJustCompleted = playerAchievement.addProgress(value);
      if (wasJustCompleted) {
        _newlyCompletedAchievements.add(achievementId);
        // 播放成就完成音效
        AudioService().playAchievementSound();
        debugPrint('🏆 成就完成: ${playerAchievement.achievement?.name}');
      }
      _saveAchievements();
      notifyListeners();
    }
  }

  // 领取成就奖励
  Map<String, dynamic>? claimAchievementReward(String achievementId, Player player) {
    final playerAchievement = _getPlayerAchievement(achievementId);
    if (playerAchievement == null || !playerAchievement.claimReward()) {
      return null;
    }

    final achievement = playerAchievement.achievement;
    if (achievement == null) return null;

    // 应用奖励到玩家
    final rewards = achievement.rewards;
    final appliedRewards = <String, dynamic>{};

    if (rewards.containsKey('spiritStones')) {
      final amount = rewards['spiritStones'] as int;
      player.spiritStones += amount;
      appliedRewards['spiritStones'] = amount;
    }

    if (rewards.containsKey('cultivationPoints')) {
      final amount = rewards['cultivationPoints'] as int;
      player.cultivationPoints += amount;
      appliedRewards['cultivationPoints'] = amount;
    }

    // 这里可以添加更多奖励类型的处理
    // 如永久属性加成、特殊装备等

    _saveAchievements();
    notifyListeners();
    
    debugPrint('🎁 领取成就奖励: ${achievement.name} - $appliedRewards');
    return appliedRewards;
  }

  // 检查玩家状态并更新相关成就
  void checkAndUpdateAchievements(Player player) {
    // 境界相关成就
    updateAchievementProgress('first_breakthrough', player.level >= 1 ? 1 : 0);
    updateAchievementProgress('foundation_builder', player.level >= 2 ? 1 : 0);
    updateAchievementProgress('golden_core', player.level >= 3 ? 1 : 0);
    updateAchievementProgress('nascent_soul', player.level >= 4 ? 1 : 0);
    updateAchievementProgress('immortal_ascension', player.level >= 10 ? 1 : 0);

    // 修炼次数成就（基于cultivationPoints）
    updateAchievementProgress('diligent_cultivator', player.cultivationPoints);
    updateAchievementProgress('cultivation_master', player.cultivationPoints);

    // 功法成就
    updateAchievementProgress('technique_learner', player.learnedTechniques.isNotEmpty ? 1 : 0);
    updateAchievementProgress('technique_master', player.learnedTechniques.length);

    // 装备成就
    final equippedCount = player.equippedItems.values.where((item) => item != null).length;
    updateAchievementProgress('first_equipment', equippedCount > 0 ? 1 : 0);

    // 灵石成就（基于总获得的灵石，这里用当前灵石作为简化）
    updateAchievementProgress('spirit_collector', player.spiritStones);
  }

  // 战斗胜利时调用
  void onBattleWon() {
    addAchievementProgress('first_victory', 1);
    addAchievementProgress('warrior', 1);
    addAchievementProgress('battle_legend', 1);
  }

  // 装备强化时调用
  void onEquipmentEnhanced() {
    addAchievementProgress('equipment_enhancer', 1);
  }

  // 清除新完成的成就通知
  void clearNewlyCompletedAchievements() {
    _newlyCompletedAchievements.clear();
    notifyListeners();
  }

  // 获取玩家成就
  PlayerAchievement? _getPlayerAchievement(String achievementId) {
    try {
      return _playerAchievements.firstWhere((pa) => pa.achievementId == achievementId);
    } catch (e) {
      return null;
    }
  }

  // 保存成就数据
  Future<void> _saveAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = _playerAchievements.map((pa) => pa.toJson()).toList();
    await prefs.setString('player_achievements', jsonEncode(achievementsJson));
  }

  // 加载成就数据
  Future<void> _loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = prefs.getString('player_achievements');
    
    if (achievementsJson != null) {
      try {
        final List<dynamic> achievementsList = jsonDecode(achievementsJson);
        _playerAchievements = achievementsList
            .map((json) => PlayerAchievement.fromJson(json))
            .toList();
      } catch (e) {
        debugPrint('加载成就数据失败: $e');
        _playerAchievements = [];
      }
    } else {
      _playerAchievements = [];
    }
  }

  // 重置所有成就（用于测试或重新开始游戏）
  Future<void> resetAllAchievements() async {
    _playerAchievements.clear();
    _newlyCompletedAchievements.clear();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('player_achievements');
    
    _initializeNewAchievements();
    notifyListeners();
  }

  // 获取成就完成度统计
  Map<String, int> getAchievementStats() {
    final total = Achievement.allAchievements.length;
    final completed = completedAchievements.length;
    final claimed = _playerAchievements.where((pa) => pa.isRewardClaimed).length;
    
    return {
      'total': total,
      'completed': completed,
      'claimed': claimed,
      'unclaimed': completed - claimed,
    };
  }

  // 根据类型获取成就完成度
  Map<AchievementType, Map<String, int>> getAchievementStatsByType() {
    final stats = <AchievementType, Map<String, int>>{};
    
    for (final type in AchievementType.values) {
      final typeAchievements = Achievement.getAchievementsByType(type);
      final completedCount = _playerAchievements
          .where((pa) => pa.isCompleted && 
                 Achievement.getAchievementById(pa.achievementId)?.type == type)
          .length;
      
      stats[type] = {
        'total': typeAchievements.length,
        'completed': completedCount,
      };
    }
    
    return stats;
  }
}
