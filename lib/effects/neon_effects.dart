import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/vector2d.dart';
import '../utils/particle_pool.dart';

/// Advanced neon glow effect painter
class NeonGlowPainter extends CustomPainter {
  final Vector2D position;
  final double radius;
  final Color color;
  final double intensity;
  final double time;
  final bool pulsing;

  NeonGlowPainter({
    required this.position,
    required this.radius,
    required this.color,
    this.intensity = 1.0,
    this.time = 0.0,
    this.pulsing = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(position.x, position.y);
    
    // Calculate dynamic intensity
    final dynamicIntensity = pulsing 
        ? intensity * (0.7 + 0.3 * math.sin(time * 8))
        : intensity;

    // Create multiple glow layers for depth
    final glowLayers = [
      (radius * 3.0, 0.1 * dynamicIntensity),
      (radius * 2.0, 0.2 * dynamicIntensity),
      (radius * 1.5, 0.4 * dynamicIntensity),
      (radius * 1.2, 0.6 * dynamicIntensity),
      (radius, 0.8 * dynamicIntensity),
    ];

    for (final layer in glowLayers) {
      final paint = Paint()
        ..color = color.withValues(alpha: layer.$2)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, layer.$1 * 0.3);

      canvas.drawCircle(center, layer.$1, paint);
    }

    // Core bright center
    final corePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9 * dynamicIntensity)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius * 0.3, corePaint);
  }

  @override
  bool shouldRepaint(NeonGlowPainter oldDelegate) {
    return oldDelegate.time != time || 
           oldDelegate.intensity != intensity ||
           oldDelegate.position != position;
  }
}

/// Advanced particle system for trails and explosions
class NeonParticle {
  Vector2D position;
  Vector2D velocity;
  double life;
  double maxLife;
  Color color;
  double size;
  double rotation;
  double rotationSpeed;
  bool isActive;
  
  NeonParticle({
    required this.position,
    required this.velocity,
    required this.maxLife,
    required this.color,
    required this.size,
    this.rotation = 0.0,
    this.rotationSpeed = 0.0,
    this.isActive = true,
  }) : life = maxLife;

  void update(double deltaTime) {
    life -= deltaTime;
    position = position + (velocity * deltaTime);
    rotation += rotationSpeed * deltaTime;
    
    // Apply physics
    velocity = velocity * 0.98; // Drag
    
    // Update active state
    if (life <= 0) {
      isActive = false;
    }
  }

  bool get isAlive => life > 0;
  double get alpha => (life / maxLife).clamp(0.0, 1.0);
  double get scale => alpha;
}

class NeonParticleSystem {
  List<NeonParticle> particles = [];
  
  void addParticle(NeonParticle particle) {
    particles.add(particle);
  }
  
  // Helper method to create a particle using the pool
  void addPooledParticle({
    required Vector2D position,
    required Vector2D velocity,
    required double maxLife,
    required Color color,
    required double size,
    double rotation = 0.0,
    double rotationSpeed = 0.0,
  }) {
    final particle = ParticlePool().getParticle(
      position: position,
      velocity: velocity,
      maxLife: maxLife,
      color: color,
      size: size,
    );
    particle.rotation = rotation;
    particle.rotationSpeed = rotationSpeed;
    particles.add(particle);
  }
  
  void addExplosion(Vector2D position, Color color, {int count = 15}) {
    final random = math.Random();
    
    for (int i = 0; i < count; i++) {
      final angle = (i / count) * 2 * math.pi + random.nextDouble() * 0.5;
      final speed = 80 + random.nextDouble() * 120;
      final velocity = Vector2D.fromAngle(angle, speed);
      
      addPooledParticle(
        position: Vector2D.copy(position),
        velocity: velocity,
        maxLife: 0.4 + random.nextDouble() * 0.6,
        color: color,
        size: 2 + random.nextDouble() * 4,
        rotationSpeed: (random.nextDouble() - 0.5) * 10,
      );
    }
  }
  
  void addTrail(Vector2D position, Vector2D velocity, Color color) {
    final random = math.Random();
    
    addPooledParticle(
      position: Vector2D.copy(position),
      velocity: velocity * 0.3 + Vector2D(
        (random.nextDouble() - 0.5) * 20,
        (random.nextDouble() - 0.5) * 20,
      ),
      maxLife: 0.2 + random.nextDouble() * 0.3,
      color: color,
      size: 1 + random.nextDouble() * 2,
    );
  }
  
