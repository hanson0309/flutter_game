# 修仙之路 - 修仙放置游戏

一个完整的修仙主题放置游戏，使用Flutter开发，支持Web、Windows、Android、iOS等多平台。游戏包含完整的修仙体系，从角色培养到战斗探索，提供丰富的游戏体验。

> **语言说明**: 游戏目前为中文版本，英文本地化将在游戏稳定后尽快推出。  
> **Language Notice**: English version is available below. The game is currently in Chinese, English localization will be available soon.

## 🎮 游戏特色

### 核心系统
- **修仙境界系统**：从凡人到永恒主宰，24个完整境界，涵盖凡人、修士、仙人、神灵四大阶段
- **自动修炼**：智能挂机系统，支持离线收益和自动经验获取
- **功法系统**：学习和升级各种功法，包含修炼、战斗、辅助三大类型
- **🆕 地图探索系统**：实时地图探索，支持摇杆控制和自动巡逻
- **🆕 智能战斗系统**：地图中自动遭遇敌人，支持手动和自动战斗模式
- **战斗系统**：回合制战斗，支持技能释放和状态效果
- **任务系统**：日常任务、主线任务、周常任务和成就任务
- **成就系统**：丰富的成就体系，记录修仙历程
- **商店系统**：多种商店类型，购买装备、功法和道具
- **现代化角色界面**：全新设计的角色信息展示界面，突出人物形象
- **音效系统**：沉浸式的音效和背景音乐

### 游戏内容
- **24个修仙境界**：完整的修仙体系，从凡人到永恒主宰的漫长修仙之路
  - **凡人阶段**：凡人 → 练气期 → 筑基期 → 金丹期 → 元婴期 → 化神期
  - **修士阶段**：炼虚期 → 合体期 → 大乘期 → 渡劫期
  - **仙人阶段**：飞升期 → 真仙 → 玄仙 → 金仙 → 太乙真仙 → 大罗金仙
  - **神灵阶段**：神君 → 真神 → 主神 → 至高神 → 混元道祖 → 太初圣尊 → 无上天尊 → 永恒主宰
- **多种功法**：修炼功法（提升修炼效率）、战斗技能（战斗中使用）、辅助技能（被动效果）
- **🆕 多地图探索**：新手森林、黑暗山谷、远古遗迹等多个探索区域
- **🆕 实时地图系统**：玩家和敌人实时移动，支持平滑动画和碰撞检测
- **🆕 摇杆控制**：专业级摇杆控制系统，支持360度精确移动
- **🆕 智能巡逻**：自动探索模式，手动控制后2秒自动恢复巡逻
- **多样敌人**：妖兽、魔族、修炼者、灵体等不同类型，每种都有独特的战斗机制
- **探索系统**：野外探索和秘境挑战，获得丰厚奖励
- **统计系统**：详细的游戏数据统计和角色信息展示

## 🚀 快速开始

### 环境要求
- Flutter SDK 3.9.2+
- Dart 3.0+

### 安装依赖
```bash
flutter pub get
```

### 生成代码
```bash
dart run build_runner build
```

### 运行游戏
```bash
# Web版本
flutter run -d chrome

# Windows版本
flutter run -d windows

# Android版本
flutter run -d android
```

## 📱 游戏界面

### 主界面 (YinianGameScreen)
- **角色信息面板**：显示道号、境界、等级、战力等核心信息
- **修炼面板**：当前境界描述、经验进度、自动修炼状态
- **浮动经验显示**：实时显示经验获取，带有动画效果
- **快捷操作区**：修炼、突破、打坐等核心操作按钮
- **导航菜单**：快速访问各个功能模块

### 🆕 地图探索界面 (MapScreen)
- **实时地图系统**：3倍屏幕大小的大地图，支持缩放和拖拽浏览
- **多区域探索**：新手森林、黑暗山谷、远古遗迹等不同难度区域
- **摇杆控制系统**：左下角专业摇杆，支持360度精确移动控制
- **智能自动巡逻**：自动探索模式，遇敌自动战斗，手动控制后2秒恢复
- **实时敌人系统**：敌人在地图中实时移动，支持动态生成和重生
- **玩家视角居中**：进入地图自动居中到玩家位置，便于快速定位
- **换地图功能**：右上角换地图按钮，快速切换不同探索区域
- **居中定位**：一键居中按钮，随时回到玩家位置
- **平滑移动动画**：玩家和敌人移动带有流畅的动画效果
- **碰撞检测**：接近敌人自动触发战斗，无缝衔接战斗界面

### 角色信息界面 (CharacterInfoScreen)
- **全新视觉设计**：以人物形象为中心的现代化界面布局
- **实时属性同步**：属性立即更新，显示基础值+境界加成的详细分解
- **增强血条蓝条**：包含自动回复功能的生命值和法力值显示
- **流畅交互体验**：简洁清晰的属性展示和信息查看

### 功法系统 (TechniqueScreen)
- **已学功法列表**：查看和升级已掌握的功法
- **功法详情**：功法描述、等级、效果和升级消耗
- **功法分类**：按修炼、战斗、辅助类型分类显示
- **学习新功法**：解锁和学习新的功法技能

### 战斗系统 (BattleScreen & MapScreen)
- **野外探索**：选择不同区域进行探索
- **战斗界面**：回合制战斗，支持技能释放和状态效果
- **敌人信息**：显示敌人属性、技能和战斗状态
- **战利品系统**：战斗胜利后获得经验、灵石和装备奖励

