import 'package:json_annotation/json_annotation.dart';
import 'equipment.dart';

part 'equipment_synthesis.g.dart';

// 合成材料
@JsonSerializable()
class SynthesisMaterial {
  final String itemId;
  final String name;
  final int requiredQuantity;
  final String description;

  const SynthesisMaterial({
    required this.itemId,
    required this.name,
    required this.requiredQuantity,
    required this.description,
  });

  factory SynthesisMaterial.fromJson(Map<String, dynamic> json) => _$SynthesisMaterialFromJson(json);
  Map<String, dynamic> toJson() => _$SynthesisMaterialToJson(this);
}

// 合成配方
@JsonSerializable()
class SynthesisRecipe {
  final String id;
  final String name;
  final String description;
  final String resultEquipmentId; // 合成结果装备ID
  final List<SynthesisMaterial> materials; // 所需材料
  final int spiritStoneCost; // 灵石消耗
  final int requiredLevel; // 所需等级
  final double successRate; // 成功率 (0.0 - 1.0)
  final bool unlocked; // 是否已解锁

  const SynthesisRecipe({
    required this.id,
    required this.name,
    required this.description,
    required this.resultEquipmentId,
    required this.materials,
    this.spiritStoneCost = 0,
    this.requiredLevel = 1,
    this.successRate = 1.0,
    this.unlocked = true,
  });

  factory SynthesisRecipe.fromJson(Map<String, dynamic> json) => _$SynthesisRecipeFromJson(json);
  Map<String, dynamic> toJson() => _$SynthesisRecipeToJson(this);

  // 获取合成结果装备
  Equipment? get resultEquipment => Equipment.getEquipmentById(resultEquipmentId);

  // 检查是否可以合成
  bool canSynthesize(Map<String, int> availableMaterials, int playerSpiritStones, int playerLevel) {
    if (!unlocked || playerLevel < requiredLevel || playerSpiritStones < spiritStoneCost) {
      return false;
    }

    for (final material in materials) {
      final available = availableMaterials[material.itemId] ?? 0;
      if (available < material.requiredQuantity) {
        return false;
      }
    }

    return true;
  }
}

// 合成结果
class SynthesisResult {
  final bool success;
  final String message;
  final Equipment? equipment;
  final Map<String, int> consumedMaterials;
  final int consumedSpiritStones;

  SynthesisResult({
    required this.success,
    required this.message,
    this.equipment,
    this.consumedMaterials = const {},
    this.consumedSpiritStones = 0,
  });
}

