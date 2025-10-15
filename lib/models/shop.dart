import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'shop.g.dart';

// 货币类型枚举
enum CurrencyType {
  spiritStones,  // 灵石
  jadePearls,    // 玉珠（高级货币）
  contribution,  // 贡献点
}

// 商品类型枚举
enum ShopItemType {
  equipment,     // 装备
  technique,     // 功法
  consumable,    // 消耗品
  material,      // 材料
  special,       // 特殊物品
}

// 商品稀有度
enum ItemRarity {
  common,        // 普通（白色）
  uncommon,      // 不凡（绿色）
  rare,          // 稀有（蓝色）
  epic,          // 史诗（紫色）
  legendary,     // 传说（橙色）
  mythic,        // 神话（红色）
}

// 商品价格
@JsonSerializable()
class ItemPrice {
  final CurrencyType currency;
  final int amount;
  final double? discount; // 折扣，0.8表示8折

  ItemPrice({
    required this.currency,
    required this.amount,
    this.discount,
  });

  factory ItemPrice.fromJson(Map<String, dynamic> json) => _$ItemPriceFromJson(json);
  Map<String, dynamic> toJson() => _$ItemPriceToJson(this);

  // 获取实际价格
  int get actualPrice {
    if (discount != null) {
      return (amount * discount!).round();
    }
    return amount;
  }

  // 获取货币显示名称
  String get currencyName {
    switch (currency) {
      case CurrencyType.spiritStones:
        return '灵石';
      case CurrencyType.jadePearls:
        return '玉珠';
      case CurrencyType.contribution:
        return '贡献点';
    }
  }

  // 获取价格显示文本
  String get displayText {
    final price = actualPrice;
    if (discount != null && discount! < 1.0) {
      return '$price $currencyName (${(discount! * 100).round()}折)';
    }
    return '$price $currencyName';
  }
}

// 商店商品
@JsonSerializable()
class ShopItem {
  final String id;
  final String name;
  final String description;
  final ShopItemType type;
  final ItemRarity rarity;
  final List<ItemPrice> prices; // 支持多种货币购买
  final String? iconPath;
  final Map<String, dynamic>? itemData; // 物品具体数据
  final int maxStock; // 最大库存，-1表示无限
  final int refreshHours; // 刷新时间（小时），0表示不刷新
  final List<String> prerequisites; // 购买前置条件
  final int playerLevelRequired; // 需要的玩家等级
  final bool isLimited; // 是否限时商品
  final DateTime? availableUntil; // 可购买截止时间

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.rarity,
    required this.prices,
    this.iconPath,
    this.itemData,
    this.maxStock = -1,
    this.refreshHours = 0,
    this.prerequisites = const [],
    this.playerLevelRequired = 0,
    this.isLimited = false,
    this.availableUntil,
  });

  factory ShopItem.fromJson(Map<String, dynamic> json) => _$ShopItemFromJson(json);
  Map<String, dynamic> toJson() => _$ShopItemToJson(this);

  // 获取稀有度颜色
  Color get rarityColor {
    switch (rarity) {
      case ItemRarity.common:
        return const Color(0xFF9E9E9E); // 灰色
      case ItemRarity.uncommon:
        return const Color(0xFF4CAF50); // 绿色
      case ItemRarity.rare:
        return const Color(0xFF2196F3); // 蓝色
      case ItemRarity.epic:
        return const Color(0xFF9C27B0); // 紫色
      case ItemRarity.legendary:
        return const Color(0xFFFF9800); // 橙色
      case ItemRarity.mythic:
        return const Color(0xFFF44336); // 红色
    }
  }

  // 获取稀有度文本
  String get rarityText {
    switch (rarity) {
      case ItemRarity.common:
        return '普通';
      case ItemRarity.uncommon:
        return '不凡';
      case ItemRarity.rare:
        return '稀有';
      case ItemRarity.epic:
        return '史诗';
      case ItemRarity.legendary:
        return '传说';
      case ItemRarity.mythic:
        return '神话';
    }
  }

  // 获取最便宜的价格
  ItemPrice? get cheapestPrice {
    if (prices.isEmpty) return null;
    return prices.reduce((a, b) => a.actualPrice < b.actualPrice ? a : b);
  }
}

// 商店类型
enum ShopType {
  general,       // 综合商店
  equipment,     // 装备商店
  technique,     // 功法商店
  consumable,    // 消耗品商店
  limited,       // 限时商店
  contribution,  // 贡献商店
}

// 商店
@JsonSerializable()
class Shop {
  final String id;
  final String name;
  final String description;
  final ShopType type;
  final List<String> itemIds; // 商品ID列表
  final int refreshHours; // 商店刷新时间
  final bool isUnlocked; // 是否已解锁
  final List<String> unlockConditions; // 解锁条件
  final int playerLevelRequired; // 需要的玩家等级

  Shop({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.itemIds,
    this.refreshHours = 24,
    this.isUnlocked = true,
    this.unlockConditions = const [],
    this.playerLevelRequired = 0,
  });

  factory Shop.fromJson(Map<String, dynamic> json) => _$ShopFromJson(json);
  Map<String, dynamic> toJson() => _$ShopToJson(this);
}

// 玩家商店数据
@JsonSerializable()
class PlayerShopData {
  final String shopId;
  Map<String, int> purchaseCount; // 商品ID -> 购买次数
  DateTime? lastRefresh; // 上次刷新时间
  Map<String, int> currentStock; // 当前库存

  PlayerShopData({
    required this.shopId,
    this.purchaseCount = const {},
    this.lastRefresh,
    this.currentStock = const {},
  });

  factory PlayerShopData.fromJson(Map<String, dynamic> json) => _$PlayerShopDataFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerShopDataToJson(this);

  // 获取商品购买次数
  int getPurchaseCount(String itemId) {
    return purchaseCount[itemId] ?? 0;
  }

  // 增加购买次数
  void addPurchase(String itemId, int count) {
    purchaseCount = Map.from(purchaseCount);
    purchaseCount[itemId] = getPurchaseCount(itemId) + count;
  }

  // 获取当前库存
  int getCurrentStock(String itemId, int maxStock) {
    if (maxStock == -1) return -1; // 无限库存
    return currentStock[itemId] ?? maxStock;
  }

  // 减少库存
  void reduceStock(String itemId, int count) {
    currentStock = Map.from(currentStock);
    final current = currentStock[itemId] ?? 0;
    currentStock[itemId] = (current - count).clamp(0, 999999);
  }

  // 检查是否需要刷新
  bool needsRefresh(int refreshHours) {
    if (refreshHours <= 0) return false;
    if (lastRefresh == null) return true;
    
    final now = DateTime.now();
    final refreshTime = lastRefresh!.add(Duration(hours: refreshHours));
    return now.isAfter(refreshTime);
  }

  // 刷新商店
  void refresh(List<ShopItem> items) {
    lastRefresh = DateTime.now();
    currentStock = {};
    
    // 重置库存
    for (final item in items) {
      if (item.maxStock > 0) {
        currentStock[item.id] = item.maxStock;
      }
    }
  }
}

// 购买结果
class PurchaseResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? itemData;

  PurchaseResult({
    required this.success,
    required this.message,
    this.itemData,
  });
}
