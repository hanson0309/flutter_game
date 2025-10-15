# 图片资源说明

## 文件夹结构
```
assets/images/
├── characters/          # 角色图片
│   ├── player.png      # 玩家角色
│   └── player_avatar.png # 玩家头像
├── enemies/            # 敌人图片
│   ├── wild_rabbit.png
│   ├── forest_wolf.png
│   ├── shadow_cat.png
│   ├── iron_golem.png
│   ├── fire_spirit.png
│   ├── rogue_cultivator.png
│   ├── ancient_dragon.png
│   └── demon_lord.png
└── effects/            # 特效图片
    ├── attack.png
    ├── skill.png
    ├── fire.png
    ├── lightning.png
    └── heal.png
```

## 图片规格建议
- **角色图片**: 256x256 像素，PNG格式，透明背景
- **敌人图片**: 256x256 像素，PNG格式，透明背景
- **特效图片**: 128x128 像素，PNG格式，透明背景
- **背景图片**: 1920x1080 像素，JPG格式

## 使用方法
1. 将图片文件放入对应文件夹
2. 确保文件名与 `ImageAssets` 类中定义的名称一致
3. 运行 `flutter pub get` 重新加载资源
4. 如果图片不存在，会自动使用图标作为后备方案

## 图片来源建议
- 免费资源: Pixabay, Unsplash, Freepik
- 游戏素材: OpenGameArt, itch.io
- AI生成: DALL-E, Midjourney, Stable Diffusion
- 手绘/设计工具: Photoshop, GIMP, Procreate
