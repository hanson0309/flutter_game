import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/technique.dart';
// import '../services/technique_service.dart'; // 临时注释掉，文件不存在
import '../providers/game_provider.dart';
import '../widgets/swipe_back_wrapper.dart';

class TechniqueScreen extends StatefulWidget {
  const TechniqueScreen({super.key});

  @override
  State<TechniqueScreen> createState() => _TechniqueScreenState();
}

class _TechniqueScreenState extends State<TechniqueScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SwipeBackScaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text(
          '功法秘籍',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF16213e),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFe94560),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: '已学功法'),
            Tab(text: '可学功法'),
            Tab(text: '功法商店'),
          ],
        ),
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          final player = gameProvider.player!;
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildLearnedTechniques(player),
              _buildAvailableTechniques(player, gameProvider),
              _buildTechniqueShop(player, gameProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLearnedTechniques(player) {
    if (player.learnedTechniques.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: Colors.white54,
            ),
            SizedBox(height: 16),
            Text(
              '还没有学会任何功法',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white54,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '去功法商店学习一些基础功法吧！',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: player.learnedTechniques.length,
      itemBuilder: (context, index) {
        final learnedTech = player.learnedTechniques[index];
        final technique = Technique.availableTechniques.firstWhere(
          (t) => t.id == learnedTech.techniqueId,
          orElse: () => Technique.availableTechniques.first,
        );
        return Card(
          color: const Color(0xFF2a2a3e),
          child: ListTile(
            title: Text(technique.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  technique.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '等级: ${learnedTech.level}/${technique.maxLevel} | ${_getTechniqueRarityName(technique.rarity)}',
                  style: const TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
            trailing: learnedTech.level < technique.maxLevel 
                ? ElevatedButton(
                    onPressed: () => _upgradeTechnique(technique.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('升级'),
                  )
                : const Icon(Icons.check_circle, color: Colors.green),
            onTap: () => _showTechniqueDetails(technique),
          ),
        );
      },
    );
  }

  Widget _buildAvailableTechniques(player, GameProvider gameProvider) {
    final availableTechniques = Technique.availableTechniques
        .where((tech) => !player.hasLearnedTechnique(tech.id))
        .toList();

    if (availableTechniques.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.green,
            ),
            SizedBox(height: 16),
            Text(
              '已学会所有功法！',
              style: TextStyle(
                fontSize: 18,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '你已经掌握了所有的功法秘籍',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: availableTechniques.length,
      itemBuilder: (context, index) {
        final technique = availableTechniques[index];
        return Card(
          color: const Color(0xFF2a2a3e),
          child: ListTile(
            title: Text(technique.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  technique.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '消耗: ${technique.baseCost} 修炼点 | ${_getTechniqueRarityName(technique.rarity)}',
                  style: const TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () => _learnTechnique(technique.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFe94560),
                foregroundColor: Colors.white,
              ),
              child: const Text('学习'),
            ),
            onTap: () => _showTechniqueDetails(technique),
          ),
        );
      },
    );
  }

  Widget _buildTechniqueShop(player, GameProvider gameProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 资源显示
          Card(
            color: const Color(0xFF0f3460),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildResourceDisplay(
                    '修炼点',
                    player.cultivationPoints.toString(),
                    Icons.star,
                    Colors.amber,
                  ),
                  _buildResourceDisplay(
                    '灵石',
                    player.spiritStones.toString(),
                    Icons.diamond,
                    Colors.blue,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 功法分类
          _buildTechniqueCategory('修炼功法', TechniqueType.cultivation, player),
          const SizedBox(height: 16),
          _buildTechniqueCategory('战斗技能', TechniqueType.combat, player),
          const SizedBox(height: 16),
          _buildTechniqueCategory('辅助技能', TechniqueType.support, player),
        ],
      ),
    );
  }

  Widget _buildResourceDisplay(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTechniqueCategory(String title, TechniqueType type, player) {
    final techniques = Technique.availableTechniques
        .where((tech) => tech.type == type)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        ...techniques.map((technique) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Card(
            color: const Color(0xFF2a2a3e),
            child: ListTile(
              title: Text(technique.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    technique.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '消耗: ${technique.baseCost} 修炼点 | ${_getTechniqueRarityName(technique.rarity)}',
                    style: const TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () => _learnTechnique(technique.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFe94560),
                  foregroundColor: Colors.white,
                ),
                child: const Text('学习'),
              ),
              onTap: () => _showTechniqueDetails(technique),
            ),
          ),
        )),
      ],
    );
  }

  void _learnTechnique(String techniqueId) {
    final gameProvider = context.read<GameProvider>();
    final player = gameProvider.player!;
    
    if (player.learnTechnique(techniqueId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('成功学会 ${Technique.getTechniqueById(techniqueId)?.name}！'),
          backgroundColor: Colors.green,
        ),
      );
      gameProvider.saveGameData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('学习失败，修炼点不足或已学会该功法'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _upgradeTechnique(String techniqueId) {
    final gameProvider = context.read<GameProvider>();
    final player = gameProvider.player!;
    
    // 升级功法的逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('功法升级功能开发中...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showTechniqueDetails(Technique technique) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2a2a3e),
          title: Text(
            technique.name,
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                technique.description,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Text(
                '类型: ${_getTechniqueTypeName(technique.type)}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                '稀有度: ${_getTechniqueRarityName(technique.rarity)}',
                style: const TextStyle(color: Colors.orange),
              ),
              Text(
                '消耗: ${technique.baseCost} 修炼点',
                style: const TextStyle(color: Colors.green),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('关闭', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _learnTechnique(technique.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFe94560),
              ),
              child: const Text('学习'),
            ),
          ],
        );
      },
    );
  }

  String _getTechniqueTypeName(TechniqueType type) {
    switch (type) {
      case TechniqueType.cultivation:
        return '修炼功法';
      case TechniqueType.combat:
        return '战斗技能';
      case TechniqueType.support:
        return '辅助技能';
    }
  }

  String _getTechniqueRarityName(TechniqueRarity rarity) {
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
}