### 商店系统 (ShopScreen)
- **多种商店**：装备商店、功法商店、道具商店等
- **商品分类**：按类型和品质分类展示商品
- **购买系统**：使用灵石购买各种物品
- **商品刷新**：定期刷新商店商品

### 任务系统 (TaskScreen)
- **任务分类**：日常任务、主线任务、周常任务
- **任务进度**：实时显示任务完成进度
- **奖励领取**：完成任务后领取丰厚奖励
- **任务描述**：详细的任务目标和奖励信息

### 成就系统 (AchievementScreen)
- **成就分类**：修炼、战斗、装备、功法等不同类型
- **成就进度**：显示各项成就的完成情况
- **稀有度系统**：普通、稀有、史诗、传说等不同等级
- **成就奖励**：解锁成就获得特殊奖励

### 统计界面 (StatisticsScreen)
- **游戏数据**：详细的游戏统计信息
- **修炼记录**：修炼时间、经验获取等数据
- **战斗统计**：战斗次数、胜率、击败敌人数量
- **资源统计**：灵石获取、消耗等资源流向

### 设置界面 (SettingsScreen)
- **音效设置**：背景音乐和音效开关
- **游戏设置**：各种游戏参数调整
- **数据管理**：游戏数据的保存和加载

## 🏗️ 项目结构

```
lib/
├── main.dart                    # 应用入口，多Provider状态管理配置
├── models/                      # 数据模型 (JSON序列化)
│   ├── player.dart             # 玩家模型 - 属性、境界、功法
│   ├── cultivation_realm.dart  # 修仙境界系统
│   ├── technique.dart          # 功法系统 - 学习、升级
│   ├── enemy.dart              # 敌人模型 - 战斗属性
│   ├── battle.dart             # 战斗数据模型
│   ├── 🆕 map_area.dart        # 地图区域模型
│   ├── 🆕 map_state.dart       # 地图状态模型
│   ├── achievement.dart        # 成就系统模型
│   ├── task.dart               # 任务系统模型
│   └── shop.dart               # 商店系统模型
├── providers/                   # 状态管理
│   └── game_provider.dart      # 核心游戏状态管理
├── screens/                     # 游戏界面
│   ├── yinian_game_screen.dart # 主界面 - 修炼、导航
│   ├── character_info_screen.dart # 角色信息界面 - 属性展示
│   ├── 🆕 map_screen.dart      # 地图探索界面 - 摇杆控制、实时战斗
│   ├── technique_screen.dart   # 功法管理界面
│   ├── battle_screen.dart      # 战斗界面
│   ├── shop_screen.dart        # 商店界面
│   ├── task_screen.dart        # 任务界面
│   ├── achievement_screen.dart # 成就界面
│   ├── statistics_screen.dart  # 统计界面
│   └── settings_screen.dart    # 设置界面
├── services/                    # 业务逻辑服务
│   ├── battle_service.dart     # 战斗系统服务
│   ├── 🆕 map_service.dart     # 地图系统服务 - 探索、敌人管理
│   ├── achievement_service.dart # 成就系统服务
│   ├── task_service.dart       # 任务系统服务
│   ├── shop_service.dart       # 商店系统服务
│   ├── audio_service.dart      # 音效系统服务
│   └── ai_task_generator.dart  # AI任务生成器
├── widgets/                     # UI组件
│   ├── player_info_panel.dart  # 玩家信息面板
│   ├── cultivation_panel.dart  # 修炼面板
│   ├── action_buttons.dart     # 操作按钮组
│   ├── technique_card.dart     # 功法卡片
│   └── swipe_back_wrapper.dart # 滑动返回组件
└── utils/                       # 工具类
    └── image_assets.dart       # 图片资源管理
```

### 资源文件结构
```
assets/
├── images/                      # 图片资源
│   ├── characters/             # 角色图片
│   ├── enemies/                # 敌人图片
│   ├── effects/                # 特效图片
│   └── backgrounds/            # 背景图片
└── audio/                       # 音频资源
    ├── sfx/                    # 音效文件
    └── music/                  # 背景音乐
```

## 🎯 游戏机制

### 修炼系统
- **智能修炼**：自动每2秒获得经验，根据境界和等级动态计算收益
- **境界突破**：经验值满足条件时可突破到下一境界，解锁新功能
- **浮动经验显示**：实时显示经验获取，带有流畅的动画效果
- **离线收益**：支持离线挂机，重新进入游戏时获得离线期间的修炼收益
- **境界加成**：不同境界提供不同的基础经验加成和属性提升

### 境界体系详解
- **凡人阶段（0-5级）**：修仙入门，从普通人到化神期的基础修炼
  - 凡人：未踏入修仙之路的普通人
  - 练气期：初入修仙门槛，开始感应天地灵气
  - 筑基期：筑建修仙根基，实力大幅提升
  - 金丹期：凝结金丹，踏入修仙中阶
  - 元婴期：元婴出窍，神通广大
  - 化神期：化神通玄，已是一方强者

- **修士阶段（6-9级）**：修仙高阶，向仙道迈进
  - 炼虚期：炼虚合道，超脱凡俗
  - 合体期：合体大道，天人合一
  - 大乘期：大乘境界，接近仙道
  - 渡劫期：渡劫成仙，生死一线

- **仙人阶段（10-15级）**：飞升仙界，掌控仙法
  - 飞升期：飞升仙界，踏入仙道
  - 真仙：真正的仙人，掌控仙法
  - 玄仙：玄妙仙境，神通无量
  - 金仙：金仙不朽，万劫不磨
  - 太乙真仙：太乙境界，超脱轮回
  - 大罗金仙：大罗天仙，跳出三界

