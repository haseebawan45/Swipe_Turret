import 'package:flutter/material.dart';
import '../utils/vector2d.dart';
import '../utils/game_constants.dart';
import 'dart:math' as math;

class Particle {
  Vector2D position;
  Vector2D velocity;
  double life;
  double maxLife;
  Color color;
  double size;

  Particle({
    required this.position,
    required this.velocity,
    required this.maxLife,
    required this.color,
    required this.size,
  }) : life = maxLife;

  void update(double deltaTime) {
    life -= deltaTime;
    position = position + (velocity * deltaTime);
    
    // Apply gravity/drag
    velocity = velocity * 0.98;
  }

  bool get isAlive => life > 0;

  double get alpha => life / maxLife;
}

class Explosion {
  Vector2D position;
  List<Particle> particles;
  double life;
  double maxLife;
  bool isActive;

  Explosion({required this.position}) 
      : particles = [],
        life = GameConstants.explosionDuration,
        maxLife = GameConstants.explosionDuration,
        isActive = true {
    _createParticles();
  }

  void _createParticles() {
    final random = math.Random();
    const particleCount = 20;

    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * math.pi + random.nextDouble() * 0.5;
      final speed = 50 + random.nextDouble() * 100;
      final velocity = Vector2D.fromAngle(angle, speed);
      
      final particle = Particle(
        position: Vector2D.copy(position),
        velocity: velocity,
        maxLife: 0.3 + random.nextDouble() * 0.4,
        color: _getRandomExplosionColor(),
        size: 2 + random.nextDouble() * 4,
      );
      
      particles.add(particle);
    }
  }

  Color _getRandomExplosionColor() {
    final random = math.Random();
    final colors = [
      GameConstants.explosionColor,
      Colors.white,
      Colors.yellow,
      Colors.orange,
      Colors.red,
    ];
    return colors[random.nextInt(colors.length)];
  }

  void update(double deltaTime) {
    if (!isActive) return;

    life -= deltaTime;
    
    // Update particles
    particles.removeWhere((particle) {
      particle.update(deltaTime);
      return !particle.isAlive;
    });

    // Deactivate explosion when no particles left or time expired
    if (particles.isEmpty || life <= 0) {
      isActive = false;
    }
  }

  void render(Canvas canvas, Size size) {
    if (!isActive) return;

    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.alpha)
        ..style = PaintingStyle.fill;

      // Draw particle with glow effect
      final glowPaint = Paint()
        ..color = particle.color.withOpacity(particle.alpha * 0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 2.0);

      canvas.drawCircle(
        Offset(particle.position.x, particle.position.y),
        particle.size + 2,
        glowPaint,
      );

      canvas.drawCircle(
        Offset(particle.position.x, particle.position.y),
        particle.size,
        paint,
      );
    }

    // Draw central flash effect
    if (life > maxLife * 0.7) {
      final flashAlpha = (life - maxLife * 0.7) / (maxLife * 0.3);
      final flashPaint = Paint()
        ..color = Colors.white.withOpacity(flashAlpha * 0.8)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 10.0);

      canvas.drawCircle(
        Offset(position.x, position.y),
        20 * flashAlpha,
        flashPaint,
      );
    }
  }
}