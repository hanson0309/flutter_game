import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/inventory.dart';
import '../models/player.dart';
import '../models/shop.dart';
import 'audio_service.dart';

class InventoryService extends ChangeNotifier {
  PlayerInventory _inventory = PlayerInventory();

  PlayerInventory get inventory => _inventory;

  // 初始化背包系统
  Future<void> initializeInventory() async {
    try {
      debugPrint('🎒 开始初始化背包系统...');
      await _loadInventory();
      _updateLegacyItems(); // 更新旧版本物品数据
      debugPrint('🎒 背包系统初始化完成，共 ${_inventory.items.length} 个物品');
    } catch (e) {
      debugPrint('🎒 背包系统初始化失败: $e');
    }
  }

  // 更新旧版本物品数据
  void _updateLegacyItems() {
    final itemsToUpdate = <InventoryItem>[];
    
    for (final item in _inventory.items) {
      // 检查需要更新的战斗掉落物品
      if (item.source == '战斗掉落' && item.type == InventoryItemType.material) {
        final updatedType = _getUpdatedItemType(item.itemId);
        if (updatedType != InventoryItemType.material) {
          itemsToUpdate.add(item);
        }
      }
    }
    
    // 移除旧物品并添加更新后的物品
    for (final oldItem in itemsToUpdate) {
      _inventory.removeItem(oldItem.itemId, oldItem.quantity);
      
      // 创建更新后的物品
      final newItem = InventoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_updated',
        itemId: oldItem.itemId,
        name: oldItem.name,
        description: oldItem.description,
        type: _getUpdatedItemType(oldItem.itemId),
        iconPath: oldItem.iconPath,
        itemData: _getUpdatedItemData(oldItem.itemId),
        quantity: oldItem.quantity,
        stackable: oldItem.stackable,
        maxStack: oldItem.maxStack,
        obtainedAt: oldItem.obtainedAt,
        source: oldItem.source,
      );
      
      _inventory.addItem(newItem);
      debugPrint('🎒 更新物品数据: ${oldItem.name} -> 可使用');
    }
    