- **神灵阶段（16-23级）**：超越仙道，成就神位
  - 神君：神道君主，统御一方
  - 真神：真正神灵，创造法则
  - 主神：主宰神界，威震诸天
  - 至高神：至高无上，神中之神
  - 混元道祖：混元一体，道之始祖
  - 太初圣尊：太初之始，圣道之尊
  - 无上天尊：无上境界，天道之尊
  - 永恒主宰：永恒不灭，主宰万物

### 功法系统
- **功法学习**：消耗修炼点学习新功法，解锁更强大的能力
- **功法升级**：提升功法等级增强效果，消耗递增的修炼点
- **功法分类**：
  - 修炼功法：提升修炼效率和经验获取
  - 战斗技能：战斗中使用，造成伤害或施加状态
  - 辅助技能：提供被动效果和属性加成
- **功法效果**：每个功法都有独特的效果和升级路径

### 🆕 地图探索系统 (全新功能)
- **实时地图探索**：3倍屏幕大小的大地图，支持自由探索和缩放浏览
- **多区域设计**：新手森林、黑暗山谷、远古遗迹等不同难度和主题的区域
- **摇杆控制系统**：专业级360度摇杆控制，支持精确移动和速度控制
- **智能巡逻模式**：自动探索功能，遇敌自动战斗，手动控制后2秒自动恢复
- **实时敌人系统**：敌人在地图中动态生成、移动和重生，增加探索乐趣
- **平滑动画效果**：玩家和敌人移动带有流畅的动画，提升视觉体验
- **碰撞检测机制**：接近敌人自动触发战斗，无缝切换到战斗界面
- **视角管理**：进入地图自动居中，支持手动居中和地图切换功能

### 战斗系统
- **回合制战斗**：策略性的回合制战斗，考验技能搭配
- **技能释放**：消耗法力值使用战斗技能，每个技能都有独特效果
- **状态效果**：燃烧、防御、治疗等多种状态效果系统
- **敌人多样性**：妖兽、魔族、修炼者等不同类型敌人，各有特色
- **战利品系统**：胜利后获得经验、灵石、装备等丰厚奖励
- **探索机制**：选择不同区域探索，遇到不同强度的敌人

### 任务系统
- **任务类型**：日常任务、主线任务、周常任务、成就任务
- **动态生成**：AI智能生成任务，保持游戏新鲜感
- **进度追踪**：实时显示任务完成进度和剩余目标
- **奖励丰富**：完成任务获得灵石、经验、装备等多种奖励

### 成就系统
- **成就分类**：修炼、战斗、装备、功法、通用五大类型
- **稀有度等级**：普通、稀有、史诗、传说四个稀有度
- **进度显示**：清晰显示各项成就的完成情况和进度
- **特殊奖励**：解锁成就获得独特奖励和称号

### 商店系统
- **多种商店**：装备商店、功法商店、道具商店等专门化商店
- **商品刷新**：定期刷新商店商品，提供新的购买选择
- **价格体系**：合理的价格体系，平衡游戏经济
- **品质分级**：按装备品质和功法等级分类展示

### 音效系统
- **背景音乐**：沉浸式的修仙主题背景音乐
- **音效反馈**：战斗、修炼、界面操作等完整的音效体系
- **音量控制**：独立的音乐和音效音量控制

## 🔧 技术栈

### 核心框架
- **Flutter SDK**：3.9.2+ (跨平台UI框架)
- **Dart**：3.0+ (编程语言)

### 状态管理
- **Provider**：6.0.5 (状态管理解决方案)
- **MultiProvider**：多服务状态管理架构

### 数据处理
- **SharedPreferences**：2.2.2 (本地数据持久化)
- **JSON序列化**：json_annotation 4.8.1 + json_serializable 6.7.1
- **代码生成**：build_runner 2.4.7 (自动生成序列化代码)

### UI增强
- **flutter_animate**：4.2.0+1 (动画效果)
- **flutter_svg**：2.0.7 (SVG图标支持)
- **Material Design 3**：现代化UI设计

### 音频系统
- **audioplayers**：5.2.1 (音效和背景音乐)

### 开发工具
- **flutter_lints**：5.0.0 (代码规范检查)
- **flutter_test** (单元测试框架)

## 📈 开发进度

### 已完成功能 ✅
- **核心架构**：完整的游戏架构设计和状态管理
- **数据模型**：所有游戏数据模型和JSON序列化
- **主界面系统**：YinianGameScreen主界面和导航
- **完整境界系统**：24个修仙境界，从凡人到永恒主宰的完整体系
- **修炼系统**：自动修炼、经验获取、境界突破
- **角色系统**：角色属性、等级、境界管理，支持自动回复
- **功法系统**：功法学习、升级、分类管理
- **🆕 地图探索系统**：实时地图探索，摇杆控制，自动巡逻
- **🆕 智能战斗系统**：地图中自动遭遇敌人，无缝战斗切换
- **🆕 多区域探索**：新手森林、黑暗山谷、远古遗迹等多个区域
- **🆕 摇杆控制**：专业级360度摇杆控制系统
- **🆕 敌人AI系统**：敌人智能移动、动态生成和重生机制
- **战斗系统**：回合制战斗、技能释放、状态效果
- **任务系统**：多类型任务、进度追踪、奖励发放
- **成就系统**：成就分类、进度显示、奖励机制
- **商店系统**：多商店类型、商品管理、购买系统
- **统计系统**：游戏数据统计和展示
- **音效系统**：背景音乐和音效管理
- **设置系统**：游戏设置和数据管理
- **数据持久化**：完整的游戏存档系统

