import 'dart:math' as math;

class Vector2D {
  double x;
  double y;

  Vector2D(this.x, this.y);

  Vector2D.zero() : x = 0, y = 0;

  Vector2D.fromAngle(double angle, double magnitude) 
      : x = math.cos(angle) * magnitude,
        y = math.sin(angle) * magnitude;

  // Copy constructor
  Vector2D.copy(Vector2D other) : x = other.x, y = other.y;

  // Basic operations
  Vector2D operator +(Vector2D other) => Vector2D(x + other.x, y + other.y);
  Vector2D operator -(Vector2D other) => Vector2D(x - other.x, y - other.y);
  Vector2D operator *(double scalar) => Vector2D(x * scalar, y * scalar);
  Vector2D operator /(double scalar) => Vector2D(x / scalar, y / scalar);

  // Magnitude and normalization
  double get magnitude => math.sqrt(x * x + y * y);
  double get magnitudeSquared => x * x + y * y;

  Vector2D normalized() {
    final mag = magnitude;
    if (mag == 0) return Vector2D.zero();
    return Vector2D(x / mag, y / mag);
  }

  void normalize() {
    final mag = magnitude;
    if (mag != 0) {
      x /= mag;
      y /= mag;
    }
  }

  // Distance between two points
  double distanceTo(Vector2D other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  double distanceSquaredTo(Vector2D other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return dx * dx + dy * dy;
  }

  // Angle from this vector to another
  double angleTo(Vector2D other) {
    return math.atan2(other.y - y, other.x - x);
  }

  // Dot product
  double dot(Vector2D other) => x * other.x + y * other.y;

  // Lerp between two vectors
  Vector2D lerp(Vector2D other, double t) {
    return Vector2D(
      x + (other.x - x) * t,
      y + (other.y - y) * t,
    );
  }

  @override
  String toString() => 'Vector2D($x, $y)';
}