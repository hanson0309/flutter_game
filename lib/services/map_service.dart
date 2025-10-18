import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/map_area.dart';
import 'battle_service.dart';

class MapService extends ChangeNotifier {
  MapState? _currentMapState;
  Timer? _enemySpawnTimer;
  Timer? _enemyRespawnTimer;
  final BattleService _battleService;
  final Random _random = Random();

  // 自动战斗相关
  bool _isAutoExploring = false;
  Timer? _autoExploreTimer;
  Function(List<String>)? onAutoBattleTriggered;

  // 平滑移动相关
  bool _isSmoothMoving = false;
  bool _isManualControl = false; // 手动控制标志
  Timer? _smoothMoveTimer;
  MapPosition? _targetPosition;
  double _moveSpeed = 1.8; // 每次移动的像素数

  // 敌人移动相关
  Timer? _enemyMoveTimer;
  Timer? _enemySmoothMoveTimer;
  Map<String, MapPosition> _enemyTargets = {}; // 存储每个敌人的目标位置

  MapService(this._battleService);

  MapState? get currentMapState => _currentMapState;
  bool get isAutoExploring => _isAutoExploring;

  // 进入地图区域
  void enterArea(String areaId, {MapPosition? startPosition}) {
    final area = MapArea.predefinedAreas.firstWhere(
      (a) => a.id == areaId,
      orElse: () => MapArea.predefinedAreas.first,
    );

    final playerPos = startPosition ?? MapPosition(
      x: area.width / 2,
      y: area.height / 2,
    );

    _currentMapState = MapState(
      currentAreaId: areaId,
      playerPosition: playerPos,
      enemies: [],
      lastUpdate: DateTime.now(),
    );

    // 生成初始敌人
    _generateInitialEnemies(area);
    
    // 启动敌人生成定时器
    _startEnemySpawnTimer(area);
    
    // 启动敌人复活定时器
    _startEnemyRespawnTimer(area);

    // 启动敌人移动定时器
    _startEnemyMoveTimer(area);

    // 启动敌人平滑移动定时器
    _startEnemySmoothMoveTimer();

    // 自动开始巡逻
    startAutoExplore();

    notifyListeners();
    debugPrint('🗺️ 进入地图区域: ${area.name}');
  }

  // 离开当前地图区域
  void exitArea() {
    _stopAllTimers();
    _currentMapState = null;
    notifyListeners();
    debugPrint('🗺️ 离开地图区域');
  }

  // 移动玩家位置
  void movePlayer(MapPosition newPosition, {bool isManual = false}) {
    if (_currentMapState == null) return;

    final area = _getCurrentArea();
    if (area == null) return;

    // 如果是手动控制，停止平滑移动
    if (isManual) {
      _isManualControl = true;
      _stopSmoothMove();
    }

    // 限制玩家在地图边界内
    final clampedPosition = MapPosition(
      x: newPosition.x.clamp(0, area.width),
      y: newPosition.y.clamp(0, area.height),
    );

    _currentMapState = _currentMapState!.copyWith(
      playerPosition: clampedPosition,
      lastUpdate: DateTime.now(),
    );

    // 检查是否触发战斗
    _checkForBattleTrigger(area);

    notifyListeners();
  }

