import 'package:flutter/material.dart';
import '../utils/vector2d.dart';
import '../utils/game_constants.dart';
import '../effects/neon_effects.dart';
import 'dart:math' as math;

enum ExplosionType {
  bullet,
  missile,
  turret,
}

class ExplosionParticle {
  Vector2D position;
  Vector2D velocity;
  double life;
  double maxLife;
  Color color;
  double size;
  double rotation;
  double rotationSpeed;
  ExplosionType type;

  ExplosionParticle({
    required this.position,
    required this.velocity,
    required this.maxLife,
    required this.color,
    required this.size,
    this.rotation = 0.0,
    this.rotationSpeed = 0.0,
    this.type = ExplosionType.bullet,
  }) : life = maxLife;

  void update(double deltaTime) {
    life -= deltaTime;
    position = position + (velocity * deltaTime);
    rotation += rotationSpeed * deltaTime;
    
    // Apply physics based on type
    switch (type) {
      case ExplosionType.bullet:
        velocity = velocity * 0.95; // Light drag
        break;
      case ExplosionType.missile:
        velocity = velocity * 0.92; // Medium drag
        break;
      case ExplosionType.turret:
        velocity = velocity * 0.88; // Heavy drag
        break;
    }
  }

  bool get isAlive => life > 0;
  double get alpha => (life / maxLife).clamp(0.0, 1.0);
  double get scale => alpha;
}

class Explosion {
  Vector2D position;
  List<ExplosionParticle> particles;
  double life;
  double maxLife;
  bool isActive;
  ExplosionType type;
  NeonParticleSystem neonParticles;
  double shockwaveRadius;
  double maxShockwaveRadius;

  Explosion({
    required this.position,
    this.type = ExplosionType.bullet,
  }) : particles = [],
       life = _getExplosionDuration(type),
       maxLife = _getExplosionDuration(type),
       isActive = true,
       neonParticles = NeonParticleSystem(),
       shockwaveRadius = 0.0,
       maxShockwaveRadius = _getMaxShockwaveRadius(type) {
    _createParticles();
    _createNeonEffects();
  }

  static double _getExplosionDuration(ExplosionType type) {
    switch (type) {
      case ExplosionType.bullet:
        return 0.6;
      case ExplosionType.missile:
        return 0.8;
      case ExplosionType.turret:
        return 1.2;
    }
  }

  static double _getMaxShockwaveRadius(ExplosionType type) {
    switch (type) {
      case ExplosionType.bullet:
        return 60.0;
      case ExplosionType.missile:
        return 100.0;
      case ExplosionType.turret:
        return 150.0;
    }
  }

  void _createParticles() {
    final random = math.Random();
    final particleCount = _getParticleCount();

    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * math.pi + random.nextDouble() * 0.5;
      final speed = _getParticleSpeed(random);
      final velocity = Vector2D.fromAngle(angle, speed);
      
      final particle = ExplosionParticle(
        position: Vector2D.copy(position),
        velocity: velocity,
        maxLife: _getParticleLifetime(random),
        color: _getRandomExplosionColor(),
        size: _getParticleSize(random),
        rotationSpeed: (random.nextDouble() - 0.5) * 10,
        type: type,
      );
      
      particles.add(particle);
    }