### 技术特色 🌟
- **模块化架构**：清晰的代码组织和模块分离
- **服务化设计**：独立的业务逻辑服务
- **响应式UI**：流畅的动画和用户交互
- **数据驱动**：完整的数据模型和状态管理
- **🆕 实时地图系统**：高性能的实时地图渲染和交互
- **🆕 智能AI系统**：敌人智能行为和自动巡逻机制
- **🆕 摇杆控制技术**：专业级游戏控制体验
- **🆕 平滑动画系统**：流畅的移动和战斗动画效果
- **跨平台支持**：支持Web、Windows、Android、iOS
- **可扩展性**：易于添加新功能和内容

## 🎮 如何游玩

### 新手指南
1. **创建角色**：首次进入游戏时输入道号，开始你的修仙之路
2. **熟悉界面**：主界面显示角色信息、修炼进度和各功能入口
3. **开始修炼**：游戏会自动进行修炼，实时显示经验获取
4. **查看角色**：点击角色头像查看详细属性和境界信息

### 进阶玩法
5. **学习功法**：进入功法界面，使用修炼点学习和升级功法
6. **🆕 地图探索**：点击底部"战斗"按钮进入地图，开始探索之旅
7. **🆕 摇杆控制**：使用左下角摇杆精确控制角色移动方向和速度
8. **🆕 智能巡逻**：开启自动探索模式，角色会自动寻找敌人并战斗
9. **🆕 区域切换**：使用右上角换地图按钮切换到不同难度的探索区域
10. **完成任务**：查看并完成各种任务，获得丰厚奖励
11. **收集成就**：解锁各种成就，展示你的修仙历程
12. **商店购物**：在各种商店中购买装备、功法和道具

### 高级策略
- **境界突破**：积累足够经验后及时突破境界，解锁新功能
- **🆕 探索策略**：根据角色实力选择合适的地图区域进行探索
- **🆕 控制技巧**：熟练掌握摇杆控制，在地图中高效移动和避敌
- **🆕 巡逻优化**：合理利用自动巡逻和手动控制，提升探索效率
- **功法搭配**：学习不同类型功法，形成有效的技能组合
- **资源管理**：平衡灵石和修炼点的使用，优化发展路径

## 🌟 游戏亮点

### 完整的修仙体验
- **史诗级修仙历程**：从凡人到永恒主宰的24个境界，涵盖修士、仙人、神灵三大超凡阶段
- **渐进式成长体验**：每个境界都有独特的属性加成和修炼体验，成长感十足
- **🆕 沉浸式探索**：实时地图探索系统，带来真正的修仙冒险体验
- **🆕 智能AI系统**：敌人智能行为、自动巡逻、摇杆控制等现代化游戏体验
- **丰富的内容**：功法、战斗、探索、任务等多元化玩法
- **智能系统**：AI任务生成、自动修炼等智能化功能
- **平衡的数值设计**：从100经验到5000亿经验的合理进阶曲线

### 优秀的技术实现
- **跨平台支持**：一套代码支持多个平台
- **流畅体验**：优化的动画和交互设计
- **数据安全**：完善的存档系统，数据不丢失

### 持续更新
- **功能完善**：基础功能已全部实现
- **体验优化**：持续优化用户体验
- **内容扩展**：可轻松添加新的游戏内容

## 🔮 未来规划

### 短期计划
- **🆕 地图扩展**：添加更多探索区域和特殊地形
- **🆕 敌人多样化**：增加更多敌人类型和AI行为模式
- **🆕 战斗优化**：改进战斗动画和特效系统
- **UI美化**：进一步优化界面设计和用户体验
- **平衡调整**：优化游戏数值平衡和进度曲线

### 中期计划
- **🆕 装备系统重构**：重新设计装备系统，与地图探索深度结合
- **🆕 技能树系统**：扩展功法系统，添加技能树和专精路线
- **宗门系统**：加入宗门玩法，增加社交元素
- **炼丹系统**：实现炼丹功能，丰富游戏玩法
- **剧情模式**：添加主线剧情和世界观设定

### 长期计划
- **🆕 多人地图**：实现多人同时探索的地图系统
- **🆕 PvP战斗**：玩家间的实时战斗系统
- **竞技系统**：添加排行榜和竞技玩法
- **移动端优化**：针对手机端进行专门优化

## 🤝 贡献指南

欢迎对项目进行贡献！你可以：
- 报告Bug和问题
- 提出新功能建议
- 提交代码改进
- 完善文档说明

## 📞 联系方式

- **开发者**：hanson
- **项目地址**：本地开发项目
- **技术交流**：欢迎讨论Flutter游戏开发技术

## 📄 许可证

本项目仅供学习和交流使用，展示Flutter跨平台游戏开发的完整实现。

---

## 🎯 版本更新

### v2.0.0 - 地图探索大版本 🆕
- **全新地图系统**：实时地图探索，支持多区域切换
- **摇杆控制**：专业级360度摇杆控制系统
- **智能巡逻**：自动探索模式，手动控制后智能恢复
- **敌人AI系统**：动态敌人生成、移动和重生机制
- **平滑动画**：流畅的移动和战斗动画效果
- **视角优化**：自动居中和手动定位功能

### v1.x.x - 基础版本
- 完整的修仙境界系统（24个境界）
- 自动修炼和功法系统
- 回合制战斗系统
- 任务和成就系统
- 商店和统计系统

---

