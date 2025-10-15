// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemPrice _$ItemPriceFromJson(Map<String, dynamic> json) => ItemPrice(
  currency: $enumDecode(_$CurrencyTypeEnumMap, json['currency']),
  amount: (json['amount'] as num).toInt(),
  discount: (json['discount'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ItemPriceToJson(ItemPrice instance) => <String, dynamic>{
  'currency': _$CurrencyTypeEnumMap[instance.currency]!,
  'amount': instance.amount,
  'discount': instance.discount,
};

const _$CurrencyTypeEnumMap = {
  CurrencyType.spiritStones: 'spiritStones',
  CurrencyType.jadePearls: 'jadePearls',
  CurrencyType.contribution: 'contribution',
};

ShopItem _$ShopItemFromJson(Map<String, dynamic> json) => ShopItem(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$ShopItemTypeEnumMap, json['type']),
  rarity: $enumDecode(_$ItemRarityEnumMap, json['rarity']),
  prices: (json['prices'] as List<dynamic>)
      .map((e) => ItemPrice.fromJson(e as Map<String, dynamic>))
      .toList(),
  iconPath: json['iconPath'] as String?,
  itemData: json['itemData'] as Map<String, dynamic>?,
  maxStock: (json['maxStock'] as num?)?.toInt() ?? -1,
  refreshHours: (json['refreshHours'] as num?)?.toInt() ?? 0,
  prerequisites:
      (json['prerequisites'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  playerLevelRequired: (json['playerLevelRequired'] as num?)?.toInt() ?? 0,
  isLimited: json['isLimited'] as bool? ?? false,
  availableUntil: json['availableUntil'] == null
      ? null
      : DateTime.parse(json['availableUntil'] as String),
);

Map<String, dynamic> _$ShopItemToJson(ShopItem instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'type': _$ShopItemTypeEnumMap[instance.type]!,
  'rarity': _$ItemRarityEnumMap[instance.rarity]!,
  'prices': instance.prices,
  'iconPath': instance.iconPath,
  'itemData': instance.itemData,
  'maxStock': instance.maxStock,
  'refreshHours': instance.refreshHours,
  'prerequisites': instance.prerequisites,
  'playerLevelRequired': instance.playerLevelRequired,
  'isLimited': instance.isLimited,
  'availableUntil': instance.availableUntil?.toIso8601String(),
};

const _$ShopItemTypeEnumMap = {
  ShopItemType.equipment: 'equipment',
  ShopItemType.technique: 'technique',
  ShopItemType.consumable: 'consumable',
  ShopItemType.material: 'material',
  ShopItemType.special: 'special',
};

const _$ItemRarityEnumMap = {
  ItemRarity.common: 'common',
  ItemRarity.uncommon: 'uncommon',
  ItemRarity.rare: 'rare',
  ItemRarity.epic: 'epic',
  ItemRarity.legendary: 'legendary',
  ItemRarity.mythic: 'mythic',
};

Shop _$ShopFromJson(Map<String, dynamic> json) => Shop(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$ShopTypeEnumMap, json['type']),
  itemIds: (json['itemIds'] as List<dynamic>).map((e) => e as String).toList(),
  refreshHours: (json['refreshHours'] as num?)?.toInt() ?? 24,
  isUnlocked: json['isUnlocked'] as bool? ?? true,
  unlockConditions:
      (json['unlockConditions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  playerLevelRequired: (json['playerLevelRequired'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ShopToJson(Shop instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'type': _$ShopTypeEnumMap[instance.type]!,
  'itemIds': instance.itemIds,
  'refreshHours': instance.refreshHours,
  'isUnlocked': instance.isUnlocked,
  'unlockConditions': instance.unlockConditions,
  'playerLevelRequired': instance.playerLevelRequired,
};

const _$ShopTypeEnumMap = {
  ShopType.general: 'general',
  ShopType.equipment: 'equipment',
  ShopType.technique: 'technique',
  ShopType.consumable: 'consumable',
  ShopType.limited: 'limited',
  ShopType.contribution: 'contribution',
};

PlayerShopData _$PlayerShopDataFromJson(Map<String, dynamic> json) =>
    PlayerShopData(
      shopId: json['shopId'] as String,
      purchaseCount:
          (json['purchaseCount'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      lastRefresh: json['lastRefresh'] == null
          ? null
          : DateTime.parse(json['lastRefresh'] as String),
      currentStock:
          (json['currentStock'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
    );

Map<String, dynamic> _$PlayerShopDataToJson(PlayerShopData instance) =>
    <String, dynamic>{
      'shopId': instance.shopId,
      'purchaseCount': instance.purchaseCount,
      'lastRefresh': instance.lastRefresh?.toIso8601String(),
      'currentStock': instance.currentStock,
    };
