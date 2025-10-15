import 'package:flutter/material.dart';
import '../models/equipment.dart';

class InventoryItem extends StatelessWidget {
  final EquippedItem equippedItem;
  final VoidCallback? onTap;

  const InventoryItem({
    super.key,
    required this.equippedItem,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final equipment = equippedItem.equipment;
    if (equipment == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: const Color(0xFF0f3460),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getRarityColor(equipment.rarity),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getTypeIcon(equipment.type),
                  size: 32,
                  color: _getRarityColor(equipment.rarity),
                ),
                const SizedBox(height: 8),
                Text(
                  equipment.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getRarityColor(equipment.rarity),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getRarityColor(equipment.rarity).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getRarityText(equipment.rarity),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getRarityColor(equipment.rarity),
                    ),
                  ),
                ),
                if (equippedItem.enhanceLevel > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber, width: 1),
                    ),
                    child: Text(
                      '+${equippedItem.enhanceLevel}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'Lv.${equipment.requiredLevel}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(EquipmentType type) {
    switch (type) {
      case EquipmentType.weapon:
        return Icons.sports_martial_arts;
      case EquipmentType.armor:
        return Icons.security;
      case EquipmentType.accessory:
        return Icons.diamond;
      case EquipmentType.treasure:
        return Icons.auto_awesome;
    }
  }

  Color _getRarityColor(EquipmentRarity rarity) {
    switch (rarity) {
      case EquipmentRarity.common:
        return Colors.grey;
      case EquipmentRarity.uncommon:
        return Colors.green;
      case EquipmentRarity.rare:
        return Colors.blue;
      case EquipmentRarity.epic:
        return Colors.purple;
      case EquipmentRarity.legendary:
        return Colors.orange;
      case EquipmentRarity.mythic:
        return Colors.red;
    }
  }

  String _getRarityText(EquipmentRarity rarity) {
    switch (rarity) {
      case EquipmentRarity.common:
        return '普通';
      case EquipmentRarity.uncommon:
        return '不凡';
      case EquipmentRarity.rare:
        return '稀有';
      case EquipmentRarity.epic:
        return '史诗';
      case EquipmentRarity.legendary:
        return '传说';
      case EquipmentRarity.mythic:
        return '神话';
    }
  }
}
