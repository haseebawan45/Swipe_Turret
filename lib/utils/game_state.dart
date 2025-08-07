import 'package:shared_preferences/shared_preferences.dart';

enum GameStatus {
  menu,
  countdown,
  playing,
  paused,
  gameOver,
}

class GameState {
  static final GameState _instance = GameState._internal();
  factory GameState() => _instance;
  GameState._internal();

  GameStatus status = GameStatus.menu;
  int score = 0;
  int bestScore = 0;
  double gameTime = 0.0;
  int missilesDestroyed = 0;
  double currentMissileSpeed = 80.0;
  double currentSpawnRate = 2.0;
  bool soundEnabled = true;

  // Game difficulty scaling
  void updateDifficulty() {
    final difficultyMultiplier = (gameTime / 10.0).floor();
    currentMissileSpeed = 80.0 + (difficultyMultiplier * 5.0);
    currentSpawnRate = 2.0 - (difficultyMultiplier * 0.1);
    
    // Clamp values to reasonable limits
    currentMissileSpeed = currentMissileSpeed.clamp(80.0, 200.0);
    currentSpawnRate = currentSpawnRate.clamp(0.5, 2.0);
  }

  void resetGame() {
    score = 0;
    gameTime = 0.0;
    missilesDestroyed = 0;
    currentMissileSpeed = 80.0;
    currentSpawnRate = 2.0;
    status = GameStatus.countdown;
  }

  void addScore(int points) {
    score += points;
    missilesDestroyed++;
    
    if (score > bestScore) {
      bestScore = score;
      _saveBestScore();
    }
  }

  void gameOver() {
    status = GameStatus.gameOver;
    if (score > bestScore) {
      bestScore = score;
      _saveBestScore();
    }
  }

  Future<void> loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    bestScore = prefs.getInt('best_score') ?? 0;
    soundEnabled = prefs.getBool('sound_enabled') ?? true;
  }

  Future<void> _saveBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('best_score', bestScore);
  }

  Future<void> toggleSound() async {
    soundEnabled = !soundEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', soundEnabled);
  }

  String get formattedScore => score.toString().padLeft(6, '0');
  String get formattedBestScore => bestScore.toString().padLeft(6, '0');
  String get formattedTime => '${gameTime.toInt()}s';
}