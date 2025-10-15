import 'package:flutter/material.dart';
import 'dart:math';

// 伤害数字飞出效果
class DamageNumber extends StatefulWidget {
  final int damage;
  final Color color;
  final Offset startPosition;

  const DamageNumber({
    super.key,
    required this.damage,
    required this.color,
    required this.startPosition,
  });

  @override
  State<DamageNumber> createState() => _DamageNumberState();
}

class _DamageNumberState extends State<DamageNumber>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -2),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.startPosition.dx,
          top: widget.startPosition.dy,
          child: Transform.translate(
            offset: _slideAnimation.value * 50,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Text(
                  '-${widget.damage}',
                  style: TextStyle(
                    color: widget.color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.8),
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// 技能特效
class SkillEffect extends StatefulWidget {
  final String skillType;
  final Offset position;

  const SkillEffect({
    super.key,
    required this.skillType,
    required this.position,
  });

  @override
  State<SkillEffect> createState() => _SkillEffectState();
}

class _SkillEffectState extends State<SkillEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.position.dx - 50,
          top: widget.position.dy - 50,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: _buildSkillIcon(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkillIcon() {
    switch (widget.skillType) {
      case 'spirit_strike':
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.cyan.withOpacity(0.8),
                Colors.blue.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
          child: const Icon(
            Icons.flash_on,
            size: 50,
            color: Colors.white,
          ),
        );
      case 'lightning_strike':
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.yellow.withOpacity(0.9),
                Colors.orange.withOpacity(0.5),
                Colors.transparent,
              ],
            ),
          ),
          child: const Icon(
            Icons.bolt,
            size: 50,
            color: Colors.white,
          ),
        );
      case 'healing_light':
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.green.withOpacity(0.8),
                Colors.lightGreen.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
          child: const Icon(
            Icons.healing,
            size: 50,
            color: Colors.white,
          ),
        );
      default:
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.red.withOpacity(0.8),
                Colors.orange.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
          child: const Icon(
            Icons.whatshot,
            size: 50,
            color: Colors.white,
          ),
        );
    }
  }
}

// 攻击冲击波效果
class AttackWave extends StatefulWidget {
  final Offset position;

  const AttackWave({
    super.key,
    required this.position,
  });

  @override
  State<AttackWave> createState() => _AttackWaveState();
}

class _AttackWaveState extends State<AttackWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 3.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.8,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.position.dx - 25,
          top: widget.position.dy - 25,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// 粒子效果
class ParticleEffect extends StatefulWidget {
  final Offset position;
  final Color color;
  final int particleCount;

  const ParticleEffect({
    super.key,
    required this.position,
    required this.color,
    this.particleCount = 20,
  });

  @override
  State<ParticleEffect> createState() => _ParticleEffectState();
}

class _ParticleEffectState extends State<ParticleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    particles = List.generate(widget.particleCount, (index) {
      final random = Random();
      return Particle(
        position: widget.position,
        velocity: Offset(
          (random.nextDouble() - 0.5) * 200,
          (random.nextDouble() - 0.5) * 200,
        ),
        color: widget.color,
        size: random.nextDouble() * 4 + 2,
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: particles.map((particle) {
            final progress = _controller.value;
            final currentPosition = particle.position + 
                (particle.velocity * progress);
            
            return Positioned(
              left: currentPosition.dx,
              top: currentPosition.dy,
              child: Opacity(
                opacity: 1.0 - progress,
                child: Container(
                  width: particle.size,
                  height: particle.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: particle.color,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class Particle {
  final Offset position;
  final Offset velocity;
  final Color color;
  final double size;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
  });
}
