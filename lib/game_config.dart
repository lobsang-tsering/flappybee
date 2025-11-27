import 'package:flappybee/types.dart';

class GameConfig {
  double gameSpeed;
  final double jumpStrength;
  final double gravity;
  final int pipeSpawnRate;
  final double pipeWidth;
  final double birdSize;
  final double gapSize;
  final double blockSize;
  final int questionDelayFrames;
  final double speedIncreaseRate;

  GameConfig({
    required this.gameSpeed,
    required this.jumpStrength,
    required this.gravity,
    required this.pipeSpawnRate,
    required this.pipeWidth,
    required this.birdSize,
    required this.gapSize,
    required this.blockSize,
    required this.questionDelayFrames,
    required this.speedIncreaseRate,
  });
  GameConfig clone() {
    return GameConfig(
      gameSpeed: gameSpeed,
      jumpStrength: jumpStrength,
      gravity: gravity,
      pipeSpawnRate: pipeSpawnRate,
      pipeWidth: pipeWidth,
      birdSize: birdSize,
      gapSize: gapSize,
      blockSize: blockSize,
      questionDelayFrames: questionDelayFrames,
      speedIncreaseRate: speedIncreaseRate,
    );
  }
}

// Classic Mode Configurations
GameConfig classicEasy = GameConfig(
  gameSpeed: 2.5,
  jumpStrength: -5.5,
  gravity: 0.25,
  pipeSpawnRate: 90,
  pipeWidth: 70.0,
  birdSize: 38.0,
  gapSize: 150.0,
  blockSize: 60.0,
  questionDelayFrames: 0,
  speedIncreaseRate: 0.01,
);
GameConfig classicMedium = GameConfig(
  gameSpeed: 3.0,
  jumpStrength: -5.5,
  gravity: 0.25,
  pipeSpawnRate: 60,
  pipeWidth: 70.0,
  birdSize: 38.0,
  gapSize: 150.0,
  blockSize: 60.0,
  questionDelayFrames: 0,
  speedIncreaseRate: 0.02,
);
GameConfig classicHard = GameConfig(
  gameSpeed: 4.0,
  jumpStrength: -5.5,
  gravity: 0.25,
  pipeSpawnRate: 50,
  pipeWidth: 70.0,
  birdSize: 38.0,
  gapSize: 120.0,
  blockSize: 60.0,
  questionDelayFrames: 0,
  speedIncreaseRate: 0.03,
);

// Math Mode Configurations
GameConfig mathEasy = GameConfig(
  gameSpeed: 2.0,
  jumpStrength: -5.5,
  gravity: 0.25,
  pipeSpawnRate: 250,
  pipeWidth: 70.0,
  birdSize: 38.0,
  gapSize: 180.0,
  blockSize: 60.0,
  questionDelayFrames: 100,
  speedIncreaseRate: 0.01,
);
GameConfig mathMedium = GameConfig(
  gameSpeed: 3.0,
  jumpStrength: -5.5,
  gravity: 0.25,
  pipeSpawnRate: 200,
  pipeWidth: 70.0,
  birdSize: 38.0,
  gapSize: 150.0,
  blockSize: 60.0,
  questionDelayFrames: 100,
  speedIncreaseRate: 0.02,
);
GameConfig mathHard = GameConfig(
  gameSpeed: 4.0,
  jumpStrength: -5.5,
  gravity: 0.25,
  pipeSpawnRate: 180,
  pipeWidth: 70.0,
  birdSize: 38.0,
  gapSize: 150.0,
  blockSize: 60.0,
  questionDelayFrames: 120,
  speedIncreaseRate: 0.03,
);

// Spelling Mode Configurations
GameConfig spellingEasy = GameConfig(
  gameSpeed: 2.0,
  jumpStrength: -5.5,
  gravity: 0.25,
  pipeSpawnRate: 200,
  pipeWidth: 70.0,
  birdSize: 38.0,
  gapSize: 220.0,
  blockSize: 60.0,
  questionDelayFrames: 120,
  speedIncreaseRate: 0.01,
);
GameConfig spellingMedium = GameConfig(
  gameSpeed: 3.0,
  jumpStrength: -5.5,
  gravity: 0.25,
  pipeSpawnRate: 200,
  pipeWidth: 70.0,
  birdSize: 38.0,
  gapSize: 200.0,
  blockSize: 60.0,
  questionDelayFrames: 120,
  speedIncreaseRate: 0.02,
);
GameConfig spellingHard = GameConfig(
  gameSpeed: 4.0,
  jumpStrength: -5.5,
  gravity: 0.25,
  pipeSpawnRate: 200,
  pipeWidth: 70.0,
  birdSize: 38.0,
  gapSize: 180.0,
  blockSize: 60.0,
  questionDelayFrames: 120,
  speedIncreaseRate: 0.03,
);

GameConfig getGameConfig(GameMode gameMode, Difficulty difficulty) {
  switch (gameMode) {
    case GameMode.classic:
      switch (difficulty) {
        case Difficulty.easy:
          return classicEasy.clone();
        case Difficulty.medium:
          return classicMedium.clone();
        case Difficulty.hard:
          return classicHard.clone();
      }
    case GameMode.math:
      switch (difficulty) {
        case Difficulty.easy:
          return mathEasy.clone();
        case Difficulty.medium:
          return mathMedium.clone();
        case Difficulty.hard:
          return mathHard.clone();
      }
    case GameMode.spelling:
      switch (difficulty) {
        case Difficulty.easy:
          return spellingEasy.clone();
        case Difficulty.medium:
          return spellingMedium.clone();
        case Difficulty.hard:
          return spellingHard.clone();
      }
  }
}