// 装备合成系统
class EquipmentSynthesis {
  // 预定义的合成配方
  static const List<SynthesisRecipe> availableRecipes = [
    // 武器合成
    SynthesisRecipe(
      id: 'iron_sword_recipe',
      name: '铁剑锻造',
      description: '使用铁矿石和木材锻造一把铁剑',
      resultEquipmentId: 'iron_sword',
      materials: [
        SynthesisMaterial(
          itemId: 'iron_ore',
          name: '铁矿石',
          requiredQuantity: 3,
          description: '锻造铁剑的主要材料',
        ),
        SynthesisMaterial(
          itemId: 'wood',
          name: '木材',
          requiredQuantity: 2,
          description: '制作剑柄的材料',
        ),
      ],
      spiritStoneCost: 50,
      requiredLevel: 1,
      successRate: 0.9,
    ),

    SynthesisRecipe(
      id: 'spirit_sword_recipe',
      name: '灵剑炼制',
      description: '注入灵气精华，炼制一把灵剑',
      resultEquipmentId: 'spirit_sword',
      materials: [
        SynthesisMaterial(
          itemId: 'iron_sword_material',
          name: '铁剑',
          requiredQuantity: 1,
          description: '作为基础的铁剑',
        ),
        SynthesisMaterial(
          itemId: 'spirit_crystal',
          name: '灵气水晶',
          requiredQuantity: 2,
          description: '蕴含纯净灵气的水晶',
        ),
        SynthesisMaterial(
          itemId: 'moonstone',
          name: '月光石',
          requiredQuantity: 1,
          description: '吸收月华的神秘石头',
        ),
      ],
      spiritStoneCost: 200,
      requiredLevel: 2,
      successRate: 0.7,
    ),

    // 护甲合成
    SynthesisRecipe(
      id: 'leather_armor_recipe',
      name: '皮甲制作',
      description: '使用妖兽皮革制作一套皮甲',
      resultEquipmentId: 'leather_armor',
      materials: [
        SynthesisMaterial(
          itemId: 'beast_hide',
          name: '妖兽皮革',
          requiredQuantity: 4,
          description: '坚韧的妖兽皮革',
        ),
        SynthesisMaterial(
          itemId: 'thread',
          name: '丝线',
          requiredQuantity: 3,
          description: '缝制护甲的丝线',
        ),
      ],
      spiritStoneCost: 80,
      requiredLevel: 1,
      successRate: 0.85,
    ),

    SynthesisRecipe(
      id: 'spirit_armor_recipe',
      name: '灵甲炼制',
      description: '在护甲中注入灵气，炼制灵甲',
      resultEquipmentId: 'spirit_armor',
      materials: [
        SynthesisMaterial(
          itemId: 'leather_armor_material',
          name: '皮甲',
          requiredQuantity: 1,
          description: '作为基础的皮甲',
        ),
        SynthesisMaterial(
          itemId: 'spirit_essence',
          name: '灵气精华',
          requiredQuantity: 3,
          description: '纯净的灵气精华',
        ),
        SynthesisMaterial(
          itemId: 'protection_rune',
          name: '护身符文',
          requiredQuantity: 2,
          description: '提供防护的神秘符文',
        ),
      ],
      spiritStoneCost: 300,
      requiredLevel: 2,
      successRate: 0.6,
    ),

    // 饰品合成
    SynthesisRecipe(
      id: 'jade_pendant_recipe',
      name: '玉佩雕琢',
      description: '精心雕琢一块温润的玉佩',
      resultEquipmentId: 'jade_pendant',
      materials: [
        SynthesisMaterial(
          itemId: 'raw_jade',
          name: '原玉',
          requiredQuantity: 1,
          description: '未经雕琢的天然玉石',
        ),
        SynthesisMaterial(
          itemId: 'carving_tool',
          name: '雕刻工具',
          requiredQuantity: 1,
          description: '精细的雕刻工具',
        ),
      ],
      spiritStoneCost: 120,
      requiredLevel: 1,
      successRate: 0.8,
    ),

    // 戒指合成
    SynthesisRecipe(
      id: 'bronze_ring_recipe',
      name: '青铜戒指铸造',
      description: '铸造一枚简单的青铜戒指',
      resultEquipmentId: 'bronze_ring',
      materials: [
        SynthesisMaterial(
          itemId: 'bronze_ingot',
          name: '青铜锭',
          requiredQuantity: 2,
          description: '精炼的青铜锭',
        ),
        SynthesisMaterial(
          itemId: 'gem_dust',
          name: '宝石粉末',
          requiredQuantity: 1,
          description: '增强法力的宝石粉末',
        ),
      ],
      spiritStoneCost: 60,
      requiredLevel: 0,
      successRate: 0.95,
    ),

    SynthesisRecipe(
      id: 'spirit_ring_recipe',
      name: '灵力戒指炼制',
      description: '炼制蕴含灵力的戒指',
      resultEquipmentId: 'spirit_ring',
      materials: [
        SynthesisMaterial(
          itemId: 'silver_ring_base',
          name: '银戒指底座',
          requiredQuantity: 1,
          description: '精制的银戒指底座',
        ),
        SynthesisMaterial(
          itemId: 'spirit_gem',
          name: '灵力宝石',
          requiredQuantity: 1,
          description: '蕴含灵力的宝石',
        ),
        SynthesisMaterial(
          itemId: 'enhancement_powder',
          name: '强化粉末',
          requiredQuantity: 2,
          description: '提升装备属性的粉末',
        ),
      ],
      spiritStoneCost: 250,
      requiredLevel: 2,
      successRate: 0.75,
    ),

    // 高级装备合成
    SynthesisRecipe(
      id: 'dragon_blade_recipe',
      name: '龙鳞剑锻造',
      description: '使用传说中的龙鳞锻造神兵',
      resultEquipmentId: 'dragon_blade',
      materials: [
        SynthesisMaterial(
          itemId: 'dragon_scale',
          name: '龙鳞',
          requiredQuantity: 5,
          description: '传说中龙族的鳞片',
        ),
        SynthesisMaterial(
          itemId: 'mithril_ingot',
          name: '秘银锭',
          requiredQuantity: 3,
          description: '珍贵的秘银锭',
        ),
        SynthesisMaterial(
          itemId: 'fire_crystal',
          name: '烈焰水晶',
          requiredQuantity: 2,
          description: '蕴含烈焰之力的水晶',
        ),
        SynthesisMaterial(
          itemId: 'master_crafting_kit',
          name: '大师锻造套装',
          requiredQuantity: 1,
          description: '大师级的锻造工具',
        ),
      ],
      spiritStoneCost: 1000,
      requiredLevel: 4,
      successRate: 0.5,
    ),

    SynthesisRecipe(
      id: 'phoenix_robe_recipe',
      name: '凤凰法袍编织',
      description: '使用凤凰羽毛编织传说法袍',
      resultEquipmentId: 'phoenix_robe',
      materials: [
        SynthesisMaterial(
          itemId: 'phoenix_feather',
          name: '凤凰羽毛',
          requiredQuantity: 8,
          description: '传说中凤凰的羽毛',
        ),
        SynthesisMaterial(
          itemId: 'celestial_silk',
          name: '天蚕丝',
          requiredQuantity: 5,
          description: '天蚕吐出的珍贵丝线',
        ),
        SynthesisMaterial(
          itemId: 'life_essence',
          name: '生命精华',
          requiredQuantity: 3,
          description: '蕴含生命力的精华',
        ),
      ],
      spiritStoneCost: 1500,
      requiredLevel: 4,
      successRate: 0.4,
    ),
  ];

  // 根据ID获取配方
  static SynthesisRecipe? getRecipeById(String id) {
    try {
      return availableRecipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }

  // 获取可用的配方（根据等级过滤）
  static List<SynthesisRecipe> getAvailableRecipes(int playerLevel) {
    return availableRecipes
        .where((recipe) => recipe.unlocked && recipe.requiredLevel <= playerLevel)
        .toList();
  }

  // 按装备类型获取配方
  static List<SynthesisRecipe> getRecipesByEquipmentType(EquipmentType type, int playerLevel) {
    return getAvailableRecipes(playerLevel)
        .where((recipe) {
          final equipment = recipe.resultEquipment;
          return equipment != null && equipment.type == type;
        })
        .toList();
  }
}