**修仙之路** - 完整的Flutter修仙放置游戏，从凡人到永恒主宰的史诗修仙之旅！

🗺️ **全新地图探索** | 🕹️ **摇杆控制** | 🤖 **智能AI** | ⚔️ **实时战斗** | 🎮 **跨平台支持**

---

# English Version / 英文版本

# Cultivation Journey - Idle Cultivation Game

A complete cultivation-themed idle game developed with Flutter, supporting Web, Windows, Android, iOS and other multi-platforms. The game contains a complete cultivation system, from character development to battle exploration, providing rich gaming experience.

> **Language Notice**: The game is currently in Chinese version. English localization will be available as soon as the game becomes stable.

## 🎮 Game Features

### Core Systems
- **Cultivation Realm System**: From mortal to Eternal Sovereign, 24 complete realms covering four major stages: Mortal, Cultivator, Immortal, and Divine
- **Auto Cultivation**: Intelligent idle system with offline benefits and automatic experience gain
- **Technique System**: Learn and upgrade various techniques including cultivation, combat, and auxiliary types
- **🆕 Map Exploration System**: Real-time map exploration with joystick control and auto patrol
- **🆕 Intelligent Combat System**: Auto encounter enemies in maps with manual and auto combat modes
- **Combat System**: Turn-based combat with skill casting and status effects
- **Quest System**: Daily quests, main quests, weekly quests and achievement quests
- **Achievement System**: Rich achievement system recording your cultivation journey
- **Shop System**: Multiple shop types for purchasing equipment, techniques and items
- **Modern Character Interface**: Newly designed character information display interface highlighting character image
- **Audio System**: Immersive sound effects and background music

### Game Content
- **24 Cultivation Realms**: Complete cultivation system from mortal to Eternal Sovereign
  - **Mortal Stage**: Mortal → Qi Refining → Foundation Building → Golden Core → Nascent Soul → Spirit Transformation
  - **Cultivator Stage**: Void Refining → Body Integration → Mahayana → Tribulation Transcendence
  - **Immortal Stage**: Ascension → True Immortal → Mysterious Immortal → Golden Immortal → Taiyi True Immortal → Daluo Golden Immortal
  - **Divine Stage**: Divine Lord → True God → Main God → Supreme God → Primordial Dao Ancestor → Primordial Saint → Supreme Celestial → Eternal Sovereign
- **Various Techniques**: Cultivation techniques (improve cultivation efficiency), combat skills (used in battle), auxiliary skills (passive effects)
- **🆕 Multi-Map Exploration**: Newbie Forest, Dark Valley, Ancient Ruins and other exploration areas
- **🆕 Real-time Map System**: Real-time movement of players and enemies with smooth animations and collision detection
- **🆕 Joystick Control**: Professional joystick control system supporting 360-degree precise movement
- **🆕 Intelligent Patrol**: Auto exploration mode, automatically resumes patrol 2 seconds after manual control
- **Diverse Enemies**: Demon beasts, demons, cultivators, spirits and other types, each with unique combat mechanics
- **Exploration System**: Wilderness exploration and secret realm challenges for rich rewards
- **Statistics System**: Detailed game data statistics and character information display

## 🚀 Quick Start

### Environment Requirements
- Flutter SDK 3.9.2+
- Dart 3.0+

### Install Dependencies
```bash
flutter pub get
```

### Generate Code
```bash
dart run build_runner build
```

### Run Game
```bash
# Web version
flutter run -d chrome

# Windows version
flutter run -d windows

# Android version
flutter run -d android
```

## 📱 Game Interfaces

### Main Interface (YinianGameScreen)
- **Character Info Panel**: Display dao name, realm, level, combat power and other core information
- **Cultivation Panel**: Current realm description, experience progress, auto cultivation status
- **Floating Experience Display**: Real-time experience gain display with animation effects
- **Quick Action Area**: Core operation buttons for cultivation, breakthrough, meditation
- **Navigation Menu**: Quick access to various functional modules

### 🆕 Map Exploration Interface (MapScreen)
- **Real-time Map System**: 3x screen size large map supporting zoom and drag browsing
- **Multi-area Exploration**: Different difficulty areas like Newbie Forest, Dark Valley, Ancient Ruins
- **Joystick Control System**: Professional joystick in bottom-left supporting 360-degree precise movement control
- **Intelligent Auto Patrol**: Auto exploration mode, auto combat when encountering enemies, resumes 2 seconds after manual control
- **Real-time Enemy System**: Enemies move in real-time on map with dynamic generation and respawn
- **Player View Centering**: Auto center to player position when entering map for quick location
- **Map Switching**: Map switching button in top-right for quick area changes
- **Center Positioning**: One-click center button to return to player position anytime
- **Smooth Movement Animation**: Smooth animation effects for player and enemy movement
- **Collision Detection**: Auto trigger combat when approaching enemies, seamless transition to battle interface

### Character Info Interface (CharacterInfoScreen)
- **Modern Visual Design**: Modern interface layout centered on character image
- **Real-time Attribute Sync**: Attributes update immediately, showing detailed breakdown of base values + realm bonuses
- **Enhanced Health/Mana Bars**: Health and mana displays with auto recovery functionality
- **Smooth Interactive Experience**: Clean and clear attribute display and information viewing

### Technique System (TechniqueScreen)
- **Learned Technique List**: View and upgrade mastered techniques
- **Technique Details**: Technique description, level, effects and upgrade costs
- **Technique Categories**: Display by cultivation, combat, auxiliary types
- **Learn New Techniques**: Unlock and learn new technique skills

