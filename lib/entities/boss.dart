import 'package:flutter/material.dart';
import '../utils/vector2d.dart';
import '../utils/game_constants.dart';
import '../effects/neon_effects.dart';
import 'dart:math' as math;
import 'missile.dart';

class Boss extends Missile {
  @override
  int health;
  double animationTime;
  double pulseRate;
  double shieldRadius;
  List<NeonParticle> shieldParticles = [];
  
  Boss({
    required super.position,
    required super.targetPosition,
  }) : health = 10,
       animationTime = 0,
       pulseRate = 2.0,
       shieldRadius = 40.0,
       super(
         speed: GameConstants.missileSpeed * 0.5,
         type: MissileType.boss,
       ) {
    radius = 35.0; // Larger size for boss
    isActive = true;
    
    // Initialize shield particles
    _initShieldParticles();
  }
  
  @override
  void update(double deltaTime) {
    animationTime += deltaTime;
    
    // Boss movement - hover at top part of screen
    final targetY = GameConstants.screenHeight * 0.2;
    final distanceToTarget = (targetY - position.y).abs();
    
    if (distanceToTarget > 5) {
      // Move to target y position
      position.y += math.min(distanceToTarget, speed * deltaTime) * 
                    (position.y < targetY ? 1 : -1);
    }
    
    // Oscillate horizontally
    position.x += math.sin(animationTime) * 1.5;
    
    // Keep within screen bounds
    position.x = position.x.clamp(
      radius, 
      GameConstants.screenWidth - radius
    );
    
    // Update shield particles
    _updateShieldParticles(deltaTime);
    
    // Update particle system
    particleSystem.update(deltaTime);
    
    // Spawn attack particles
    if (math.Random().nextDouble() < 0.1) {
      _spawnAttackParticle();
    }
  }
  
