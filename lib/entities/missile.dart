import 'package:flutter/material.dart';
import '../utils/vector2d.dart';
import '../utils/game_constants.dart';
import 'dart:math' as math;

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
  
  Missile({
    required this.position,
    required this.targetPosition,
    required this.speed,
  }) : velocity = Vector2D.zero(),
       radius = GameConstants.missileRadius,
       isActive = true,
       trail = [],
       lifeTime = 0.0,
       rotationAngle = 0.0;

  void update(double deltaTime) {
    if (!isActive) return;

    lifeTime += deltaTime;
    rotationAngle += deltaTime * 5.0; // Spinning effect

    // Add current position to trail
    trail.add(Vector2D.copy(position));
    if (trail.length > GameConstants.maxTrailPoints) {
      trail.removeAt(0);
    }

    // Homing behavior - calculate direction to target
    final directionToTarget = Vector2D(
      targetPosition.x - position.x,
      targetPosition.y - position.y,
    ).normalized();

    // Update velocity with homing behavior
    velocity = directionToTarget * speed;

    // Update position
    position = position + (velocity * deltaTime);

    // Check if missile is way off screen (cleanup)
    if (position.x < -100 || 
        position.x > GameConstants.screenWidth + 100 ||
        position.y < -100 || 
        position.y > GameConstants.screenHeight + 100) {
      isActive = false;
    }
  }

  void render(Canvas canvas, Size size) {
    if (!isActive) return;

    // Draw trail with smoke effect
    if (trail.length > 1) {
      final trailPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < trail.length - 1; i++) {
        final alpha = (i / trail.length) * 0.7;
        final width = (i / trail.length) * 4.0 + 1.0;
        
        trailPaint
          ..color = GameConstants.missileColor.withOpacity(alpha)
          ..strokeWidth = width;

        canvas.drawLine(
          Offset(trail[i].x, trail[i].y),
          Offset(trail[i + 1].x, trail[i + 1].y),
          trailPaint,
        );
      }
    }

    // Save canvas state for rotation
    canvas.save();
    canvas.translate(position.x, position.y);
    canvas.rotate(rotationAngle);

    // Draw missile body (diamond shape)
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = GameConstants.missileGradient.createShader(
        Rect.fromCircle(center: Offset.zero, radius: radius),
      );

    final path = Path();
    path.moveTo(0, -radius);
    path.lineTo(radius * 0.6, 0);
    path.lineTo(0, radius);
    path.lineTo(-radius * 0.6, 0);
    path.close();

    canvas.drawPath(path, paint);

    // Draw outer glow
    final glowPaint = Paint()
      ..color = GameConstants.missileColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4.0);
    
    canvas.drawPath(path, glowPaint);

    // Draw center core with pulsing effect
    final corePaint = Paint()
      ..color = Colors.white.withOpacity((0.9 + 0.1 * math.sin(lifeTime * 8)).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset.zero, radius * 0.3, corePaint);

    // Restore canvas state
    canvas.restore();

    // Draw warning indicator when close to target
    final distanceToTarget = position.distanceTo(targetPosition);
    if (distanceToTarget < 100) {
      final warningPaint = Paint()
        ..color = Colors.red.withOpacity((0.3 + 0.3 * math.sin(lifeTime * 15)).abs().clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      canvas.drawCircle(
        Offset(position.x, position.y), 
        radius + 10 + 5 * math.sin(lifeTime * 10), 
        warningPaint,
      );
    }
  }

  bool checkCollision(Vector2D point, double otherRadius) {
    return isActive && position.distanceTo(point) < (radius + otherRadius);
  }

  void destroy() {
    isActive = false;
  }
}