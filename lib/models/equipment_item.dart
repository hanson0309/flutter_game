import 'package:flutter/material.dart';

// 装备项数据类
class EquipmentItem {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int id;
  final double attackBonus;
  final double defenseBonus;
  final double healthBonus;
  final double manaBonus;
  
  EquipmentItem(
    this.name, 
    this.description, 
    this.icon, 
    this.color, 
    this.id, {
    this.attackBonus = 0,
    this.defenseBonus = 0,
    this.healthBonus = 0,
    this.manaBonus = 0,
  });

  // 从商店物品创建装备项
  factory EquipmentItem.fromShopItem(String name, String description, int id) {
    // 根据装备名称设置属性和图标
    IconData icon = Icons.shield;
    Color color = Colors.grey;
    double attackBonus = 0;
    double defenseBonus = 0;
    double healthBonus = 0;
    double manaBonus = 0;

    // 根据装备名称判断类型和属性
    if (name.contains('剑') || name.contains('刀') || name.contains('枪')) {
      icon = Icons.flash_on;
      color = Colors.red;
      attackBonus = 10 + (id * 2); // 基础攻击力
    } else if (name.contains('甲') || name.contains('盾') || name.contains('护')) {
      icon = Icons.shield;
      color = Colors.blue;
      defenseBonus = 8 + (id * 1.5); // 基础防御力
    } else if (name.contains('帽') || name.contains('冠') || name.contains('法')) {
      icon = Icons.auto_awesome;
      color = Colors.purple;
      manaBonus = 15 + (id * 2.5); // 基础法力值
    } else if (name.contains('靴') || name.contains('鞋')) {
      icon = Icons.directions_run;
      color = Colors.brown;
      defenseBonus = 5.0 + id; // 基础防御力
    } else if (name.contains('项链') || name.contains('戒指') || name.contains('护符')) {
      icon = Icons.circle;
      color = Colors.amber;
      healthBonus = 20.0 + (id * 3); // 基础生命值
    } else {
      // 默认装备
      attackBonus = 5.0 + id;
      defenseBonus = 3.0 + id;
    }

    return EquipmentItem(
      name,
      description,
      icon,
      color,
      id,
      attackBonus: attackBonus,
      defenseBonus: defenseBonus,
      healthBonus: healthBonus,
      manaBonus: manaBonus,
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'iconCodePoint': icon.codePoint,
      'colorValue': color.value,
      'id': id,
      'attackBonus': attackBonus,
      'defenseBonus': defenseBonus,
      'healthBonus': healthBonus,
      'manaBonus': manaBonus,
    };
  }

  // 从JSON创建
  factory EquipmentItem.fromJson(Map<String, dynamic> json) {
    return EquipmentItem(
      json['name'],
      json['description'],
      IconData(json['iconCodePoint'], fontFamily: 'MaterialIcons'),
      Color(json['colorValue']),
      json['id'],
      attackBonus: json['attackBonus']?.toDouble() ?? 0,
      defenseBonus: json['defenseBonus']?.toDouble() ?? 0,
      healthBonus: json['healthBonus']?.toDouble() ?? 0,
      manaBonus: json['manaBonus']?.toDouble() ?? 0,
    );
  }
}
