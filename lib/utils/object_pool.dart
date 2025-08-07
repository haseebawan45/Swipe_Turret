import 'dart:collection';

/// A generic object pool to reuse objects and reduce memory allocations
class ObjectPool<T> {
  final Queue<T> _pool = Queue<T>();
  final T Function() _factory;
  final void Function(T) _reset;
  
  /// Creates a new object pool
  /// 
  /// [factory] is a function that creates a new object
  /// [reset] is a function that resets an object before it's reused
  ObjectPool({
    required T Function() factory,
    required void Function(T) reset,
  }) : _factory = factory,
       _reset = reset;
  
  /// Get an object from the pool or create a new one if the pool is empty
  T get() {
    if (_pool.isEmpty) {
      return _factory();
    }
    return _pool.removeFirst();
  }
  
  /// Return an object to the pool
  void release(T object) {
    _reset(object);
    _pool.add(object);
  }
  
  /// Clear the pool
  void clear() {
    _pool.clear();
  }
  
  /// The current size of the pool
  int get size => _pool.length;
}