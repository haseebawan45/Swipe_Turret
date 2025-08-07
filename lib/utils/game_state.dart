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
  int currentLevel = 1;
  int enemiesRemainingInLevel = 0;
  bool isBossFight = false;
  double currentMissileSpeed = 80.0;
  double currentSpawnRate = 2.0;
  bool soundEnabled = true;

  // Game difficulty scaling
  void updateDifficulty() {
    // Base difficulty on current level instead of time
    final difficultyMultiplier = currentLevel - 1;
    currentMissileSpeed = 80.0 + (difficultyMultiplier * 8.0);
    currentSpawnRate = 2.0 - (difficultyMultiplier * 0.15);
    
    // Clamp values to reasonable limits
    currentMissileSpeed = currentMissileSpeed.clamp(80.0, 300.0);
    currentSpawnRate = currentSpawnRate.clamp(0.3, 2.0);
  }

  void resetGame() {
    score = 0;
    gameTime = 0.0;
    missilesDestroyed = 0;
    currentLevel = 1;
    enemiesRemainingInLevel = _getEnemiesForLevel(1);
    isBossFight = false;
    currentMissileSpeed = 80.0;
    currentSpawnRate = 2.0;
    status = GameStatus.countdown;
  }
  
  int _getEnemiesForLevel(int level) {
    // Each level has more enemies to destroy
    return 10 + (level - 1) * 5;
  }
  
  bool checkLevelProgress() {
    // Decrease remaining enemies counter
    enemiesRemainingInLevel--;
    
    // Check if level is complete
    if (enemiesRemainingInLevel <= 0) {
      if (isBossFight) {
        // Level completed after boss is defeated
        currentLevel++;
        isBossFight = false;
        enemiesRemainingInLevel = _getEnemiesForLevel(currentLevel);
      } else {
        // Start boss fight
        isBossFight = true;
        enemiesRemainingInLevel = 1; // One boss to defeat
      }
      return true; // Level progress changed
    }
    return false; // No level progress change
  }

  void addScore(int points) {
    score += points;
    missilesDestroyed++;
    
    // Check level progress
    checkLevelProgress();
    
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
  String get formattedLevel => 'LVL $currentLevel';
  String get formattedEnemiesRemaining => isBossFight ? 'BOSS' : '${enemiesRemainingInLevel}';
}