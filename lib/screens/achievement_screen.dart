import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/achievement.dart';
import '../services/achievement_service.dart';
import '../services/audio_service.dart';
import '../providers/game_provider.dart';
import '../widgets/swipe_back_wrapper.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SwipeBackScaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        title: const Text(
          '成就系统',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1a1a1a),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFFe94560),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFe94560),
          tabs: const [
            Tab(text: '全部'),
            Tab(text: '修炼'),
            Tab(text: '战斗'),
            Tab(text: '功法'),
            Tab(text: '装备'),
            Tab(text: '通用'),
          ],
        ),
      ),
      body: Consumer<AchievementService>(
        builder: (context, achievementService, child) {
          return Column(
            children: [
              // 成就统计面板
              _buildStatsPanel(achievementService),
              // 成就列表
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAchievementList(achievementService, null),
                    _buildAchievementList(achievementService, AchievementType.cultivation),
                    _buildAchievementList(achievementService, AchievementType.combat),
                    _buildAchievementList(achievementService, AchievementType.technique),
                    _buildAchievementList(achievementService, AchievementType.equipment),
                    _buildAchievementList(achievementService, AchievementType.general),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsPanel(AchievementService achievementService) {
    final stats = achievementService.getAchievementStats();
    final completionRate = stats['total']! > 0 
        ? (stats['completed']! / stats['total']! * 100).toInt()
        : 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('总成就', '${stats['total']}', Colors.blue),
              _buildStatItem('已完成', '${stats['completed']}', Colors.green),
              _buildStatItem('可领取', '${stats['unclaimed']}', const Color(0xFFe94560)),
              _buildStatItem('完成度', '$completionRate%', Colors.orange),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: stats['total']! > 0 ? stats['completed']! / stats['total']! : 0,
            backgroundColor: const Color(0xFF333333),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFe94560)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementList(AchievementService achievementService, AchievementType? type) {
    List<PlayerAchievement> achievements;
    
    if (type == null) {
      achievements = achievementService.playerAchievements;
    } else {
      achievements = achievementService.playerAchievements
          .where((pa) => Achievement.getAchievementById(pa.achievementId)?.type == type)
          .toList();
    }

    // 按完成状态和稀有度排序
    achievements.sort((a, b) {
      // 未完成的排在前面
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      
      // 可领取奖励的排在最前面
      if (a.isCompleted && b.isCompleted) {
        if (a.isRewardClaimed != b.isRewardClaimed) {
          return a.isRewardClaimed ? 1 : -1;
        }
      }
      
      // 按稀有度排序
      final aRarity = Achievement.getAchievementById(a.achievementId)?.rarity.index ?? 0;
      final bRarity = Achievement.getAchievementById(b.achievementId)?.rarity.index ?? 0;
      return bRarity.compareTo(aRarity);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final playerAchievement = achievements[index];
        final achievement = Achievement.getAchievementById(playerAchievement.achievementId);
        
        if (achievement == null) return const SizedBox.shrink();
        
        return _buildAchievementCard(playerAchievement, achievement);
      },
    );
  }

  Widget _buildAchievementCard(PlayerAchievement playerAchievement, Achievement achievement) {
    final isCompleted = playerAchievement.isCompleted;
    final canClaimReward = isCompleted && !playerAchievement.isRewardClaimed;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: canClaimReward 
              ? const Color(0xFFe94560) 
              : isCompleted 
                  ? Colors.green.withOpacity(0.5)
                  : const Color(0xFF333333),
          width: canClaimReward ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildAchievementIcon(achievement, isCompleted),
        title: Row(
          children: [
            Expanded(
              child: Text(
                achievement.name,
                style: TextStyle(
                  color: isCompleted ? Colors.white : Colors.grey[400],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildRarityBadge(achievement.rarity),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              achievement.description,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            _buildProgressBar(playerAchievement, achievement),
            const SizedBox(height: 8),
            _buildRewardInfo(achievement),
          ],
        ),
        trailing: canClaimReward
            ? ElevatedButton(
                onPressed: () {
                  AudioService().playCoinsSound();
                  _claimReward(playerAchievement.achievementId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFe94560),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('领取'),
              )
            : isCompleted
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
      ),
    );
  }

  Widget _buildAchievementIcon(Achievement achievement, bool isCompleted) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: _getRarityColor(achievement.rarity).withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: _getRarityColor(achievement.rarity),
          width: 2,
        ),
      ),
      child: Icon(
        _getAchievementTypeIcon(achievement.type),
        color: isCompleted ? _getRarityColor(achievement.rarity) : Colors.grey,
        size: 24,
      ),
    );
  }

  Widget _buildRarityBadge(AchievementRarity rarity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getRarityColor(rarity).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getRarityColor(rarity)),
      ),
      child: Text(
        _getRarityName(rarity),
        style: TextStyle(
          color: _getRarityColor(rarity),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProgressBar(PlayerAchievement playerAchievement, Achievement achievement) {
    final progress = playerAchievement.progressPercentage;
    final current = playerAchievement.currentProgress;
    final target = achievement.targetValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '进度: $current / $target',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: const Color(0xFF333333),
          valueColor: AlwaysStoppedAnimation<Color>(
            playerAchievement.isCompleted 
                ? Colors.green 
                : const Color(0xFFe94560),
          ),
        ),
      ],
    );
  }

  Widget _buildRewardInfo(Achievement achievement) {
    final rewards = achievement.rewards;
    final rewardTexts = <String>[];

    if (rewards.containsKey('spiritStones')) {
      rewardTexts.add('灵石 +${rewards['spiritStones']}');
    }
    if (rewards.containsKey('cultivationPoints')) {
      rewardTexts.add('修炼点 +${rewards['cultivationPoints']}');
    }

    return Text(
      '奖励: ${rewardTexts.join(', ')}',
      style: const TextStyle(
        color: Colors.orange,
        fontSize: 12,
      ),
    );
  }

  Color _getRarityColor(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return Colors.grey;
      case AchievementRarity.rare:
        return Colors.blue;
      case AchievementRarity.epic:
        return Colors.purple;
      case AchievementRarity.legendary:
        return Colors.orange;
    }
  }

  String _getRarityName(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return '普通';
      case AchievementRarity.rare:
        return '稀有';
      case AchievementRarity.epic:
        return '史诗';
      case AchievementRarity.legendary:
        return '传说';
    }
  }

  IconData _getAchievementTypeIcon(AchievementType type) {
    switch (type) {
      case AchievementType.cultivation:
        return Icons.self_improvement;
      case AchievementType.combat:
        return Icons.sports_martial_arts;
      case AchievementType.technique:
        return Icons.auto_fix_high;
      case AchievementType.equipment:
        return Icons.shield;
      case AchievementType.general:
        return Icons.star;
    }
  }

  void _claimReward(String achievementId) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final achievementService = Provider.of<AchievementService>(context, listen: false);
    
    if (gameProvider.player != null) {
      final rewards = achievementService.claimAchievementReward(achievementId, gameProvider.player!);
      
      if (rewards != null) {
        // 保存游戏数据
        gameProvider.saveGameData();
        
        // 显示奖励提示
        _showRewardDialog(rewards);
      }
    }
  }

  void _showRewardDialog(Map<String, dynamic> rewards) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Text(
          '🎉 获得奖励',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: rewards.entries.map((entry) {
            String rewardName;
            switch (entry.key) {
              case 'spiritStones':
                rewardName = '灵石';
                break;
              case 'cultivationPoints':
                rewardName = '修炼点';
                break;
              default:
                rewardName = entry.key;
            }
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    rewardName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    '+${entry.value}',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '确定',
              style: TextStyle(color: Color(0xFFe94560)),
            ),
          ),
        ],
      ),
    );
  }
}
