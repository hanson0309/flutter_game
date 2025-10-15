import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'inventory.g.dart';

// 物品类型枚举
enum InventoryItemType {
  equipment,    // 装备
  consumable,   // 消耗品
  material,     // 材料
  technique,    // 功法
  special,      // 特殊物品
  quest,        // 任务物品
}

// 背包物品
@JsonSerializable()
class InventoryItem {
  final String id;
  final String itemId; // 对应商店物品ID或其他物品ID
  final String name;
  final String description;
  final InventoryItemType type;
  final String? iconPath;
  final Map<String, dynamic> itemData; // 物品具体数据
  int quantity; // 数量
  final bool stackable; // 是否可堆叠
  final int maxStack; // 最大堆叠数量
  final DateTime obtainedAt; // 获得时间
  final String? source; // 获得来源

  InventoryItem({
    required this.id,
    required this.itemId,
    required this.name,
    required this.description,
    required this.type,
    this.iconPath,
    required this.itemData,
    this.quantity = 1,
    this.stackable = true,
    this.maxStack = 99,
    required this.obtainedAt,
    this.source,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) => _$InventoryItemFromJson(json);
  Map<String, dynamic> toJson() => _$InventoryItemToJson(this);

  // 获取物品品质颜色
  Color get qualityColor {
    final rarity = itemData['rarity'] as String?;
    switch (rarity) {
      case 'common':
        return const Color(0xFF9E9E9E); // 灰色
      case 'uncommon':
        return const Color(0xFF4CAF50); // 绿色
      case 'rare':
        return const Color(0xFF2196F3); // 蓝色
      case 'epic':
        return const Color(0xFF9C27B0); // 紫色
      case 'legendary':
        return const Color(0xFFFF9800); // 橙色
      case 'mythic':
        return const Color(0xFFF44336); // 红色
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  // 获取物品品质文本
  String get qualityText {
    final rarity = itemData['rarity'] as String?;
    switch (rarity) {
      case 'common':
        return '普通';
      case 'uncommon':
        return '不凡';
      case 'rare':
        return '稀有';
      case 'epic':
        return '史诗';
      case 'legendary':
        return '传说';
      case 'mythic':
        return '神话';
      default:
        return '普通';
    }
  }

  // 是否可以使用
  bool get canUse {
    switch (type) {
      case InventoryItemType.consumable:
        return true;
      case InventoryItemType.equipment:
        return true;
      case InventoryItemType.technique:
        return true;
      case InventoryItemType.special:
        return itemData.containsKey('usable') && itemData['usable'] == true;
      default:
        return false;
    }
  }

  // 增加数量
  bool addQuantity(int amount) {
    if (!stackable) return false;
    final newQuantity = quantity + amount;
    if (newQuantity > maxStack) return false;
    quantity = newQuantity;
    return true;
  }

  // 减少数量
  bool reduceQuantity(int amount) {
    if (quantity < amount) return false;
    quantity -= amount;
    return true;
  }

  // 是否为空
  bool get isEmpty => quantity <= 0;
}

// 背包分类
enum InventoryCategory {
  all,          // 全部
  equipment,    // 装备
  consumable,   // 消耗品
  material,     // 材料
  technique,    // 功法
  special,      // 特殊
  quest,        // 任务
}

// 背包排序方式
enum InventorySortType {
  name,         // 按名称
  type,         // 按类型
  quality,      // 按品质
  quantity,     // 按数量
  obtainTime,   // 按获得时间
}

// 玩家背包
@JsonSerializable()
class PlayerInventory {
  List<InventoryItem> items;
  final int maxSlots; // 最大槽位数
  final Map<String, int> categoryLimits; // 分类限制

  PlayerInventory({
    this.items = const [],
    this.maxSlots = 100,
    this.categoryLimits = const {},
  });

  factory PlayerInventory.fromJson(Map<String, dynamic> json) => _$PlayerInventoryFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerInventoryToJson(this);

  // 获取当前使用的槽位数
  int get usedSlots => items.length;

  // 获取剩余槽位数
  int get remainingSlots => maxSlots - usedSlots;

  // 是否已满
  bool get isFull => usedSlots >= maxSlots;

  // 按分类获取物品
  List<InventoryItem> getItemsByCategory(InventoryCategory category) {
    if (category == InventoryCategory.all) return items;
    
    final targetType = _categoryToItemType(category);
    if (targetType == null) return [];
    
    return items.where((item) => item.type == targetType).toList();
  }

  // 按类型获取物品数量
  int getItemCountByType(InventoryItemType type) {
    return items.where((item) => item.type == type).fold(0, (sum, item) => sum + item.quantity);
  }

  // 查找物品
  InventoryItem? findItem(String itemId) {
    try {
      return items.firstWhere((item) => item.itemId == itemId);
    } catch (e) {
      return null;
    }
  }

  // 查找可堆叠的物品
  InventoryItem? findStackableItem(String itemId) {
    try {
      return items.firstWhere((item) => 
        item.itemId == itemId && 
        item.stackable && 
        item.quantity < item.maxStack
      );
    } catch (e) {
      return null;
    }
  }

  // 添加物品
  bool addItem(InventoryItem newItem) {
    // 检查是否可以堆叠
    if (newItem.stackable) {
      final existingItem = findStackableItem(newItem.itemId);
      if (existingItem != null) {
        final canAdd = existingItem.maxStack - existingItem.quantity;
        if (canAdd >= newItem.quantity) {
          existingItem.quantity += newItem.quantity;
          return true;
        } else if (canAdd > 0) {
          existingItem.quantity = existingItem.maxStack;
          newItem.quantity -= canAdd;
          // 继续添加剩余数量
        }
      }
    }

    // 检查背包空间
    if (isFull) return false;

    // 添加新物品
    items = List.from(items)..add(newItem);
    return true;
  }

  // 移除物品
  bool removeItem(String itemId, int quantity) {
    final item = findItem(itemId);
    if (item == null || item.quantity < quantity) return false;

    if (item.reduceQuantity(quantity)) {
      if (item.isEmpty) {
        items = List.from(items)..removeWhere((i) => i.id == item.id);
      }
      return true;
    }
    return false;
  }

  // 使用物品
  Map<String, dynamic>? useItem(String itemId, int quantity) {
    final item = findItem(itemId);
    if (item == null || !item.canUse || item.quantity < quantity) return null;

    final result = <String, dynamic>{
      'itemId': itemId,
      'name': item.name,
      'type': item.type.toString(),
      'quantity': quantity,
      'effects': <String, dynamic>{},
    };

    // 根据物品类型处理使用效果
    switch (item.type) {
      case InventoryItemType.consumable:
      case InventoryItemType.special:
        result['effects'] = _extractEffectsFromItemData(item.itemData, quantity);
        break;
      default:
        break;
    }

    // 减少物品数量
    if (removeItem(itemId, quantity)) {
      return result;
    }
    return null;
  }

  // 排序物品
  void sortItems(InventorySortType sortType, {bool ascending = true}) {
    items.sort((a, b) {
      int comparison = 0;
      
      switch (sortType) {
        case InventorySortType.name:
          comparison = a.name.compareTo(b.name);
          break;
        case InventorySortType.type:
          comparison = a.type.index.compareTo(b.type.index);
          break;
        case InventorySortType.quality:
          comparison = a.qualityText.compareTo(b.qualityText);
          break;
        case InventorySortType.quantity:
          comparison = a.quantity.compareTo(b.quantity);
          break;
        case InventorySortType.obtainTime:
          comparison = a.obtainedAt.compareTo(b.obtainedAt);
          break;
      }
      
      return ascending ? comparison : -comparison;
    });
  }

  // 获取背包统计信息
  Map<String, dynamic> getStatistics() {
    final stats = <String, dynamic>{
      'totalItems': items.length,
      'totalQuantity': items.fold(0, (sum, item) => sum + item.quantity),
      'usedSlots': usedSlots,
      'maxSlots': maxSlots,
      'remainingSlots': remainingSlots,
      'categories': <String, int>{},
    };

    // 统计各分类数量
    for (final category in InventoryCategory.values) {
      if (category == InventoryCategory.all) continue;
      final categoryItems = getItemsByCategory(category);
      stats['categories'][category.toString()] = categoryItems.length;
    }

    return stats;
  }

  // 辅助方法：分类转物品类型
  InventoryItemType? _categoryToItemType(InventoryCategory category) {
    switch (category) {
      case InventoryCategory.equipment:
        return InventoryItemType.equipment;
      case InventoryCategory.consumable:
        return InventoryItemType.consumable;
      case InventoryCategory.material:
        return InventoryItemType.material;
      case InventoryCategory.technique:
        return InventoryItemType.technique;
      case InventoryCategory.special:
        return InventoryItemType.special;
      case InventoryCategory.quest:
        return InventoryItemType.quest;
      default:
        return null;
    }
  }

  // 从物品数据中提取效果
  Map<String, dynamic> _extractEffectsFromItemData(Map<String, dynamic> itemData, int quantity) {
    final effects = <String, dynamic>{};
    
    // 处理生命恢复效果
    if (itemData.containsKey('heal')) {
      effects['heal'] = (itemData['heal'] as int) * quantity;
    }
    if (itemData.containsKey('healAmount')) {
      effects['heal'] = (itemData['healAmount'] as int) * quantity;
    }
    
    // 处理法力恢复效果
    if (itemData.containsKey('mana')) {
      effects['mana'] = (itemData['mana'] as int) * quantity;
    }
    if (itemData.containsKey('manaAmount')) {
      effects['mana'] = (itemData['manaAmount'] as int) * quantity;
    }
    
    // 处理经验获得效果
    if (itemData.containsKey('exp')) {
      effects['exp'] = (itemData['exp'] as int) * quantity;
    }
    if (itemData.containsKey('expAmount')) {
      effects['exp'] = (itemData['expAmount'] as int) * quantity;
    }
    
    // 处理特殊效果
    if (itemData.containsKey('luckBonus')) {
      effects['luck'] = itemData['luckBonus'];
      effects['duration'] = itemData['duration'] ?? 3600;
    }
    
    return effects;
  }

  // 获取消耗品效果（保留兼容性）
  Map<String, dynamic> _getConsumableEffects(Map<String, dynamic> itemData, int quantity) {
    return _extractEffectsFromItemData(itemData, quantity);
  }

  // 获取特殊物品效果
  Map<String, dynamic> _getSpecialEffects(Map<String, dynamic> itemData, int quantity) {
    final effects = <String, dynamic>{};
    
    if (itemData.containsKey('luckBonus')) {
      effects['luck'] = itemData['luckBonus'];
      effects['duration'] = itemData['duration'] ?? 3600;
    }
    
    return effects;
  }
}

// 物品使用结果
class ItemUseResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? effects;

  ItemUseResult({
    required this.success,
    required this.message,
    this.effects,
  });
}
