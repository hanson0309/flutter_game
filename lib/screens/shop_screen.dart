import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shop.dart';
import '../models/player.dart';
import '../services/shop_service.dart';
import '../services/audio_service.dart';
import '../providers/game_provider.dart';
import '../widgets/swipe_back_wrapper.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SwipeBackScaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        title: const Text(
          '修仙商店',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1a1a1a),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFe94560),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          isScrollable: true,
          tabs: const [
            Tab(text: '杂货铺'),
            Tab(text: '兵器坊'),
            Tab(text: '功法阁'),
            Tab(text: '丹药房'),
            Tab(text: '奇珍阁'),
          ],
        ),
      ),
      body: Consumer2<ShopService, GameProvider>(
        builder: (context, shopService, gameProvider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildShopView(shopService, gameProvider, 'general_shop'),
              _buildShopView(shopService, gameProvider, 'weapon_shop'),
              _buildShopView(shopService, gameProvider, 'technique_pavilion'),
              _buildShopView(shopService, gameProvider, 'alchemy_shop'),
              _buildShopView(shopService, gameProvider, 'rare_goods'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShopView(ShopService shopService, GameProvider gameProvider, String shopId) {
    final shop = shopService.getShop(shopId);
    final player = gameProvider.player;
    
    if (shop == null || player == null) {
      return _buildEmptyState('商店暂时关闭');
    }

    // 检查商店是否解锁
    if (player.level < shop.playerLevelRequired) {
      return _buildLockedShop(shop);
    }

    final items = shopService.getShopItems(shopId, player);
    
    if (items.isEmpty) {
      return _buildEmptyState('商店暂时没有商品\n请稍后再来看看');
    }

    return Column(
      children: [
        // 商店信息栏
        _buildShopHeader(shop, player),
        
        // 商品列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildItemCard(item, shopService, gameProvider);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShopHeader(Shop shop, Player player) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getShopIcon(shop.type),
                color: const Color(0xFFe94560),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                shop.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _buildCurrencyDisplay(player),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            shop.description,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyDisplay(Player player) {
    return Row(
      children: [
        const Icon(Icons.diamond, color: Colors.blue, size: 16),
        const SizedBox(width: 4),
        Text(
          '${player.spiritStones}',
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildItemCard(ShopItem item, ShopService shopService, GameProvider gameProvider) {
    final player = gameProvider.player!;
    final price = item.cheapestPrice;
    final canAfford = price != null && _canPlayerAfford(player, price);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.rarityColor.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 商品标题和稀有度
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildItemTypeIcon(item.type),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.name,
                            style: TextStyle(
                              color: item.rarityColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildRarityBadge(item.rarity),
            ],
          ),

          const SizedBox(height: 12),

          // 商品属性
          if (item.itemData != null)
            _buildItemStats(item.itemData!),

          const SizedBox(height: 12),

          // 价格和购买按钮
          Row(
            children: [
              if (price != null) ...[
                Icon(
                  _getCurrencyIcon(price.currency),
                  color: _getCurrencyColor(price.currency),
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  price.displayText,
                  style: TextStyle(
                    color: canAfford ? Colors.white : Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: canAfford 
                    ? () => _purchaseItem(item, shopService, gameProvider)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canAfford 
                      ? const Color(0xFFe94560) 
                      : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(canAfford ? '购买' : '买不起'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemTypeIcon(ShopItemType type) {
    IconData icon;
    Color color;
    
    switch (type) {
      case ShopItemType.equipment:
        icon = Icons.shield;
        color = Colors.orange;
        break;
      case ShopItemType.technique:
        icon = Icons.book;
        color = Colors.purple;
        break;
      case ShopItemType.consumable:
        icon = Icons.local_pharmacy;
        color = Colors.green;
        break;
      case ShopItemType.material:
        icon = Icons.build;
        color = Colors.brown;
        break;
      case ShopItemType.special:
        icon = Icons.star;
        color = Colors.yellow;
        break;
    }

    return Icon(icon, color: color, size: 20);
  }

  Widget _buildRarityBadge(ItemRarity rarity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getRarityColor(rarity).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getRarityColor(rarity)),
      ),
      child: Text(
        _getRarityText(rarity),
        style: TextStyle(
          color: _getRarityColor(rarity),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildItemStats(Map<String, dynamic> itemData) {
    final stats = <Widget>[];
    
    itemData.forEach((key, value) {
      String displayKey = key;
      String displayValue = value.toString();
      
      switch (key) {
        case 'attack':
          displayKey = '攻击力';
          break;
        case 'defense':
          displayKey = '防御力';
          break;
        case 'durability':
          displayKey = '耐久度';
          break;
        case 'healAmount':
          displayKey = '恢复生命';
          break;
        case 'manaAmount':
          displayKey = '恢复法力';
          break;
        case 'expAmount':
          displayKey = '经验值';
          break;
        case 'expBonus':
          displayKey = '经验加成';
          displayValue = '${(double.parse(value.toString()) * 100).round()}%';
          break;
        case 'attackBonus':
          displayKey = '攻击加成';
          displayValue = '${(double.parse(value.toString()) * 100).round()}%';
          break;
      }
      
      if (displayKey != key) {
        stats.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Text(
                  '$displayKey: ',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                Text(
                  displayValue,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      }
    });
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: stats,
    );
  }

  Widget _buildLockedShop(Shop shop) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            '${shop.name}已锁定',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '需要达到${_getLevelName(shop.playerLevelRequired)}才能解锁',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // 辅助方法
  IconData _getShopIcon(ShopType type) {
    switch (type) {
      case ShopType.general:
        return Icons.store;
      case ShopType.equipment:
        return Icons.shield;
      case ShopType.technique:
        return Icons.book;
      case ShopType.consumable:
        return Icons.local_pharmacy;
      case ShopType.limited:
        return Icons.star;
      case ShopType.contribution:
        return Icons.emoji_events;
    }
  }

  IconData _getCurrencyIcon(CurrencyType currency) {
    switch (currency) {
      case CurrencyType.spiritStones:
        return Icons.diamond;
      case CurrencyType.jadePearls:
        return Icons.circle;
      case CurrencyType.contribution:
        return Icons.star;
    }
  }

  Color _getCurrencyColor(CurrencyType currency) {
    switch (currency) {
      case CurrencyType.spiritStones:
        return Colors.blue;
      case CurrencyType.jadePearls:
        return Colors.green;
      case CurrencyType.contribution:
        return Colors.purple;
    }
  }

  Color _getRarityColor(ItemRarity rarity) {
    switch (rarity) {
      case ItemRarity.common:
        return Colors.grey;
      case ItemRarity.uncommon:
        return Colors.green;
      case ItemRarity.rare:
        return Colors.blue;
      case ItemRarity.epic:
        return Colors.purple;
      case ItemRarity.legendary:
        return Colors.orange;
      case ItemRarity.mythic:
        return Colors.red;
    }
  }

  String _getRarityText(ItemRarity rarity) {
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

  String _getLevelName(int level) {
    // 这里应该从CultivationRealm获取，简化处理
    const levelNames = [
      '凡人', '练气期', '筑基期', '金丹期', '元婴期', '化神期'
    ];
    if (level < levelNames.length) {
      return levelNames[level];
    }
    return '第${level}境界';
  }

  bool _canPlayerAfford(Player player, ItemPrice price) {
    switch (price.currency) {
      case CurrencyType.spiritStones:
        return player.spiritStones >= price.actualPrice;
      case CurrencyType.jadePearls:
      case CurrencyType.contribution:
        return false; // 暂未实现其他货币
    }
  }

  void _purchaseItem(ShopItem item, ShopService shopService, GameProvider gameProvider) {
    AudioService().playClickSound();
    
    final result = shopService.purchaseItem(item.id, gameProvider.player!);
    
    if (result.success) {
      _showPurchaseSuccessDialog(item, result);
    } else {
      _showPurchaseFailDialog(result.message);
    }
  }

  void _showPurchaseSuccessDialog(ShopItem item, PurchaseResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            const Text(
              '购买成功！',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '成功购买：${item.name}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '物品已添加到背包中',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '确定',
              style: TextStyle(color: Color(0xFFe94560)),
            ),
          ),
        ],
      ),
    );
  }

  void _showPurchaseFailDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text(
              '购买失败',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '确定',
              style: TextStyle(color: Color(0xFFe94560)),
            ),
          ),
        ],
      ),
    );
  }
}
