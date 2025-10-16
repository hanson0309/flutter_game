import 'inventory.dart';

// 合成材料数据
class SynthesisMaterials {
  // 预定义的合成材料
  static const List<Map<String, dynamic>> materialData = [
    // 基础材料
    {
      'id': 'iron_ore',
      'name': '铁矿石',
      'description': '常见的铁矿石，锻造武器的基础材料',
      'type': 'material',
      'rarity': 'common',
      'sellPrice': 10,
    },
    {
      'id': 'wood',
      'name': '木材',
      'description': '坚硬的木材，制作武器手柄的材料',
      'type': 'material',
      'rarity': 'common',
      'sellPrice': 5,
    },
    {
      'id': 'beast_hide',
      'name': '妖兽皮革',
      'description': '从妖兽身上剥下的坚韧皮革',
      'type': 'material',
      'rarity': 'uncommon',
      'sellPrice': 20,
    },
    {
      'id': 'thread',
      'name': '丝线',
      'description': '用于缝制装备的坚韧丝线',
      'type': 'material',
      'rarity': 'common',
      'sellPrice': 8,
    },
    {
      'id': 'bronze_ingot',
      'name': '青铜锭',
      'description': '精炼的青铜锭，制作饰品的材料',
      'type': 'material',
      'rarity': 'common',
      'sellPrice': 15,
    },
    {
      'id': 'gem_dust',
      'name': '宝石粉末',
      'description': '研磨宝石得到的粉末，能增强法力',
      'type': 'material',
      'rarity': 'uncommon',
      'sellPrice': 25,
    },
    {
      'id': 'raw_jade',
      'name': '原玉',
      'description': '未经雕琢的天然玉石',
      'type': 'material',
      'rarity': 'uncommon',
      'sellPrice': 40,
    },
    {
      'id': 'carving_tool',
      'name': '雕刻工具',
      'description': '精细的雕刻工具，可重复使用',
      'type': 'material',
      'rarity': 'uncommon',
      'sellPrice': 60,
    },

    // 中级材料
    {
      'id': 'spirit_crystal',
      'name': '灵气水晶',
      'description': '蕴含纯净灵气的水晶',
      'type': 'material',
      'rarity': 'rare',
      'sellPrice': 80,
    },
    {
      'id': 'moonstone',
      'name': '月光石',
      'description': '吸收月华的神秘石头',
      'type': 'material',
      'rarity': 'rare',
      'sellPrice': 100,
    },
    {
      'id': 'spirit_essence',
      'name': '灵气精华',
      'description': '纯净的灵气精华',
      'type': 'material',
      'rarity': 'rare',
      'sellPrice': 120,
    },
    {
      'id': 'protection_rune',
      'name': '护身符文',
      'description': '提供防护的神秘符文',
      'type': 'material',
      'rarity': 'rare',
      'sellPrice': 90,
    },
    {
      'id': 'silver_ring_base',
      'name': '银戒指底座',
      'description': '精制的银戒指底座',
      'type': 'material',
      'rarity': 'rare',
      'sellPrice': 150,
    },
    {
      'id': 'spirit_gem',
      'name': '灵力宝石',
      'description': '蕴含灵力的宝石',
      'type': 'material',
      'rarity': 'rare',
      'sellPrice': 200,
    },
    {
      'id': 'enhancement_powder',
      'name': '强化粉末',
      'description': '提升装备属性的粉末',
      'type': 'material',
      'rarity': 'rare',
      'sellPrice': 75,
    },

    // 高级材料
    {
      'id': 'dragon_scale',
      'name': '龙鳞',
      'description': '传说中龙族的鳞片',
      'type': 'material',
      'rarity': 'legendary',
      'sellPrice': 500,
    },
    {
      'id': 'mithril_ingot',
      'name': '秘银锭',
      'description': '珍贵的秘银锭',
      'type': 'material',
      'rarity': 'epic',
      'sellPrice': 300,
    },
    {
      'id': 'fire_crystal',
      'name': '烈焰水晶',
      'description': '蕴含烈焰之力的水晶',
      'type': 'material',
      'rarity': 'epic',
      'sellPrice': 250,
    },
    {
      'id': 'master_crafting_kit',
      'name': '大师锻造套装',
      'description': '大师级的锻造工具',
      'type': 'material',
      'rarity': 'epic',
      'sellPrice': 800,
    },
    {
      'id': 'phoenix_feather',
      'name': '凤凰羽毛',
      'description': '传说中凤凰的羽毛',
      'type': 'material',
      'rarity': 'mythic',
      'sellPrice': 1000,
    },
    {
      'id': 'celestial_silk',
      'name': '天蚕丝',
      'description': '天蚕吐出的珍贵丝线',
      'type': 'material',
      'rarity': 'legendary',
      'sellPrice': 600,
    },
    {
      'id': 'life_essence',
      'name': '生命精华',
      'description': '蕴含生命力的精华',
      'type': 'material',
      'rarity': 'legendary',
      'sellPrice': 700,
    },

    // 装备材料（用于升级合成）
    {
      'id': 'iron_sword_material',
      'name': '铁剑',
      'description': '作为合成材料的铁剑',
      'type': 'material',
      'rarity': 'uncommon',
      'sellPrice': 50,
    },
    {
      'id': 'leather_armor_material',
      'name': '皮甲',
      'description': '作为合成材料的皮甲',
      'type': 'material',
      'rarity': 'uncommon',
      'sellPrice': 80,
    },
  ];

  // 创建背包物品
  static InventoryItem createMaterialItem(String materialId, int quantity, {String? source}) {
    final materialInfo = materialData.firstWhere(
      (material) => material['id'] == materialId,
      orElse: () => {
        'id': materialId,
        'name': '未知材料',
        'description': '未知的合成材料',
        'type': 'material',
        'rarity': 'common',
        'sellPrice': 1,
      },
    );

    return InventoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itemId: materialId,
      name: materialInfo['name'] as String,
      description: materialInfo['description'] as String,
      type: InventoryItemType.material,
      itemData: {
        'rarity': materialInfo['rarity'] as String,
        'sellPrice': materialInfo['sellPrice'] as int,
        'type': materialInfo['type'] as String,
      },
      quantity: quantity,
      stackable: true,
      maxStack: 999,
      obtainedAt: DateTime.now(),
      source: source ?? '合成材料',
    );
  }

  // 获取材料信息
  static Map<String, dynamic>? getMaterialInfo(String materialId) {
    try {
      return materialData.firstWhere((material) => material['id'] == materialId);
    } catch (e) {
      return null;
    }
  }

  // 获取所有材料ID列表
  static List<String> getAllMaterialIds() {
    return materialData.map((material) => material['id'] as String).toList();
  }

  // 按稀有度获取材料
  static List<Map<String, dynamic>> getMaterialsByRarity(String rarity) {
    return materialData.where((material) => material['rarity'] == rarity).toList();
  }
}
