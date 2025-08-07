import 'package:flutter/material.dart';
import '../utils/vector2d.dart';
import '../utils/game_constants.dart';
import '../effects/neon_effects.dart';
import 'dart:math' as math;

class Turret {
  Vector2D position;
  double radius;
  double cooldownTimer;
  bool canShoot;
  double chargeLevel; // 0.0 to 1.0 for visual feedback
  double animationTime;
  double rotationAngle;
  NeonParticleSystem particleSystem;
  
  Turret({required this.position}) 
      : radius = GameConstants.turretRadius,
        cooldownTimer = 0.0,
        canShoot = true,
        chargeLevel = 1.0,
        animationTime = 0.0,
        rotationAngle = 0.0,
        particleSystem = NeonParticleSystem();

  void update(double deltaTime) {
    animationTime += deltaTime;
    rotationAngle += deltaTime * 2.0; // Slow rotation
    
    if (!canShoot) {
      cooldownTimer -= deltaTime;
      chargeLevel = math.max(0.0, 1.0 - (cooldownTimer / GameConstants.bulletCooldown));
      
      if (cooldownTimer <= 0) {
        canShoot = true;
        chargeLevel = 1.0;
        cooldownTimer = 0.0;
        
        // Add charge complete effect
        _addChargeCompleteEffect();
      }
    }
    
    // Update particle system
    particleSystem.update(deltaTime);
    
    // Add ambient particles when charged
    if (canShoot && math.Random().nextDouble() < 0.3) {
      _addAmbientParticle();
    }
  }

  void startCooldown() {
    canShoot = false;
    cooldownTimer = GameConstants.bulletCooldown;
    chargeLevel = 0.0;
  }

  void _addChargeCompleteEffect() {
    particleSystem.addExplosion(
      position, 
      GameConstants.turretColor, 
      count: 8
    );
  }

  void _addAmbientParticle() {
    final random = math.Random();
    final angle = random.nextDouble() * 2 * math.pi;
    final distance = radius + 10 + random.nextDouble() * 20;
    final particlePos = Vector2D(
      position.x + math.cos(angle) * distance,
      position.y + math.sin(angle) * distance,
    );
    
    particleSystem.addParticle(NeonParticle(
      position: particlePos,
      velocity: Vector2D.fromAngle(angle + math.pi, 20),
      maxLife: 0.5,
      color: GameConstants.turretColor,
      size: 1.0,
    ));
  }

  void render(Canvas canvas, Size size) {
    // Render particle system first (behind turret)
    particleSystem.render(canvas, size);
    
    // Draw multiple glow layers for depth
    _drawGlowLayers(canvas);
    
    // Draw rotating outer ring
    _drawRotatingRing(canvas);
    
    // Draw main turret body with advanced shader
    _drawTurretBody(canvas);
    
    // Draw charge indicator with neon effect
    if (!canShoot) {
      _drawChargeIndicator(canvas);
    }
    
    // Draw pulsing core
    _drawPulsatingCore(canvas);
    
    // Draw energy field when fully charged
    if (canShoot) {
      _drawEnergyField(canvas);
    }
  }

  void _drawGlowLayers(Canvas canvas) {
    final center = Offset(position.x, position.y);
    final intensity = canShoot ? 1.0 : 0.3 + chargeLevel * 0.7;
    
    // Multiple glow layers for depth
    final glowLayers = [
      (radius * 4.0, 0.05 * intensity),
      (radius * 3.0, 0.1 * intensity),
      (radius * 2.5, 0.15 * intensity),
      (radius * 2.0, 0.2 * intensity),
    ];

    for (final layer in glowLayers) {
      final paint = Paint()
        ..color = GameConstants.turretColor.withValues(alpha: layer.$2)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, layer.$1 * 0.2);

      canvas.drawCircle(center, layer.$1, paint);
    }
  }

  void _drawRotatingRing(Canvas canvas) {
    final center = Offset(position.x, position.y);
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);

    final ringPaint = Paint()
      ..color = GameConstants.turretColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw rotating segments
    for (int i = 0; i < 8; i++) {
      final startAngle = (i / 8) * 2 * math.pi;
      final sweepAngle = math.pi / 6;
      
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: radius + 25),
        startAngle,
        sweepAngle,
        false,
        ringPaint,
      );
    }

    canvas.restore();
  }

  void _drawTurretBody(Canvas canvas) {
    final center = Offset(position.x, position.y);
    
    // Create advanced gradient
    final gradient = RadialGradient(
      colors: [
        GameConstants.turretColor,
        GameConstants.turretColor.withValues(alpha: 0.8),
        GameConstants.turretColor.withValues(alpha: 0.4),
      ],
      stops: const [0.0, 0.7, 1.0],
    );

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, paint);

    // Draw hexagonal details
    _drawHexagonalDetails(canvas);
  }

  void _drawHexagonalDetails(Canvas canvas) {
    final center = Offset(position.x, position.y);
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-rotationAngle * 0.5); // Counter-rotate for effect

    final detailPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw hexagon
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i / 6) * 2 * math.pi;
      final x = math.cos(angle) * radius * 0.7;
      final y = math.sin(angle) * radius * 0.7;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, detailPaint);
    canvas.restore();
  }

  void _drawChargeIndicator(Canvas canvas) {
    final center = Offset(position.x, position.y);
    
    // Animated charge ring
    final chargePaint = Paint()
      ..color = GameConstants.turretColor.withValues(
        alpha: 0.8 + 0.2 * math.sin(animationTime * 10)
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius + 20);

    // Draw charge progress with glow
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * chargeLevel,
      false,
      chargePaint,
    );

    // Add glow effect to charge indicator
    final glowPaint = Paint()
      ..color = GameConstants.turretColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * chargeLevel,
      false,
      glowPaint,
    );
  }

  void _drawPulsatingCore(Canvas canvas) {
    final center = Offset(position.x, position.y);
    final pulseScale = 1.0 + 0.1 * math.sin(animationTime * 6);
    final coreRadius = radius * 0.4 * pulseScale;
    
    // Core with pulsing effect
    final corePaint = Paint()
      ..color = Colors.white.withValues(
        alpha: 0.9 + 0.1 * math.sin(animationTime * 8)
      )
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, coreRadius, corePaint);

    // Inner glow
    final innerGlowPaint = Paint()
      ..color = GameConstants.turretColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    
    canvas.drawCircle(center, coreRadius + 3, innerGlowPaint);
  }

  void _drawEnergyField(Canvas canvas) {
    final center = Offset(position.x, position.y);
    
    // Pulsing energy field when ready to shoot
    final fieldPaint = Paint()
      ..color = GameConstants.turretColor.withValues(
        alpha: 0.1 + 0.05 * math.sin(animationTime * 4)
      )
      ..style = PaintingStyle.fill;

    final fieldRadius = radius + 15 + 5 * math.sin(animationTime * 3);
    canvas.drawCircle(center, fieldRadius, fieldPaint);
  }

  bool checkCollision(Vector2D point, double otherRadius) {
    return position.distanceTo(point) < (radius + otherRadius);
  }
}