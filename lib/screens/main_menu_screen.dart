import 'package:flutter/material.dart';
import '../utils/game_constants.dart';
import '../utils/game_state.dart';
import 'game_screen.dart';
import 'dart:math' as math;

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with TickerProviderStateMixin {
  late AnimationController _titleAnimationController;
  late AnimationController _backgroundAnimationController;
  late Animation<double> _titlePulse;
  late Animation<double> _backgroundRotation;

  @override
  void initState() {
    super.initState();
    
    // Load saved data
    GameState().loadBestScore();
    
    // Initialize animations
    _titleAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _titlePulse = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _titleAnimationController,
      curve: Curves.easeInOut,
    ));

    _backgroundRotation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_backgroundAnimationController);
  }

  @override
  void dispose() {
    _titleAnimationController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    GameConstants.updateScreenSize(MediaQuery.of(context).size);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              GameConstants.backgroundColor,
              Color(0xFF1A1A2E),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background
            AnimatedBuilder(
              animation: _backgroundRotation,
              builder: (context, child) {
                return CustomPaint(
                  painter: BackgroundPainter(_backgroundRotation.value),
                  size: Size.infinite,
                );
              },
            ),
            
            // Main content
            SafeArea(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 
                               MediaQuery.of(context).padding.top - 
                               MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      
                      // Animated title
                      AnimatedBuilder(
                        animation: _titlePulse,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _titlePulse.value,
                            child: ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  GameConstants.turretColor,
                                  GameConstants.uiColor,
                                ],
                              ).createShader(bounds),
                              child: Text(
                                'SWIPE\nTURRET',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width * 0.12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: const [
                                    Shadow(
                                      blurRadius: 20.0,
                                      color: GameConstants.turretColor,
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Best score display
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: GameConstants.uiColor.withValues(alpha: 0.5),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: GameConstants.uiColor.withValues(alpha: 0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          'BEST: ${GameState().formattedBestScore}',
                          style: const TextStyle(
                            color: GameConstants.uiColor,
                            fontSize: GameConstants.fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Menu buttons
                      _buildMenuButton(
                        'START GAME',
                        () => _startGame(),
                        GameConstants.turretColor,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      _buildMenuButton(
                        GameState().soundEnabled ? 'SOUND: ON' : 'SOUND: OFF',
                        () => _toggleSound(),
                        GameConstants.uiColor,
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Instructions
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: GameConstants.gridColor,
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'SWIPE to shoot bullets\nDestroy incoming missiles\nSurvive as long as possible',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(String text, VoidCallback onPressed, Color color) {
    return Container(
      width: GameConstants.buttonWidth,
      height: GameConstants.buttonHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.8),
            color.withValues(alpha: 0.6),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onPressed,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: GameConstants.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _startGame() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const GameScreen()),
    );
  }

  void _toggleSound() {
    setState(() {
      GameState().toggleSound();
    });
  }
}

class BackgroundPainter extends CustomPainter {
  final double rotation;

  BackgroundPainter(this.rotation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GameConstants.gridColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(rotation);

    // Draw rotating grid
    const gridSize = 50.0;
    final maxDistance = math.sqrt(size.width * size.width + size.height * size.height);
    
    for (double i = -maxDistance; i <= maxDistance; i += gridSize) {
      // Vertical lines
      canvas.drawLine(
        Offset(i, -maxDistance),
        Offset(i, maxDistance),
        paint,
      );
      
      // Horizontal lines
      canvas.drawLine(
        Offset(-maxDistance, i),
        Offset(maxDistance, i),
        paint,
      );
    }

    canvas.restore();

    // Draw pulsing circles
    final circlePaint = Paint()
      ..color = GameConstants.turretColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 1; i <= 5; i++) {
      final radius = (i * 80.0) + (math.sin(rotation * 2 + i) * 20);
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        radius,
        circlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) {
    return oldDelegate.rotation != rotation;
  }
}