### Combat System (BattleScreen & MapScreen)
- **Wilderness Exploration**: Select different areas for exploration
- **Combat Interface**: Turn-based combat with skill casting and status effects
- **Enemy Information**: Display enemy attributes, skills and combat status
- **Loot System**: Gain experience, spirit stones and equipment rewards after victory

### Shop System (ShopScreen)
- **Multiple Shops**: Equipment shop, technique shop, item shop, etc.
- **Item Categories**: Display items by type and quality categories
- **Purchase System**: Use spirit stones to buy various items
- **Item Refresh**: Periodically refresh shop items

### Quest System (TaskScreen)
- **Quest Categories**: Daily quests, main quests, weekly quests
- **Quest Progress**: Real-time display of quest completion progress
- **Reward Collection**: Collect rich rewards after completing quests
- **Quest Description**: Detailed quest objectives and reward information

### Achievement System (AchievementScreen)
- **Achievement Categories**: Different types like cultivation, combat, equipment, techniques
- **Achievement Progress**: Display completion status of various achievements
- **Rarity System**: Different levels like common, rare, epic, legendary
- **Achievement Rewards**: Unlock achievements to gain special rewards

### Statistics Interface (StatisticsScreen)
- **Game Data**: Detailed game statistics information
- **Cultivation Records**: Cultivation time, experience gain and other data
- **Combat Statistics**: Battle count, win rate, defeated enemy numbers
- **Resource Statistics**: Spirit stone gain, consumption and other resource flows

### Settings Interface (SettingsScreen)
- **Audio Settings**: Background music and sound effect switches
- **Game Settings**: Various game parameter adjustments
- **Data Management**: Game data saving and loading

## 🏗️ Project Structure

```
lib/
├── main.dart                    # App entry, multi-Provider state management config
├── models/                      # Data models (JSON serialization)
│   ├── player.dart             # Player model - attributes, realm, techniques
│   ├── cultivation_realm.dart  # Cultivation realm system
│   ├── technique.dart          # Technique system - learning, upgrading
│   ├── enemy.dart              # Enemy model - combat attributes
│   ├── battle.dart             # Battle data model
│   ├── 🆕 map_area.dart        # Map area model
│   ├── 🆕 map_state.dart       # Map state model
│   ├── achievement.dart        # Achievement system model
│   ├── task.dart               # Quest system model
│   └── shop.dart               # Shop system model
├── providers/                   # State management
│   └── game_provider.dart      # Core game state management
├── screens/                     # Game interfaces
│   ├── yinian_game_screen.dart # Main interface - cultivation, navigation
│   ├── character_info_screen.dart # Character info interface - attribute display
│   ├── 🆕 map_screen.dart      # Map exploration interface - joystick control, real-time combat
│   ├── technique_screen.dart   # Technique management interface
│   ├── battle_screen.dart      # Combat interface
│   ├── shop_screen.dart        # Shop interface
│   ├── task_screen.dart        # Quest interface
│   ├── achievement_screen.dart # Achievement interface
│   ├── statistics_screen.dart  # Statistics interface
│   └── settings_screen.dart    # Settings interface
├── services/                    # Business logic services
│   ├── battle_service.dart     # Combat system service
│   ├── 🆕 map_service.dart     # Map system service - exploration, enemy management
│   ├── achievement_service.dart # Achievement system service
│   ├── task_service.dart       # Quest system service
│   ├── shop_service.dart       # Shop system service
│   ├── audio_service.dart      # Audio system service
│   └── ai_task_generator.dart  # AI quest generator
├── widgets/                     # UI components
│   ├── player_info_panel.dart  # Player info panel
│   ├── cultivation_panel.dart  # Cultivation panel
│   ├── action_buttons.dart     # Action button group
│   ├── technique_card.dart     # Technique card
│   └── swipe_back_wrapper.dart # Swipe back component
└── utils/                       # Utilities
    └── image_assets.dart       # Image asset management
```

### Asset File Structure
```
assets/
├── images/                      # Image assets
│   ├── characters/             # Character images
│   ├── enemies/                # Enemy images
│   ├── effects/                # Effect images
│   └── backgrounds/            # Background images
└── audio/                       # Audio assets
    ├── sfx/                    # Sound effect files
    └── music/                  # Background music
```

## 🎯 Game Mechanics

### Cultivation System
- **Intelligent Cultivation**: Auto gain experience every 2 seconds, dynamically calculated based on realm and level
- **Realm Breakthrough**: Break through to next realm when experience meets requirements, unlock new features
- **Floating Experience Display**: Real-time experience gain display with smooth animation effects
- **Offline Benefits**: Support offline idle, gain offline cultivation benefits when re-entering game
- **Realm Bonuses**: Different realms provide different base experience bonuses and attribute improvements

### Realm System Details
- **Mortal Stage (0-5)**: Cultivation entry, from ordinary person to Spirit Transformation basic cultivation
- **Cultivator Stage (6-9)**: High-level cultivation, advancing towards immortal path
- **Immortal Stage (10-15)**: Ascend to immortal realm, master immortal techniques
- **Divine Stage (16-23)**: Transcend immortal path, achieve divine position

### Technique System
- **Technique Learning**: Consume cultivation points to learn new techniques, unlock more powerful abilities
- **Technique Upgrading**: Improve technique levels to enhance effects, consume increasing cultivation points
- **Technique Categories**:
  - Cultivation Techniques: Improve cultivation efficiency and experience gain
  - Combat Skills: Used in battle, cause damage or apply status
  - Auxiliary Skills: Provide passive effects and attribute bonuses
