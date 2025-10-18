import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/image_assets.dart';
import '../screens/technique_screen.dart';
import '../screens/task_screen.dart';
import '../screens/achievement_screen.dart';
import 'shop_screen.dart';
import 'settings_screen.dart';
import 'character_info_screen.dart';
import 'map_screen.dart';
import '../services/audio_service.dart';

class YinianGameScreen extends StatefulWidget {
  const YinianGameScreen({super.key});

  @override
  State<YinianGameScreen> createState() => _YinianGameScreenState();
}

class _YinianGameScreenState extends State<YinianGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _expFloatController;
  late Animation<double> _floatingAnimation;
  late Animation<double> _expFloatAnimation;
  
  String _floatingExpText = '';
  bool _showFloatingExp = false;
  Timer? _expDisplayTimer;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _expFloatController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _floatingAnimation = Tween<double>(begin: -3, end: 3).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
    
    _expFloatAnimation = Tween<double>(begin: 0, end: -50).animate(
      CurvedAnimation(parent: _expFloatController, curve: Curves.easeOut),
    );
    
    // 启动自动显示经验值定时器
    _startExpDisplayTimer();
    
    // 不自动播放音乐，等待用户点击音乐按钮启动
  }
  
  void _startExpDisplayTimer() {
    _expDisplayTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _showAutoExpGain();
    });
  }
  
  void _showAutoExpGain() async {
    if (!mounted) return;
    
    // 获取当前玩家的经验值增长
    final gameProvider = context.read<GameProvider>();
    final player = gameProvider.player;
    if (player != null) {
      // 根据境界计算基础经验值
      int baseExp;
      switch (player.currentRealm.level) {
        case 0: // 凡人
          baseExp = 5;
          break;
        case 1: // 练气期
          baseExp = 12;
          break;
        case 2: // 筑基期
          baseExp = 25;
          break;
        case 3: // 金丹期
          baseExp = 50;
          break;
        case 4: // 元婴期
          baseExp = 100;
          break;
        case 5: // 化神期
          baseExp = 200;
          break;
        default:
          baseExp = 10;
      }
      
      // 加上等级加成
      baseExp += (player.level * 3);
      
      // 应用经验加成倍数
      final actualExp = (baseExp * player.expBonusMultiplier).round();
      
      setState(() {
        _floatingExpText = '+$actualExp EXP';
        _showFloatingExp = true;
      });
      
      _expFloatController.reset();
      await _expFloatController.forward();
      
      if (mounted) {
        setState(() {
          _showFloatingExp = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _expFloatController.dispose();
    _expDisplayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImageAssets.cultivationChamber),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 顶部资源栏
              _buildTopBar(),
              
              // 主游戏区域
              Expanded(
                child: _buildMainGameArea(),
              ),
              
              // 底部属性面板
              _buildBottomAttributePanel(),
              
              // 底部导航栏
              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final player = gameProvider.player;
        if (player == null) return const SizedBox(height: 60);
        
        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // 左侧角色信息按钮
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CharacterInfoScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 28,
                ),
                tooltip: '角色信息',
              ),
              
              const Spacer(),
              
              // 右侧功能按钮
              Row(
                children: [
                  Consumer<AudioService>(
                    builder: (context, audioService, child) {
                      return IconButton(
                        onPressed: () {
                          // 启动音效系统（需要用户交互）
                          audioService.playGameplayMusic();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(audioService.hasUserInteracted 
                                ? '🎵 音乐已启动' 
                                : '🎵 音效系统已启动'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: Icon(
                          audioService.hasUserInteracted 
                            ? Icons.volume_up 
                            : Icons.volume_off,
                          color: audioService.hasUserInteracted 
                            ? Colors.green 
                            : Colors.white,
                        ),
                        tooltip: audioService.hasUserInteracted 
                          ? '音乐已启动' 
                          : '点击启动音乐',
                      );
                    },
                  ),
                  IconButton(
                    onPressed: () => _navigateToScreen(const SettingsScreen()),
                    icon: const Icon(Icons.settings, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildMainGameArea() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final player = gameProvider.player;
        if (player == null) return const Center(child: CircularProgressIndicator());
        
        return Stack(
          children: [
            // 中央战斗区域
            _buildCenterBattleArea(),
            
            // 浮动伤害数字
            _buildFloatingDamageNumbers(),
            
            // 境界信息面板
            _buildRealmInfoPanel(),
          ],
        );
      },
    );
  }


  Widget _buildCenterBattleArea() {
    return Center(
      child: Stack(
        children: [
          // 中央修仙角色 - 放置在石盘上
          Positioned(
            bottom: 100, // 调整垂直位置，让人物坐在石盘上
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatingAnimation.value * 2), // 轻微浮动
                  child: _buildTransparentCharacter(),
                );
              },
            ),
          ),
          
          // 浮动经验值
          if (_showFloatingExp)
            Center(
              child: AnimatedBuilder(
                animation: _expFloatAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _expFloatAnimation.value),
                    child: Opacity(
                      opacity: 1 - _expFloatController.value,
                      child: Text(
                        _floatingExpText,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // 构建完全透明的人物角色
  Widget _buildTransparentCharacter() {
    return SizedBox(
      width: 300, // 调整大小以适配石盘
      height: 300,
      child: Image.asset(
        ImageAssets.cultivator,
        width: 300,
        height: 300,
        fit: BoxFit.contain, // 保持比例，不裁剪
        errorBuilder: (context, error, stackTrace) {
          // 如果图片加载失败，显示一个透明的图标
          return Container(
            width: 300,
            height: 300,
            child: Icon(
              Icons.person,
              size: 150,
              color: Colors.blue.withOpacity(0.5),
            ),
          );
        },
      ),
    );
  }


  Widget _buildFloatingDamageNumbers() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return const SizedBox.shrink(); // 删除所有浮动伤害数字
      },
    );
  }

  Widget _buildRealmInfoPanel() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final player = gameProvider.player;
        if (player == null) return const SizedBox.shrink();
        
        return Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withOpacity(0.7), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 当前境界
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${player.currentRealm.name}',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                
                // 经验进度
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: player.currentExp / player.currentRealm.maxExp,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                
                // 经验数值
                Text(
                  '${player.currentExp}/${player.currentRealm.maxExp}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomAttributePanel() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final player = gameProvider.player;
        if (player == null) return const SizedBox.shrink();
        
        return Container(
          height: 140,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // 顶部信息栏
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${(player.totalPower + gameProvider.equipmentAttackBonus + gameProvider.equipmentDefenseBonus).toInt()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    const Spacer(),
                  ],
                ),
              ),
              
              // 属性列表
              Expanded(
                child: ListView(
                  children: [
                    _buildAttributeRow(
                      Icons.flash_on,
                      '攻击力',
                      'Lv.${player.level}',
                      '${(player.actualAttack + gameProvider.equipmentAttackBonus).toInt()}',
                    ),
                    _buildAttributeRow(
                      Icons.favorite,
                      '气血',
                      'Lv.${player.level}',
                      '${player.currentHealth.toInt()}/${(player.actualMaxHealth + gameProvider.equipmentHealthBonus).toInt()}',
                    ),
                    _buildAttributeRow(
                      Icons.shield,
                      '防御力',
                      'Lv.${player.level}',
                      '${(player.actualDefense + gameProvider.equipmentDefenseBonus).toInt()}',
                    ),
                    _buildAttributeRow(
                      Icons.auto_fix_high,
                      '法力值',
                      'Lv.${player.level}',
                      '${player.currentMana.toInt()}/${(player.actualMaxMana + gameProvider.equipmentManaBonus).toInt()}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttributeRow(
    IconData icon,
    String title,
    String level,
    String value,
  ) {
    return Container(
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Icon(icon, color: Colors.amber, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(width: 8),
          Text(
            level,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.5)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.task_alt, '任务', () => _navigateToScreen(const TaskScreen())),
          _buildNavItem(Icons.book, '功法', () => _navigateToScreen(const TechniqueScreen())),
          _buildNavItem(Icons.sports_martial_arts, '战斗', () => _navigateToScreen(const MapScreen())),
          _buildNavItem(Icons.emoji_events, '成就', () => _navigateToScreen(const AchievementScreen())),
          _buildNavItem(Icons.store, '商店', () => _navigateToScreen(const ShopScreen())),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          print('导航按钮 $label 被点击了！');
          onTap();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _navigateToScreen(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

}
