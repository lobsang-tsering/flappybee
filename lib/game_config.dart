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
}

GameConfig classicConfig = GameConfig(
  gameSpeed: 3.0,
  jumpStrength: -5.5,
  gravity: 0.25,
  pipeSpawnRate: 90,
  pipeWidth: 70.0,
  birdSize: 38.0,
  gapSize: 150.0,
  blockSize: 60.0,
  questionDelayFrames: 0,
  speedIncreaseRate: 0.2,
);

GameConfig mathConfig = GameConfig(
  gameSpeed: 3.0,
  jumpStrength: -5.5,
  gravity: 0.25,
  pipeSpawnRate: 150,
  pipeWidth: 70.0,
  birdSize: 38.0,
  gapSize: 150.0,
  blockSize: 60.0,
  questionDelayFrames: 120,
  speedIncreaseRate: 0.2,
);

GameConfig spellingConfig = GameConfig(
  gameSpeed: 3.0,
  jumpStrength: -5.5,
  gravity: 0.25,
  pipeSpawnRate: 180,
  pipeWidth: 70.0,
  birdSize: 38.0,
  gapSize: 200.0,
  blockSize: 60.0,
  questionDelayFrames: 120,
  speedIncreaseRate: 0.2,
);

GameConfig getGameConfig(GameMode gameMode) {
  switch (gameMode) {
    case GameMode.classic:
      return classicConfig;
    case GameMode.math:
      return mathConfig;
    case GameMode.spelling:
      return spellingConfig;
  }
}
