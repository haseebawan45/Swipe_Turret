import 'package:flutter/material.dart';
import '../utils/vector2d.dart';
import '../utils/game_constants.dart';
import '../effects/neon_effects.dart';
import 'dart:math' as math;

enum MissileType {
  standard,
  fast,
  heavy,
  boss,
}

class Missile {
  Vector2D position;
  Vector2D velocity;
  Vector2D targetPosition;
  double radius;
  double speed;
  bool isActive;
  List<Vector2D> trail;
  double lifeTime;
  double rotationAngle;
  NeonParticleSystem particleSystem;
  MissileType type;
  int health;
  double thrusterIntensity;
  
  Missile({
    required this.position,
    required this.targetPosition,
    required this.speed,
    this.type = MissileType.standard,
  }) : velocity = Vector2D.zero(),
       radius = GameConstants.missileRadius,
       isActive = true,
       trail = [],
       lifeTime = 0.0,
       rotationAngle = 0.0,
       particleSystem = NeonParticleSystem(),
       health = type == MissileType.heavy ? 2 : 1,
       thrusterIntensity = 1.0;

  void update(double deltaTime) {
    if (!isActive) return;

    lifeTime += deltaTime;
    rotationAngle += deltaTime * (type == MissileType.fast ? 8.0 : 5.0);

    // Add current position to trail with more points for smoother effect
    trail.add(Vector2D.copy(position));
    final maxTrailPoints = type == MissileType.fast ? 
        GameConstants.maxTrailPoints * 2 : GameConstants.maxTrailPoints;
    if (trail.length > maxTrailPoints) {
      trail.removeAt(0);
    }

    // Homing behavior with improved steering
    final directionToTarget = Vector2D(
      targetPosition.x - position.x,
      targetPosition.y - position.y,
    ).normalized();

    // Smooth steering instead of instant direction change
    final currentDirection = velocity.magnitude > 0 ? velocity.normalized() : directionToTarget;
    final steeringForce = (directionToTarget - currentDirection) * 2.0;
    velocity = (velocity + steeringForce * deltaTime).normalized() * speed;

    // Update position
    position = position + (velocity * deltaTime);

    // Update particle system
    particleSystem.update(deltaTime);
    
    // Add thruster particles
    _addThrusterParticles();

    // Check if missile is way off screen (cleanup)
    if (position.x < -100 || 
        position.x > GameConstants.screenWidth + 100 ||
        position.y < -100 || 
        position.y > GameConstants.screenHeight + 100) {
      isActive = false;
    }
  }

  void _addThrusterParticles() {
    if (math.Random().nextDouble() < 0.7) {
      final thrusterDirection = velocity.normalized() * -1;
      final random = math.Random();
      
      // Add main thruster particle
      particleSystem.addParticle(NeonParticle(
        position: Vector2D.copy(position) + thrusterDirection * radius,
        velocity: thrusterDirection * (30 + random.nextDouble() * 40) + Vector2D(
          (random.nextDouble() - 0.5) * 20,
          (random.nextDouble() - 0.5) * 20,
        ),
        maxLife: 0.4 + random.nextDouble() * 0.3,
        color: _getThrusterColor(),
        size: 1.0 + random.nextDouble() * 2.0,
      ));
    }
  }

  Color _getThrusterColor() {
    switch (type) {
      case MissileType.standard:
        return GameConstants.missileColor;
      case MissileType.fast:
        return Colors.white;
      case MissileType.heavy:
        return Colors.purple;
      case MissileType.boss:
        return Colors.red;
    }
  }

  Color _getMissileColor() {
    switch (type) {
      case MissileType.standard:
        return GameConstants.missileColor;
      case MissileType.fast:
        return const Color(0xFFFFFFFF);
      case MissileType.heavy:
        return const Color(0xFF8000FF);
      case MissileType.boss:
        return const Color(0xFFFF0000);
    }
  }

