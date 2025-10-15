import 'package:json_annotation/json_annotation.dart';
import 'cultivation_realm.dart';
import 'technique.dart';
import 'equipment.dart';

part 'player.g.dart';

@JsonSerializable()
class Player {
  String name;
  int level;
  int currentExp;
  int totalExp;
  
  // 基础属性
  double baseAttack;
  double baseDefense;
  double baseHealth;
  double baseMana;
  
  // 当前状态
  double currentHealth;
  double currentMana;
  
  // 修炼相关
  bool isAutoTraining;
  DateTime? lastTrainingTime;
  
  // 灵石和资源
  int spiritStones;
  int cultivationPoints;
  
  // 功法系统
  List<LearnedTechnique> learnedTechniques;
  
  // 装备系统
  Map<String, EquippedItem?> equippedItems; // key: EquipmentType.name
  List<EquippedItem> inventory;

  Player({
    required this.name,
    this.level = 0,
    this.currentExp = 0,
    this.totalExp = 0,
    this.baseAttack = 10.0,
    this.baseDefense = 8.0,
    this.baseHealth = 100.0,
    this.baseMana = 50.0,
    double? currentHealth,
    double? currentMana,
    this.isAutoTraining = false,
    this.lastTrainingTime,
    this.spiritStones = 100,
    this.cultivationPoints = 0,
    List<LearnedTechnique>? learnedTechniques,
    Map<String, EquippedItem?>? equippedItems,
    List<EquippedItem>? inventory,
  }) : currentHealth = currentHealth ?? baseHealth * CultivationRealm.getRealmByLevel(level).attributeMultipliers['health']!,
       currentMana = currentMana ?? baseMana * CultivationRealm.getRealmByLevel(level).attributeMultipliers['mana']!,
       learnedTechniques = learnedTechniques ?? [],
       equippedItems = equippedItems ?? {
         'weapon': null,
         'armor': null,
         'accessory': null,
         'treasure': null,
       },
       inventory = inventory ?? [];

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);

  // 获取当前境界
  CultivationRealm get currentRealm => CultivationRealm.getRealmByLevel(level);

  // 获取下一境界
  CultivationRealm? get nextRealm {
    if (level + 1 < CultivationRealm.realms.length) {
      return CultivationRealm.getRealmByLevel(level + 1);
    }
    return null;
  }

  // 计算实际属性（基础属性 * 境界加成 * 装备加成 * 功法加成）
  double get actualAttack {
    double base = baseAttack * currentRealm.attributeMultipliers['attack']!;
    double equipBonus = _getEquipmentStat('attack');
    return base + equipBonus;
  }
  
  double get actualDefense {
    double base = baseDefense * currentRealm.attributeMultipliers['defense']! * defenseMultiplier;
    double equipBonus = _getEquipmentStat('defense');
    return base + equipBonus;
  }
  
  double get actualMaxHealth {
    double base = baseHealth * currentRealm.attributeMultipliers['health']! * healthMultiplier;
    double equipBonus = _getEquipmentStat('health');
    return base + equipBonus;
  }
  
  double get actualMaxMana {
    double base = baseMana * currentRealm.attributeMultipliers['mana']!;
    double equipBonus = _getEquipmentStat('mana');
    return base + equipBonus;
  }

  // 获取当前境界升级所需经验
  int get expToNextLevel {
    if (nextRealm == null) return 0;
    return currentRealm.maxExp - currentExp;
  }

  // 获取升级进度百分比
  double get levelProgress {
    if (currentRealm.maxExp == 0) return 1.0;
    return currentExp / currentRealm.maxExp;
  }

  // 添加经验值
  bool addExp(int exp) {
    currentExp += exp;
    totalExp += exp;
    
    // 检查是否可以升级
    if (currentExp >= currentRealm.maxExp && nextRealm != null) {
      return levelUp();
    }
    return false;
  }

  // 升级
  bool levelUp() {
    if (nextRealm == null) return false;
    
    currentExp -= currentRealm.maxExp;
    level++;
    
    // 升级后恢复满血满蓝
    currentHealth = actualMaxHealth;
    currentMana = actualMaxMana;
    
    return true;
  }

  // 修炼获得经验
  int trainOnce() {
    final baseExpGain = 10 + (level * 5);
    final expGain = (baseExpGain * (1 + (spiritStones > 0 ? 0.1 : 0))).round();
    
    // 消耗灵石提升修炼效率（20%概率消耗）
    if (spiritStones > 0 && expGain > baseExpGain) {
      final random = DateTime.now().millisecond % 100;
      if (random < 20) { // 20%概率消耗灵石
        spiritStones--;
      }
    }
    
    addExp(expGain);
    cultivationPoints += 1;
    lastTrainingTime = DateTime.now();
    
    // 修炼时有小概率获得灵石（5%概率）
    final gainRandom = DateTime.now().microsecond % 100;
    if (gainRandom < 5) {
      spiritStones += 1;
    }
    
    return expGain;
  }

  // 恢复生命值
  void restoreHealth(double amount) {
    currentHealth = (currentHealth + amount).clamp(0, actualMaxHealth);
  }

  // 恢复法力值
  void restoreMana(double amount) {
    currentMana = (currentMana + amount).clamp(0, actualMaxMana);
  }

  // 消耗法力值
  bool consumeMana(double amount) {
    if (currentMana >= amount) {
      currentMana -= amount;
      return true;
    }
    return false;
  }

  // 受到伤害
  int takeDamage(int damage) {
    final actualDamage = (damage - actualDefense * 0.1).clamp(1, damage).round();
    currentHealth = (currentHealth - actualDamage).clamp(0, actualMaxHealth);
    return actualDamage;
  }

  // 战斗相关属性
  bool get isAlive => currentHealth > 0;

  // 恢复生命值（战斗用）
  int heal(int amount) {
    final oldHealth = currentHealth;
    currentHealth = (currentHealth + amount).clamp(0, actualMaxHealth);
    return (currentHealth - oldHealth).round();
  }

  // 功法相关方法
  
  // 学习功法
  bool learnTechnique(String techniqueId) {
    // 检查是否已经学会
    if (hasLearnedTechnique(techniqueId)) return false;
    
    final technique = Technique.getTechniqueById(techniqueId);
    if (technique == null) return false;
    
    // 检查是否有足够的修炼点
    if (cultivationPoints < technique.baseCost) return false;
    
    cultivationPoints -= technique.baseCost;
    learnedTechniques.add(LearnedTechnique(techniqueId: techniqueId));
    return true;
  }
  
  // 检查是否已学会功法
  bool hasLearnedTechnique(String techniqueId) {
    return learnedTechniques.any((lt) => lt.techniqueId == techniqueId);
  }
  
  // 获取已学会的功法
  LearnedTechnique? getLearnedTechnique(String techniqueId) {
    try {
      return learnedTechniques.firstWhere((lt) => lt.techniqueId == techniqueId);
    } catch (e) {
      return null;
    }
  }
  
  // 升级功法
  bool upgradeTechnique(String techniqueId) {
    final learnedTech = getLearnedTechnique(techniqueId);
    if (learnedTech == null) return false;
    
    final technique = learnedTech.technique;
    if (technique == null || learnedTech.level >= technique.maxLevel) return false;
    
    final upgradeCost = technique.baseCost * (technique.levelCostMultiplier * learnedTech.level);
    if (cultivationPoints < upgradeCost) return false;
    
    cultivationPoints -= upgradeCost;
    learnedTech.level++;
    return true;
  }
  
  // 获取修炼效率加成
  double get cultivationSpeedMultiplier {
    double multiplier = 1.0;
    for (final learnedTech in learnedTechniques) {
      final technique = learnedTech.technique;
      if (technique?.type == TechniqueType.cultivation) {
        final effects = learnedTech.getCurrentEffects();
        multiplier *= effects['cultivation_speed'] ?? 1.0;
      }
    }
    return multiplier;
  }
  
  // 获取经验加成
  double get expBonusMultiplier {
    double bonus = 0.0;
    for (final learnedTech in learnedTechniques) {
      final technique = learnedTech.technique;
      if (technique?.type == TechniqueType.cultivation) {
        final effects = learnedTech.getCurrentEffects();
        bonus += effects['exp_bonus'] ?? 0.0;
      }
    }
    return 1.0 + bonus;
  }
  
  // 获取法力恢复加成
  double get manaRegenMultiplier {
    double multiplier = 1.0;
    for (final learnedTech in learnedTechniques) {
      final effects = learnedTech.getCurrentEffects();
      multiplier *= effects['mana_regen'] ?? 1.0;
    }
    return multiplier;
  }
  
  // 获取生命恢复加成
  double get healthRegenMultiplier {
    double multiplier = 1.0;
    for (final learnedTech in learnedTechniques) {
      final effects = learnedTech.getCurrentEffects();
      multiplier *= effects['health_regen'] ?? 1.0;
    }
    return multiplier;
  }
  
  // 获取防御加成
  double get defenseMultiplier {
    double multiplier = 1.0;
    for (final learnedTech in learnedTechniques) {
      final effects = learnedTech.getCurrentEffects();
      multiplier *= effects['defense_multiplier'] ?? 1.0;
    }
    return multiplier;
  }
  
  // 获取生命值加成
  double get healthMultiplier {
    double multiplier = 1.0;
    for (final learnedTech in learnedTechniques) {
      final effects = learnedTech.getCurrentEffects();
      multiplier *= effects['health_multiplier'] ?? 1.0;
    }
    return multiplier;
  }

  // 装备相关方法
  
  // 获取装备属性加成
  double _getEquipmentStat(String statName) {
    double total = 0.0;
    for (final equippedItem in equippedItems.values) {
      if (equippedItem != null) {
        final stats = equippedItem.getCurrentStats();
        total += stats[statName] ?? 0.0;
      }
    }
    return total;
  }
  
  // 装备物品
  bool equipItem(EquippedItem item) {
    final equipment = item.equipment;
    if (equipment == null) return false;
    
    // 检查等级要求
    if (level < equipment.requiredLevel) return false;
    
    final slotKey = equipment.type.name;
    
    // 如果已有装备，放回背包
    final currentEquipped = equippedItems[slotKey];
    if (currentEquipped != null) {
      inventory.add(currentEquipped);
    }
    
    // 装备新物品
    equippedItems[slotKey] = item;
    inventory.remove(item);
    
    return true;
  }
  
  // 卸下装备
  bool unequipItem(EquipmentType type) {
    final slotKey = type.name;
    final equippedItem = equippedItems[slotKey];
    
    if (equippedItem == null) return false;
    
    equippedItems[slotKey] = null;
    inventory.add(equippedItem);
    
    return true;
  }
  
  // 强化装备
  bool enhanceEquipment(EquipmentType type) {
    final slotKey = type.name;
    final equippedItem = equippedItems[slotKey];
    
    if (equippedItem == null) return false;
    
    final cost = equippedItem.getNextEnhanceCost();
    if (spiritStones < cost) return false;
    
    if (equippedItem.enhance()) {
      spiritStones -= cost;
      return true;
    }
    
    return false;
  }
  
  // 添加物品到背包
  void addItemToInventory(String equipmentId) {
    final equipment = Equipment.getEquipmentById(equipmentId);
    if (equipment != null) {
      inventory.add(EquippedItem(equipmentId: equipmentId));
    }
  }
  
  // 获取装备的总战力
  int get totalPower {
    double power = actualAttack + actualDefense + (actualMaxHealth / 10) + (actualMaxMana / 5);
    
    // 加上装备特殊属性的战力
    power += _getEquipmentStat('critical_rate') * 1000;
    power += _getEquipmentStat('critical_damage') * 500;
    power += _getEquipmentStat('skill_damage') * 800;
    power += _getEquipmentStat('damage_reduction') * 1200;
    
    return power.round();
  }
  
  // 获取暴击率
  double get criticalRate {
    return _getEquipmentStat('critical_rate');
  }
  
  // 获取暴击伤害
  double get criticalDamage {
    return _getEquipmentStat('critical_damage');
  }
  
  // 获取技能伤害加成
  double get skillDamageBonus {
    return _getEquipmentStat('skill_damage');
  }
  
  // 获取伤害减免
  double get damageReduction {
    return _getEquipmentStat('damage_reduction');
  }
  
  // 获取闪避率
  double get dodgeRate {
    return _getEquipmentStat('dodge_rate');
  }
}
