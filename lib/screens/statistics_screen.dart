import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cultivation_realm.dart';
import '../models/achievement.dart';
import '../services/achievement_service.dart';
import '../providers/game_provider.dart';
import '../widgets/swipe_back_wrapper.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
          '数据统计',
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
          labelColor: const Color(0xFFe94560),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFe94560),
          tabs: const [
            Tab(text: '总览'),
            Tab(text: '修炼'),
            Tab(text: '战斗'),
            Tab(text: '成就'),
          ],
        ),
      ),
      body: Consumer2<GameProvider, AchievementService>(
        builder: (context, gameProvider, achievementService, child) {
          final player = gameProvider.player;
          if (player == null) {
            return const Center(
              child: Text(
                '暂无数据',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(player, achievementService),
              _buildCultivationTab(player),
              _buildCombatTab(player),
              _buildAchievementTab(achievementService),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(player, AchievementService achievementService) {
    final totalPower = player.totalPower;
    final achievementStats = achievementService.getAchievementStats();
    final completionRate = achievementStats['total']! > 0 
        ? (achievementStats['completed']! / achievementStats['total']! * 100).toInt()
        : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 角色基本信息卡片
          _buildInfoCard(
            '角色信息',
            Icons.person,
            [
              _buildStatRow('角色名称', player.name, Colors.white),
              _buildStatRow('当前境界', player.currentRealm.name, _getRealmColor(player.level)),
              _buildStatRow('总战力', _formatNumber(totalPower), Colors.orange),
              _buildStatRow('灵石', _formatNumber(player.spiritStones), Colors.amber),
              _buildStatRow('修炼点', _formatNumber(player.cultivationPoints), Colors.cyan),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 属性统计卡片
          _buildInfoCard(
            '属性统计',
            Icons.bar_chart,
            [
              _buildStatRow('攻击力', _formatNumber(player.actualAttack.round()), Colors.red),
              _buildStatRow('防御力', _formatNumber(player.actualDefense.round()), Colors.blue),
              _buildStatRow('生命值', '${_formatNumber(player.currentHealth.round())}/${_formatNumber(player.actualMaxHealth.round())}', Colors.green),
              _buildStatRow('法力值', '${_formatNumber(player.currentMana.round())}/${_formatNumber(player.actualMaxMana.round())}', Colors.purple),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 进度统计卡片
          _buildInfoCard(
            '进度统计',
            Icons.trending_up,
            [
              _buildProgressRow('境界进度', player.levelProgress, Colors.orange),
              _buildStatRow('总经验值', _formatNumber(player.totalExp), Colors.yellow),
              _buildStatRow('当前经验', _formatNumber(player.currentExp), Colors.lime),
              _buildStatRow('升级所需', _formatNumber(player.expToNextLevel), Colors.lightBlue),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 成就统计卡片
          _buildInfoCard(
            '成就统计',
            Icons.emoji_events,
            [
              _buildStatRow('成就完成度', '$completionRate%', Colors.orange),
              _buildStatRow('已完成成就', '${achievementStats['completed']}/${achievementStats['total']}', Colors.green),
              _buildStatRow('可领取奖励', '${achievementStats['unclaimed']}', const Color(0xFFe94560)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCultivationTab(player) {
    final currentRealm = player.currentRealm;
    final nextRealm = player.nextRealm;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 境界进度卡片
          _buildInfoCard(
            '境界修炼',
            Icons.self_improvement,
            [
              _buildStatRow('当前境界', currentRealm.name, _getRealmColor(player.level)),
              if (nextRealm != null) 
                _buildStatRow('下一境界', nextRealm.name, _getRealmColor(player.level + 1)),
              _buildProgressRow('突破进度', player.levelProgress, Colors.orange),
              _buildStatRow('当前经验', _formatNumber(player.currentExp), Colors.yellow),
              _buildStatRow('境界上限', _formatNumber(currentRealm.maxExp), Colors.grey),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 修炼效率卡片
          _buildInfoCard(
            '修炼效率',
            Icons.speed,
            [
              _buildStatRow('经验加成', '${((player.expBonusMultiplier - 1) * 100).toStringAsFixed(1)}%', Colors.green),
              _buildStatRow('修炼速度', '${((player.cultivationSpeedMultiplier - 1) * 100).toStringAsFixed(1)}%', Colors.blue),
              _buildStatRow('生命恢复', '${((player.healthRegenMultiplier - 1) * 100).toStringAsFixed(1)}%', Colors.red),
              _buildStatRow('法力恢复', '${((player.manaRegenMultiplier - 1) * 100).toStringAsFixed(1)}%', Colors.purple),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 功法统计卡片
          _buildInfoCard(
            '功法统计',
            Icons.auto_fix_high,
            [
              _buildStatRow('已学功法', '${player.learnedTechniques.length}', Colors.cyan),
              _buildStatRow('总修炼次数', _formatNumber(player.cultivationPoints), Colors.orange),
              if (player.learnedTechniques.isNotEmpty)
                ...player.learnedTechniques.map((lt) => 
                  _buildStatRow(
                    lt.technique?.name ?? '未知功法', 
                    '等级 ${lt.level}', 
                    Colors.lightBlue
                  )
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 境界历程卡片
          _buildRealmHistoryCard(player),
        ],
      ),
    );
  }

  Widget _buildCombatTab(player) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 战斗属性卡片
          _buildInfoCard(
            '战斗属性',
            Icons.sports_martial_arts,
            [
              _buildStatRow('总战力', _formatNumber(player.totalPower), Colors.orange),
              _buildStatRow('攻击力', _formatNumber(player.actualAttack.round()), Colors.red),
              _buildStatRow('防御力', _formatNumber(player.actualDefense.round()), Colors.blue),
              _buildStatRow('暴击率', '${(player.criticalRate * 100).toStringAsFixed(1)}%', Colors.yellow),
              _buildStatRow('暴击伤害', '${(player.criticalDamage * 100).toStringAsFixed(1)}%', Colors.orange),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 特殊属性卡片
          _buildInfoCard(
            '特殊属性',
            Icons.shield,
            [
              _buildStatRow('技能伤害', '${(player.skillDamageBonus * 100).toStringAsFixed(1)}%', Colors.purple),
              _buildStatRow('伤害减免', '${(player.damageReduction * 100).toStringAsFixed(1)}%', Colors.green),
              _buildStatRow('闪避率', '${(player.dodgeRate * 100).toStringAsFixed(1)}%', Colors.cyan),
              _buildStatRow('防御加成', '${((player.defenseMultiplier - 1) * 100).toStringAsFixed(1)}%', Colors.blue),
              _buildStatRow('生命加成', '${((player.healthMultiplier - 1) * 100).toStringAsFixed(1)}%', Colors.red),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 装备统计卡片
          _buildEquipmentStatsCard(player),
        ],
      ),
    );
  }

  Widget _buildAchievementTab(AchievementService achievementService) {
    final stats = achievementService.getAchievementStats();
    final statsByType = achievementService.getAchievementStatsByType();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 总体成就统计
          _buildInfoCard(
            '成就总览',
            Icons.emoji_events,
            [
              _buildStatRow('总成就数', '${stats['total']}', Colors.white),
              _buildStatRow('已完成', '${stats['completed']}', Colors.green),
              _buildStatRow('完成率', '${stats['total']! > 0 ? (stats['completed']! / stats['total']! * 100).toInt() : 0}%', Colors.orange),
              _buildStatRow('可领取', '${stats['unclaimed']}', const Color(0xFFe94560)),
              _buildStatRow('已领取', '${stats['claimed']}', Colors.blue),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 分类成就统计
          ...statsByType.entries.map((entry) {
            final type = entry.key;
            final typeStats = entry.value;
            final typeName = _getAchievementTypeName(type);
            final typeIcon = _getAchievementTypeIcon(type);
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildInfoCard(
                typeName,
                typeIcon,
                [
                  _buildStatRow('总数', '${typeStats['total']}', Colors.white),
                  _buildStatRow('已完成', '${typeStats['completed']}', Colors.green),
                  _buildProgressRow(
                    '完成度', 
                    typeStats['total']! > 0 ? typeStats['completed']! / typeStats['total']! : 0.0,
                    Colors.orange
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFe94560), size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: const Color(0xFF333333),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildRealmHistoryCard(player) {
    return _buildInfoCard(
      '境界历程',
      Icons.timeline,
      [
        Container(
          height: 200,
          child: ListView.builder(
            itemCount: CultivationRealm.realms.length,
            itemBuilder: (context, index) {
              final realm = CultivationRealm.realms[index];
              final isCurrentRealm = player.level == index;
              final isCompleted = player.level > index;
              
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCurrentRealm 
                      ? const Color(0xFFe94560).withOpacity(0.2)
                      : isCompleted 
                          ? Colors.green.withOpacity(0.2)
                          : const Color(0xFF2a2a2a),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCurrentRealm 
                        ? const Color(0xFFe94560)
                        : isCompleted 
                            ? Colors.green
                            : const Color(0xFF333333),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isCompleted 
                          ? Icons.check_circle
                          : isCurrentRealm 
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                      color: isCompleted 
                          ? Colors.green
                          : isCurrentRealm 
                              ? const Color(0xFFe94560)
                              : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        realm.name,
                        style: TextStyle(
                          color: isCurrentRealm || isCompleted ? Colors.white : Colors.grey,
                          fontWeight: isCurrentRealm ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isCurrentRealm)
                      Text(
                        '当前',
                        style: TextStyle(
                          color: const Color(0xFFe94560),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentStatsCard(player) {
    final equippedItems = player.equippedItems.values.where((item) => item != null).toList();
    
    return _buildInfoCard(
      '装备统计',
      Icons.inventory,
      [
        _buildStatRow('已装备', '${equippedItems.length}/4', Colors.cyan),
        _buildStatRow('背包物品', '${player.inventory.length}', Colors.orange),
        const SizedBox(height: 8),
        if (equippedItems.isNotEmpty)
          ...equippedItems.map((item) {
            final equipment = item!.equipment;
            if (equipment == null) return const SizedBox.shrink();
            
            return _buildStatRow(
              equipment.name,
              '+${item.enhanceLevel}',
              _getEquipmentRarityColor(equipment.rarity),
            );
          }).toList(),
      ],
    );
  }

  Color _getRealmColor(int level) {
    if (level <= 2) return Colors.grey;
    if (level <= 5) return Colors.blue;
    if (level <= 9) return Colors.purple;
    if (level <= 15) return Colors.orange;
    return Colors.red;
  }

  Color _getEquipmentRarityColor(rarity) {
    // 这里需要根据装备稀有度返回颜色
    // 由于我没有看到Equipment的rarity定义，使用默认颜色
    return Colors.cyan;
  }

  String _getAchievementTypeName(AchievementType type) {
    switch (type) {
      case AchievementType.cultivation:
        return '修炼成就';
      case AchievementType.combat:
        return '战斗成就';
      case AchievementType.technique:
        return '功法成就';
      case AchievementType.equipment:
        return '装备成就';
      case AchievementType.general:
        return '通用成就';
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

  String _formatNumber(num number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
