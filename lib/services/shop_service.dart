import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shop.dart';
import '../models/player.dart';
import 'audio_service.dart';
import 'inventory_service.dart';

class ShopService extends ChangeNotifier {
  List<Shop> _shops = [];
  List<ShopItem> _allItems = [];
  Map<String, PlayerShopData> _playerShopData = {};

  List<Shop> get shops => _shops;
  List<ShopItem> get allItems => _allItems;

  // 初始化商店系统
  Future<void> initializeShops() async {
    try {
      debugPrint('🏪 开始初始化商店系统...');
      _initializeShopData();
      await _loadPlayerShopData();
      _refreshExpiredShops();
      debugPrint('🏪 商店系统初始化完成，共 ${_shops.length} 个商店，${_allItems.length} 种商品');
    } catch (e) {
      debugPrint('🏪 商店系统初始化失败: $e');
    }
  }

  // 初始化商店数据
  void _initializeShopData() {
    // 创建商品
    _allItems = [
      // 装备类
      ShopItem(
        id: 'wooden_sword',
        name: '木剑',
        description: '普通的木制长剑，适合初学者使用',
        type: ShopItemType.equipment,
        rarity: ItemRarity.common,
        prices: [
          ItemPrice(currency: CurrencyType.spiritStones, amount: 100),
        ],
        itemData: {
          'equipmentType': 'weapon',
          'attack': 10,
          'durability': 100,
        },
        maxStock: 5,
        refreshHours: 24,
      ),

      ShopItem(
        id: 'iron_sword',
        name: '铁剑',
        description: '锋利的铁制长剑，比木剑更加坚固',
        type: ShopItemType.equipment,
        rarity: ItemRarity.uncommon,
        prices: [
          ItemPrice(currency: CurrencyType.spiritStones, amount: 500),
        ],
        itemData: {
          'equipmentType': 'weapon',
          'attack': 25,
          'durability': 200,
        },
        maxStock: 3,
        refreshHours: 24,
        playerLevelRequired: 2,
      ),

      ShopItem(
        id: 'steel_armor',
        name: '钢甲',
        description: '坚固的钢制护甲，提供良好的防护',
        type: ShopItemType.equipment,
        rarity: ItemRarity.uncommon,
        prices: [
          ItemPrice(currency: CurrencyType.spiritStones, amount: 800),
        ],
        itemData: {
          'equipmentType': 'armor',
          'defense': 20,
          'durability': 300,
        },
        maxStock: 2,
        refreshHours: 24,
        playerLevelRequired: 3,
      ),

      // 功法类
      ShopItem(
        id: 'basic_cultivation_manual',
        name: '基础修炼手册',
        description: '记录基础修炼方法的手册',
        type: ShopItemType.technique,
        rarity: ItemRarity.common,
        prices: [
          ItemPrice(currency: CurrencyType.spiritStones, amount: 200),
        ],
        itemData: {
          'techniqueType': 'cultivation',
          'expBonus': 0.1,
          'maxLevel': 10,
        },
        maxStock: -1, // 无限库存
      ),

      ShopItem(
        id: 'advanced_sword_technique',
        name: '高级剑法',
        description: '威力强大的剑法技巧',
        type: ShopItemType.technique,
        rarity: ItemRarity.rare,
        prices: [
          ItemPrice(currency: CurrencyType.spiritStones, amount: 2000),
        ],
        itemData: {
          'techniqueType': 'combat',
          'attackBonus': 0.3,
          'maxLevel': 20,
        },
        maxStock: 1,
        refreshHours: 168, // 一周刷新
        playerLevelRequired: 5,
      ),

      // 消耗品类
      ShopItem(
        id: 'healing_pill',
        name: '疗伤丹',
        description: '能够快速恢复生命值的丹药',
        type: ShopItemType.consumable,
        rarity: ItemRarity.common,
        prices: [
          ItemPrice(currency: CurrencyType.spiritStones, amount: 50),
        ],
        itemData: {
          'healAmount': 100,
          'stackable': true,
        },
        maxStock: 10,
        refreshHours: 12,
      ),

      ShopItem(
        id: 'spirit_pill',
        name: '回灵丹',
        description: '能够快速恢复法力值的丹药',
        type: ShopItemType.consumable,
        rarity: ItemRarity.common,
        prices: [
          ItemPrice(currency: CurrencyType.spiritStones, amount: 60),
        ],
        itemData: {
          'manaAmount': 50,
          'stackable': true,
        },
        maxStock: 10,
        refreshHours: 12,
      ),

      ShopItem(
        id: 'exp_pill',
        name: '经验丹',
        description: '服用后能够获得大量修炼经验',
        type: ShopItemType.consumable,
        rarity: ItemRarity.uncommon,
        prices: [
          ItemPrice(currency: CurrencyType.spiritStones, amount: 300),
        ],
        itemData: {
          'expAmount': 500,
          'stackable': true,
        },
        maxStock: 5,
        refreshHours: 24,
        playerLevelRequired: 2,
      ),

      // 戒指类装备
      ShopItem(
        id: 'bronze_ring',
        name: '青铜戒指',
        description: '简单的青铜戒指，能够提供基础的法力增强',
        type: ShopItemType.equipment,
        rarity: ItemRarity.common,
        prices: [
          ItemPrice(currency: CurrencyType.spiritStones, amount: 150),
        ],
        itemData: {
          'equipmentType': 'ring',
          'mana': 20,
        },
        maxStock: 3,
        refreshHours: 24,
      ),

      ShopItem(
        id: 'spirit_ring',
        name: '灵力戒指',
        description: '蕴含灵力的戒指，能够增强修炼效果',
        type: ShopItemType.equipment,
        rarity: ItemRarity.rare,
        prices: [
          ItemPrice(currency: CurrencyType.spiritStones, amount: 1200),
        ],
        itemData: {
          'equipmentType': 'ring',
          'mana': 60,
          'cultivation_speed': 1.1,
        },
        maxStock: 2,
        refreshHours: 48,
        playerLevelRequired: 2,
      ),

      // 项链类装备
      ShopItem(
        id: 'jade_necklace',
        name: '玉石项链',
        description: '温润的玉石项链，能够平静心神，增强防御',
        type: ShopItemType.equipment,
        rarity: ItemRarity.uncommon,
        prices: [
          ItemPrice(currency: CurrencyType.spiritStones, amount: 400),
        ],
        itemData: {
          'equipmentType': 'necklace',
          'defense': 15,
          'health': 40,
        },
        maxStock: 2,
        refreshHours: 24,
        playerLevelRequired: 1,
      ),

      // 靴子类装备
      ShopItem(
        id: 'cloth_boots',
        name: '布靴',
        description: '简单的布制靴子，轻便舒适',
        type: ShopItemType.equipment,
        rarity: ItemRarity.common,
        prices: [
          ItemPrice(currency: CurrencyType.spiritStones, amount: 120),
        ],
        itemData: {
          'equipmentType': 'boots',
          'defense': 5,
        },
        maxStock: 4,
        refreshHours: 24,
      ),

      ShopItem(
        id: 'wind_boots',
        name: '疾风靴',
        description: '蕴含风之力的靴子，能够提升移动和闪避能力',
        type: ShopItemType.equipment,
        rarity: ItemRarity.rare,
        prices: [
          ItemPrice(currency: CurrencyType.spiritStones, amount: 1000),
        ],
        itemData: {
          'equipmentType': 'boots',
          'defense': 25,
          'dodge_rate': 0.08,
        },
        maxStock: 1,
        refreshHours: 48,
        playerLevelRequired: 2,
      ),

      // 腰带类装备
      ShopItem(
        id: 'leather_belt',
        name: '皮革腰带',
        description: '坚韧的皮革腰带，能够提供额外的防护',
        type: ShopItemType.equipment,
        rarity: ItemRarity.common,
        prices: [
          ItemPrice(currency: CurrencyType.spiritStones, amount: 180),
        ],
        itemData: {
          'equipmentType': 'belt',
          'defense': 8,
          'health': 25,
        },
        maxStock: 3,
        refreshHours: 24,
      ),

      // 手套类装备
      ShopItem(
        id: 'cloth_gloves',
        name: '布手套',
        description: '简单的布制手套，能够保护双手',
        type: ShopItemType.equipment,
        rarity: ItemRarity.common,
        prices: [
          ItemPrice(currency: CurrencyType.spiritStones, amount: 100),
        ],
        itemData: {
          'equipmentType': 'gloves',
          'attack': 5,
          'defense': 3,
        },
        maxStock: 4,
        refreshHours: 24,
      ),

      ShopItem(
        id: 'iron_gauntlets',
        name: '铁制护手',
        description: '坚固的铁制护手，能够大幅提升攻击和防御',
        type: ShopItemType.equipment,
        rarity: ItemRarity.uncommon,
        prices: [
          ItemPrice(currency: CurrencyType.spiritStones, amount: 600),
        ],
        itemData: {
          'equipmentType': 'gloves',
          'attack': 18,
          'defense': 12,
        },
        maxStock: 2,
        refreshHours: 24,
        playerLevelRequired: 1,
      ),

      // 头盔类装备
      ShopItem(
        id: 'cloth_hat',
        name: '布帽',
        description: '简单的布制帽子，能够提供基础防护',
        type: ShopItemType.equipment,
        rarity: ItemRarity.common,
        prices: [
          ItemPrice(currency: CurrencyType.spiritStones, amount: 130),
        ],
        itemData: {
          'equipmentType': 'helmet',
          'defense': 6,
          'health': 20,
        },
        maxStock: 3,
        refreshHours: 24,
      ),

      ShopItem(
        id: 'iron_helmet',
        name: '铁盔',
        description: '坚固的铁制头盔，能够有效保护头部',
        type: ShopItemType.equipment,
        rarity: ItemRarity.uncommon,
        prices: [
          ItemPrice(currency: CurrencyType.spiritStones, amount: 700),
        ],
        itemData: {
          'equipmentType': 'helmet',
          'defense': 22,
          'health': 60,
        },
        maxStock: 2,
        refreshHours: 24,
        playerLevelRequired: 1,
      ),

      // 符文类装备
      ShopItem(
        id: 'power_rune',
        name: '力量符文',
        description: '蕴含力量之源的神秘符文，能够大幅提升攻击力',
        type: ShopItemType.equipment,
        rarity: ItemRarity.rare,
        prices: [
          ItemPrice(currency: CurrencyType.spiritStones, amount: 1500),
        ],
        itemData: {
          'equipmentType': 'rune',
          'attack': 45,
          'critical_rate': 0.08,
        },
        maxStock: 1,
        refreshHours: 72,
        playerLevelRequired: 2,
      ),

      // 宝石类装备
      ShopItem(
        id: 'ruby_gem',
        name: '红宝石',
        description: '炽热的红宝石，能够增强攻击力和暴击',
        type: ShopItemType.equipment,
        rarity: ItemRarity.rare,
        prices: [
          ItemPrice(currency: CurrencyType.spiritStones, amount: 1300),
        ],
        itemData: {
          'equipmentType': 'gem',
          'attack': 35,
          'critical_rate': 0.12,
        },
        maxStock: 1,
        refreshHours: 72,
        playerLevelRequired: 2,
      ),

      ShopItem(
        id: 'sapphire_gem',
        name: '蓝宝石',
        description: '深邃的蓝宝石，能够增强法力和防御',
        type: ShopItemType.equipment,
        rarity: ItemRarity.rare,
        prices: [
          ItemPrice(currency: CurrencyType.spiritStones, amount: 1300),
        ],
        itemData: {
          'equipmentType': 'gem',
          'defense': 30,
          'mana': 70,
        },
        maxStock: 1,
        refreshHours: 72,
        playerLevelRequired: 2,
      ),

      // 特殊物品
      ShopItem(
        id: 'lucky_charm',
        name: '幸运符',
        description: '增加获得稀有物品概率的神秘符咒',
        type: ShopItemType.special,
        rarity: ItemRarity.epic,
        prices: [
          ItemPrice(currency: CurrencyType.spiritStones, amount: 5000),
        ],
        itemData: {
          'luckBonus': 0.1,
          'duration': 3600, // 1小时
        },
        maxStock: 1,
        refreshHours: 168, // 一周刷新
        playerLevelRequired: 10,
      ),
    ];

    // 创建商店
    _shops = [
      Shop(
        id: 'general_shop',
        name: '杂货铺',
        description: '售卖各种基础物品的商店',
        type: ShopType.general,
        itemIds: [
          'wooden_sword',
          'healing_pill',
          'spirit_pill',
          'basic_cultivation_manual',
          'cloth_boots',
          'cloth_gloves',
          'cloth_hat',
          'leather_belt',
          'bronze_ring',
        ],
        refreshHours: 24,
      ),

      Shop(
        id: 'weapon_shop',
        name: '兵器坊',
        description: '专门售卖武器装备的商店',
        type: ShopType.equipment,
        itemIds: [
          'wooden_sword',
          'iron_sword',
          'steel_armor',
          'iron_gauntlets',
          'iron_helmet',
          'jade_necklace',
          'wind_boots',
          'spirit_ring',
        ],
        refreshHours: 24,
        playerLevelRequired: 2,
      ),

      Shop(
        id: 'technique_pavilion',
        name: '功法阁',
        description: '收藏各种功法秘籍的地方',
        type: ShopType.technique,
        itemIds: [
          'basic_cultivation_manual',
          'advanced_sword_technique',
        ],
        refreshHours: 168, // 一周刷新
        playerLevelRequired: 3,
      ),

      Shop(
        id: 'alchemy_shop',
        name: '丹药房',
        description: '售卖各种丹药的商店',
        type: ShopType.consumable,
        itemIds: [
          'healing_pill',
          'spirit_pill',
          'exp_pill',
        ],
        refreshHours: 12,
      ),

      Shop(
        id: 'rare_goods',
        name: '奇珍阁',
        description: '售卖稀有物品的神秘商店',
        type: ShopType.limited,
        itemIds: [
          'lucky_charm',
          'advanced_sword_technique',
          'power_rune',
          'ruby_gem',
          'sapphire_gem',
        ],
        refreshHours: 168,
        playerLevelRequired: 8,
      ),
    ];
  }

