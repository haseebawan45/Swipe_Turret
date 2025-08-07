import 'package:flutter/material.dart';
import '../utils/vector2d.dart';
import '../utils/game_constants.dart';
import '../effects/neon_effects.dart';
import 'dart:math' as math;

class Bullet {
  Vector2D position;
  Vector2D velocity;
  double radius;
  bool isActive;
  List<Vector2D> trail;
  double lifeTime;
  NeonParticleSystem particleSystem;
  double energyLevel;
  
  Bullet({
    required this.position,
    required Vector2D direction,
  }) : velocity = direction.normalized() * GameConstants.bulletSpeed,
       radius = GameConstants.bulletRadius,
       isActive = true,
       trail = [],
       lifeTime = 0.0,
       particleSystem = NeonParticleSystem(),
       energyLevel = 1.0;

  void update(double deltaTime) {
    if (!isActive) return;

    lifeTime += deltaTime;
    
    // Add current position to trail with more points for smoother effect
    trail.add(Vector2D.copy(position));
    if (trail.length > GameConstants.maxTrailPoints * 2) {
      trail.removeAt(0);
    }

    // Update position
    position = position + (velocity * deltaTime);

    // Update particle system
    particleSystem.update(deltaTime);
    
    // Add continuous trail particles
    if (math.Random().nextDouble() < 0.8) {
      _addTrailParticle();
    }

    // Check if bullet is off screen
    if (position.x < -50 || 
        position.x > GameConstants.screenWidth + 50 ||
        position.y < -50 || 
        position.y > GameConstants.screenHeight + 50) {
      isActive = false;
    }
  }

  void _addTrailParticle() {
    final random = math.Random();
    final perpendicular = Vector2D(-velocity.y, velocity.x).normalized();
    final offset = perpendicular * (random.nextDouble() - 0.5) * 10;
    
    particleSystem.addParticle(NeonParticle(
      position: Vector2D.copy(position) + offset,
      velocity: velocity * -0.2 + Vector2D(
        (random.nextDouble() - 0.5) * 30,
        (random.nextDouble() - 0.5) * 30,
      ),
      maxLife: 0.3 + random.nextDouble() * 0.2,
      color: GameConstants.bulletColor,
      size: 0.5 + random.nextDouble() * 1.5,
    ));
  }

  void render(Canvas canvas, Size size) {
    if (!isActive) return;

    // Render particle system first
    particleSystem.render(canvas, size);
    
    // Draw advanced trail with multiple layers
    _drawAdvancedTrail(canvas);
    
    // Draw multiple glow layers for depth
    _drawGlowLayers(canvas);
    
    // Draw main bullet body
    _drawBulletCore(canvas);
    
    // Draw energy corona
    _drawEnergyCorona(canvas);
    
    // Draw leading spark effect
    _drawLeadingSpark(canvas);
  }

  void _drawAdvancedTrail(Canvas canvas) {
    if (trail.length < 2) return;

    // Draw multiple trail layers for depth
    final trailLayers = [
      (8.0, 0.1), // Outer glow
      (5.0, 0.2), // Mid glow
      (3.0, 0.4), // Inner trail
      (1.5, 0.6), // Core trail
    ];

    for (final layer in trailLayers) {
      final trailPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = layer.$1
        ..maskFilter = layer.$1 > 3 ? const MaskFilter.blur(BlurStyle.normal, 2.0) : null;

      final path = Path();
      path.moveTo(trail[0].x, trail[0].y);

      for (int i = 1; i < trail.length; i++) {
        final alpha = (i / trail.length) * layer.$2;
        trailPaint.color = GameConstants.bulletColor.withValues(alpha: alpha);
        
        // Create smooth curve
        if (i < trail.length - 1) {
          final controlPoint = Vector2D(
            (trail[i].x + trail[i + 1].x) / 2,
            (trail[i].y + trail[i + 1].y) / 2,
          );
          path.quadraticBezierTo(
            trail[i].x, trail[i].y,
            controlPoint.x, controlPoint.y,
          );
        } else {
          path.lineTo(trail[i].x, trail[i].y);
        }
      }

      canvas.drawPath(path, trailPaint);
    }
  }

  void _drawGlowLayers(Canvas canvas) {
    final center = Offset(position.x, position.y);
    
    // Multiple glow layers
    final glowLayers = [
      (radius * 6.0, 0.05),
      (radius * 4.0, 0.1),
      (radius * 3.0, 0.15),
      (radius * 2.0, 0.25),
    ];

    for (final layer in glowLayers) {
      final paint = Paint()
        ..color = GameConstants.bulletColor.withValues(alpha: layer.$2)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, layer.$1 * 0.3);

      canvas.drawCircle(center, layer.$1, paint);
    }
  }

  void _drawBulletCore(Canvas canvas) {
    final center = Offset(position.x, position.y);
    
    // Create advanced radial gradient
    final gradient = RadialGradient(
      colors: [
        Colors.white,
        GameConstants.bulletColor,
        GameConstants.bulletColor.withValues(alpha: 0.8),
        GameConstants.bulletColor.withValues(alpha: 0.4),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius * 2),
      );

    canvas.drawCircle(center, radius, paint);
  }

  void _drawEnergyCorona(Canvas canvas) {
    final center = Offset(position.x, position.y);
    
    // Pulsing energy corona
    final coronaRadius = radius + 3 + 2 * math.sin(lifeTime * 15);
    final coronaPaint = Paint()
      ..color = GameConstants.bulletColor.withValues(
        alpha: 0.3 + 0.2 * math.sin(lifeTime * 12)
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

    canvas.drawCircle(center, coronaRadius, coronaPaint);
  }

  void _drawLeadingSpark(Canvas canvas) {
    final center = Offset(position.x, position.y);
    
    // Leading spark in direction of movement
    final sparkLength = 15.0;
    final sparkDirection = velocity.normalized();
    final sparkEnd = Vector2D(
      position.x + sparkDirection.x * sparkLength,
      position.y + sparkDirection.y * sparkLength,
    );

    final sparkPaint = Paint()
      ..color = Colors.white.withValues(
        alpha: 0.8 + 0.2 * math.sin(lifeTime * 20)
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);

    canvas.drawLine(
      center,
      Offset(sparkEnd.x, sparkEnd.y),
      sparkPaint,
    );

    // Additional spark effects
    for (int i = 0; i < 3; i++) {
      final angle = (i - 1) * 0.3; // Spread sparks
      final sparkDir = Vector2D(
        sparkDirection.x * math.cos(angle) - sparkDirection.y * math.sin(angle),
        sparkDirection.x * math.sin(angle) + sparkDirection.y * math.cos(angle),
      );
      
      final miniSparkEnd = Vector2D(
        position.x + sparkDir.x * sparkLength * 0.6,
        position.y + sparkDir.y * sparkLength * 0.6,
      );

      final miniSparkPaint = Paint()
        ..color = GameConstants.bulletColor.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        center,
        Offset(miniSparkEnd.x, miniSparkEnd.y),
        miniSparkPaint,
      );
    }
  }

  bool checkCollision(Vector2D point, double otherRadius) {
    return isActive && position.distanceTo(point) < (radius + otherRadius);
  }

  void destroy() {
    isActive = false;
    
    // Add destruction particle effect
    particleSystem.addExplosion(
      position, 
      GameConstants.bulletColor, 
      count: 6
    );
  }
}