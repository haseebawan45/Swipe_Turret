import 'package:flutter/material.dart';
import '../utils/vector2d.dart';
import '../utils/game_constants.dart';
import 'dart:math' as math;

class Turret {
  Vector2D position;
  double radius;
  double cooldownTimer;
  bool canShoot;
  double chargeLevel; // 0.0 to 1.0 for visual feedback
  
  Turret({required this.position}) 
      : radius = GameConstants.turretRadius,
        cooldownTimer = 0.0,
        canShoot = true,
        chargeLevel = 1.0;

  void update(double deltaTime) {
    if (!canShoot) {
      cooldownTimer -= deltaTime;
      chargeLevel = math.max(0.0, 1.0 - (cooldownTimer / GameConstants.bulletCooldown));
      
      if (cooldownTimer <= 0) {
        canShoot = true;
        chargeLevel = 1.0;
        cooldownTimer = 0.0;
      }
    }
  }

  void startCooldown() {
    canShoot = false;
    cooldownTimer = GameConstants.bulletCooldown;
    chargeLevel = 0.0;
  }

  void render(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = GameConstants.turretGradient.createShader(
        Rect.fromCircle(center: Offset(position.x, position.y), radius: radius),
      );

    // Draw main turret body
    canvas.drawCircle(Offset(position.x, position.y), radius, paint);

    // Draw outer glow
    final glowPaint = Paint()
      ..color = GameConstants.turretColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 5.0);
    
    canvas.drawCircle(Offset(position.x, position.y), radius + 5, glowPaint);

    // Draw charge indicator ring
    if (!canShoot) {
      final chargePaint = Paint()
        ..color = GameConstants.turretColor.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;

      final rect = Rect.fromCircle(
        center: Offset(position.x, position.y), 
        radius: radius + 15,
      );

      canvas.drawArc(
        rect,
        -math.pi / 2, // Start from top
        2 * math.pi * chargeLevel, // Progress based on charge level
        false,
        chargePaint,
      );
    }

    // Draw center core
    final corePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(position.x, position.y), radius * 0.3, corePaint);
  }

  bool checkCollision(Vector2D point, double otherRadius) {
    return position.distanceTo(point) < (radius + otherRadius);
  }
}