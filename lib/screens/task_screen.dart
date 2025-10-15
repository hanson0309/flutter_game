import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../services/audio_service.dart';
import '../providers/game_provider.dart';
import '../widgets/swipe_back_wrapper.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SwipeBackScaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        title: const Text(
          '任务中心',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1a1a1a),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => _generateAITasks(context),
            icon: const Icon(Icons.auto_awesome, color: Colors.yellow),
            tooltip: '生成AI任务',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFe94560),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: '日常'),
            Tab(text: '主线'),
            Tab(text: '周常'),
            Tab(text: '已完成'),
          ],
        ),
      ),
      body: Consumer2<TaskService, GameProvider>(
        builder: (context, taskService, gameProvider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildTaskList(taskService, gameProvider, TaskType.daily),
              _buildTaskList(taskService, gameProvider, TaskType.main),
              _buildTaskList(taskService, gameProvider, TaskType.weekly),
              _buildCompletedTaskList(taskService, gameProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTaskList(TaskService taskService, GameProvider gameProvider, TaskType type) {
    final tasks = taskService.allTasks.where((task) => task.type == type).toList();
    final availableTasks = tasks.where((task) {
      final playerTask = taskService.getPlayerTask(task.id);
      return playerTask?.status == TaskStatus.active;
    }).toList();

    if (availableTasks.isEmpty) {
      return _buildEmptyState(_getEmptyMessage(type));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: availableTasks.length,
      itemBuilder: (context, index) {
        final task = availableTasks[index];
        final playerTask = taskService.getPlayerTask(task.id);
        return _buildTaskCard(task, playerTask, taskService, gameProvider);
      },
    );
  }

  Widget _buildCompletedTaskList(TaskService taskService, GameProvider gameProvider) {
    final completedTasks = taskService.completedTasks;
    final claimedTasks = taskService.allTasks.where((task) {
      final playerTask = taskService.getPlayerTask(task.id);
      return playerTask?.status == TaskStatus.claimed;
    }).toList();

    final allCompletedTasks = [...completedTasks, ...claimedTasks];

    if (allCompletedTasks.isEmpty) {
      return _buildEmptyState('还没有完成任何任务\n继续努力修炼吧！');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allCompletedTasks.length,
      itemBuilder: (context, index) {
        final task = allCompletedTasks[index];
        final playerTask = taskService.getPlayerTask(task.id);
        return _buildTaskCard(task, playerTask, taskService, gameProvider);
      },
    );
  }

  Widget _buildTaskCard(Task task, PlayerTask? playerTask, TaskService taskService, GameProvider gameProvider) {
    final isCompleted = playerTask?.status == TaskStatus.completed;
    final isClaimed = playerTask?.status == TaskStatus.claimed;
    final isActive = playerTask?.status == TaskStatus.active;
    final canClaim = isCompleted && !isClaimed;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: canClaim 
              ? const Color(0xFFe94560) 
              : isClaimed 
                  ? Colors.green.withOpacity(0.5)
                  : const Color(0xFF333333),
          width: canClaim ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 任务标题和状态
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildTaskTypeIcon(task.type),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            task.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: isClaimed ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusIcon(playerTask?.status ?? TaskStatus.locked),
            ],
          ),

          const SizedBox(height: 12),

          // 进度条
          if (playerTask != null && isActive)
            _buildProgressBar(task, playerTask),

          // 时间限制
          if (task.timeLimit != null && playerTask != null && isActive)
            _buildTimeLimit(task, playerTask),

          const SizedBox(height: 12),

          // 奖励展示
          _buildRewards(task.rewards),

          const SizedBox(height: 12),

          // 操作按钮
          if (canClaim)
            _buildClaimButton(task, taskService, gameProvider)
          else if (isClaimed)
            _buildClaimedIndicator()
          else if (isActive && playerTask != null)
            _buildProgressText(task, playerTask),
        ],
      ),
    );
  }

  Widget _buildTaskTypeIcon(TaskType type) {
    IconData icon;
    Color color;
    
    switch (type) {
      case TaskType.daily:
        icon = Icons.today;
        color = Colors.orange;
        break;
      case TaskType.main:
        icon = Icons.flag;
        color = Colors.blue;
        break;
      case TaskType.weekly:
        icon = Icons.calendar_today;
        color = Colors.purple;
        break;
      case TaskType.achievement:
        icon = Icons.emoji_events;
        color = Colors.yellow;
        break;
    }

    return Icon(icon, color: color, size: 20);
  }

  Widget _buildStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.active:
        return const Icon(Icons.play_circle, color: Colors.blue, size: 24);
      case TaskStatus.completed:
        return const Icon(Icons.check_circle, color: Colors.orange, size: 24);
      case TaskStatus.claimed:
        return const Icon(Icons.check_circle, color: Colors.green, size: 24);
      case TaskStatus.locked:
        return const Icon(Icons.lock, color: Colors.grey, size: 24);
    }
  }

  Widget _buildProgressBar(Task task, PlayerTask playerTask) {
    final progress = playerTask.getProgressPercentage(task);
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '进度',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            Text(
              playerTask.getProgressText(task),
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[800],
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFe94560)),
        ),
      ],
    );
  }

  Widget _buildTimeLimit(Task task, PlayerTask playerTask) {
    final remainingTime = playerTask.getRemainingTime(task);
    if (remainingTime == null) return const SizedBox.shrink();

    final hours = remainingTime.inHours;
    final minutes = remainingTime.inMinutes % 60;
    
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          const Icon(Icons.timer, color: Colors.orange, size: 16),
          const SizedBox(width: 4),
          Text(
            '剩余时间: ${hours}小时${minutes}分钟',
            style: const TextStyle(color: Colors.orange, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildRewards(List<TaskReward> rewards) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: rewards.map((reward) => _buildRewardChip(reward)).toList(),
    );
  }

  Widget _buildRewardChip(TaskReward reward) {
    IconData icon;
    Color color;
    
    switch (reward.type) {
      case RewardType.spiritStones:
        icon = Icons.diamond;
        color = Colors.blue;
        break;
      case RewardType.experience:
        icon = Icons.star;
        color = Colors.yellow;
        break;
      case RewardType.equipment:
        icon = Icons.shield;
        color = Colors.green;
        break;
      case RewardType.technique:
        icon = Icons.book;
        color = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            reward.displayText,
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimButton(Task task, TaskService taskService, GameProvider gameProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          AudioService().playCoinsSound();
          final rewards = taskService.claimTaskReward(task.id, gameProvider.player!);
          if (rewards != null) {
            _showRewardDialog(task, rewards);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFe94560),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('领取奖励', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildClaimedIndicator() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.5)),
      ),
      child: const Text(
        '已完成',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildProgressText(Task task, PlayerTask playerTask) {
    return Text(
      '进度: ${playerTask.getProgressText(task)}',
      style: TextStyle(color: Colors.grey[400], fontSize: 14),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _getEmptyMessage(TaskType type) {
    switch (type) {
      case TaskType.daily:
        return '今日任务已全部完成！\n明天再来看看吧';
      case TaskType.main:
        return '主线任务已全部完成！\n恭喜你完成了修仙之路';
      case TaskType.weekly:
        return '本周任务已全部完成！\n下周再来挑战吧';
      case TaskType.achievement:
        return '成就任务已全部完成！\n你真是修仙天才';
    }
  }

  void _showRewardDialog(Task task, Map<String, dynamic> rewards) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: Row(
          children: [
            const Icon(Icons.card_giftcard, color: Color(0xFFe94560)),
            const SizedBox(width: 8),
            const Text(
              '任务完成！',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '完成任务：${task.name}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              '获得奖励：',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 8),
            ...rewards.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    entry.key == 'spiritStones' ? Icons.diamond : Icons.star,
                    color: entry.key == 'spiritStones' ? Colors.blue : Colors.yellow,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${entry.key == 'spiritStones' ? '灵石' : '经验值'} +${entry.value}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '确定',
              style: TextStyle(color: Color(0xFFe94560)),
            ),
          ),
        ],
      ),
    );
  }

  void _generateAITasks(BuildContext context) {
    final taskService = Provider.of<TaskService>(context, listen: false);
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final player = gameProvider.player;
    
    if (player == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.yellow),
            SizedBox(width: 8),
            Text(
              'AI任务生成器',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '使用AI为你生成个性化的修炼任务',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '• 根据你的修炼境界定制难度',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            Text(
              '• 智能推荐适合的任务类型',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            Text(
              '• 动态调整奖励和时间限制',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '取消',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              taskService.generateAITasks(player, count: 3);
              _showAITasksGeneratedDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFe94560),
              foregroundColor: Colors.white,
            ),
            child: const Text('生成任务'),
          ),
        ],
      ),
    );
  }

  void _showAITasksGeneratedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text(
              '任务生成成功！',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: const Text(
          '已为你生成3个个性化任务，快去完成吧！',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '确定',
              style: TextStyle(color: Color(0xFFe94560)),
            ),
          ),
        ],
      ),
    );
  }
}