  void _initShieldParticles() {
    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * math.pi;
      final particlePos = Vector2D(
        position.x + math.cos(angle) * shieldRadius,
        position.y + math.sin(angle) * shieldRadius,
      );
      
      shieldParticles.add(NeonParticle(
        position: particlePos,
        velocity: Vector2D(0, 0),
        maxLife: double.infinity,
        color: GameConstants.missileColor,
        size: 3.0,
      ));
    }
  }
  
  void _updateShieldParticles(double deltaTime) {
    for (int i = 0; i < shieldParticles.length; i++) {
      final angle = (i / shieldParticles.length) * 2 * math.pi + animationTime;
      
      shieldParticles[i].position = Vector2D(
        position.x + math.cos(angle) * (shieldRadius + math.sin(animationTime * pulseRate) * 5),
        position.y + math.sin(angle) * (shieldRadius + math.sin(animationTime * pulseRate) * 5),
      );
    }
  }
  
  void _spawnAttackParticle() {
    final random = math.Random();
    final angle = random.nextDouble() * 2 * math.pi;
    
    // Create particle at random position on boss
    final particlePos = Vector2D(
      position.x + math.cos(angle) * radius * 0.8,
      position.y + math.sin(angle) * radius * 0.8,
    );
    
    // Direct particle downward
    final particleVelocity = Vector2D(
      (random.nextDouble() - 0.5) * 50, // Spread horizontally
      random.nextDouble() * 150 + 100,  // Downward with random speed
    );
    
    particleSystem.addParticle(NeonParticle(
      position: particlePos,
      velocity: particleVelocity,
      maxLife: 1.5 + random.nextDouble(),
      color: GameConstants.missileColor,
      size: 3.0 + random.nextDouble() * 2,
    ));
  }
  
  @override
  void render(Canvas canvas, Size size) {
    // Render particle system first
    particleSystem.render(canvas, size);
    
    // Draw shield particles
    _renderShield(canvas);
    
    // Draw boss body with glow effects
    _renderBossBody(canvas);
    
    // Draw energy core
    _renderEnergyCore(canvas);
  }
  
  void _renderShield(Canvas canvas) {
    final shieldPaint = Paint()
      ..color = GameConstants.missileColor.withValues(
        alpha: 0.15 + 0.05 * math.sin(animationTime * pulseRate)
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    
    final shieldCenter = Offset(position.x, position.y);
    canvas.drawCircle(
      shieldCenter, 
      shieldRadius + math.sin(animationTime * pulseRate) * 5,
      shieldPaint
    );
    
    // Draw shield particles
    for (final particle in shieldParticles) {
      final particlePaint = Paint()
        ..color = GameConstants.missileColor.withValues(
          alpha: 0.7 + 0.3 * math.sin(animationTime * 5)
        )
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
      
      canvas.drawCircle(
        Offset(particle.position.x, particle.position.y),
        2.0 + math.sin(animationTime * 3) * 0.5,
        particlePaint
      );
    }
  }
  
  void _renderBossBody(Canvas canvas) {
    final center = Offset(position.x, position.y);
    
    // Multiple glow layers
    final glowLayers = [
      (radius * 1.5, 0.1),
      (radius * 1.2, 0.2),
      (radius * 1.1, 0.3),
    ];

    for (final layer in glowLayers) {
      final paint = Paint()
        ..color = GameConstants.missileColor.withValues(alpha: layer.$2)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, layer.$1 * 0.1);

      canvas.drawCircle(center, layer.$1, paint);
    }
    
    // Main body with gradient
    final gradient = RadialGradient(
      colors: [
        Colors.white,
        GameConstants.missileColor,
        GameConstants.missileColor.withValues(alpha: 0.7),
      ],
      stops: const [0.0, 0.3, 1.0],
    );
    
    final bodyPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius)
      );
    
    canvas.drawCircle(center, radius, bodyPaint);
    
    // Draw geometric patterns
    _renderGeometricPatterns(canvas);
  }
  
  void _renderGeometricPatterns(Canvas canvas) {
    final center = Offset(position.x, position.y);
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(animationTime * 0.5);
    
    final patternPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    // Draw hexagonal pattern
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
    
    canvas.drawPath(path, patternPaint);
    
    // Draw inner patterns
    final innerPath = Path();
    for (int i = 0; i < 3; i++) {
      final angle = (i / 3) * 2 * math.pi;
      final x = math.cos(angle) * radius * 0.4;
      final y = math.sin(angle) * radius * 0.4;
      
      if (i == 0) {
        innerPath.moveTo(x, y);
      } else {
        innerPath.lineTo(x, y);
      }
    }
    innerPath.close();
    
    canvas.drawPath(innerPath, patternPaint);
    canvas.restore();
  }
  
  void _renderEnergyCore(Canvas canvas) {
    final center = Offset(position.x, position.y);
    
    // Pulsing core
    final coreRadius = radius * 0.3 * (1 + 0.2 * math.sin(animationTime * 5));
    
    final corePaint = Paint()
      ..color = Colors.white.withValues(
        alpha: 0.8 + 0.2 * math.sin(animationTime * 3)
      );
    
    canvas.drawCircle(center, coreRadius, corePaint);
    
    // Core glow
    final glowPaint = Paint()
      ..color = GameConstants.missileColor.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    canvas.drawCircle(center, coreRadius * 1.5, glowPaint);
  }
  
  @override
  void takeDamage() {
    health--;
    
    // Add hit effect
    _addHitEffect();
    
    if (health <= 0) {
      isActive = false;
    }
  }
  
  void _addHitEffect() {
    final random = math.Random();
    
    // Add explosion particles
    for (int i = 0; i < 5; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final speed = random.nextDouble() * 100 + 50;
      final distance = random.nextDouble() * radius;
      
      final particlePos = Vector2D(
        position.x + math.cos(angle) * distance,
        position.y + math.sin(angle) * distance,
      );
      
      final particleVel = Vector2D(
        math.cos(angle) * speed,
        math.sin(angle) * speed,
      );
      
      particleSystem.addParticle(NeonParticle(
        position: particlePos,
        velocity: particleVel,
        maxLife: 0.3 + random.nextDouble() * 0.5,
        color: Colors.white,
        size: 2.0 + random.nextDouble() * 3.0,
      ));
    }
  }
}