  // 获取商店
  Shop? getShop(String shopId) {
    try {
      return _shops.firstWhere((shop) => shop.id == shopId);
    } catch (e) {
      return null;
    }
  }

  // 获取商品
  ShopItem? getItem(String itemId) {
    try {
      return _allItems.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  // 获取商店的可用商品
  List<ShopItem> getShopItems(String shopId, Player player) {
    final shop = getShop(shopId);
    if (shop == null) return [];

    return shop.itemIds
        .map((id) => getItem(id))
        .where((item) => item != null && _canPlayerBuyItem(item!, player))
        .cast<ShopItem>()
        .toList();
  }

  // 检查玩家是否可以购买商品
  bool _canPlayerBuyItem(ShopItem item, Player player) {
    // 检查等级要求
    if (player.level < item.playerLevelRequired) return false;

    // 检查是否过期
    if (item.isLimited && item.availableUntil != null) {
      if (DateTime.now().isAfter(item.availableUntil!)) return false;
    }

    // 检查库存
    final shopData = _getPlayerShopData(item.id);
    final currentStock = shopData.getCurrentStock(item.id, item.maxStock);
    if (currentStock == 0) return false;

    return true;
  }

  // 获取玩家商店数据
  PlayerShopData _getPlayerShopData(String shopId) {
    return _playerShopData[shopId] ??= PlayerShopData(shopId: shopId);
  }

  // 购买商品
  PurchaseResult purchaseItem(String itemId, Player player, InventoryService inventoryService, {int quantity = 1}) {
    final item = getItem(itemId);
    if (item == null) {
      return PurchaseResult(success: false, message: '商品不存在');
    }

    // 检查购买条件
    if (!_canPlayerBuyItem(item, player)) {
      return PurchaseResult(success: false, message: '不满足购买条件');
    }

    // 检查库存
    final shopData = _getPlayerShopData(itemId);
    final currentStock = shopData.getCurrentStock(itemId, item.maxStock);
    if (currentStock != -1 && currentStock < quantity) {
      return PurchaseResult(success: false, message: '库存不足');
    }

    // 检查价格和货币
    final price = item.cheapestPrice;
    if (price == null) {
      return PurchaseResult(success: false, message: '商品价格错误');
    }

    final totalCost = price.actualPrice * quantity;
    if (!_hasEnoughCurrency(player, price.currency, totalCost)) {
      return PurchaseResult(success: false, message: '${price.currencyName}不足');
    }

    // 扣除货币
    _deductCurrency(player, price.currency, totalCost);

    // 减少库存
    if (currentStock != -1) {
      shopData.reduceStock(itemId, quantity);
    }

    // 记录购买
    shopData.addPurchase(itemId, quantity);

    // 将物品添加到背包
    final addSuccess = inventoryService.addItemFromShop(item, quantity, '商店购买');
    if (!addSuccess) {
      return PurchaseResult(success: false, message: '背包空间不足');
    }

    // 保存数据
    _savePlayerShopData();

    // 播放购买音效
    AudioService().playCoinsSound();

    debugPrint('🏪 购买成功: ${item.name} x$quantity，花费 ${price.displayText}');

    return PurchaseResult(
      success: true,
      message: '购买成功！物品已添加到背包',
      itemData: {'itemId': itemId, 'quantity': quantity},
    );
  }

  // 检查是否有足够货币
  bool _hasEnoughCurrency(Player player, CurrencyType currency, int amount) {
    switch (currency) {
      case CurrencyType.spiritStones:
        return player.spiritStones >= amount;
      case CurrencyType.jadePearls:
        // TODO: 实现玉珠系统
        return false;
      case CurrencyType.contribution:
        // TODO: 实现贡献点系统
        return false;
    }
  }

  // 扣除货币
  void _deductCurrency(Player player, CurrencyType currency, int amount) {
    switch (currency) {
      case CurrencyType.spiritStones:
        player.spiritStones = (player.spiritStones - amount).clamp(0, 999999999);
        break;
      case CurrencyType.jadePearls:
        // TODO: 实现玉珠系统
        break;
      case CurrencyType.contribution:
        // TODO: 实现贡献点系统
        break;
    }
  }

  // 给予物品给玩家
  Map<String, dynamic> _giveItemToPlayer(ShopItem item, Player player, int quantity) {
    final itemData = item.itemData ?? {};
    
    switch (item.type) {
      case ShopItemType.equipment:
        // TODO: 实现装备给予逻辑
        return {'type': 'equipment', 'data': itemData, 'quantity': quantity};
        
      case ShopItemType.technique:
        // TODO: 实现功法给予逻辑
        return {'type': 'technique', 'data': itemData, 'quantity': quantity};
        
      case ShopItemType.consumable:
        // 消耗品直接使用效果
        _applyConsumableEffect(itemData, player, quantity);
        return {'type': 'consumable', 'data': itemData, 'quantity': quantity};
        
      case ShopItemType.material:
        // TODO: 实现材料给予逻辑
        return {'type': 'material', 'data': itemData, 'quantity': quantity};
        
      case ShopItemType.special:
        // TODO: 实现特殊物品给予逻辑
        return {'type': 'special', 'data': itemData, 'quantity': quantity};
    }
  }

  // 应用消耗品效果
  void _applyConsumableEffect(Map<String, dynamic> itemData, Player player, int quantity) {
    if (itemData.containsKey('healAmount')) {
      final healAmount = (itemData['healAmount'] as int) * quantity;
      player.currentHealth = (player.currentHealth + healAmount).clamp(0, player.actualMaxHealth);
      debugPrint('🏪 恢复生命值: $healAmount');
    }
    
    if (itemData.containsKey('manaAmount')) {
      final manaAmount = (itemData['manaAmount'] as int) * quantity;
      player.currentMana = (player.currentMana + manaAmount).clamp(0, player.actualMaxMana);
      debugPrint('🏪 恢复法力值: $manaAmount');
    }
    
    if (itemData.containsKey('expAmount')) {
      final expAmount = (itemData['expAmount'] as int) * quantity;
      player.addExp(expAmount);
      debugPrint('🏪 获得经验值: $expAmount');
    }
  }

  // 刷新过期商店
  void _refreshExpiredShops() {
    for (final shop in _shops) {
      final shopData = _getPlayerShopData(shop.id);
      if (shopData.needsRefresh(shop.refreshHours)) {
        final shopItems = shop.itemIds.map((id) => getItem(id)).where((item) => item != null).cast<ShopItem>().toList();
        shopData.refresh(shopItems);
        debugPrint('🏪 刷新商店: ${shop.name}');
      }
    }
  }

  // 获取商店统计
  Map<String, dynamic> getShopStatistics() {
    return {
      'totalShops': _shops.length,
      'totalItems': _allItems.length,
      'availableShops': _shops.where((shop) => shop.isUnlocked).length,
    };
  }

  // 保存玩家商店数据
  Future<void> _savePlayerShopData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataJson = _playerShopData.map((key, value) => MapEntry(key, value.toJson()));
      await prefs.setString('player_shop_data', jsonEncode(dataJson));
    } catch (e) {
      debugPrint('保存商店数据失败: $e');
    }
  }

  // 加载玩家商店数据
  Future<void> _loadPlayerShopData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataJson = prefs.getString('player_shop_data');
      
      if (dataJson != null) {
        final dataMap = jsonDecode(dataJson) as Map<String, dynamic>;
        _playerShopData = dataMap.map((key, value) => 
          MapEntry(key, PlayerShopData.fromJson(value))
        );
      }
    } catch (e) {
      debugPrint('加载商店数据失败: $e');
      _playerShopData = {};
    }
  }
}
