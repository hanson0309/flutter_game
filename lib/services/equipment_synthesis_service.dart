import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/equipment_synthesis.dart';
import '../models/synthesis_materials.dart';
import '../models/equipment.dart';
import '../models/inventory.dart';
import '../models/player.dart';
import 'inventory_service.dart';
import 'audio_service.dart';

class EquipmentSynthesisService extends ChangeNotifier {
  final InventoryService _inventoryService;
  final Random _random = Random();

  EquipmentSynthesisService(this._inventoryService);

  // 获取可用的合成配方
  List<SynthesisRecipe> getAvailableRecipes(int playerLevel) {
    return EquipmentSynthesis.getAvailableRecipes(playerLevel);
  }

  // 按装备类型获取配方
  List<SynthesisRecipe> getRecipesByEquipmentType(EquipmentType type, int playerLevel) {
    return EquipmentSynthesis.getRecipesByEquipmentType(type, playerLevel);
  }

  // 检查是否可以合成
  bool canSynthesize(SynthesisRecipe recipe, Player player) {
    final availableMaterials = _getAvailableMaterials();
    return recipe.canSynthesize(availableMaterials, player.spiritStones, player.level);
  }

  // 获取缺少的材料
  Map<String, int> getMissingMaterials(SynthesisRecipe recipe) {
    final availableMaterials = _getAvailableMaterials();
    final missing = <String, int>{};

    for (final material in recipe.materials) {
      final available = availableMaterials[material.itemId] ?? 0;
      final needed = material.requiredQuantity;
      if (available < needed) {
        missing[material.itemId] = needed - available;
      }
    }

    return missing;
  }

  // 执行合成
  Future<SynthesisResult> synthesizeEquipment(SynthesisRecipe recipe, Player player) async {
    // 检查是否可以合成
    if (!canSynthesize(recipe, player)) {
      return SynthesisResult(
        success: false,
        message: '材料不足或条件不满足',
      );
    }

    // 消耗材料和金币
    final consumedMaterials = <String, int>{};
    
    // 消耗材料
    for (final material in recipe.materials) {
      final success = _inventoryService.removeItem(material.itemId, material.requiredQuantity);
      if (!success) {
        // 如果移除失败，回滚已消耗的材料
        _rollbackMaterials(consumedMaterials);
        return SynthesisResult(
          success: false,
          message: '材料消耗失败',
        );
      }
      consumedMaterials[material.itemId] = material.requiredQuantity;
    }

    // 消耗灵石
    player.spiritStones -= recipe.spiritStoneCost;

    // 判断合成是否成功
    final isSuccess = _random.nextDouble() < recipe.successRate;

    if (isSuccess) {
      // 合成成功，添加装备到背包
      final equipment = recipe.resultEquipment;
      if (equipment != null) {
        final success = _addEquipmentToInventory(equipment);
        if (success) {
          // 播放成功音效
          AudioService().playClickSound();
          
          debugPrint('🔨 合成成功: ${equipment.name}');
          
          return SynthesisResult(
            success: true,
            message: '合成成功！获得了 ${equipment.name}',
            equipment: equipment,
            consumedMaterials: consumedMaterials,
            consumedSpiritStones: recipe.spiritStoneCost,
          );
        } else {
          // 背包满了，返还材料和灵石
          _rollbackMaterials(consumedMaterials);
          player.spiritStones += recipe.spiritStoneCost;
          return SynthesisResult(
            success: false,
            message: '背包空间不足，合成失败',
          );
        }
      } else {
        // 装备数据错误，返还材料和灵石
        _rollbackMaterials(consumedMaterials);
        player.spiritStones += recipe.spiritStoneCost;
        return SynthesisResult(
          success: false,
          message: '装备数据错误，合成失败',
        );
      }
    } else {
      // 合成失败
      AudioService().playClickSound();
      
      debugPrint('🔨 合成失败: ${recipe.name}');
      
      return SynthesisResult(
        success: false,
        message: '合成失败！材料已消耗',
        consumedMaterials: consumedMaterials,
        consumedSpiritStones: recipe.spiritStoneCost,
      );
    }
  }