  void update(double deltaTime) {
    particles.removeWhere((particle) {
      particle.update(deltaTime);
      if (!particle.isAlive) {
        // Return particle to pool
        ParticlePool().releaseParticle(particle);
        return true;
      }
      return false;
    });
  }
  
  void render(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.alpha)
        ..style = PaintingStyle.fill;

      // Glow effect
      final glowPaint = Paint()
        ..color = particle.color.withValues(alpha: particle.alpha * 0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

      final center = Offset(particle.position.x, particle.position.y);
      final scaledSize = particle.size * particle.scale;

      canvas.drawCircle(center, scaledSize + 2, glowPaint);
      canvas.drawCircle(center, scaledSize, paint);
    }
  }
  
  void clear() {
    particles.clear();
  }
}

/// Cyberpunk grid background with animated effects
class CyberpunkGridPainter extends CustomPainter {
  final double time;
  final Size screenSize;
  final double intensity;

  CyberpunkGridPainter({
    required this.time,
    required this.screenSize,
    this.intensity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawAnimatedGrid(canvas, size);
    _drawScanlines(canvas, size);
    _drawCenterRadar(canvas, size);
    _drawFloatingParticles(canvas, size);
  }

  void _drawAnimatedGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF00FFFF).withValues(alpha: 0.15 * intensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const gridSize = 40.0;
    final offset = (time * 20) % gridSize;
    
    // Vertical lines with wave effect
    for (double x = -offset; x <= size.width + gridSize; x += gridSize) {
      final path = Path();
      path.moveTo(x, 0);
      
      for (double y = 0; y <= size.height; y += 10) {
        final wave = math.sin((y + time * 100) * 0.01) * 2;
        path.lineTo(x + wave, y);
      }
      
      canvas.drawPath(path, gridPaint);
    }
    
    // Horizontal lines with pulse effect
    for (double y = -offset; y <= size.height + gridSize; y += gridSize) {
      final alpha = (0.1 + 0.05 * math.sin(time * 3 + y * 0.01)) * intensity;
      final pulsePaint = Paint()
        ..color = const Color(0xFF00FFFF).withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
        
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        pulsePaint,
      );
    }
  }

  void _drawScanlines(Canvas canvas, Size size) {
    final scanlinePaint = Paint()
      ..color = const Color(0xFF00FF00).withValues(alpha: 0.1 * intensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final scanlineY = (time * 200) % (size.height + 100) - 50;
    
    for (int i = 0; i < 3; i++) {
      final y = scanlineY + i * 20;
      final alpha = (0.2 - i * 0.05) * intensity;
      
      scanlinePaint.color = const Color(0xFF00FF00).withValues(alpha: alpha);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), scanlinePaint);
    }
  }

  void _drawCenterRadar(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radarPaint = Paint()
      ..color = const Color(0xFF00FFFF).withValues(alpha: 0.2 * intensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Rotating radar sweep
    final sweepAngle = time * 2;
    
    for (int i = 1; i <= 4; i++) {
      final radius = i * 60.0;
      final alpha = (0.3 - i * 0.05) * intensity;
      
      radarPaint.color = const Color(0xFF00FFFF).withValues(alpha: alpha);
      canvas.drawCircle(center, radius, radarPaint);
    }

    // Radar sweep line
    final sweepPaint = Paint()
      ..color = const Color(0xFF00FFFF).withValues(alpha: 0.6 * intensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final sweepEnd = Offset(
      center.dx + math.cos(sweepAngle) * 240,
      center.dy + math.sin(sweepAngle) * 240,
    );

    canvas.drawLine(center, sweepEnd, sweepPaint);
  }

  void _drawFloatingParticles(Canvas canvas, Size size) {
    final particlePaint = Paint()
      ..color = const Color(0xFF00FFFF).withValues(alpha: 0.4 * intensity)
      ..style = PaintingStyle.fill;

    final random = math.Random(42); // Fixed seed for consistent particles
    
    for (int i = 0; i < 20; i++) {
      final x = (random.nextDouble() * size.width + time * 10 * (i % 3 + 1)) % size.width;
      final y = (random.nextDouble() * size.height + time * 5 * (i % 2 + 1)) % size.height;
      final particleSize = 1 + random.nextDouble() * 2;
      final alpha = (0.2 + 0.3 * math.sin(time * 4 + i)) * intensity;
      
      particlePaint.color = const Color(0xFF00FFFF).withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), particleSize, particlePaint);
    }
  }

  @override
  bool shouldRepaint(CyberpunkGridPainter oldDelegate) {
    return oldDelegate.time != time || oldDelegate.intensity != intensity;
  }
}