    // Add secondary particle ring for larger explosions
    if (type != ExplosionType.bullet) {
      _createSecondaryParticles();
    }
  }

  void _createSecondaryParticles() {
    final random = math.Random();
    final secondaryCount = type == ExplosionType.turret ? 15 : 10;

    for (int i = 0; i < secondaryCount; i++) {
      final angle = (i / secondaryCount) * 2 * math.pi;
      final speed = 30 + random.nextDouble() * 50;
      final velocity = Vector2D.fromAngle(angle, speed);
      
      final particle = ExplosionParticle(
        position: Vector2D.copy(position),
        velocity: velocity,
        maxLife: 0.8 + random.nextDouble() * 0.6,
        color: _getSecondaryExplosionColor(),
        size: 1.5 + random.nextDouble() * 3.0,
        rotationSpeed: (random.nextDouble() - 0.5) * 8,
        type: type,
      );
      
      particles.add(particle);
    }
  }

  void _createNeonEffects() {
    final random = math.Random();
    final neonCount = type == ExplosionType.turret ? 25 : 15;

    for (int i = 0; i < neonCount; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final speed = 80 + random.nextDouble() * 120;
      final velocity = Vector2D.fromAngle(angle, speed);
      
      neonParticles.addParticle(NeonParticle(
        position: Vector2D.copy(position),
        velocity: velocity,
        maxLife: 0.5 + random.nextDouble() * 0.7,
        color: _getPrimaryExplosionColor(),
        size: 1.0 + random.nextDouble() * 3.0,
        rotationSpeed: (random.nextDouble() - 0.5) * 12,
      ));
    }
  }

  int _getParticleCount() {
    switch (type) {
      case ExplosionType.bullet:
        return 15;
      case ExplosionType.missile:
        return 25;
      case ExplosionType.turret:
        return 40;
    }
  }

  double _getParticleSpeed(math.Random random) {
    switch (type) {
      case ExplosionType.bullet:
        return 60 + random.nextDouble() * 80;
      case ExplosionType.missile:
        return 80 + random.nextDouble() * 120;
      case ExplosionType.turret:
        return 100 + random.nextDouble() * 150;
    }
  }

  double _getParticleLifetime(math.Random random) {
    switch (type) {
      case ExplosionType.bullet:
        return 0.3 + random.nextDouble() * 0.4;
      case ExplosionType.missile:
        return 0.4 + random.nextDouble() * 0.6;
      case ExplosionType.turret:
        return 0.6 + random.nextDouble() * 0.8;
    }
  }

  double _getParticleSize(math.Random random) {
    switch (type) {
      case ExplosionType.bullet:
        return 1.5 + random.nextDouble() * 3.0;
      case ExplosionType.missile:
        return 2.0 + random.nextDouble() * 4.0;
      case ExplosionType.turret:
        return 3.0 + random.nextDouble() * 6.0;
    }
  }

  Color _getPrimaryExplosionColor() {
    switch (type) {
      case ExplosionType.bullet:
        return GameConstants.bulletColor;
      case ExplosionType.missile:
        return GameConstants.missileColor;
      case ExplosionType.turret:
        return GameConstants.turretColor;
    }
  }

  Color _getRandomExplosionColor() {
    final random = math.Random();
    final primaryColor = _getPrimaryExplosionColor();
    
    final colors = [
      primaryColor,
      Colors.white,
      Colors.yellow,
      Colors.orange,
      primaryColor.withValues(alpha: 0.8),
    ];
    return colors[random.nextInt(colors.length)];
  }

  Color _getSecondaryExplosionColor() {
    final random = math.Random();
    final colors = [
      Colors.white,
      Colors.yellow.withValues(alpha: 0.8),
      Colors.orange.withValues(alpha: 0.6),
    ];
    return colors[random.nextInt(colors.length)];
  }

  void update(double deltaTime) {
    if (!isActive) return;

    life -= deltaTime;
    
    // Update shockwave
    if (shockwaveRadius < maxShockwaveRadius) {
      shockwaveRadius += (maxShockwaveRadius / (maxLife * 0.3)) * deltaTime;
    }
    
    // Update particles
    particles.removeWhere((particle) {
      particle.update(deltaTime);
      return !particle.isAlive;
    });

    // Update neon particle system
    neonParticles.update(deltaTime);

    // Deactivate explosion when no particles left or time expired
    if (particles.isEmpty && neonParticles.particles.isEmpty || life <= 0) {
      isActive = false;
    }
  }

  void render(Canvas canvas, Size size) {
    if (!isActive) return;

    // Draw shockwave first
    _drawShockwave(canvas);
    
    // Draw central flash effect
    _drawCentralFlash(canvas);
    
    // Render neon particles
    neonParticles.render(canvas, size);

    // Draw main explosion particles with advanced effects
    _drawExplosionParticles(canvas);
    
    // Draw additional effects based on type
    _drawTypeSpecificEffects(canvas);
  }

  void _drawShockwave(Canvas canvas) {
    if (shockwaveRadius <= 0) return;

    final center = Offset(position.x, position.y);
    final shockwaveAlpha = 1.0 - (shockwaveRadius / maxShockwaveRadius);
    
    if (shockwaveAlpha <= 0) return;

    // Multiple shockwave rings for depth
    for (int i = 0; i < 3; i++) {
      final ringRadius = shockwaveRadius - i * 8;
      if (ringRadius <= 0) continue;
      
      final ringAlpha = shockwaveAlpha * (0.6 - i * 0.15);
      final shockwavePaint = Paint()
        ..color = _getPrimaryExplosionColor().withValues(alpha: ringAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0 - i * 1.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

      canvas.drawCircle(center, ringRadius, shockwavePaint);
    }
  }

  void _drawCentralFlash(Canvas canvas) {
    final flashProgress = 1.0 - (life / maxLife);
    if (flashProgress > 0.4) return; // Flash only in first 40% of explosion

    final center = Offset(position.x, position.y);
    final flashAlpha = (0.4 - flashProgress) / 0.4;
    final flashRadius = 30 * (1.0 - flashAlpha) * _getFlashScale();

    // Multiple flash layers
    final flashLayers = [
      (flashRadius * 2.0, flashAlpha * 0.2),
      (flashRadius * 1.5, flashAlpha * 0.4),
      (flashRadius, flashAlpha * 0.8),
      (flashRadius * 0.5, flashAlpha * 1.0),
    ];

    for (final layer in flashLayers) {
      final flashPaint = Paint()
        ..color = Colors.white.withValues(alpha: layer.$2)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, layer.$1 * 0.3);

      canvas.drawCircle(center, layer.$1, flashPaint);
    }
  }

  double _getFlashScale() {
    switch (type) {
      case ExplosionType.bullet:
        return 1.0;
      case ExplosionType.missile:
        return 1.5;
      case ExplosionType.turret:
        return 2.5;
    }
  }

  void _drawExplosionParticles(Canvas canvas) {
    for (final particle in particles) {
      final center = Offset(particle.position.x, particle.position.y);
      final scaledSize = particle.size * particle.scale;

      // Draw particle with multiple glow layers
      final glowLayers = [
        (scaledSize * 3.0, particle.alpha * 0.1),
        (scaledSize * 2.0, particle.alpha * 0.2),
        (scaledSize * 1.5, particle.alpha * 0.4),
      ];

      for (final layer in glowLayers) {
        final glowPaint = Paint()
          ..color = particle.color.withValues(alpha: layer.$2)
          ..style = PaintingStyle.fill
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, layer.$1 * 0.2);

        canvas.drawCircle(center, layer.$1, glowPaint);
      }

      // Draw main particle
      final particlePaint = Paint()
        ..color = particle.color.withValues(alpha: particle.alpha)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(particle.rotation);

      // Draw different shapes based on particle type
      if (particle.size > 3.0) {
        // Draw star shape for larger particles
        _drawStarParticle(canvas, scaledSize, particlePaint);
      } else {
        // Draw circle for smaller particles
        canvas.drawCircle(Offset.zero, scaledSize, particlePaint);
      }

      canvas.restore();
    }
  }

  void _drawStarParticle(Canvas canvas, double size, Paint paint) {
    final path = Path();
    const points = 5;
    
    for (int i = 0; i < points * 2; i++) {
      final angle = (i / (points * 2)) * 2 * math.pi;
      final radius = i.isEven ? size : size * 0.5;
      final x = math.cos(angle) * radius;
      final y = math.sin(angle) * radius;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawTypeSpecificEffects(Canvas canvas) {
    switch (type) {
      case ExplosionType.turret:
        _drawTurretExplosionEffects(canvas);
        break;
      case ExplosionType.missile:
        _drawMissileExplosionEffects(canvas);
        break;
      case ExplosionType.bullet:
        _drawBulletExplosionEffects(canvas);
        break;
    }
  }

  void _drawTurretExplosionEffects(Canvas canvas) {
    final center = Offset(position.x, position.y);
    final progress = 1.0 - (life / maxLife);
    
    // Draw expanding energy rings
    for (int i = 0; i < 4; i++) {
      final ringRadius = (progress * 120) + i * 20;
      final ringAlpha = (1.0 - progress) * (0.4 - i * 0.08);
      
      if (ringAlpha <= 0) continue;
      
      final ringPaint = Paint()
        ..color = GameConstants.turretColor.withValues(alpha: ringAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

      canvas.drawCircle(center, ringRadius, ringPaint);
    }
  }

  void _drawMissileExplosionEffects(Canvas canvas) {
    final center = Offset(position.x, position.y);
    final progress = 1.0 - (life / maxLife);
    
    // Draw directional blast effect
    final blastLength = progress * 80;
    final blastAlpha = 1.0 - progress;
    
    if (blastAlpha > 0) {
      final blastPaint = Paint()
        ..color = GameConstants.missileColor.withValues(alpha: blastAlpha * 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.0
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

      // Draw cross-shaped blast
      canvas.drawLine(
        Offset(center.dx - blastLength, center.dy),
        Offset(center.dx + blastLength, center.dy),
        blastPaint,
      );
      canvas.drawLine(
        Offset(center.dx, center.dy - blastLength),
        Offset(center.dx, center.dy + blastLength),
        blastPaint,
      );
    }
  }

  void _drawBulletExplosionEffects(Canvas canvas) {
    final center = Offset(position.x, position.y);
    final progress = 1.0 - (life / maxLife);
    
    // Draw sparkling effect
    if (progress < 0.5) {
      final sparkleAlpha = (0.5 - progress) / 0.5;
      final sparkleCount = 8;
      
      for (int i = 0; i < sparkleCount; i++) {
        final angle = (i / sparkleCount) * 2 * math.pi;
        final sparkleRadius = 15 + progress * 10;
        final sparklePos = Offset(
          center.dx + math.cos(angle) * sparkleRadius,
          center.dy + math.sin(angle) * sparkleRadius,
        );

        final sparklePaint = Paint()
          ..color = Colors.white.withValues(alpha: sparkleAlpha * 0.8)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(sparklePos, 1.5, sparklePaint);
      }
    }
  }
}