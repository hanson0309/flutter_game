import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/image_assets.dart';

class CharacterAvatar extends StatelessWidget {
  final String? imagePath;
  final IconData fallbackIcon;
  final Color fallbackColor;
  final double size;
  final bool isAnimated;

  const CharacterAvatar({
    super.key,
    this.imagePath,
    required this.fallbackIcon,
    required this.fallbackColor,
    this.size = 60,
    this.isAnimated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: fallbackColor.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    // 如果有图片路径且图片存在，显示图片
    if (imagePath != null) {
      if (imagePath!.endsWith('.svg')) {
        // SVG图片
        return SvgPicture.asset(
          imagePath!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholderBuilder: (context) => _buildFallbackIcon(),
        );
      } else {
        // 普通图片
        return Image.asset(
          imagePath!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // 图片加载失败时显示图标
            return _buildFallbackIcon();
          },
        );
      }
    }
    
    // 没有图片时显示图标
    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: fallbackColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        fallbackIcon,
        size: size * 0.6,
        color: Colors.white,
      ),
    );
  }
}

class EnemyAvatar extends StatelessWidget {
  final String enemyId;
  final IconData fallbackIcon;
  final Color fallbackColor;
  final double size;
  final bool isAnimated;

  const EnemyAvatar({
    super.key,
    required this.enemyId,
    required this.fallbackIcon,
    required this.fallbackColor,
    this.size = 80,
    this.isAnimated = false,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = ImageAssets.hasEnemyImage(enemyId) 
        ? ImageAssets.getEnemyImage(enemyId) 
        : null;

    return CharacterAvatar(
      imagePath: imagePath,
      fallbackIcon: fallbackIcon,
      fallbackColor: fallbackColor,
      size: size,
      isAnimated: isAnimated,
    );
  }
}

// 动画版本的角色头像
class AnimatedCharacterAvatar extends StatefulWidget {
  final String? imagePath;
  final IconData fallbackIcon;
  final Color fallbackColor;
  final double size;
  final Duration animationDuration;

  const AnimatedCharacterAvatar({
    super.key,
    this.imagePath,
    required this.fallbackIcon,
    required this.fallbackColor,
    this.size = 60,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  State<AnimatedCharacterAvatar> createState() => _AnimatedCharacterAvatarState();
}

class _AnimatedCharacterAvatarState extends State<AnimatedCharacterAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _rotationAnimation = Tween<double>(begin: 0, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void playAnimation() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: playAnimation,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: CharacterAvatar(
                imagePath: widget.imagePath,
                fallbackIcon: widget.fallbackIcon,
                fallbackColor: widget.fallbackColor,
                size: widget.size,
              ),
            ),
          );
        },
      ),
    );
  }
}