- **Technique Effects**: Each technique has unique effects and upgrade paths

### 🆕 Map Exploration System (New Feature)
- **Real-time Map Exploration**: 3x screen size large map supporting free exploration and zoom browsing
- **Multi-area Design**: Different difficulty and themed areas like Newbie Forest, Dark Valley, Ancient Ruins
- **Joystick Control System**: Professional 360-degree joystick control supporting precise movement and speed control
- **Intelligent Patrol Mode**: Auto exploration function, auto combat when encountering enemies, auto resumes 2 seconds after manual control
- **Real-time Enemy System**: Enemies dynamically generate, move and respawn in map, increasing exploration fun
- **Smooth Animation Effects**: Smooth animations for player and enemy movement, enhancing visual experience
- **Collision Detection Mechanism**: Auto trigger combat when approaching enemies, seamless transition to combat interface
- **View Management**: Auto center when entering map, support manual centering and map switching functions

### Combat System
- **Turn-based Combat**: Strategic turn-based combat testing skill combinations
- **Skill Casting**: Consume mana to use combat skills, each skill has unique effects
- **Status Effects**: Various status effect systems like burning, defense, healing
- **Enemy Diversity**: Different enemy types like demon beasts, demons, cultivators, each with characteristics
- **Loot System**: Gain rich rewards like experience, spirit stones, equipment after victory
- **Exploration Mechanism**: Select different areas for exploration, encounter enemies of different strengths

### Quest System
- **Quest Types**: Daily quests, main quests, weekly quests, achievement quests
- **Dynamic Generation**: AI intelligently generates quests, keeping game fresh
- **Progress Tracking**: Real-time display of quest completion progress and remaining objectives
- **Rich Rewards**: Complete quests to gain various rewards like spirit stones, experience, equipment

### Achievement System
- **Achievement Categories**: Five major types including cultivation, combat, equipment, techniques, general
- **Rarity Levels**: Four rarity levels: common, rare, epic, legendary
- **Progress Display**: Clearly display completion status and progress of various achievements
- **Special Rewards**: Unlock achievements to gain unique rewards and titles

### Shop System
- **Multiple Shops**: Specialized shops like equipment shop, technique shop, item shop
- **Item Refresh**: Periodically refresh shop items, providing new purchase options
- **Price System**: Reasonable price system balancing game economy
- **Quality Classification**: Display by equipment quality and technique level categories

### Audio System
- **Background Music**: Immersive cultivation-themed background music
- **Sound Feedback**: Complete sound system for combat, cultivation, interface operations
- **Volume Control**: Independent music and sound effect volume controls

## 🔧 Tech Stack

### Core Framework
- **Flutter SDK**: 3.9.2+ (Cross-platform UI framework)
- **Dart**: 3.0+ (Programming language)

### State Management
- **Provider**: 6.0.5 (State management solution)
- **MultiProvider**: Multi-service state management architecture

### Data Processing
- **SharedPreferences**: 2.2.2 (Local data persistence)
- **JSON Serialization**: json_annotation 4.8.1 + json_serializable 6.7.1
- **Code Generation**: build_runner 2.4.7 (Auto generate serialization code)

### UI Enhancement
- **flutter_animate**: 4.2.0+1 (Animation effects)
- **flutter_svg**: 2.0.7 (SVG icon support)
- **Material Design 3**: Modern UI design

### Audio System
- **audioplayers**: 5.2.1 (Sound effects and background music)

### Development Tools
- **flutter_lints**: 5.0.0 (Code style checking)
- **flutter_test** (Unit testing framework)

## 📈 Development Progress

### Completed Features ✅
- **Core Architecture**: Complete game architecture design and state management
- **Data Models**: All game data models and JSON serialization
- **Main Interface System**: YinianGameScreen main interface and navigation
- **Complete Realm System**: 24 cultivation realms from mortal to Eternal Sovereign
- **Cultivation System**: Auto cultivation, experience gain, realm breakthrough
- **Character System**: Character attributes, level, realm management with auto recovery
- **Technique System**: Technique learning, upgrading, category management
- **🆕 Map Exploration System**: Real-time map exploration, joystick control, auto patrol
- **🆕 Intelligent Combat System**: Auto encounter enemies in map, seamless combat transition
- **🆕 Multi-area Exploration**: Multiple areas like Newbie Forest, Dark Valley, Ancient Ruins
- **🆕 Joystick Control**: Professional 360-degree joystick control system
- **🆕 Enemy AI System**: Intelligent enemy movement, dynamic generation and respawn mechanism
- **Combat System**: Turn-based combat, skill casting, status effects
- **Quest System**: Multi-type quests, progress tracking, reward distribution
- **Achievement System**: Achievement categories, progress display, reward mechanism
- **Shop System**: Multi-shop types, item management, purchase system
- **Statistics System**: Game data statistics and display
- **Audio System**: Background music and sound effect management
- **Settings System**: Game settings and data management
- **Data Persistence**: Complete game save system

### Technical Features 🌟
- **Modular Architecture**: Clear code organization and module separation
- **Service-oriented Design**: Independent business logic services
- **Responsive UI**: Smooth animations and user interactions
- **Data-driven**: Complete data models and state management
- **🆕 Real-time Map System**: High-performance real-time map rendering and interaction
- **🆕 Intelligent AI System**: Enemy intelligent behavior and auto patrol mechanism
- **🆕 Joystick Control Technology**: Professional game control experience
- **🆕 Smooth Animation System**: Smooth movement and combat animation effects
- **Cross-platform Support**: Support Web, Windows, Android, iOS
- **Scalability**: Easy to add new features and content

