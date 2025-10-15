class ImageAssets {
  // 角色图片
  static const String playerAvatar = 'assets/images/characters/player_avatar.svg';
  static const String playerCharacter = 'assets/images/characters/player.png';
  static const String cultivator = 'assets/images/characters/cultivator.png';
  
  // 背景图片
  static const String cultivationChamber = 'assets/images/backgrounds/cultivation_chamber.png';
  
  // 敌人图片
  static const String wildRabbit = 'assets/images/enemies/wild_rabbit.svg';
  static const String forestWolf = 'assets/images/enemies/forest_wolf.png';
  static const String shadowCat = 'assets/images/enemies/shadow_cat.png';
  static const String ironGolem = 'assets/images/enemies/iron_golem.png';
  static const String fireSpirit = 'assets/images/enemies/fire_spirit.png';
  static const String rogueCultivator = 'assets/images/enemies/rogue_cultivator.png';
  static const String ancientDragon = 'assets/images/enemies/ancient_dragon.png';
  static const String demonLord = 'assets/images/enemies/demon_lord.png';
  static const String crocodile = 'assets/images/enemies/crocodile.gif'; // 你的鳄鱼GIF
  
  // 特效图片
  static const String attackEffect = 'assets/images/effects/attack.png';
  static const String skillEffect = 'assets/images/effects/skill.png';
  static const String fireEffect = 'assets/images/effects/fire.png';
  static const String lightningEffect = 'assets/images/effects/lightning.png';
  static const String healEffect = 'assets/images/effects/heal.png';
  
  // 背景图片
  static const String battleBackground = 'assets/images/battle_bg.png';
  static const String mainBackground = 'assets/images/main_bg.png';
  
  // 获取敌人图片路径
  static String getEnemyImage(String enemyId) {
    switch (enemyId) {
      case 'wild_rabbit':
        return wildRabbit;
      case 'forest_wolf':
        return forestWolf;
      case 'shadow_cat':
        return shadowCat;
      case 'iron_golem':
        return ironGolem;
      case 'fire_spirit':
        return fireSpirit;
      case 'rogue_cultivator':
        return rogueCultivator;
      case 'ancient_dragon':
        return ancientDragon;
      case 'demon_lord':
        return demonLord;
      case 'swamp_crocodile':
        return crocodile;
      default:
        return wildRabbit; // 默认图片
    }
  }
  
  // 检查图片是否存在
  static bool hasEnemyImage(String enemyId) {
    // 检查是否有对应的图片文件
    switch (enemyId) {
      case 'wild_rabbit':
        return true; // 我们已经创建了这个SVG文件
      case 'swamp_crocodile':
        return true; // 用户提供的鳄鱼GIF文件
      default:
        return false; // 其他敌人暂时使用图标
    }
  }
}
