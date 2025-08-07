import 'package:flutter/material.dart';
import '../utils/vector2d.dart';
import '../utils/game_constants.dart';
import 'dart:math' as math;

class Bullet {
  Vector2D position;
  Vector2D velocity;
  double radius;
  bool isActive;
  List<Vector2D> trail;
  double lifeTime;
  
  Bullet({
    required this.position,
    required Vector2D direction,
  }) : velocity = direction.normalized() * GameConstants.bulletSpeed,
       radius = GameConstants.bulletRadius,
       isActive = true,
       trail = [],
       lifeTime = 0.0;

  void update(double deltaTime) {
    if (!isActive) return;

    lifeTime += deltaTime;
    
    // Add current position to trail
    trail.add(Vector2D.copy(position));
    if (trail.length > GameConstants.maxTrailPoints) {
      trail.removeAt(0);
    }

    // Update position
    position = position + (velocity * deltaTime);

    // Check if bullet is off screen
    if (position.x < -50 || 
        position.x > GameConstants.screenWidth + 50 ||
        position.y < -50 || 
        position.y > GameConstants.screenHeight + 50) {
      isActive = false;
    }
  }

  void render(Canvas canvas, Size size) {
    if (!isActive) return;

    // Draw trail
    if (trail.length > 1) {
      final trailPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < trail.length - 1; i++) {
        final alpha = (i / trail.length) * 0.5;
        final width = (i / trail.length) * 3.0 + 1.0;
        
        trailPaint
          ..color = GameConstants.bulletColor.withOpacity(alpha)
          ..strokeWidth = width;

        canvas.drawLine(
          Offset(trail[i].x, trail[i].y),
          Offset(trail[i + 1].x, trail[i + 1].y),
          trailPaint,
        );
      }
    }

    // Draw bullet core
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = GameConstants.bulletGradient.createShader(
        Rect.fromCircle(center: Offset(position.x, position.y), radius: radius),
      );

    canvas.drawCircle(Offset(position.x, position.y), radius, paint);

    // Draw outer glow
    final glowPaint = Paint()
      ..color = GameConstants.bulletColor.withOpacity(0.6)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 3.0);
    
    canvas.drawCircle(Offset(position.x, position.y), radius + 2, glowPaint);

    // Draw pulsing energy effect
    final pulsePaint = Paint()
      ..color = Colors.white.withOpacity((0.8 * math.sin(lifeTime * 10)).abs().clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(position.x, position.y), radius * 0.5, pulsePaint);
  }

  bool checkCollision(Vector2D point, double otherRadius) {
    return isActive && position.distanceTo(point) < (radius + otherRadius);
  }

  void destroy() {
    isActive = false;
  }
}