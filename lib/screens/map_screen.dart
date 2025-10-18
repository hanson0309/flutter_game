import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/map_area.dart';
import '../services/map_service.dart';
import '../widgets/swipe_back_wrapper.dart';
import 'battle_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late AnimationController _playerAnimationController;
  late AnimationController _enemyAnimationController;
  late Animation<double> _playerPulseAnimation;
  late TransformationController _transformationController;
  
  bool _showAreaSelection = false; // 默认直接进入地图，不显示选择界面
  Timer? _autoResumeTimer; // 自动恢复巡逻定时器
  bool _hasInitialCentered = false; // 是否已经初始居中
  
  // 地图尺寸倍数（比屏幕大多少倍）
  static const double _mapSizeMultiplier = 3.0;

  @override
  void initState() {
    super.initState();
    
    _transformationController = TransformationController();
    
    _playerAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _enemyAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _playerPulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _playerAnimationController, curve: Curves.easeInOut),
    );

    // 设置自动战斗触发回调
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mapService = Provider.of<MapService>(context, listen: false);
      mapService.onAutoBattleTriggered = _onAutoBattleTriggered;
      
      // 自动进入默认地图区域（新手森林）
      if (mapService.currentMapState == null) {
        mapService.enterArea('newbie_forest');
      }
    });
  }

  // 让地图跟随玩家移动
  void _centerMapOnPlayer(MapPosition playerPosition, MapArea area) {
    final screenSize = MediaQuery.of(context).size;
    final mapWidth = screenSize.width * _mapSizeMultiplier;
    final mapHeight = (screenSize.height - 200) * _mapSizeMultiplier;
    
    // 计算玩家在地图上的像素位置
    final playerX = (playerPosition.x / area.width) * mapWidth;
    final playerY = (playerPosition.y / area.height) * mapHeight;
    
    // 计算需要的平移量，让玩家位于屏幕中心
    final translateX = screenSize.width / 2 - playerX;
    final translateY = (screenSize.height - 200) / 2 - playerY;
    
    // 创建变换矩阵
    final matrix = Matrix4.identity()
      ..translate(translateX, translateY);
    
    _transformationController.value = matrix;
  }

  @override
  void dispose() {
    _autoResumeTimer?.cancel();
    _transformationController.dispose();
    _playerAnimationController.dispose();
    _enemyAnimationController.dispose();
    super.dispose();
  }

  // 自动战斗触发回调
  void _onAutoBattleTriggered(List<String> enemyIds) {
    if (!mounted) return;
    
    // 停止自动探索
    final mapService = Provider.of<MapService>(context, listen: false);
    mapService.stopAutoExplore();
    
    // 启动战斗
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BattleScreen(enemyIds: enemyIds),
      ),
    ).then((_) {
      // 战斗结束后可以选择重新开始自动探索
      if (mounted) {
        _showAutoExploreDialog();
      }
    });
  }

  // 显示自动探索对话框
  void _showAutoExploreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Text('继续探索？', style: TextStyle(color: Colors.white)),
        content: const Text(
          '是否继续自动探索寻找敌人？',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('手动探索', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              final mapService = Provider.of<MapService>(context, listen: false);
              mapService.startAutoExplore();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('继续自动探索'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SwipeBackScaffold(
      appBar: AppBar(
        title: Consumer<MapService>(
          builder: (context, mapService, child) {
            if (mapService.currentMapState == null) {
              return const Text('地图探索');
            }
            final area = MapArea.predefinedAreas.firstWhere(
              (a) => a.id == mapService.currentMapState!.currentAreaId
            );
            return Text(area.name);
          },
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Consumer<MapService>(
        builder: (context, mapService, child) {
          if (_showAreaSelection || mapService.currentMapState == null) {
            return _buildAreaSelection(mapService);
          }
          
          // 进入地图时自动居中到玩家位置（只执行一次）
          if (!_hasInitialCentered) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mapService.currentMapState != null && !_hasInitialCentered) {
                final area = MapArea.predefinedAreas.firstWhere(
                  (a) => a.id == mapService.currentMapState!.currentAreaId
                );
                _centerMapOnPlayer(mapService.currentMapState!.playerPosition, area);
                _hasInitialCentered = true;
              }
            });
          }
          
          return _buildMapView(mapService);
        },
      ),
    );
  }

  // 构建区域选择界面
  Widget _buildAreaSelection(MapService mapService) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1B5E20),
            Color(0xFF2E7D32),
            Color(0xFF388E3C),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              '选择探索区域',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: MapArea.predefinedAreas.length,
                itemBuilder: (context, index) {
                  final area = MapArea.predefinedAreas[index];
                  return _buildAreaCard(area, mapService);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建区域卡片
  Widget _buildAreaCard(MapArea area, MapService mapService) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: InkWell(
        onTap: () {
          setState(() {
            _showAreaSelection = false;
            _hasInitialCentered = false; // 重置居中标志，新地图需要重新居中
          });
          mapService.enterArea(area.id);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getAreaIcon(area.id),
                    size: 32,
                    color: _getAreaColor(area.id),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          area.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          area.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoChip('等级', '${area.minEnemyLevel}-${area.maxEnemyLevel}', Colors.orange),
                  const SizedBox(width: 8),
                  _buildInfoChip('敌人', '最多${area.maxEnemyCount}个', Colors.red),
                  const SizedBox(width: 8),
                  _buildInfoChip('范围', '${area.enemyDetectionRange.toInt()}m', Colors.blue),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建信息标签
  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 构建地图视图
  Widget _buildMapView(MapService mapService) {
    final mapState = mapService.currentMapState!;
    final area = MapArea.predefinedAreas.firstWhere((a) => a.id == mapState.currentAreaId);
    final screenSize = MediaQuery.of(context).size;
    
    // 计算实际地图尺寸
    final mapWidth = screenSize.width * _mapSizeMultiplier;
    final mapHeight = (screenSize.height - 200) * _mapSizeMultiplier; // 减去状态面板高度

    return Stack(
      children: [
        // 可交互的地图视图
        InteractiveViewer(
          transformationController: _transformationController,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 3.0,
          constrained: false,
          child: Container(
            width: mapWidth,
            height: mapHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _getAreaGradientColors(area.id),
              ),
            ),
            child: Stack(
              children: [
                // 地图背景网格
                _buildMapGrid(area, mapWidth, mapHeight),
                
                // 地图内容
                GestureDetector(
                  onTapDown: (details) {
                    if (!mapService.isAutoExploring) {
                      _handleMapTap(details, area, mapService, mapWidth, mapHeight);
                    }
                  },
                  child: Container(
                    width: mapWidth,
                    height: mapHeight,
                    child: Stack(
                      children: [
                        // 敌人
                        ...mapState.enemies.where((e) => e.isAlive).map((enemy) {
                          return _buildEnemyMarker(enemy, area, mapWidth, mapHeight);
                        }).toList(),
                        
                        // 玩家
                        _buildPlayerMarker(mapState.playerPosition, area, mapWidth, mapHeight),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // 换地图按钮
        Positioned(
          right: 20,
          top: 100,
          child: FloatingActionButton.small(
            onPressed: () {
              setState(() {
                _showAreaSelection = true;
                _hasInitialCentered = false; // 重置居中标志
              });
              mapService.exitArea();
            },
            backgroundColor: Colors.green.withOpacity(0.8),
            child: const Icon(Icons.map, color: Colors.white),
          ),
        ),
        
        // 居中按钮
        Positioned(
          right: 20,
          top: 160,
          child: FloatingActionButton.small(
            onPressed: () => _centerMapOnPlayer(mapState.playerPosition, area),
            backgroundColor: Colors.blue.withOpacity(0.8),
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        ),
        
        // 方向轮盘
        _buildDirectionPad(mapService, area),
      ],
    );
  }

  // 构建地图网格
  Widget _buildMapGrid(MapArea area, double mapWidth, double mapHeight) {
    return CustomPaint(
      size: Size(mapWidth, mapHeight),
      painter: MapGridPainter(area),
    );
  }

  // 构建玩家标记
  Widget _buildPlayerMarker(MapPosition position, MapArea area, double mapWidth, double mapHeight) {
    final x = (position.x / area.width) * mapWidth;
    final y = (position.y / area.height) * mapHeight;

    return Positioned(
      left: x - 25,
      top: y - 25,
      child: AnimatedBuilder(
        animation: _playerPulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _playerPulseAnimation.value,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 32,
              ),
            ),
          );
        },
      ),
    );
  }

  // 构建敌人标记
  Widget _buildEnemyMarker(MapEnemy enemy, MapArea area, double mapWidth, double mapHeight) {
    final x = (enemy.position.x / area.width) * mapWidth;
    final y = (enemy.position.y / area.height) * mapHeight;

    return Positioned(
      left: x - 20,
      top: y - 20,
      child: AnimatedBuilder(
        animation: _enemyAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.8 + _enemyAnimationController.value * 0.2,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getEnemyTypeColor(enemy.type),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: _getEnemyTypeColor(enemy.type).withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _getEnemyTypeIcon(enemy.type),
                color: Colors.white,
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }


  // 构建方向轮盘（拖拽摇杆）
  Widget _buildDirectionPad(MapService mapService, MapArea area) {
    return Positioned(
      left: 20,
      bottom: 20,
      child: _JoystickWidget(
        onDirectionChanged: (dx, dy) => _movePlayerWithJoystick(mapService, area, dx, dy),
        onStop: () {
          mapService.stopAutoExplore();
          _startAutoResumeTimer(mapService);
        },
      ),
    );
  }

  // 启动自动恢复巡逻定时器
  void _startAutoResumeTimer(MapService mapService) {
    _autoResumeTimer?.cancel();
    _autoResumeTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && !mapService.isAutoExploring) {
        mapService.startAutoExplore();
        debugPrint('🤖 2秒后自动恢复巡逻');
      }
    });
  }

  // 摇杆控制玩家移动
  void _movePlayerWithJoystick(MapService mapService, MapArea area, double dx, double dy) {
    if (mapService.currentMapState == null) return;
    
    final currentPos = mapService.currentMapState!.playerPosition;
    final moveSpeed = 2.0; // 降低摇杆移动速度，减少抖动
    
    final newPosition = MapPosition(
      x: (currentPos.x + dx * moveSpeed).clamp(0, area.width),
      y: (currentPos.y + dy * moveSpeed).clamp(0, area.height),
    );
    
    // 停止自动探索，手动控制
    mapService.stopAutoExplore();
    
    // 直接移动玩家（标记为手动控制）
    mapService.movePlayer(newPosition, isManual: true);
    
    // 重新启动自动恢复定时器
    _startAutoResumeTimer(mapService);
  }

  // 处理地图点击
  void _handleMapTap(TapDownDetails details, MapArea area, MapService mapService, double mapWidth, double mapHeight) {
    final tapX = details.localPosition.dx;
    final tapY = details.localPosition.dy;

    // 转换为地图坐标
    final mapX = (tapX / mapWidth) * area.width;
    final mapY = (tapY / mapHeight) * area.height;

    final newPosition = MapPosition(x: mapX, y: mapY);
    
    // 停止自动探索，手动控制
    mapService.stopAutoExplore();
    mapService.movePlayer(newPosition, isManual: true);
    
    // 启动自动恢复定时器
    _startAutoResumeTimer(mapService);
  }

  // 辅助方法
  IconData _getAreaIcon(String areaId) {
    switch (areaId) {
      case 'newbie_forest':
        return Icons.forest;
      case 'dark_valley':
        return Icons.landscape;
      case 'ancient_ruins':
        return Icons.account_balance;
      default:
        return Icons.map;
    }
  }

  Color _getAreaColor(String areaId) {
    switch (areaId) {
      case 'newbie_forest':
        return Colors.green;
      case 'dark_valley':
        return Colors.purple;
      case 'ancient_ruins':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  List<Color> _getAreaGradientColors(String areaId) {
    switch (areaId) {
      case 'newbie_forest':
        return [const Color(0xFF1B5E20), const Color(0xFF2E7D32), const Color(0xFF4CAF50)];
      case 'dark_valley':
        return [const Color(0xFF4A148C), const Color(0xFF6A1B9A), const Color(0xFF8E24AA)];
      case 'ancient_ruins':
        return [const Color(0xFFE65100), const Color(0xFFFF9800), const Color(0xFFFFC107)];
      default:
        return [Colors.grey.shade800, Colors.grey.shade600, Colors.grey.shade400];
    }
  }

  Color _getEnemyTypeColor(String type) {
    switch (type) {
      case 'beast':
        return Colors.brown;
      case 'demon':
        return Colors.red;
      case 'spirit':
        return Colors.cyan;
      case 'undead':
        return Colors.purple;
      case 'cultivator':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getEnemyTypeIcon(String type) {
    switch (type) {
      case 'beast':
        return Icons.pets;
      case 'demon':
        return Icons.whatshot;
      case 'spirit':
        return Icons.blur_on;
      case 'undead':
        return Icons.dangerous;
      case 'cultivator':
        return Icons.person;
      default:
        return Icons.help;
    }
  }
}

// 地图网格绘制器
class MapGridPainter extends CustomPainter {
  final MapArea area;

  MapGridPainter(this.area);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 0.5;

    final gridSize = 50.0;
    final horizontalLines = (size.height / gridSize).ceil();
    final verticalLines = (size.width / gridSize).ceil();

    // 绘制水平线
    for (int i = 0; i <= horizontalLines; i++) {
      final y = i * gridSize;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // 绘制垂直线
    for (int i = 0; i <= verticalLines; i++) {
      final x = i * gridSize;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 摇杆控制Widget
class _JoystickWidget extends StatefulWidget {
  final Function(double dx, double dy) onDirectionChanged;
  final VoidCallback onStop;

  const _JoystickWidget({
    required this.onDirectionChanged,
    required this.onStop,
  });

  @override
  State<_JoystickWidget> createState() => _JoystickWidgetState();
}

class _JoystickWidgetState extends State<_JoystickWidget> {
  Offset _knobPosition = Offset.zero;
  bool _isDragging = false;
  Timer? _moveTimer;
  
  static const double _joystickSize = 120.0;
  static const double _knobSize = 40.0;
  static const double _maxDistance = (_joystickSize - _knobSize) / 2;

  @override
  void dispose() {
    _moveTimer?.cancel();
    super.dispose();
  }

  void _startMoving() {
    _moveTimer?.cancel();
    _moveTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isDragging && _knobPosition != Offset.zero) {
        final distance = _knobPosition.distance;
        if (distance > 8) { // 增大死区，避免微小移动
          final normalizedX = _knobPosition.dx / _maxDistance;
          final normalizedY = _knobPosition.dy / _maxDistance;
          widget.onDirectionChanged(normalizedX, normalizedY);
        }
      }
    });
  }

  void _stopMoving() {
    _moveTimer?.cancel();
    widget.onStop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          _isDragging = true;
        });
        _startMoving();
      },
      onPanUpdate: (details) {
        if (_isDragging) {
          final center = Offset(_joystickSize / 2, _joystickSize / 2);
          final localPosition = details.localPosition - center;
          final distance = localPosition.distance;
          
          setState(() {
            if (distance <= _maxDistance) {
              _knobPosition = localPosition;
            } else {
              // 限制在最大距离内
              _knobPosition = localPosition * (_maxDistance / distance);
            }
          });
        }
      },
      onPanEnd: (details) {
        setState(() {
          _isDragging = false;
          _knobPosition = Offset.zero;
        });
        _stopMoving();
      },
      child: Container(
        width: _joystickSize,
        height: _joystickSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.3),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
        ),
        child: Stack(
          children: [
            // 摇杆旋钮
            Positioned(
              left: _joystickSize / 2 - _knobSize / 2 + _knobPosition.dx,
              top: _joystickSize / 2 - _knobSize / 2 + _knobPosition.dy,
              child: Container(
                width: _knobSize,
                height: _knobSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isDragging ? Colors.blue : Colors.blue.withOpacity(0.8),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.control_camera,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
