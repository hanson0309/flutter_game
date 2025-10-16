import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/inventory.dart';
import '../models/player.dart';
import '../services/inventory_service.dart';
import '../services/audio_service.dart';
import '../providers/game_provider.dart';
import '../widgets/swipe_back_wrapper.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  InventorySortType _currentSort = InventorySortType.obtainTime;
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
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
          '背包',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1a1a1a),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.build, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushNamed('/equipment_synthesis');
            },
            tooltip: '装备合成',
          ),
          PopupMenuButton<InventorySortType>(
            icon: const Icon(Icons.sort, color: Colors.white),
            onSelected: (sortType) {
              setState(() {
                if (_currentSort == sortType) {
                  _sortAscending = !_sortAscending;
                } else {
                  _currentSort = sortType;
                  _sortAscending = true;
                }
              });
              Provider.of<InventoryService>(context, listen: false)
                  .sortItems(sortType, ascending: _sortAscending);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: InventorySortType.name,
                child: Text('按名称排序'),
              ),
              const PopupMenuItem(
                value: InventorySortType.type,
                child: Text('按类型排序'),
              ),
              const PopupMenuItem(
                value: InventorySortType.quality,
                child: Text('按品质排序'),
              ),
              const PopupMenuItem(
                value: InventorySortType.quantity,
                child: Text('按数量排序'),
              ),
              const PopupMenuItem(
                value: InventorySortType.obtainTime,
                child: Text('按获得时间排序'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFe94560),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          isScrollable: true,
          tabs: const [
            Tab(text: '全部'),
            Tab(text: '装备'),
            Tab(text: '消耗品'),
            Tab(text: '材料'),
            Tab(text: '功法'),
            Tab(text: '特殊'),
          ],
        ),
      ),
      body: Consumer2<InventoryService, GameProvider>(
        builder: (context, inventoryService, gameProvider, child) {
          return Column(
            children: [
              // 背包信息栏
              _buildInventoryHeader(inventoryService),
              
              // 物品列表
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildItemGrid(inventoryService, gameProvider, InventoryCategory.all),
                    _buildItemGrid(inventoryService, gameProvider, InventoryCategory.equipment),
                    _buildItemGrid(inventoryService, gameProvider, InventoryCategory.consumable),
                    _buildItemGrid(inventoryService, gameProvider, InventoryCategory.material),
                    _buildItemGrid(inventoryService, gameProvider, InventoryCategory.technique),
                    _buildItemGrid(inventoryService, gameProvider, InventoryCategory.special),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInventoryHeader(InventoryService inventoryService) {
    final stats = inventoryService.getStatistics();
    final usedSlots = stats['usedSlots'] as int;
    final maxSlots = stats['maxSlots'] as int;
    final totalQuantity = stats['totalQuantity'] as int;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory, color: Color(0xFFe94560), size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '背包容量: $usedSlots/$maxSlots',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '物品总数: $totalQuantity',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // 容量进度条
          SizedBox(
            width: 100,
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: usedSlots / maxSlots,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    usedSlots / maxSlots > 0.8 ? Colors.red : const Color(0xFFe94560),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(usedSlots / maxSlots * 100).round()}%',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemGrid(InventoryService inventoryService, GameProvider gameProvider, InventoryCategory category) {
    final items = inventoryService.getItemsByCategory(category);
    
    if (items.isEmpty) {
      return _buildEmptyState(_getEmptyMessage(category));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItemCard(item, inventoryService, gameProvider);
      },
    );
  }

  Widget _buildItemCard(InventoryItem item, InventoryService inventoryService, GameProvider gameProvider) {
    return GestureDetector(
      onTap: () => _showItemDetails(item, inventoryService, gameProvider),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a1a),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: item.qualityColor.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            // 物品图标
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                child: item.iconPath != null
                    ? Image.asset(
                        item.iconPath!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => 
                            _buildDefaultIcon(item.type),
                      )
                    : _buildDefaultIcon(item.type),
              ),
            ),
            
            // 物品信息
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        color: item.qualityColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    if (item.quantity > 1) ...[
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultIcon(InventoryItemType type) {
    IconData icon;
    Color color;
    
    switch (type) {
      case InventoryItemType.equipment:
        icon = Icons.shield;
        color = Colors.orange;
        break;
      case InventoryItemType.consumable:
        icon = Icons.local_pharmacy;
        color = Colors.green;
        break;
      case InventoryItemType.material:
        icon = Icons.build;
        color = Colors.brown;
        break;
      case InventoryItemType.technique:
        icon = Icons.book;
        color = Colors.purple;
        break;
      case InventoryItemType.special:
        icon = Icons.star;
        color = Colors.yellow;
        break;
      case InventoryItemType.quest:
        icon = Icons.assignment;
        color = Colors.blue;
        break;
    }

    return Icon(icon, color: color, size: 32);
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2,
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

  String _getEmptyMessage(InventoryCategory category) {
    switch (category) {
      case InventoryCategory.all:
        return '背包空空如也\n去商店购买一些物品吧！';
      case InventoryCategory.equipment:
        return '还没有装备\n去兵器坊看看吧！';
      case InventoryCategory.consumable:
        return '没有消耗品\n去丹药房购买一些丹药！';
      case InventoryCategory.material:
        return '没有材料\n通过战斗和探索获得材料！';
      case InventoryCategory.technique:
        return '还没有功法\n去功法阁学习功法！';
      case InventoryCategory.special:
        return '没有特殊物品\n去奇珍阁寻找宝物！';
      case InventoryCategory.quest:
        return '没有任务物品';
    }
  }

  void _showItemDetails(InventoryItem item, InventoryService inventoryService, GameProvider gameProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: Row(
          children: [
            _buildDefaultIcon(item.type),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      color: item.qualityColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    item.qualityText,
                    style: TextStyle(
                      color: item.qualityColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.description,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 16),
              
              // 物品属性
              if (item.itemData.isNotEmpty) ...[
                const Text(
                  '属性:',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                ...item.itemData.entries.map((entry) => 
                  _buildPropertyRow(entry.key, entry.value)
                ).toList(),
                const SizedBox(height: 16),
              ],
              
              // 物品信息
              _buildInfoRow('数量', '${item.quantity}'),
              _buildInfoRow('获得时间', _formatDateTime(item.obtainedAt)),
              if (item.source != null)
                _buildInfoRow('来源', item.source!),
            ],
          ),
        ),
        actions: [
          if (item.canUse) ...[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _useItem(item, inventoryService, gameProvider);
              },
              child: const Text(
                '使用',
                style: TextStyle(color: Color(0xFFe94560)),
              ),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '关闭',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyRow(String key, dynamic value) {
    String displayKey = key;
    String displayValue = value.toString();
    
    switch (key) {
      case 'attack':
        displayKey = '攻击力';
        break;
      case 'defense':
        displayKey = '防御力';
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
      case 'rarity':
        return const SizedBox.shrink(); // 稀有度已在标题显示
    }
    
    if (displayKey == key) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            displayKey,
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
          Text(
            displayValue,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _useItem(InventoryItem item, InventoryService inventoryService, GameProvider gameProvider) {
    final player = gameProvider.player;
    if (player == null) return;

    // 显示使用数量选择对话框
    if (item.quantity > 1) {
      _showQuantityDialog(item, inventoryService, player);
    } else {
      _performUseItem(item, 1, inventoryService, player);
    }
  }

  void _showQuantityDialog(InventoryItem item, InventoryService inventoryService, Player player) {
    int selectedQuantity = 1;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1a1a1a),
          title: Text(
            '使用 ${item.name}',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '选择使用数量 (最多 ${item.quantity})',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    onPressed: selectedQuantity > 1 
                        ? () => setState(() => selectedQuantity--)
                        : null,
                    icon: const Icon(Icons.remove, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      '$selectedQuantity',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  IconButton(
                    onPressed: selectedQuantity < item.quantity 
                        ? () => setState(() => selectedQuantity++)
                        : null,
                    icon: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '取消',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performUseItem(item, selectedQuantity, inventoryService, player);
              },
              child: const Text(
                '使用',
                style: TextStyle(color: Color(0xFFe94560)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _performUseItem(InventoryItem item, int quantity, InventoryService inventoryService, Player player) {
    final result = inventoryService.useItem(item.itemId, quantity, player);
    
    if (result.success) {
      _showUseResultDialog(item, quantity, result);
    } else {
      _showErrorDialog(result.message);
    }
  }

  void _showUseResultDialog(InventoryItem item, int quantity, ItemUseResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text(
              '使用成功！',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '使用了 ${item.name} x$quantity',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            if (result.effects != null && result.effects!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                '效果:',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 8),
              ...result.effects!.entries.map((entry) => 
                _buildEffectRow(entry.key, entry.value)
              ).toList(),
            ],
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

  Widget _buildEffectRow(String key, dynamic value) {
    String effectText = '';
    Color effectColor = Colors.white;
    
    switch (key) {
      case 'heal':
        effectText = '恢复生命值 +$value';
        effectColor = Colors.green;
        break;
      case 'mana':
        effectText = '恢复法力值 +$value';
        effectColor = Colors.blue;
        break;
      case 'exp':
        effectText = '获得经验值 +$value';
        effectColor = Colors.yellow;
        break;
      case 'luck':
        effectText = '幸运加成 +${(value * 100).round()}%';
        effectColor = Colors.purple;
        break;
    }
    
    if (effectText.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.arrow_forward, color: effectColor, size: 16),
          const SizedBox(width: 4),
          Text(
            effectText,
            style: TextStyle(color: effectColor, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text(
              '使用失败',
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
