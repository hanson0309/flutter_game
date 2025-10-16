import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'services/achievement_service.dart';
import 'services/audio_service.dart';
import 'services/task_service.dart';
import 'services/shop_service.dart';
import 'services/inventory_service.dart';
import 'services/battle_service.dart';
import 'services/equipment_synthesis_service.dart';
import 'screens/yinian_game_screen.dart';
import 'screens/equipment_synthesis_screen.dart';

void main() {
  runApp(const XiuXianApp());
}

class XiuXianApp extends StatelessWidget {
  const XiuXianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AudioService()..initialize()),
        ChangeNotifierProvider(create: (context) => AchievementService()..initializeAchievements()),
        ChangeNotifierProvider(create: (context) => TaskService()..initializeTasks()),
        ChangeNotifierProvider(create: (context) => ShopService()..initializeShops()),
        ChangeNotifierProvider(create: (context) => InventoryService()..initializeInventory()),
        ChangeNotifierProvider(create: (context) => BattleService()..initializeBattleSystem()),
        ChangeNotifierProxyProvider<InventoryService, EquipmentSynthesisService>(
          create: (context) => EquipmentSynthesisService(context.read<InventoryService>()),
          update: (context, inventoryService, synthesisService) => 
              synthesisService ?? EquipmentSynthesisService(inventoryService),
        ),
        ChangeNotifierProxyProvider2<AchievementService, TaskService, GameProvider>(
          create: (context) {
            final gameProvider = GameProvider();
            gameProvider.initializeGame();
            return gameProvider;
          },
          update: (context, achievementService, taskService, gameProvider) {
            gameProvider?.setAchievementService(achievementService);
            gameProvider?.setTaskService(taskService);
            return gameProvider!;
          },
        ),
      ],
      child: MaterialApp(
        title: '修仙之路',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFe94560),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const YinianGameScreen(),
        routes: {
          '/equipment_synthesis': (context) => const EquipmentSynthesisScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
