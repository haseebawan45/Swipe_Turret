import '../entities/bullet.dart';
import '../utils/vector2d.dart';
import 'object_pool.dart';

/// A pool of bullet objects for optimized performance
class BulletPool {
  static final BulletPool _instance = BulletPool._internal();
  
  /// Factory constructor to return the singleton instance
  factory BulletPool() => _instance;
  
  /// Private constructor for the singleton pattern
  BulletPool._internal() : 
    _pool = ObjectPool<Bullet>(
      factory: () => Bullet(
        position: Vector2D(0, 0),
        direction: Vector2D(0, -1),
      ),
      reset: (bullet) {
        bullet.isActive = true;
        bullet.trail.clear();
        bullet.lifeTime = 0;
        bullet.energyLevel = 1.0;
        bullet.particleSystem.clear();
      },
    );
  
  final ObjectPool<Bullet> _pool;
  
  /// Get a bullet from the pool
  Bullet getBullet({
    required Vector2D position,
    required Vector2D direction,
  }) {
    final bullet = _pool.get();
    bullet.position = Vector2D.copy(position);
    bullet.velocity = direction.normalized() * 400.0; // Using bullet speed
    return bullet;
  }
  
  /// Return a bullet to the pool
  void releaseBullet(Bullet bullet) {
    _pool.release(bullet);
  }
  
  /// Clear the pool
  void clear() {
    _pool.clear();
  }
}