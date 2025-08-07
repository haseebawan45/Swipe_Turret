import 'package:flutter/material.dart';
import '../effects/neon_effects.dart';
import '../utils/vector2d.dart';
import 'object_pool.dart';

/// A pool of particle objects for optimized performance
class ParticlePool {
  static final ParticlePool _instance = ParticlePool._internal();
  
  /// Factory constructor to return the singleton instance
  factory ParticlePool() => _instance;
  
  /// Private constructor for the singleton pattern
  ParticlePool._internal() : 
    _pool = ObjectPool<NeonParticle>(
      factory: () => NeonParticle(
        position: Vector2D(0, 0),
        velocity: Vector2D(0, 0),
        maxLife: 1.0,
        color: Colors.white,
        size: 1.0,
      ),
      reset: (particle) {
        particle.life = 0;
        particle.isActive = true;
      },
    );
  
  final ObjectPool<NeonParticle> _pool;
  
  /// Get a particle from the pool
  NeonParticle getParticle({
    required Vector2D position,
    required Vector2D velocity,
    required double maxLife,
    required Color color,
    required double size,
  }) {
    final particle = _pool.get();
    particle.position = Vector2D.copy(position);
    particle.velocity = Vector2D.copy(velocity);
    particle.maxLife = maxLife;
    particle.color = color;
    particle.size = size;
    return particle;
  }
  
  /// Return a particle to the pool
  void releaseParticle(NeonParticle particle) {
    _pool.release(particle);
  }
  
  /// Clear the pool
  void clear() {
    _pool.clear();
  }
}