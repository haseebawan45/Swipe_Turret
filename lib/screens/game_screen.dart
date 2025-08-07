import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../entities/turret.dart';
import '../entities/bullet.dart';
import '../entities/missile.dart';
import '../entities/explosion.dart';
import '../utils/vector2d.dart';
import '../utils/game_constants.dart';
import '../utils/game_state.dart';
import 'main_menu_screen.dart';
import 'dart:math' as math;

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  late AnimationController _gameLoopController;
  late Turret turret;
  Bullet? currentBullet;
  List<Missile> missiles = [];
  List<Explosion> explosions = [];
  
  double lastMissileSpawn = 0.0;
  double countdownTimer = 3.0;
  bool isGameActive = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize game loop
    _gameLoopController = AnimationController(
      duration: const Duration(days: 1), // Infinite duration
      vsync: this,
    );
    
    _gameLoopController.addListener(_gameLoop);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Initialize game after dependencies are available
    _initializeGame();
    
    // Start countdown
    GameState().resetGame();
    _gameLoopController.forward();
  }

  void _initializeGame() {
    final screenSize = MediaQuery.of(context).size;
    GameConstants.updateScreenSize(screenSize);
    
    turret = Turret(
      position: Vector2D(screenSize.width / 2, screenSize.height / 2),
    );
    
    missiles.clear();
    explosions.clear();
    currentBullet = null;
    lastMissileSpawn = 0.0;
    countdownTimer = 3.0;
    isGameActive = false;
  }

  @override
  void dispose() {
    _gameLoopController.dispose();
    super.dispose();
  }

  void _gameLoop() {
    if (!mounted) return;
    
    const deltaTime = 1.0 / 60.0; // 60 FPS target
    
    setState(() {
      if (GameState().status == GameStatus.countdown) {
        _updateCountdown(deltaTime);
      } else if (GameState().status == GameStatus.playing) {
        _updateGame(deltaTime);
      }
    });
  }

  void _updateCountdown(double deltaTime) {
    countdownTimer -= deltaTime;
    
    if (countdownTimer <= 0) {
      GameState().status = GameStatus.playing;
      isGameActive = true;
    }
  }

  void _updateGame(double deltaTime) {
    // Update game time and difficulty
    GameState().gameTime += deltaTime;
    GameState().updateDifficulty();
    
    // Update turret
    turret.update(deltaTime);
    
    // Update bullet
    currentBullet?.update(deltaTime);
    if (currentBullet?.isActive == false) {
      currentBullet = null;
    }
    
    // Spawn missiles
    lastMissileSpawn += deltaTime;
    if (lastMissileSpawn >= GameState().currentSpawnRate) {
      _spawnMissile();
      lastMissileSpawn = 0.0;
    }
    
    // Update missiles
    for (final missile in missiles) {
      missile.targetPosition = turret.position;
      missile.update(deltaTime);
    }
    
    // Remove inactive missiles
    missiles.removeWhere((missile) => !missile.isActive);
    
    // Update explosions
    for (final explosion in explosions) {
      explosion.update(deltaTime);
    }
    explosions.removeWhere((explosion) => !explosion.isActive);
    
    // Check collisions
    _checkCollisions();
  }

  void _spawnMissile() {
    final random = math.Random();
    final screenSize = MediaQuery.of(context).size;
    
    // Choose random edge
    Vector2D spawnPosition;
    final edge = random.nextInt(4);
    
    switch (edge) {
      case 0: // Top
        spawnPosition = Vector2D(
          random.nextDouble() * screenSize.width,
          -50,
        );
        break;
      case 1: // Right
        spawnPosition = Vector2D(
          screenSize.width + 50,
          random.nextDouble() * screenSize.height,
        );
        break;
      case 2: // Bottom
        spawnPosition = Vector2D(
          random.nextDouble() * screenSize.width,
          screenSize.height + 50,
        );
        break;
      case 3: // Left
        spawnPosition = Vector2D(
          -50,
          random.nextDouble() * screenSize.height,
        );
        break;
      default:
        spawnPosition = Vector2D(0, 0);
    }
    
    missiles.add(Missile(
      position: spawnPosition,
      targetPosition: turret.position,
      speed: GameState().currentMissileSpeed,
    ));
  }

  void _checkCollisions() {
    // Bullet vs Missiles
    if (currentBullet != null) {
      for (final missile in missiles) {
        if (currentBullet!.checkCollision(missile.position, missile.radius)) {
          // Create explosion
          explosions.add(Explosion(position: Vector2D.copy(missile.position)));
          
          // Destroy bullet and missile
          currentBullet!.destroy();
          missile.destroy();
          
          // Add score
          GameState().addScore(100);
          
          // Play sound effect (if implemented)
          _playExplosionSound();
          
          break;
        }
      }
    }
    
    // Missiles vs Turret
    for (final missile in missiles) {
      if (missile.checkCollision(turret.position, turret.radius)) {
        // Game over
        explosions.add(Explosion(position: Vector2D.copy(turret.position)));
        GameState().gameOver();
        _playGameOverSound();
        break;
      }
    }
  }

  void _handleSwipe(DragEndDetails details) {
    if (!isGameActive || !turret.canShoot || GameState().status != GameStatus.playing) {
      return;
    }
    
    final velocity = details.velocity.pixelsPerSecond;
    if (velocity.distance < 100) return; // Minimum swipe speed
    
    // Calculate direction from swipe
    final direction = Vector2D(velocity.dx, velocity.dy).normalized();
    
    // Create bullet
    currentBullet = Bullet(
      position: Vector2D.copy(turret.position),
      direction: direction,
    );
    
    // Start turret cooldown
    turret.startCooldown();
    
    // Play shoot sound
    _playShootSound();
    
    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  void _playShootSound() {
    // TODO: Implement sound effect
  }

  void _playExplosionSound() {
    // TODO: Implement sound effect
  }

  void _playGameOverSound() {
    // TODO: Implement sound effect
  }

  void _pauseGame() {
    if (GameState().status == GameStatus.playing) {
      GameState().status = GameStatus.paused;
    } else if (GameState().status == GameStatus.paused) {
      GameState().status = GameStatus.playing;
    }
  }

  void _exitGame() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainMenuScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              GameConstants.backgroundColor,
              Color(0xFF0F0F1A),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Game canvas
            GestureDetector(
              onPanEnd: _handleSwipe,
              child: CustomPaint(
                painter: GamePainter(
                  turret: turret,
                  bullet: currentBullet,
                  missiles: missiles,
                  explosions: explosions,
                  gameState: GameState(),
                  countdownTimer: countdownTimer,
                ),
                size: Size.infinite,
              ),
            ),
            
            // UI Overlay
            _buildUIOverlay(),
            
            // Game Over Screen
            if (GameState().status == GameStatus.gameOver)
              _buildGameOverScreen(),
              
            // Pause Screen
            if (GameState().status == GameStatus.paused)
              _buildPauseScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildUIOverlay() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Top UI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Score
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: GameConstants.uiColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'SCORE: ${GameState().formattedScore}',
                    style: const TextStyle(
                      color: GameConstants.uiColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                // Pause button
                if (isGameActive)
                  GestureDetector(
                    onTap: _pauseGame,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: GameConstants.uiColor.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.pause,
                        color: GameConstants.uiColor,
                        size: 24,
                      ),
                    ),
                  ),
              ],
            ),
            
            const Spacer(),
            
            // Bottom UI - Time and missiles destroyed
            if (isGameActive)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatContainer('TIME', GameState().formattedTime),
                  _buildStatContainer('DESTROYED', '${GameState().missilesDestroyed}'),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatContainer(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: GameConstants.uiColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: GameConstants.uiColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverScreen() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(40),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: GameConstants.backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: GameConstants.uiColor,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: GameConstants.uiColor.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GAME OVER',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 30),
              
              Text(
                'FINAL SCORE',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              
              Text(
                GameState().formattedScore,
                style: const TextStyle(
                  color: GameConstants.uiColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 20),
              
              Text(
                'BEST SCORE',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              
              Text(
                GameState().formattedBestScore,
                style: const TextStyle(
                  color: GameConstants.turretColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 40),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildGameOverButton('RESTART', () {
                    _initializeGame();
                    GameState().resetGame();
                  }),
                  
                  _buildGameOverButton('EXIT', _exitGame),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPauseScreen() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(40),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: GameConstants.backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: GameConstants.uiColor,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'PAUSED',
                style: TextStyle(
                  color: GameConstants.uiColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 40),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildGameOverButton('RESUME', _pauseGame),
                  _buildGameOverButton('EXIT', _exitGame),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverButton(String text, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: GameConstants.uiColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: GameConstants.uiColor,
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: GameConstants.uiColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class GamePainter extends CustomPainter {
  final Turret turret;
  final Bullet? bullet;
  final List<Missile> missiles;
  final List<Explosion> explosions;
  final GameState gameState;
  final double countdownTimer;

  GamePainter({
    required this.turret,
    required this.bullet,
    required this.missiles,
    required this.explosions,
    required this.gameState,
    required this.countdownTimer,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw animated background grid
    _drawBackground(canvas, size);
    
    // Draw game entities only if game is active
    if (gameState.status == GameStatus.playing || gameState.status == GameStatus.paused) {
      // Draw explosions first (behind everything)
      for (final explosion in explosions) {
        explosion.render(canvas, size);
      }
      
      // Draw missiles
      for (final missile in missiles) {
        missile.render(canvas, size);
      }
      
      // Draw bullet
      bullet?.render(canvas, size);
      
      // Draw turret
      turret.render(canvas, size);
    } else if (gameState.status == GameStatus.countdown) {
      // Draw turret during countdown
      turret.render(canvas, size);
      
      // Draw countdown
      _drawCountdown(canvas, size);
    }
  }

  void _drawBackground(Canvas canvas, Size size) {
    // Draw subtle grid pattern
    final gridPaint = Paint()
      ..color = GameConstants.gridColor.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const gridSize = 40.0;
    
    // Vertical lines
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
    
    // Horizontal lines
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Draw center crosshair
    final crosshairPaint = Paint()
      ..color = GameConstants.turretColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);
    const crosshairSize = 30.0;

    canvas.drawLine(
      Offset(center.dx - crosshairSize, center.dy),
      Offset(center.dx + crosshairSize, center.dy),
      crosshairPaint,
    );
    
    canvas.drawLine(
      Offset(center.dx, center.dy - crosshairSize),
      Offset(center.dx, center.dy + crosshairSize),
      crosshairPaint,
    );

    // Draw concentric circles around center
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(
        center,
        i * 60.0,
        Paint()
          ..color = GameConstants.turretColor.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }
  }

  void _drawCountdown(Canvas canvas, Size size) {
    final countdownNumber = countdownTimer.ceil();
    if (countdownNumber <= 0) return;

    final textPainter = TextPainter(
      text: TextSpan(
        text: countdownNumber.toString(),
        style: TextStyle(
          color: GameConstants.uiColor,
          fontSize: 120,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 20.0,
              color: GameConstants.uiColor.withOpacity(0.8),
              offset: const Offset(0, 0),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    
    final center = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );

    // Draw pulsing effect
    final scale = 1.0 + (1.0 - (countdownTimer % 1.0)) * 0.2;
    
    canvas.save();
    canvas.translate(center.dx + textPainter.width / 2, center.dy + textPainter.height / 2);
    canvas.scale(scale);
    canvas.translate(-textPainter.width / 2, -textPainter.height / 2);
    
    textPainter.paint(canvas, Offset.zero);
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) {
    return true; // Always repaint for smooth animation
  }
}