import 'package:flutter/material.dart';
import '../models/technique.dart';

class TechniqueCard extends StatelessWidget {
  final Technique? technique;
  final LearnedTechnique? learnedTechnique;
  final bool isLearned;
  final bool canAfford;
  final VoidCallback? onLearn;
  final VoidCallback? onUpgrade;

  const TechniqueCard({
    super.key,
    this.technique,
    this.learnedTechnique,
    required this.isLearned,
    this.canAfford = true,
    this.onLearn,
    this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final tech = technique ?? learnedTechnique?.technique;
    if (tech == null) return const SizedBox.shrink();

    return Card(
      color: const Color(0xFF0f3460),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 功法名称和稀有度
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tech.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getRarityColor(tech.rarity),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getTypeColor(tech.type),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getTypeText(tech.type),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getRarityColor(tech.rarity).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getRarityColor(tech.rarity),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _getRarityText(tech.rarity),
                              style: TextStyle(
                                fontSize: 12,
                                color: _getRarityColor(tech.rarity),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isLearned && learnedTechnique != null) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Lv.${learnedTechnique!.level}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      Text(
                        '${learnedTechnique!.level}/${tech.maxLevel}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 功法描述
            Text(
              tech.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // 功法效果
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a2e),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '功法效果',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isLearned && learnedTechnique != null) ...[
                    ...learnedTechnique!.getCurrentEffects().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _getEffectName(entry.key),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              _formatEffectValue(entry.key, entry.value),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    ...tech.baseEffects.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _getEffectName(entry.key),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              _formatEffectValue(entry.key, entry.value),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // 升级进度条（仅已学会的功法显示）
            if (isLearned && learnedTechnique != null && learnedTechnique!.level < tech.maxLevel) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '升级进度',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        '${learnedTechnique!.experience}/${learnedTechnique!.expToNextLevel}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: learnedTechnique!.levelProgress,
                    backgroundColor: const Color(0xFF1a1a2e),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                    minHeight: 6,
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            
            // 操作按钮
            Row(
              children: [
                if (!isLearned) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: canAfford ? onLearn : null,
                      icon: const Icon(Icons.school, size: 16),
                      label: Text('学习 (${tech.baseCost} 修炼点)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canAfford 
                            ? const Color(0xFFe94560) 
                            : Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ] else if (learnedTechnique != null && learnedTechnique!.level < tech.maxLevel) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onUpgrade,
                      icon: const Icon(Icons.upgrade, size: 16),
                      label: Text('升级 (${tech.baseCost * (tech.levelCostMultiplier * learnedTechnique!.level)} 修炼点)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0f4c75),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 16),
                          SizedBox(width: 8),
                          Text(
                            '已满级',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRarityColor(TechniqueRarity rarity) {
    switch (rarity) {
      case TechniqueRarity.common:
        return Colors.grey;
      case TechniqueRarity.rare:
        return Colors.blue;
      case TechniqueRarity.epic:
        return Colors.purple;
      case TechniqueRarity.legendary:
        return Colors.orange;
      case TechniqueRarity.mythic:
        return Colors.red;
    }
  }

  String _getRarityText(TechniqueRarity rarity) {
    switch (rarity) {
      case TechniqueRarity.common:
        return '普通';
      case TechniqueRarity.rare:
        return '稀有';
      case TechniqueRarity.epic:
        return '史诗';
      case TechniqueRarity.legendary:
        return '传说';
      case TechniqueRarity.mythic:
        return '神话';
    }
  }

  Color _getTypeColor(TechniqueType type) {
    switch (type) {
      case TechniqueType.cultivation:
        return Colors.green;
      case TechniqueType.combat:
        return Colors.red;
      case TechniqueType.support:
        return Colors.blue;
    }
  }

  String _getTypeText(TechniqueType type) {
    switch (type) {
      case TechniqueType.cultivation:
        return '修炼';
      case TechniqueType.combat:
        return '战斗';
      case TechniqueType.support:
        return '辅助';
    }
  }

  String _getEffectName(String key) {
    switch (key) {
      case 'cultivation_speed':
        return '修炼速度';
      case 'exp_bonus':
        return '经验加成';
      case 'mana_regen':
        return '法力恢复';
      case 'health_regen':
        return '生命恢复';
      case 'damage_multiplier':
        return '伤害倍率';
      case 'defense_multiplier':
        return '防御倍率';
      case 'health_multiplier':
        return '生命倍率';
      case 'mana_cost':
        return '法力消耗';
      case 'burn_damage':
        return '燃烧伤害';
      case 'damage_reduction':
        return '伤害减免';
      default:
        return key;
    }
  }

  String _formatEffectValue(String key, double value) {
    switch (key) {
      case 'cultivation_speed':
      case 'mana_regen':
      case 'health_regen':
      case 'damage_multiplier':
      case 'defense_multiplier':
      case 'health_multiplier':
        return '${(value * 100).toInt()}%';
      case 'exp_bonus':
      case 'burn_damage':
      case 'damage_reduction':
        return '+${(value * 100).toInt()}%';
      case 'mana_cost':
        return '${value.toInt()}';
      default:
        return value.toString();
    }
  }
}
