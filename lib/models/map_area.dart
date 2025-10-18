import 'package:json_annotation/json_annotation.dart';
import 'dart:math';

part 'map_area.g.dart';

@JsonSerializable()
class MapPosition {
  final double x;
  final double y;

  const MapPosition({required this.x, required this.y});

  factory MapPosition.fromJson(Map<String, dynamic> json) => _$MapPositionFromJson(json);
  Map<String, dynamic> toJson() => _$MapPositionToJson(this);

  double distanceTo(MapPosition other) {
    return sqrt(pow(x - other.x, 2) + pow(y - other.y, 2));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapPosition && runtimeType == other.runtimeType && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

@JsonSerializable()
class MapEnemy {
  final String id;
  final String enemyId; // 对应battle.dart中的Enemy ID
  final MapPosition position;
  final int level;
  final String type;
  final bool isAlive;
  final DateTime? lastRespawnTime;

  const MapEnemy({
    required this.id,
    required this.enemyId,
    required this.position,
    required this.level,
    required this.type,
    this.isAlive = true,
    this.lastRespawnTime,
  });

  factory MapEnemy.fromJson(Map<String, dynamic> json) => _$MapEnemyFromJson(json);
  Map<String, dynamic> toJson() => _$MapEnemyToJson(this);

  MapEnemy copyWith({
    String? id,
    String? enemyId,
    MapPosition? position,
    int? level,
    String? type,
    bool? isAlive,
    DateTime? lastRespawnTime,
  }) {
    return MapEnemy(
      id: id ?? this.id,
      enemyId: enemyId ?? this.enemyId,
      position: position ?? this.position,
      level: level ?? this.level,
      type: type ?? this.type,
      isAlive: isAlive ?? this.isAlive,
      lastRespawnTime: lastRespawnTime ?? this.lastRespawnTime,
    );
  }
}

@JsonSerializable()
class MapArea {
  final String id;
  final String name;
  final String description;
  final double width;
  final double height;
  final int minEnemyLevel;
  final int maxEnemyLevel;
  final int maxEnemyCount;
  final double enemyDetectionRange;
  final List<String> enemyTypes;
  final String backgroundImage;

  const MapArea({
    required this.id,
    required this.name,
    required this.description,
    required this.width,
    required this.height,
    required this.minEnemyLevel,
    required this.maxEnemyLevel,
    required this.maxEnemyCount,
    this.enemyDetectionRange = 50.0,
    required this.enemyTypes,
    required this.backgroundImage,
  });

  factory MapArea.fromJson(Map<String, dynamic> json) => _$MapAreaFromJson(json);
  Map<String, dynamic> toJson() => _$MapAreaToJson(this);

  // 预定义的地图区域
  static const List<MapArea> predefinedAreas = [
    MapArea(
      id: 'newbie_forest',
      name: '新手森林',
      description: '适合初学者探索的安全森林',
      width: 2400,
      height: 1800,
      minEnemyLevel: 1,
      maxEnemyLevel: 3,
      maxEnemyCount: 15,
      enemyDetectionRange: 60.0,
      enemyTypes: ['beast', 'spirit'],
      backgroundImage: 'assets/images/forest_bg.jpg',
    ),
    MapArea(
      id: 'dark_valley',
      name: '幽暗山谷',
      description: '危险的山谷，充满强大的敌人',
      width: 3000,
      height: 2400,
      minEnemyLevel: 3,
      maxEnemyLevel: 8,
      maxEnemyCount: 20,
      enemyDetectionRange: 80.0,
      enemyTypes: ['demon', 'undead', 'beast'],
      backgroundImage: 'assets/images/valley_bg.jpg',
    ),
    MapArea(
      id: 'ancient_ruins',
      name: '远古遗迹',
      description: '神秘的远古遗迹，隐藏着强大的守护者',
      width: 3600,
      height: 3000,
      minEnemyLevel: 8,
      maxEnemyLevel: 15,
      maxEnemyCount: 25,
      enemyDetectionRange: 100.0,
      enemyTypes: ['cultivator', 'spirit', 'demon'],
      backgroundImage: 'assets/images/ruins_bg.jpg',
    ),
  ];
}

@JsonSerializable()
class MapState {
  final String currentAreaId;
  final MapPosition playerPosition;
  final List<MapEnemy> enemies;
  final DateTime lastUpdate;

  const MapState({
    required this.currentAreaId,
    required this.playerPosition,
    required this.enemies,
    required this.lastUpdate,
  });

  factory MapState.fromJson(Map<String, dynamic> json) => _$MapStateFromJson(json);
  Map<String, dynamic> toJson() => _$MapStateToJson(this);

  MapState copyWith({
    String? currentAreaId,
    MapPosition? playerPosition,
    List<MapEnemy>? enemies,
    DateTime? lastUpdate,
  }) {
    return MapState(
      currentAreaId: currentAreaId ?? this.currentAreaId,
      playerPosition: playerPosition ?? this.playerPosition,
      enemies: enemies ?? this.enemies,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}
