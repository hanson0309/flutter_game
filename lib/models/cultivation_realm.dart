import 'package:json_annotation/json_annotation.dart';

part 'cultivation_realm.g.dart';

@JsonSerializable()
class CultivationRealm {
  final String name;
  final int level;
  final int maxExp;
  final String description;
  final Map<String, double> attributeMultipliers;

  const CultivationRealm({
    required this.name,
    required this.level,
    required this.maxExp,
    required this.description,
    required this.attributeMultipliers,
  });

  factory CultivationRealm.fromJson(Map<String, dynamic> json) =>
      _$CultivationRealmFromJson(json);

  Map<String, dynamic> toJson() => _$CultivationRealmToJson(this);

  static const List<CultivationRealm> realms = [
    CultivationRealm(
      name: '凡人',
      level: 0,
      maxExp: 100,
      description: '未踏入修仙之路的普通人',
      attributeMultipliers: {
        'attack': 1.0,
        'defense': 1.0,
        'health': 1.0,
        'mana': 1.0,
      },
    ),
    CultivationRealm(
      name: '练气期',
      level: 1,
      maxExp: 500,
      description: '初入修仙门槛，开始感应天地灵气',
      attributeMultipliers: {
        'attack': 1.5,
        'defense': 1.3,
        'health': 1.4,
        'mana': 2.0,
      },
    ),
    CultivationRealm(
      name: '筑基期',
      level: 2,
      maxExp: 2000,
      description: '筑建修仙根基，实力大幅提升',
      attributeMultipliers: {
        'attack': 2.5,
        'defense': 2.0,
        'health': 2.2,
        'mana': 3.5,
      },
    ),
    CultivationRealm(
      name: '金丹期',
      level: 3,
      maxExp: 8000,
      description: '凝结金丹，踏入修仙中阶',
      attributeMultipliers: {
        'attack': 4.0,
        'defense': 3.5,
        'health': 3.8,
        'mana': 6.0,
      },
    ),
    CultivationRealm(
      name: '元婴期',
      level: 4,
      maxExp: 30000,
      description: '元婴出窍，神通广大',
      attributeMultipliers: {
        'attack': 7.0,
        'defense': 6.0,
        'health': 6.5,
        'mana': 10.0,
      },
    ),
    CultivationRealm(
      name: '化神期',
      level: 5,
      maxExp: 100000,
      description: '化神通玄，已是一方强者',
      attributeMultipliers: {
        'attack': 12.0,
        'defense': 10.0,
        'health': 11.0,
        'mana': 18.0,
      },
    ),
    CultivationRealm(
      name: '炼虚期',
      level: 6,
      maxExp: 300000,
      description: '炼虚合道，超脱凡俗',
      attributeMultipliers: {
        'attack': 20.0,
        'defense': 16.0,
        'health': 18.0,
        'mana': 30.0,
      },
    ),
    CultivationRealm(
      name: '合体期',
      level: 7,
      maxExp: 800000,
      description: '合体大道，天人合一',
      attributeMultipliers: {
        'attack': 35.0,
        'defense': 28.0,
        'health': 32.0,
        'mana': 50.0,
      },
    ),
    CultivationRealm(
      name: '大乘期',
      level: 8,
      maxExp: 2000000,
      description: '大乘境界，接近仙道',
      attributeMultipliers: {
        'attack': 60.0,
        'defense': 48.0,
        'health': 55.0,
        'mana': 85.0,
      },
    ),
    CultivationRealm(
      name: '渡劫期',
      level: 9,
      maxExp: 5000000,
      description: '渡劫成仙，生死一线',
      attributeMultipliers: {
        'attack': 100.0,
        'defense': 80.0,
        'health': 90.0,
        'mana': 140.0,
      },
    ),
    CultivationRealm(
      name: '飞升期（仙人）',
      level: 10,
      maxExp: 12000000,
      description: '飞升仙界，踏入仙道',
      attributeMultipliers: {
        'attack': 170.0,
        'defense': 135.0,
        'health': 155.0,
        'mana': 240.0,
      },
    ),
    CultivationRealm(
      name: '真仙',
      level: 11,
      maxExp: 30000000,
      description: '真正的仙人，掌控仙法',
      attributeMultipliers: {
        'attack': 280.0,
        'defense': 220.0,
        'health': 250.0,
        'mana': 400.0,
      },
    ),
    CultivationRealm(
      name: '玄仙',
      level: 12,
      maxExp: 70000000,
      description: '玄妙仙境，神通无量',
      attributeMultipliers: {
        'attack': 450.0,
        'defense': 360.0,
        'health': 410.0,
        'mana': 650.0,
      },
    ),
    CultivationRealm(
      name: '金仙',
      level: 13,
      maxExp: 150000000,
      description: '金仙不朽，万劫不磨',
      attributeMultipliers: {
        'attack': 720.0,
        'defense': 580.0,
        'health': 660.0,
        'mana': 1050.0,
      },
    ),
    CultivationRealm(
      name: '太乙真仙',
      level: 14,
      maxExp: 350000000,
      description: '太乙境界，超脱轮回',
      attributeMultipliers: {
        'attack': 1200.0,
        'defense': 950.0,
        'health': 1100.0,
        'mana': 1700.0,
      },
    ),
    CultivationRealm(
      name: '大罗金仙',
      level: 15,
      maxExp: 800000000,
      description: '大罗天仙，跳出三界',
      attributeMultipliers: {
        'attack': 2000.0,
        'defense': 1600.0,
        'health': 1800.0,
        'mana': 2800.0,
      },
    ),
    CultivationRealm(
      name: '神君',
      level: 16,
      maxExp: 1800000000,
      description: '神道君主，统御一方',
      attributeMultipliers: {
        'attack': 3300.0,
        'defense': 2650.0,
        'health': 3000.0,
        'mana': 4600.0,
      },
    ),
    CultivationRealm(
      name: '真神',
      level: 17,
      maxExp: 4000000000,
      description: '真正神灵，创造法则',
      attributeMultipliers: {
        'attack': 5500.0,
        'defense': 4400.0,
        'health': 5000.0,
        'mana': 7500.0,
      },
    ),
    CultivationRealm(
      name: '主神',
      level: 18,
      maxExp: 9000000000,
      description: '主宰神界，威震诸天',
      attributeMultipliers: {
        'attack': 9000.0,
        'defense': 7200.0,
        'health': 8200.0,
        'mana': 12500.0,
      },
    ),
    CultivationRealm(
      name: '至高神',
      level: 19,
      maxExp: 20000000000,
      description: '至高无上，神中之神',
      attributeMultipliers: {
        'attack': 15000.0,
        'defense': 12000.0,
        'health': 13500.0,
        'mana': 20000.0,
      },
    ),
    CultivationRealm(
      name: '混元道祖',
      level: 20,
      maxExp: 45000000000,
      description: '混元一体，道之始祖',
      attributeMultipliers: {
        'attack': 25000.0,
        'defense': 20000.0,
        'health': 22500.0,
        'mana': 33000.0,
      },
    ),
    CultivationRealm(
      name: '太初圣尊',
      level: 21,
      maxExp: 100000000000,
      description: '太初之始，圣道之尊',
      attributeMultipliers: {
        'attack': 40000.0,
        'defense': 32000.0,
        'health': 36000.0,
        'mana': 55000.0,
      },
    ),
    CultivationRealm(
      name: '无上天尊',
      level: 22,
      maxExp: 220000000000,
      description: '无上境界，天道之尊',
      attributeMultipliers: {
        'attack': 65000.0,
        'defense': 52000.0,
        'health': 58500.0,
        'mana': 90000.0,
      },
    ),
    CultivationRealm(
      name: '永恒主宰',
      level: 23,
      maxExp: 500000000000,
      description: '永恒不灭，主宰万物',
      attributeMultipliers: {
        'attack': 100000.0,
        'defense': 80000.0,
        'health': 90000.0,
        'mana': 150000.0,
      },
    ),
  ];

  static CultivationRealm getRealmByLevel(int level) {
    if (level < 0) return realms.first;
    if (level >= realms.length) return realms.last;
    return realms.firstWhere(
      (realm) => realm.level == level,
      orElse: () => realms.first,
    );
  }
}