## 🎮 How to Play

### Beginner Guide
1. **Create Character**: Enter dao name when first entering game, start your cultivation journey
2. **Familiarize Interface**: Main interface displays character info, cultivation progress and feature entrances
3. **Start Cultivation**: Game will auto cultivate, real-time display experience gain
4. **View Character**: Click character avatar to view detailed attributes and realm info

### Advanced Gameplay
5. **Learn Techniques**: Enter technique interface, use cultivation points to learn and upgrade techniques
6. **🆕 Map Exploration**: Click bottom "Combat" button to enter map, start exploration journey
7. **🆕 Joystick Control**: Use bottom-left joystick to precisely control character movement direction and speed
8. **🆕 Intelligent Patrol**: Enable auto exploration mode, character will auto find enemies and combat
9. **🆕 Area Switching**: Use top-right map switching button to switch to different difficulty exploration areas
10. **Complete Quests**: View and complete various quests for rich rewards
11. **Collect Achievements**: Unlock various achievements, showcase your cultivation journey
12. **Shop Shopping**: Purchase equipment, techniques and items in various shops

### Advanced Strategies
- **Realm Breakthrough**: Accumulate enough experience then breakthrough realms timely, unlock new features
- **🆕 Exploration Strategy**: Choose appropriate map areas for exploration based on character strength
- **🆕 Control Skills**: Master joystick control proficiently, move efficiently and avoid enemies in map
- **🆕 Patrol Optimization**: Reasonably utilize auto patrol and manual control, improve exploration efficiency
- **Technique Combination**: Learn different types of techniques, form effective skill combinations
- **Resource Management**: Balance use of spirit stones and cultivation points, optimize development path

## 🌟 Game Highlights

### Complete Cultivation Experience
- **Epic Cultivation Journey**: 24 realms from mortal to Eternal Sovereign, covering three transcendent stages of cultivator, immortal, divine
- **Progressive Growth Experience**: Each realm has unique attribute bonuses and cultivation experience, full of growth satisfaction
- **🆕 Immersive Exploration**: Real-time map exploration system bringing true cultivation adventure experience
- **🆕 Intelligent AI System**: Enemy intelligent behavior, auto patrol, joystick control and other modern gaming experiences
- **Rich Content**: Multi-faceted gameplay including techniques, combat, exploration, quests
- **Intelligent Systems**: AI quest generation, auto cultivation and other intelligent functions
- **Balanced Numerical Design**: Reasonable progression curve from 100 experience to 500 billion experience

### Excellent Technical Implementation
- **Cross-platform Support**: One codebase supporting multiple platforms
- **Smooth Experience**: Optimized animation and interaction design
- **Data Security**: Complete save system, no data loss

### Continuous Updates
- **Feature Completion**: All basic features fully implemented
- **Experience Optimization**: Continuously optimizing user experience
- **Content Expansion**: Easy to add new game content

## 🔮 Future Plans

### Short-term Plans
- **🆕 Map Expansion**: Add more exploration areas and special terrains
- **🆕 Enemy Diversification**: Add more enemy types and AI behavior patterns
- **🆕 Combat Optimization**: Improve combat animations and effect systems
- **UI Beautification**: Further optimize interface design and user experience
- **Balance Adjustment**: Optimize game numerical balance and progression curve

### Medium-term Plans
- **🆕 Equipment System Reconstruction**: Redesign equipment system, deeply integrate with map exploration
- **🆕 Skill Tree System**: Expand technique system, add skill trees and specialization routes
- **Sect System**: Add sect gameplay, increase social elements
- **Alchemy System**: Implement alchemy function, enrich gameplay
- **Story Mode**: Add main storyline and worldview settings

### Long-term Plans
- **🆕 Multiplayer Maps**: Implement map system for multiple players exploring simultaneously
- **🆕 PvP Combat**: Real-time combat system between players
- **Competitive System**: Add leaderboards and competitive gameplay
- **Mobile Optimization**: Specialized optimization for mobile devices

## 🤝 Contribution Guide

Welcome to contribute to the project! You can:
- Report bugs and issues
- Suggest new features
- Submit code improvements
- Improve documentation

## 📞 Contact

- **Developer**: hanson
- **Project Address**: Local development project
- **Technical Exchange**: Welcome to discuss Flutter game development technology

## 📄 License

This project is for learning and communication purposes only, demonstrating complete implementation of Flutter cross-platform game development.

---

## 🎯 Version Updates

### v2.0.0 - Map Exploration Major Version 🆕
- **New Map System**: Real-time map exploration with multi-area switching support
- **Joystick Control**: Professional 360-degree joystick control system
- **Intelligent Patrol**: Auto exploration mode, intelligently resumes after manual control
- **Enemy AI System**: Dynamic enemy generation, movement and respawn mechanism
- **Smooth Animation**: Smooth movement and combat animation effects
- **View Optimization**: Auto centering and manual positioning functions

### v1.x.x - Base Version
- Complete cultivation realm system (24 realms)
- Auto cultivation and technique system
- Turn-based combat system
- Quest and achievement system
- Shop and statistics system

---

**Cultivation Journey** - Complete Flutter cultivation idle game, epic cultivation journey from mortal to Eternal Sovereign!

🗺️ **New Map Exploration** | 🕹️ **Joystick Control** | 🤖 **Intelligent AI** | ⚔️ **Real-time Combat** | 🎮 **Cross-platform Support**
