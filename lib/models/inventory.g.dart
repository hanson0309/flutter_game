// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InventoryItem _$InventoryItemFromJson(Map<String, dynamic> json) =>
    InventoryItem(
      id: json['id'] as String,
      itemId: json['itemId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$InventoryItemTypeEnumMap, json['type']),
      iconPath: json['iconPath'] as String?,
      itemData: json['itemData'] as Map<String, dynamic>,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      stackable: json['stackable'] as bool? ?? true,
      maxStack: (json['maxStack'] as num?)?.toInt() ?? 99,
      obtainedAt: DateTime.parse(json['obtainedAt'] as String),
      source: json['source'] as String?,
    );

Map<String, dynamic> _$InventoryItemToJson(InventoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'itemId': instance.itemId,
      'name': instance.name,
      'description': instance.description,
      'type': _$InventoryItemTypeEnumMap[instance.type]!,
      'iconPath': instance.iconPath,
      'itemData': instance.itemData,
      'quantity': instance.quantity,
      'stackable': instance.stackable,
      'maxStack': instance.maxStack,
      'obtainedAt': instance.obtainedAt.toIso8601String(),
      'source': instance.source,
    };

const _$InventoryItemTypeEnumMap = {
  InventoryItemType.equipment: 'equipment',
  InventoryItemType.consumable: 'consumable',
  InventoryItemType.material: 'material',
  InventoryItemType.technique: 'technique',
  InventoryItemType.special: 'special',
  InventoryItemType.quest: 'quest',
};

PlayerInventory _$PlayerInventoryFromJson(Map<String, dynamic> json) =>
    PlayerInventory(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      maxSlots: (json['maxSlots'] as num?)?.toInt() ?? 100,
      categoryLimits:
          (json['categoryLimits'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
    );

Map<String, dynamic> _$PlayerInventoryToJson(PlayerInventory instance) =>
    <String, dynamic>{
      'items': instance.items,
      'maxSlots': instance.maxSlots,
      'categoryLimits': instance.categoryLimits,
    };