    if (itemsToUpdate.isNotEmpty) {
      _saveInventory();
      notifyListeners();
    }
  }

  // 获取更新后的物品类型
  InventoryItemType _getUpdatedItemType(String itemId) {
    const itemTypes = {
      'poison_sac': InventoryItemType.consumable,
      'stone_core': InventoryItemType.consumable,
      'earth_crystal': InventoryItemType.consumable,
      'shadow_essence': InventoryItemType.consumable,
      'fire_crystal': InventoryItemType.consumable,
      'dragon_heart': InventoryItemType.consumable,
      'goblin_dagger': InventoryItemType.equipment,
      'cursed_blade': InventoryItemType.equipment,
      'dragon_scale': InventoryItemType.equipment,
    };
    
    return itemTypes[itemId] ?? InventoryItemType.material;
  }

  // 获取更新后的物品数据
  Map<String, dynamic> _getUpdatedItemData(String itemId) {
    const itemDataMap = {
      'poison_sac': {
        'rarity': 'uncommon',
        'sellPrice': 25,
        'heal': -20,
      },
      'stone_core': {
        'rarity': 'uncommon',
        'sellPrice': 30,
        'mana': 20,
      },
      'earth_crystal': {
        'rarity': 'rare',
        'sellPrice': 50,
        'mana': 40,
      },
      'shadow_essence': {
        'rarity': 'rare',
        'sellPrice': 80,
        'exp': 50,
      },
      'fire_crystal': {
        'rarity': 'rare',
        'sellPrice': 60,
        'heal': 30,
      },
      'dragon_heart': {
        'rarity': 'epic',
        'sellPrice': 500,
        'heal': 100,
        'mana': 100,
        'exp': 200,
      },
    };
    
    return Map<String, dynamic>.from(itemDataMap[itemId] ?? {});
  }

  // 比较两个Map是否相等
  bool _mapsEqual(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    if (map1.length != map2.length) return false;
    for (final key in map1.keys) {
      if (!map2.containsKey(key) || map1[key] != map2[key]) return false;
    }
    return true;
  }

  // 从商店购买添加物品
  bool addItemFromShop(ShopItem shopItem, int quantity, String source) {
    final inventoryItem = InventoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itemId: shopItem.id,
      name: shopItem.name,
      description: shopItem.description,
      type: _shopItemTypeToInventoryType(shopItem.type),
      iconPath: shopItem.iconPath,
      itemData: {
        ...shopItem.itemData ?? {},
        'rarity': shopItem.rarity.toString().split('.').last,
      },
      quantity: quantity,
      stackable: _isStackable(shopItem.type),
      maxStack: _getMaxStack(shopItem.type),
      obtainedAt: DateTime.now(),
      source: source,
    );

    final success = _inventory.addItem(inventoryItem);
    if (success) {
      _saveInventory();
      notifyListeners();
      debugPrint('🎒 添加物品: ${shopItem.name} x$quantity');
    }
    return success;
  }

  // 添加自定义物品
  bool addCustomItem({
    required String itemId,
    required String name,
    required String description,
    required InventoryItemType type,
    String? iconPath,
    Map<String, dynamic>? itemData,
    int quantity = 1,
    String? source,
  }) {
    final inventoryItem = InventoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itemId: itemId,
      name: name,
      description: description,
      type: type,
      iconPath: iconPath,
      itemData: itemData ?? {},
      quantity: quantity,
      stackable: _isStackable(_inventoryTypeToShopType(type)),
      maxStack: _getMaxStack(_inventoryTypeToShopType(type)),
      obtainedAt: DateTime.now(),
      source: source ?? '系统奖励',
    );

    final success = _inventory.addItem(inventoryItem);
    if (success) {
      _saveInventory();
      notifyListeners();
      debugPrint('🎒 添加物品: $name x$quantity');
    }
    return success;
  }

  // 使用物品
  ItemUseResult useItem(String itemId, int quantity, Player player) {
    final useResult = _inventory.useItem(itemId, quantity);
    if (useResult == null) {
      return ItemUseResult(
        success: false,
        message: '无法使用该物品',
      );
    }

    // 应用物品效果
    final effects = useResult['effects'] as Map<String, dynamic>;
    final appliedEffects = <String, dynamic>{};

    // 恢复生命值
    if (effects.containsKey('heal')) {
      final healAmount = effects['heal'] as int;
      final oldHealth = player.currentHealth;
      player.currentHealth = (player.currentHealth + healAmount).clamp(0, player.actualMaxHealth);
      appliedEffects['heal'] = player.currentHealth - oldHealth;
    }

    // 恢复法力值
    if (effects.containsKey('mana')) {
      final manaAmount = effects['mana'] as int;
      final oldMana = player.currentMana;
      player.currentMana = (player.currentMana + manaAmount).clamp(0, player.actualMaxMana);
      appliedEffects['mana'] = player.currentMana - oldMana;
    }

    // 增加经验值
    if (effects.containsKey('exp')) {
      final expAmount = effects['exp'] as int;
      player.addExp(expAmount);
      appliedEffects['exp'] = expAmount;
    }

    // 应用幸运加成等特殊效果
    if (effects.containsKey('luck')) {
      appliedEffects['luck'] = effects['luck'];
      appliedEffects['duration'] = effects['duration'];
      // TODO: 实现幸运加成效果
    }

    _saveInventory();
    notifyListeners();

    // 播放使用物品音效
    AudioService().playClickSound();

    debugPrint('🎒 使用物品: ${useResult['name']} x$quantity');

    return ItemUseResult(
      success: true,
      message: '使用成功！',
      effects: appliedEffects,
    );
  }

  // 移除物品
  bool removeItem(String itemId, int quantity) {
    final success = _inventory.removeItem(itemId, quantity);
    if (success) {
      _saveInventory();
      notifyListeners();
      debugPrint('🎒 移除物品: $itemId x$quantity');
    }
    return success;
  }

  // 按分类获取物品
  List<InventoryItem> getItemsByCategory(InventoryCategory category) {
    return _inventory.getItemsByCategory(category);
  }

  // 排序物品
  void sortItems(InventorySortType sortType, {bool ascending = true}) {
    _inventory.sortItems(sortType, ascending: ascending);
    notifyListeners();
  }

  // 查找物品
  InventoryItem? findItem(String itemId) {
    return _inventory.findItem(itemId);
  }

  // 获取物品数量
  int getItemQuantity(String itemId) {
    final item = findItem(itemId);
    return item?.quantity ?? 0;
  }

  // 检查是否有足够的物品
  bool hasEnoughItems(String itemId, int requiredQuantity) {
    return getItemQuantity(itemId) >= requiredQuantity;
  }

  // 获取背包统计信息
  Map<String, dynamic> getStatistics() {
    return _inventory.getStatistics();
  }

  // 清理空物品
  void cleanupEmptyItems() {
    final originalCount = _inventory.items.length;
    _inventory.items = _inventory.items.where((item) => !item.isEmpty).toList();
    final removedCount = originalCount - _inventory.items.length;
    
    if (removedCount > 0) {
      _saveInventory();
      notifyListeners();
      debugPrint('🎒 清理了 $removedCount 个空物品');
    }
  }

  // 扩展背包容量
  bool expandInventory(int additionalSlots) {
    final newMaxSlots = _inventory.maxSlots + additionalSlots;
    _inventory = PlayerInventory(
      items: _inventory.items,
      maxSlots: newMaxSlots,
      categoryLimits: _inventory.categoryLimits,
    );
    
    _saveInventory();
    notifyListeners();
    debugPrint('🎒 背包容量扩展到 $newMaxSlots 个槽位');
    return true;
  }

  // 辅助方法：商店物品类型转背包物品类型
  InventoryItemType _shopItemTypeToInventoryType(ShopItemType shopType) {
    switch (shopType) {
      case ShopItemType.equipment:
        return InventoryItemType.equipment;
      case ShopItemType.technique:
        return InventoryItemType.technique;
      case ShopItemType.consumable:
        return InventoryItemType.consumable;
      case ShopItemType.material:
        return InventoryItemType.material;
      case ShopItemType.special:
        return InventoryItemType.special;
    }
  }

  // 辅助方法：背包物品类型转商店物品类型
  ShopItemType _inventoryTypeToShopType(InventoryItemType inventoryType) {
    switch (inventoryType) {
      case InventoryItemType.equipment:
        return ShopItemType.equipment;
      case InventoryItemType.technique:
        return ShopItemType.technique;
      case InventoryItemType.consumable:
        return ShopItemType.consumable;
      case InventoryItemType.material:
        return ShopItemType.material;
      case InventoryItemType.special:
        return ShopItemType.special;
      case InventoryItemType.quest:
        return ShopItemType.special; // 任务物品归类为特殊物品
    }
  }

  // 辅助方法：判断是否可堆叠
  bool _isStackable(ShopItemType type) {
    switch (type) {
      case ShopItemType.consumable:
      case ShopItemType.material:
        return true;
      case ShopItemType.equipment:
      case ShopItemType.technique:
      case ShopItemType.special:
        return false;
    }
  }

  // 辅助方法：获取最大堆叠数量
  int _getMaxStack(ShopItemType type) {
    switch (type) {
      case ShopItemType.consumable:
        return 99;
      case ShopItemType.material:
        return 999;
      case ShopItemType.equipment:
      case ShopItemType.technique:
      case ShopItemType.special:
        return 1;
    }
  }

  // 保存背包数据
  Future<void> _saveInventory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final inventoryJson = jsonEncode(_inventory.toJson());
      await prefs.setString('player_inventory', inventoryJson);
    } catch (e) {
      debugPrint('保存背包数据失败: $e');
    }
  }

  // 加载背包数据
  Future<void> _loadInventory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final inventoryJson = prefs.getString('player_inventory');
      
      if (inventoryJson != null) {
        final inventoryData = jsonDecode(inventoryJson);
        _inventory = PlayerInventory.fromJson(inventoryData);
        
        // 清理空物品
        cleanupEmptyItems();
      } else {
        // 创建默认背包并添加一些初始物品
        _inventory = PlayerInventory();
        await _addInitialItems();
      }
    } catch (e) {
      debugPrint('加载背包数据失败: $e');
      _inventory = PlayerInventory();
      await _addInitialItems();
    }
  }

  // 添加初始物品
  Future<void> _addInitialItems() async {
    // 添加一些初始消耗品
    addCustomItem(
      itemId: 'starter_healing_pill',
      name: '新手疗伤丹',
      description: '新手专用的疗伤丹药，能够恢复少量生命值',
      type: InventoryItemType.consumable,
      itemData: {
        'healAmount': 50,
        'rarity': 'common',
      },
      quantity: 5,
      source: '新手礼包',
    );

    addCustomItem(
      itemId: 'starter_spirit_pill',
      name: '新手回灵丹',
      description: '新手专用的回灵丹药，能够恢复少量法力值',
      type: InventoryItemType.consumable,
      itemData: {
        'manaAmount': 30,
        'rarity': 'common',
      },
      quantity: 3,
      source: '新手礼包',
    );

    debugPrint('🎒 添加了新手礼包物品');
  }
}