  // 开始自动探索
  void startAutoExplore() {
    if (_currentMapState == null || _isAutoExploring) return;

    _isAutoExploring = true;
    _isManualControl = false; // 重置手动控制标志
    _autoExploreTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _performAutoExploreStep();
    });

    notifyListeners();
    debugPrint('🤖 开始自动探索');
  }

  // 停止自动探索
  void stopAutoExplore() {
    _isAutoExploring = false;
    _autoExploreTimer?.cancel();
    _autoExploreTimer = null;
    _stopSmoothMove();
    notifyListeners();
    debugPrint('🤖 停止自动探索');
  }

  // 执行自动探索步骤
  void _performAutoExploreStep() {
    if (_currentMapState == null || _isSmoothMoving) return;

    final area = _getCurrentArea();
    if (area == null) return;

    // 只进行随机移动探索，不主动寻找敌人
    _performRandomMove(area);
  }

  // 随机移动
  void _performRandomMove(MapArea area) {
    final moveDistance = 40.0 + _random.nextDouble() * 60.0; // 随机距离40-100像素
    final angle = _random.nextDouble() * 2 * pi;
    
    final targetPosition = MapPosition(
      x: _currentMapState!.playerPosition.x + cos(angle) * moveDistance,
      y: _currentMapState!.playerPosition.y + sin(angle) * moveDistance,
    );

    // 确保目标位置在地图边界内
    final clampedTarget = MapPosition(
      x: targetPosition.x.clamp(0, area.width),
      y: targetPosition.y.clamp(0, area.height),
    );

    _startSmoothMoveToTarget(clampedTarget);
  }

  // 获取到目标的方向向量
  MapPosition _getDirectionToTarget(MapPosition target, [MapPosition? from]) {
    final startPos = from ?? _currentMapState!.playerPosition;
    final dx = target.x - startPos.x;
    final dy = target.y - startPos.y;
    final distance = sqrt(dx * dx + dy * dy);
    
    if (distance == 0) return const MapPosition(x: 0, y: 0);
    
    return MapPosition(x: dx / distance, y: dy / distance);
  }


  // 检查战斗触发
  void _checkForBattleTrigger(MapArea area) {
    if (_currentMapState == null) return;

    final nearbyEnemies = _currentMapState!.enemies.where((enemy) {
      if (!enemy.isAlive) return false;
      final distance = _currentMapState!.playerPosition.distanceTo(enemy.position);
      return distance <= area.enemyDetectionRange;
    }).toList();

    if (nearbyEnemies.isNotEmpty) {
      // 触发战斗
      final enemyIds = nearbyEnemies.map((e) => e.enemyId).toList();
      
      // 将触发战斗的敌人标记为死亡
      final updatedEnemies = _currentMapState!.enemies.map((enemy) {
        if (nearbyEnemies.any((ne) => ne.id == enemy.id)) {
          return enemy.copyWith(
            isAlive: false,
            lastRespawnTime: DateTime.now(),
          );
        }
        return enemy;
      }).toList();

      _currentMapState = _currentMapState!.copyWith(
        enemies: updatedEnemies,
        lastUpdate: DateTime.now(),
      );

      // 触发战斗回调
      onAutoBattleTriggered?.call(enemyIds);
      
      debugPrint('⚔️ 触发战斗，敌人数量: ${nearbyEnemies.length}');
    }
  }

  // 生成初始敌人
  void _generateInitialEnemies(MapArea area) {
    final enemies = <MapEnemy>[];
    final enemyCount = _random.nextInt(area.maxEnemyCount ~/ 2) + area.maxEnemyCount ~/ 2;

    for (int i = 0; i < enemyCount; i++) {
      final enemy = _generateRandomEnemy(area, i);
      enemies.add(enemy);
    }

    _currentMapState = _currentMapState!.copyWith(
      enemies: enemies,
      lastUpdate: DateTime.now(),
    );

    debugPrint('🎯 生成初始敌人: $enemyCount 个');
  }

  // 生成随机敌人
  MapEnemy _generateRandomEnemy(MapArea area, int index) {
    final enemyType = area.enemyTypes[_random.nextInt(area.enemyTypes.length)];
    final level = _random.nextInt(area.maxEnemyLevel - area.minEnemyLevel + 1) + area.minEnemyLevel;
    
    // 生成随机位置，避免与玩家太近
    MapPosition position;
    int attempts = 0;
    do {
      position = MapPosition(
        x: _random.nextDouble() * area.width,
        y: _random.nextDouble() * area.height,
      );
      attempts++;
    } while (attempts < 10 && _currentMapState != null && 
             _currentMapState!.playerPosition.distanceTo(position) < area.enemyDetectionRange * 2);

    // 创建对应的战斗敌人
    final battleEnemies = _battleService.getEnemiesByArea(area.id);
    final battleEnemy = battleEnemies.isNotEmpty 
        ? battleEnemies[_random.nextInt(battleEnemies.length)]
        : null;

    return MapEnemy(
      id: 'map_enemy_${area.id}_$index',
      enemyId: battleEnemy?.id ?? 'default_enemy',
      position: position,
      level: level,
      type: enemyType,
      isAlive: true,
    );
  }

  // 启动敌人生成定时器
  void _startEnemySpawnTimer(MapArea area) {
    _enemySpawnTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _spawnNewEnemies(area);
    });
  }

  // 启动敌人复活定时器
  void _startEnemyRespawnTimer(MapArea area) {
    _enemyRespawnTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _respawnDeadEnemies(area);
    });
  }

  // 生成新敌人
  void _spawnNewEnemies(MapArea area) {
    if (_currentMapState == null) return;

    final currentAliveCount = _currentMapState!.enemies.where((e) => e.isAlive).length;
    if (currentAliveCount >= area.maxEnemyCount) return;

    final spawnCount = min(2, area.maxEnemyCount - currentAliveCount);
    final newEnemies = List.generate(spawnCount, (index) {
      return _generateRandomEnemy(area, _currentMapState!.enemies.length + index);
    });

    _currentMapState = _currentMapState!.copyWith(
      enemies: [..._currentMapState!.enemies, ...newEnemies],
      lastUpdate: DateTime.now(),
    );

    notifyListeners();
    debugPrint('🆕 生成新敌人: $spawnCount 个');
  }

  // 复活死亡敌人
  void _respawnDeadEnemies(MapArea area) {
    if (_currentMapState == null) return;

    final now = DateTime.now();
    final respawnDelay = const Duration(minutes: 2); // 2分钟后复活

    final updatedEnemies = _currentMapState!.enemies.map((enemy) {
      if (!enemy.isAlive && 
          enemy.lastRespawnTime != null && 
          now.difference(enemy.lastRespawnTime!) >= respawnDelay) {
        
        // 重新生成位置
        final newPosition = MapPosition(
          x: _random.nextDouble() * area.width,
          y: _random.nextDouble() * area.height,
        );

        return enemy.copyWith(
          isAlive: true,
          position: newPosition,
          lastRespawnTime: null,
        );
      }
      return enemy;
    }).toList();

    final respawnedCount = updatedEnemies.where((e) => e.isAlive).length - 
                          _currentMapState!.enemies.where((e) => e.isAlive).length;

    if (respawnedCount > 0) {
      _currentMapState = _currentMapState!.copyWith(
        enemies: updatedEnemies,
        lastUpdate: DateTime.now(),
      );

      notifyListeners();
      debugPrint('♻️ 复活敌人: $respawnedCount 个');
    }
  }

  // 启动敌人移动定时器
  void _startEnemyMoveTimer(MapArea area) {
    _enemyMoveTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      _moveEnemies(area);
    });
  }

  // 设置敌人移动目标
  void _moveEnemies(MapArea area) {
    if (_currentMapState == null) return;

    for (final enemy in _currentMapState!.enemies) {
      if (!enemy.isAlive) continue;

      // 随机移动敌人
      final moveDistance = 30.0 + _random.nextDouble() * 60.0; // 30-90像素随机移动
      final angle = _random.nextDouble() * 2 * pi;
      
      final targetPosition = MapPosition(
        x: enemy.position.x + cos(angle) * moveDistance,
        y: enemy.position.y + sin(angle) * moveDistance,
      );

      // 确保敌人不会移出地图边界
      final clampedTarget = MapPosition(
        x: targetPosition.x.clamp(0, area.width),
        y: targetPosition.y.clamp(0, area.height),
      );

      // 设置敌人的目标位置
      _enemyTargets[enemy.id] = clampedTarget;
    }

    debugPrint('👹 设置敌人移动目标: ${_enemyTargets.length} 个敌人');
  }

  // 启动敌人平滑移动定时器
  void _startEnemySmoothMoveTimer() {
    _enemySmoothMoveTimer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      _performEnemySmoothMove();
    });
  }

  // 执行敌人平滑移动
  void _performEnemySmoothMove() {
    if (_currentMapState == null || _enemyTargets.isEmpty) return;

    bool hasMovement = false;
    final updatedEnemies = _currentMapState!.enemies.map((enemy) {
      if (!enemy.isAlive || !_enemyTargets.containsKey(enemy.id)) {
        return enemy;
      }

      final targetPos = _enemyTargets[enemy.id]!;
      final currentPos = enemy.position;
      
      // 计算到目标的距离
      final distance = currentPos.distanceTo(targetPos);
      
      // 如果已经很接近目标，停止移动
      if (distance <= 2.0) {
        _enemyTargets.remove(enemy.id);
        return enemy.copyWith(position: targetPos);
      }

      // 计算移动方向
      final direction = _getDirectionToTarget(targetPos, currentPos);
      
      // 敌人移动速度比玩家慢一些
      final enemyMoveSpeed = 1.8;
      
      // 计算新位置
      final newPosition = MapPosition(
        x: currentPos.x + direction.x * enemyMoveSpeed,
        y: currentPos.y + direction.y * enemyMoveSpeed,
      );

      hasMovement = true;
      return enemy.copyWith(position: newPosition);
    }).toList();

    if (hasMovement) {
      _currentMapState = _currentMapState!.copyWith(
        enemies: updatedEnemies,
        lastUpdate: DateTime.now(),
      );
      notifyListeners();
    }
  }


  // 获取当前区域
  MapArea? _getCurrentArea() {
    if (_currentMapState == null) return null;
    return MapArea.predefinedAreas.firstWhere(
      (area) => area.id == _currentMapState!.currentAreaId,
      orElse: () => MapArea.predefinedAreas.first,
    );
  }

  // 开始平滑移动到目标位置
  void _startSmoothMoveToTarget(MapPosition target) {
    if (_isSmoothMoving || _isManualControl) return; // 手动控制时不启动平滑移动

    _targetPosition = target;
    _isSmoothMoving = true;
    
    _smoothMoveTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _performSmoothMoveStep();
    });
  }

  // 执行平滑移动步骤
  void _performSmoothMoveStep() {
    if (_currentMapState == null || _targetPosition == null) {
      _stopSmoothMove();
      return;
    }

    final currentPos = _currentMapState!.playerPosition;
    final targetPos = _targetPosition!;
    
    // 计算到目标的距离
    final distance = currentPos.distanceTo(targetPos);
    
    // 如果已经很接近目标，停止移动
    if (distance <= _moveSpeed) {
      movePlayer(targetPos);
      _stopSmoothMove();
      return;
    }

    // 计算移动方向
    final direction = _getDirectionToTarget(targetPos);
    
    // 动态调整移动速度 - 接近目标时减速，远离时加速
    double currentSpeed = _moveSpeed;
    if (distance < 25) {
      // 接近目标时减速到60%
      currentSpeed = _moveSpeed * 0.6;
    } else if (distance > 80) {
      // 距离较远时加速到130%
      currentSpeed = _moveSpeed * 1.3;
    }
    
    // 计算新位置
    final newPosition = MapPosition(
      x: currentPos.x + direction.x * currentSpeed,
      y: currentPos.y + direction.y * currentSpeed,
    );

    movePlayer(newPosition);
  }

  // 停止平滑移动
  void _stopSmoothMove() {
    _isSmoothMoving = false;
    _smoothMoveTimer?.cancel();
    _smoothMoveTimer = null;
    _targetPosition = null;
  }

  // 停止所有定时器
  void _stopAllTimers() {
    _enemySpawnTimer?.cancel();
    _enemyRespawnTimer?.cancel();
    _autoExploreTimer?.cancel();
    _enemyMoveTimer?.cancel();
    _enemySmoothMoveTimer?.cancel();
    _stopSmoothMove();
    _enemySpawnTimer = null;
    _enemyRespawnTimer = null;
    _autoExploreTimer = null;
    _enemyMoveTimer = null;
    _enemySmoothMoveTimer = null;
    _enemyTargets.clear();
    _isAutoExploring = false;
  }

  @override
  void dispose() {
    _stopAllTimers();
    super.dispose();
  }
}