  void render(Canvas canvas, Size size) {
    if (!isActive) return;

    // Render particle system first
    particleSystem.render(canvas, size);
    
    // Draw advanced trail
    _drawAdvancedTrail(canvas);
    
    // Draw warning indicator when close to target
    _drawWarningIndicator(canvas);
    
    // Draw glow layers
    _drawGlowLayers(canvas);
    
    // Draw missile body
    _drawMissileBody(canvas);
    
    // Draw type-specific effects
    _drawTypeSpecificEffects(canvas);
  }

  void _drawAdvancedTrail(Canvas canvas) {
    if (trail.length < 2) return;

    final missileColor = _getMissileColor();
    
    // Multiple trail layers for depth
    final trailLayers = [
      (6.0, 0.15), // Outer glow
      (4.0, 0.25), // Mid trail
      (2.5, 0.4),  // Inner trail
      (1.0, 0.6),  // Core trail
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
        trailPaint.color = missileColor.withValues(alpha: alpha);
        
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

  void _drawWarningIndicator(Canvas canvas) {
    final distanceToTarget = position.distanceTo(targetPosition);
    if (distanceToTarget < 120) {
      final intensity = 1.0 - (distanceToTarget / 120.0);
      final warningRadius = radius + 15 + 8 * math.sin(lifeTime * 12) * intensity;
      
      final warningPaint = Paint()
        ..color = Colors.red.withValues(
          alpha: (0.4 + 0.4 * math.sin(lifeTime * 15)) * intensity
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
      
      canvas.drawCircle(
        Offset(position.x, position.y), 
        warningRadius, 
        warningPaint,
      );

      // Additional warning rings
      for (int i = 1; i <= 2; i++) {
        final ringRadius = warningRadius + i * 10;
        final ringAlpha = (0.2 - i * 0.05) * intensity;
        
        final ringPaint = Paint()
          ..color = Colors.red.withValues(alpha: ringAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        
        canvas.drawCircle(
          Offset(position.x, position.y),
          ringRadius,
          ringPaint,
        );
      }
    }
  }

  void _drawGlowLayers(Canvas canvas) {
    final center = Offset(position.x, position.y);
    final missileColor = _getMissileColor();
    
    // Multiple glow layers
    final glowLayers = [
      (radius * 4.0, 0.1),
      (radius * 3.0, 0.15),
      (radius * 2.0, 0.25),
    ];

    for (final layer in glowLayers) {
      final paint = Paint()
        ..color = missileColor.withValues(alpha: layer.$2)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, layer.$1 * 0.3);

      canvas.drawCircle(center, layer.$1, paint);
    }
  }

  void _drawMissileBody(Canvas canvas) {
    final center = Offset(position.x, position.y);
    final missileColor = _getMissileColor();
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);

    // Create missile shape based on type
    final path = _createMissileShape();
    
    // Create advanced gradient
    final gradient = RadialGradient(
      colors: [
        Colors.white,
        missileColor,
        missileColor.withValues(alpha: 0.8),
        missileColor.withValues(alpha: 0.4),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = gradient.createShader(
        Rect.fromCircle(center: Offset.zero, radius: radius * 2),
      );

    canvas.drawPath(path, paint);

    // Draw outer glow
    final glowPaint = Paint()
      ..color = missileColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    
    canvas.drawPath(path, glowPaint);

    // Draw center core with pulsing effect
    final corePaint = Paint()
      ..color = Colors.white.withValues(
        alpha: 0.9 + 0.1 * math.sin(lifeTime * 8)
      )
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset.zero, radius * 0.4, corePaint);

    // Draw health indicators for heavy missiles
    if (type == MissileType.heavy && health > 1) {
      _drawHealthIndicators(canvas);
    }

    canvas.restore();
  }

  Path _createMissileShape() {
    final path = Path();
    
    switch (type) {
      case MissileType.standard:
        // Diamond shape
        path.moveTo(0, -radius);
        path.lineTo(radius * 0.6, 0);
        path.lineTo(0, radius);
        path.lineTo(-radius * 0.6, 0);
        path.close();
        break;
        
      case MissileType.fast:
        // Arrow shape
        path.moveTo(0, -radius * 1.2);
        path.lineTo(radius * 0.4, -radius * 0.3);
        path.lineTo(radius * 0.3, radius);
        path.lineTo(-radius * 0.3, radius);
        path.lineTo(-radius * 0.4, -radius * 0.3);
        path.close();
        break;
        
      case MissileType.heavy:
        // Hexagonal shape
        for (int i = 0; i < 6; i++) {
          final angle = (i / 6) * 2 * math.pi;
          final x = math.cos(angle) * radius;
          final y = math.sin(angle) * radius;
          
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        break;
        
      case MissileType.boss:
        // Boss shape (handled in the Boss class)
        path.addOval(Rect.fromCircle(center: Offset.zero, radius: radius));
        break;
    }
    
    return path;
  }

  void _drawHealthIndicators(Canvas canvas) {
    for (int i = 0; i < health; i++) {
      final indicatorPaint = Paint()
        ..color = Colors.green.withValues(alpha: 0.8)
        ..style = PaintingStyle.fill;
      
      final x = -radius * 0.3 + i * (radius * 0.6 / (health - 1));
      canvas.drawCircle(Offset(x, -radius * 0.7), 2.0, indicatorPaint);
    }
  }

  void _drawTypeSpecificEffects(Canvas canvas) {
    switch (type) {
      case MissileType.fast:
        // Speed lines
        _drawSpeedLines(canvas);
        break;
        
      case MissileType.heavy:
        // Energy field
        _drawEnergyField(canvas);
        break;
        
      case MissileType.standard:
        // Standard pulsing effect
        _drawPulsingEffect(canvas);
        break;
        
      case MissileType.boss:
        // Boss-specific effects are handled in the Boss class
        break;
    }
  }

  void _drawSpeedLines(Canvas canvas) {
    final direction = velocity.normalized() * -1;
    
    for (int i = 0; i < 5; i++) {
      final lineLength = 20 + i * 5;
      final lineStart = Vector2D(
        position.x + direction.x * (radius + i * 8),
        position.y + direction.y * (radius + i * 8),
      );
      final lineEnd = Vector2D(
        lineStart.x + direction.x * lineLength,
        lineStart.y + direction.y * lineLength,
      );

      final linePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.6 - i * 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 - i * 0.3
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(lineStart.x, lineStart.y),
        Offset(lineEnd.x, lineEnd.y),
        linePaint,
      );
    }
  }

  void _drawEnergyField(Canvas canvas) {
    final center = Offset(position.x, position.y);
    final fieldRadius = radius + 12 + 4 * math.sin(lifeTime * 6);
    
    final fieldPaint = Paint()
      ..color = Colors.purple.withValues(
        alpha: 0.2 + 0.1 * math.sin(lifeTime * 8)
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    canvas.drawCircle(center, fieldRadius, fieldPaint);
  }

  void _drawPulsingEffect(Canvas canvas) {
    final center = Offset(position.x, position.y);
    final pulseRadius = radius + 8 + 3 * math.sin(lifeTime * 10);
    
    final pulsePaint = Paint()
      ..color = GameConstants.missileColor.withValues(
        alpha: 0.3 + 0.2 * math.sin(lifeTime * 10)
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, pulseRadius, pulsePaint);
  }

  bool checkCollision(Vector2D point, double otherRadius) {
    return isActive && position.distanceTo(point) < (radius + otherRadius);
  }

  void takeDamage() {
    health--;
    if (health <= 0) {
      destroy();
    } else {
      // Add damage effect
      particleSystem.addExplosion(
        position, 
        _getMissileColor(), 
        count: 5
      );
    }
  }

  void destroy() {
    isActive = false;
    
    // Add destruction particle effect
    final explosionCount = type == MissileType.heavy ? 20 : 15;
    particleSystem.addExplosion(
      position, 
      _getMissileColor(), 
      count: explosionCount
    );
  }
}