  // 添加装备到背包
  bool _addEquipmentToInventory(Equipment equipment) {
    return _inventoryService.addCustomItem(
      itemId: equipment.id,
      name: equipment.name,
      description: equipment.description,
      type: InventoryItemType.equipment,
      itemData: {
        'rarity': equipment.rarity.toString().split('.').last,
        'type': equipment.type.toString().split('.').last,
        'requiredLevel': equipment.requiredLevel,
        'baseStats': equipment.baseStats,
        'maxEnhanceLevel': equipment.maxEnhanceLevel,
        'enhanceStatMultiplier': equipment.enhanceStatMultiplier,
      },
      quantity: 1,
      source: '装备合成',
    );
  }

  // 获取当前可用的材料
  Map<String, int> _getAvailableMaterials() {
    final materials = <String, int>{};
    final materialItems = _inventoryService.getItemsByCategory(InventoryCategory.material);
    
    for (final item in materialItems) {
      materials[item.itemId] = (materials[item.itemId] ?? 0) + item.quantity;
    }
    
    return materials;
  }

  // 回滚已消耗的材料
  void _rollbackMaterials(Map<String, int> consumedMaterials) {
    for (final entry in consumedMaterials.entries) {
      final materialInfo = SynthesisMaterials.getMaterialInfo(entry.key);
      if (materialInfo != null) {
        _inventoryService.addCustomItem(
          itemId: entry.key,
          name: materialInfo['name'] as String,
          description: materialInfo['description'] as String,
          type: InventoryItemType.material,
          itemData: {
            'rarity': materialInfo['rarity'] as String,
            'sellPrice': materialInfo['sellPrice'] as int,
          },
          quantity: entry.value,
          source: '合成回滚',
        );
      }
    }
  }

  // 添加合成材料到背包（用于测试或奖励）
  bool addSynthesisMaterial(String materialId, int quantity, {String? source}) {
    final materialInfo = SynthesisMaterials.getMaterialInfo(materialId);
    if (materialInfo == null) return false;

    return _inventoryService.addCustomItem(
      itemId: materialId,
      name: materialInfo['name'] as String,
      description: materialInfo['description'] as String,
      type: InventoryItemType.material,
      itemData: {
        'rarity': materialInfo['rarity'] as String,
        'sellPrice': materialInfo['sellPrice'] as int,
      },
      quantity: quantity,
      source: source ?? '系统奖励',
    );
  }

  // 批量添加测试材料
  void addTestMaterials() {
    // 添加一些基础材料用于测试
    addSynthesisMaterial('iron_ore', 10, source: '测试材料');
    addSynthesisMaterial('wood', 8, source: '测试材料');
    addSynthesisMaterial('beast_hide', 6, source: '测试材料');
    addSynthesisMaterial('thread', 5, source: '测试材料');
    addSynthesisMaterial('bronze_ingot', 4, source: '测试材料');
    addSynthesisMaterial('gem_dust', 3, source: '测试材料');
    addSynthesisMaterial('raw_jade', 2, source: '测试材料');
    addSynthesisMaterial('carving_tool', 1, source: '测试材料');
    
    // 添加一些中级材料
    addSynthesisMaterial('spirit_crystal', 3, source: '测试材料');
    addSynthesisMaterial('moonstone', 2, source: '测试材料');
    addSynthesisMaterial('spirit_essence', 4, source: '测试材料');
    addSynthesisMaterial('protection_rune', 3, source: '测试材料');
    
    debugPrint('🔨 已添加测试合成材料');
    notifyListeners();
  }

  // 获取材料的详细信息
  Map<String, dynamic>? getMaterialInfo(String materialId) {
    return SynthesisMaterials.getMaterialInfo(materialId);
  }

  // 获取所有材料列表
  List<String> getAllMaterialIds() {
    return SynthesisMaterials.getAllMaterialIds();
  }
}
