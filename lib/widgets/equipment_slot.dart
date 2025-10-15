import 'package:flutter/material.dart';
import '../models/equipment.dart';

class EquipmentSlot extends StatelessWidget {
  final EquipmentType type;
  final EquippedItem? equippedItem;
  final VoidCallback? onTap;

  const EquipmentSlot({
    super.key,
    required this.type,
    this.equippedItem,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFF0f3460),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: equippedItem != null 
                ? _getRarityColor(equippedItem!.equipment?.rarity ?? EquipmentRarity.common)
                : Colors.white24,
            width: 2,
          ),
        ),
        child: equippedItem != null
            ? _buildEquippedItem()
            : _buildEmptySlot(),
      ),
    );
  }

  Widget _buildEquippedItem() {
    final equipment = equippedItem!.equipment!;
    
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getTypeIcon(equipment.type),
            size: 32,
            color: _getRarityColor(equipment.rarity),
          ),
          const SizedBox(height: 4),
          Text(
            equipment.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _getRarityColor(equipment.rarity),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (equippedItem!.enhanceLevel > 0) ...[
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber, width: 1),
              ),
              child: Text(
                '+${equippedItem!.enhanceLevel}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptySlot() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _getTypeIcon(type),
          size: 32,
          color: Colors.white38,
        ),
        const SizedBox(height: 8),
        Text(
          _getTypeName(type),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white38,
          ),
        ),
      ],
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

  String _getTypeName(EquipmentType type) {
    switch (type) {
      case EquipmentType.weapon:
        return '武器';
      case EquipmentType.armor:
        return '护甲';
      case EquipmentType.accessory:
        return '饰品';
      case EquipmentType.treasure:
        return '法宝';
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
}
