import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'constants.dart';
import 'types.dart';
import 'services/question_service.dart';
import 'services/audio_service.dart';
import 'services/score_service.dart';
import 'screens/scores_screen.dart';
import 'widgets/bird.dart';
import 'widgets/obstacle.dart';

void main() {
  runApp(const AbacusFlapApp());
}

class AbacusFlapApp extends StatelessWidget {
  const AbacusFlapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Abacus Flap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(textTheme: GoogleFonts.vt323TextTheme()),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Game State
  GameState _gameState = GameState.start;
  int _score = 0;
  int _highScore = 0;

  // Settings
  GameMode _gameMode = GameMode.math;
  Difficulty _difficulty = Difficulty.easy;
  CharacterType _character = CharacterType.bird;

  // Physics
  late Ticker _ticker;
  double _birdY = 0;
  double _birdVelocity = 0;
  double _birdRotation = 0;

  // Entities
  final List<PipeData> _pipes = [];
  final List<VisualEffect> _effects = [];

  // Logic
  int _frames = 0;
  double _gameHeight = 0;
  double _gameWidth = 0;

  // Spelling Mode State
  String _currentWord = "";
  int _wordIdx = 0;

  @override
  void initState() {
    super.initState();
    _initializeServices().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
    _ticker = createTicker(_updatePhysics);
    QuestionService.configure(_gameMode, _difficulty);
    QuestionService.fetchProblems(); // Pre-fetch
  }

  Future<void> _initializeServices() async {
    await AudioService.init(); // Wait for init to complete
    ScoreService.initialize(); // Initialize score persistence
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _resetGame() {
    QuestionService.configure(_gameMode, _difficulty);
    setState(() {
      _birdY = _gameHeight / 2;
      _birdVelocity = 0;
      _birdRotation = 0;
      _pipes.clear();
      _effects.clear();
      _frames = 0;
      _score = 0;
      _currentWord = "";
      _wordIdx = 0;
      _gameState = GameState.start;
    });
  }

  void _startGame() {
    QuestionService.configure(_gameMode, _difficulty);
    setState(() {
      _gameState = GameState.playing;
      _birdVelocity = kJumpStrength;
      _birdY = _gameHeight / 2;
      _pipes.clear();
      _score = 0;
    });
    AudioService.playJump();
    if (!_ticker.isTicking) _ticker.start();
  }

  void _jump() {
    if (_gameState == GameState.playing) {
      _birdVelocity = kJumpStrength;
      AudioService.playJump();
    } else if (_gameState == GameState.start) {
      _startGame();
    } else if (_gameState == GameState.gameOver) {
      // Do nothing on click here, let buttons handle retry
    }
  }

  void _gameOver() {
    AudioService.playCrash();

    // Check if new record
    final isNewRecord = _score > _highScore;
    if (isNewRecord) {
      _highScore = _score;
      _spawnCelebrationEffects();
      AudioService.playCelebration();
    }

    // Save score to local storage
    _saveScore();

    _spawnExplosion(kMaxGameWidth * 0.2, _birdY);

    setState(() {
      _gameState = GameState.gameOver;
    });
  }

  void _saveScore() {
    final modeString = _gameMode == GameMode.classic
        ? 'classic'
        : _gameMode == GameMode.math
        ? 'math'
        : 'spelling';

    final difficultyString = _difficulty == Difficulty.easy
        ? 'easy'
        : _difficulty == Difficulty.medium
        ? 'medium'
        : 'hard';

    ScoreService.saveScore(
      score: _score,
      mode: modeString,
      difficulty: difficultyString,
    );
  }

  void _spawnCelebrationEffects() {
    // Create celebration confetti around the screen
    for (int i = 0; i < 20; i++) {
      final angle = Random().nextDouble() * pi * 2;
      final speed = Random().nextDouble() * 8 + 4;
      final colors = [
        Colors.yellow,
        Colors.yellowAccent,
        Colors.orange,
        Colors.amber,
        Colors.lime,
      ];
      _effects.add(
        VisualEffect(
          id: Random().nextInt(10000),
          type: EffectType.particle,
          x: _gameWidth / 2,
          y: _gameHeight / 3,
          color: colors[Random().nextInt(colors.length)],
          life: 60 + Random().nextInt(40),
          velocityX: cos(angle) * speed,
          velocityY: sin(angle) * speed - 2,
          scale: Random().nextDouble() * 0.8 + 0.5,
        ),
      );
    }
  }

  void _spawnPipe() {
    dynamic problem;
    if (_gameMode == GameMode.math) {
      problem = QuestionService.getNextMathProblem();
    } else if (_gameMode == GameMode.spelling) {
      if (_currentWord.isEmpty || _wordIdx >= _currentWord.length) {
        _currentWord = QuestionService.getNextSpellingWord();
        _wordIdx = 0;
      }

      String target = _currentWord[_wordIdx];
      String distractor = QuestionService.generateDistractorChar(target);

      problem = SpellingProblem(
        id: "${DateTime.now().millisecondsSinceEpoch}",
        correctAnswer: target,
        wrongAnswer: distractor,
        word: _currentWord,
        letterIndex: _wordIdx,
        totalLength: _currentWord.length,
      );

      _wordIdx++;
    } else {
      // Classic mode: no problem attached to pipes
      problem = null;
    }

    const padding = 100.0;
    final safeHeight = _gameHeight - (padding * 2);
    final obstacleContent = (kGapSize * 2) + 60;
    final complexCenterY =
        padding +
        (obstacleContent / 2) +
        Random().nextDouble() * (safeHeight - obstacleContent);

    final gapTop = complexCenterY - 30 - (kGapSize / 2);
    final gapBottom = complexCenterY + 30 + (kGapSize / 2);

    // Add delay before pipe becomes visible
    // This gives the player time to read the question
    final visibilityDelay = problem != null ? kQuestionDelayFrames : 0;

    _pipes.add(
      PipeData(
        id: DateTime.now().millisecondsSinceEpoch,
        x: _gameWidth + 50,
        gapTop: gapTop,
        gapBottom: gapBottom,
        problem: problem,
        correctIsTop: Random().nextBool(),
        visibilityDelay: visibilityDelay,
      ),
    );
  }

  void _updatePhysics(Duration elapsed) {
    if (_gameState == GameState.start) return;
    if (_gameHeight == 0) return; // Wait for layout

    setState(() {
      const visualGroundHeight = 100.0;
      final groundY = _gameHeight - visualGroundHeight;
      final groundLevel = groundY - (kBirdSize / 2) + 4;
      final onGround = _birdY >= groundLevel;

      // Bird Physics
      if (_gameState == GameState.playing ||
          (_gameState == GameState.gameOver && !onGround)) {
        _birdVelocity += kGravity;
        _birdY += _birdVelocity;

        if (_gameState == GameState.gameOver && _birdY > groundLevel) {
          _birdY = groundLevel;
          _birdVelocity = 0;
        }

        // Rotation
        _birdRotation =
            min(pi / 4, max(-pi / 4, (_birdVelocity * 0.1))) * (180 / pi);
      }

      if (_gameState == GameState.playing) {
        const birdHitboxRadius = 12.0;

        // Floor/Ceiling
        if (_birdY + birdHitboxRadius > groundY ||
            _birdY - birdHitboxRadius < 0) {
          _gameOver();
          return;
        }

        _frames++;
        if (_frames % kPipeSpawnRate == 0) _spawnPipe();

        // Update pipe visibility delays and move visible pipes
        for (var pipe in _pipes) {
          if (pipe.visibilityDelay > 0) {
            pipe.visibilityDelay--;
          } else {
            // Only move pipes that are visible
            pipe.x -= kGameSpeed;
          }
        }
        _pipes.removeWhere((p) => p.x < -kPipeWidth);

        // Collision
        final birdX = _gameWidth * 0.2;
        final halfGap = kGapSize / 2;

        // Check Pipe Collision
        for (var pipe in _pipes) {
          final pipeLeft = pipe.x;
          final pipeRight = pipe.x + kPipeWidth;

          // Horizontal overlap
          if ((birdX + birdHitboxRadius > pipeLeft) &&
              (birdX - birdHitboxRadius < pipeRight)) {
            // There are TWO safe gaps:
            // Gap 1 (top): from (gapTop - halfGap) to (gapTop + halfGap)
            // Gap 2 (bottom): from (gapBottom - halfGap) to (gapBottom + halfGap)
            // The middle section is the obstacle (middle pipe)

            final topGapMin = pipe.gapTop - halfGap;
            final topGapMax = pipe.gapTop + halfGap;
            final bottomGapMin = pipe.gapBottom - halfGap;
            final bottomGapMax = pipe.gapBottom + halfGap;

            final birdTop = _birdY - birdHitboxRadius;
            final birdBottom = _birdY + birdHitboxRadius;

            // Check if bird is in EITHER safe gap
            final inTopGap =
                (birdBottom <= topGapMax) && (birdTop >= topGapMin);
            final inBottomGap =
                (birdBottom <= bottomGapMax) && (birdTop >= bottomGapMin);

            print('🐦 COLLISION CHECK');
            print('  Bird Y: $_birdY (top: $birdTop, bottom: $birdBottom)');
            print('  Top gap: $topGapMin to $topGapMax, In? $inTopGap');
            print(
              '  Bottom gap: $bottomGapMin to $bottomGapMax, In? $inBottomGap',
            );
            print('  Hit? ${!inTopGap && !inBottomGap}');

            // Bird collides if it's NOT in either safe gap
            if (!inTopGap && !inBottomGap) {
              _gameOver();
              return;
            }
          }

          // Scoring & Answer Checking
          if (!pipe.passed && pipe.x + kPipeWidth < birdX - birdHitboxRadius) {
            pipe.passed = true;

            // Check if the answer is correct based on which gap the bird passed through
            bool correctAnswer = false;

            if (pipe.problem != null) {
              // Determine which gap the bird was in when it passed
              // (uses the same gap logic as collision detection)
              final topGapMin = pipe.gapTop - halfGap;
              final topGapMax = pipe.gapTop + halfGap;
              final bottomGapMin = pipe.gapBottom - halfGap;
              final bottomGapMax = pipe.gapBottom + halfGap;

              final birdTop = _birdY - birdHitboxRadius;
              final birdBottom = _birdY + birdHitboxRadius;

              final inTopGap =
                  (birdBottom <= topGapMax) && (birdTop >= topGapMin);
              final inBottomGap =
                  (birdBottom <= bottomGapMax) && (birdTop >= bottomGapMin);

              // Top gap = correct answer, Bottom gap = wrong answer
              correctAnswer = pipe.correctIsTop ? inTopGap : inBottomGap;

              print(
                '✅ ANSWER CHECK: correctIsTop=${pipe.correctIsTop}, inTopGap=$inTopGap, inBottomGap=$inBottomGap, correct=$correctAnswer',
              );
            } else {
              // Classic mode has no correct/wrong answers
              correctAnswer = true;
            }

            if (correctAnswer) {
              _score++;
              AudioService.playCoin();
              _spawnTextEffect(birdX, _birdY, "+1", Colors.amber);
            } else {
              // Wrong answer - game over
              print('❌ WRONG ANSWER!');
              _gameOver();
              return;
            }

            if (pipe.problem is SpellingProblem) {
              _spawnTextEffect(
                birdX + 30,
                _birdY - 30,
                pipe.problem.correctAnswer,
                Colors.green,
              );
            }
          }
        }
      }

      // Effects Logic
      for (var eff in _effects) {
        eff.life--;
        eff.x += eff.velocityX;
        eff.y += eff.velocityY;
        if (eff.type == EffectType.particle)
          eff.velocityY += 0.4;
        else
          eff.velocityY *= 0.9;
      }
      _effects.removeWhere((e) => e.life <= 0);
    });
  }

  void _spawnTextEffect(double x, double y, String text, Color color) {
    _effects.add(
      VisualEffect(
        id: Random().nextInt(10000),
        type: EffectType.text,
        x: x,
        y: y,
        text: text,
        color: color,
        life: 60,
        velocityY: -2,
      ),
    );
  }

  void _spawnExplosion(double x, double y) {
    for (int i = 0; i < 12; i++) {
      final angle = Random().nextDouble() * pi * 2;
      final speed = Random().nextDouble() * 6 + 2;
      final colors = [Colors.orange, Colors.white, Colors.red];
      _effects.add(
        VisualEffect(
          id: Random().nextInt(10000),
          type: EffectType.particle,
          x: x,
          y: y,
          color: colors[Random().nextInt(colors.length)],
          life: 40 + Random().nextInt(20),
          velocityX: cos(angle) * speed,
          velocityY: sin(angle) * speed,
          scale: Random().nextDouble() * 0.5 + 0.5,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _gameHeight = constraints.maxHeight;
        _gameWidth = min(constraints.maxWidth, kMaxGameWidth);

        return Scaffold(
          backgroundColor: Colors.blueGrey[900],
          body: Center(
            child: Container(
              width: _gameWidth,
              height: _gameHeight,
              color: kSkyColor,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _jump,
                child: Stack(
                  children: [
                    // Background
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 100,
                      child: Container(
                        color: const Color(0xFFDED895),
                        margin: const EdgeInsets.only(top: 4),
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                width: 4,
                                color: Color(0xFFD4CF85),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 90,
                      left: 0,
                      right: 0,
                      height: 20,
                      child: Container(
                        color: const Color(0xFF73BF2E),
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                width: 4,
                                color: Color(0xFF5FA622),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Clouds
                    const Positioned(
                      top: 80,
                      left: 40,
                      child: Text(
                        "☁",
                        style: TextStyle(fontSize: 60, color: Colors.white38),
                      ),
                    ),
                    const Positioned(
                      top: 160,
                      right: 80,
                      child: Text(
                        "☁",
                        style: TextStyle(fontSize: 80, color: Colors.white30),
                      ),
                    ),

                    // Pipes
                    ..._pipes.map(
                      (p) => ObstacleWidget(key: ValueKey(p.id), data: p),
                    ),

                    // Bird
                    Positioned(
                      top: _birdY - (kBirdSize * 0.75 / 2),
                      left: (_gameWidth * 0.2) - (kBirdSize / 2),
                      child: BirdWidget(
                        rotation: _birdRotation,
                        type: _character,
                      ),
                    ),

                    // Effects
                    ..._effects.map(
                      (eff) => Positioned(
                        left: eff.x,
                        top: eff.y,
                        child: eff.type == EffectType.text
                            ? Text(
                                eff.text!,
                                style: GoogleFonts.vt323(
                                  fontSize: 30,
                                  color: eff.color,
                                  fontWeight: FontWeight.bold,
                                  shadows: [const Shadow(offset: Offset(2, 2))],
                                ),
                              )
                            : Container(
                                width: 8 * eff.scale,
                                height: 8 * eff.scale,
                                color: eff.color,
                              ),
                      ),
                    ),

                    // HUD
                    _buildHUD(),

                    // Start Screen
                    if (_gameState == GameState.start) _buildStartScreen(),

                    // Game Over Screen
                    if (_gameState == GameState.gameOver)
                      _buildGameOverScreen(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHUD() {
    Widget centerContent = const SizedBox.shrink();
    bool hasQuestion = false;

    if (_gameState == GameState.playing &&
        _pipes.isNotEmpty &&
        !_pipes.first.passed) {
      final prob = _pipes.first.problem;
      if (prob is MathProblem) {
        centerContent = Text(
          "${prob.question} = ?",
          style: GoogleFonts.vt323(
            fontSize: 56,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              const Shadow(
                offset: Offset(3, 3),
                blurRadius: 2,
                color: Colors.black87,
              ),
              const Shadow(
                offset: Offset(-1, -1),
                blurRadius: 1,
                color: Colors.black54,
              ),
            ],
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        );
        hasQuestion = true;
      } else if (prob is SpellingProblem) {
        // Spelling HUD
        List<Widget> chars = [];
        for (int i = 0; i < prob.totalLength; i++) {
          Color c = Colors.white24;
          String t = "_";
          if (i < prob.letterIndex) {
            c = Colors.greenAccent;
            t = prob.word[i];
          } else if (i == prob.letterIndex) {
            c = Colors.white;
            t = "_";
          }

          chars.add(
            Text(
              t,
              style: GoogleFonts.vt323(
                fontSize: 48,
                color: c,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
          chars.add(const SizedBox(width: 2));
        }
        centerContent = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "COLLECT: ${prob.correctAnswer}",
              style: GoogleFonts.vt323(
                fontSize: 36,
                color: Colors.yellowAccent,
                fontWeight: FontWeight.bold,
                shadows: [
                  const Shadow(
                    offset: Offset(2, 2),
                    blurRadius: 2,
                    color: Colors.black87,
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 8),
            Row(mainAxisSize: MainAxisSize.min, children: chars),
          ],
        );
        hasQuestion = true;
      }
    }

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$_score",
              style: GoogleFonts.vt323(
                fontSize: 60,
                color: Colors.white,
                shadows: [const Shadow(offset: Offset(3, 3))],
              ),
            ),
            if (_gameState == GameState.playing && hasQuestion)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white54, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: centerContent,
                  ),
                ),
              ),
            IconButton(
              icon: Icon(
                AudioService.isMuted()
                    ? LucideIcons.volumeX
                    : LucideIcons.volume2,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  AudioService.toggleMute();
                });
              },
              tooltip: AudioService.isMuted() ? "Unmute" : "Mute",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartScreen() {
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFCF8DC),
          border: Border.all(width: 4, color: const Color(0xFFD69736)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "FLAPPY MATH",
              style: GoogleFonts.vt323(
                fontSize: 50,
                color: const Color(0xFFF47E1B),
                shadows: [const Shadow(offset: Offset(2, 2))],
              ),
            ),
            Text(
              "Educational Edition",
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: const Color(0xFFD69736),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Character Select
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.chevronLeft),
                  onPressed: () => setState(
                    () => _character =
                        CharacterType.values[(_character.index - 1) % 3],
                  ),
                ),
                SizedBox(
                  width: 60,
                  height: 50,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 15,
                        left: 15,
                        child: BirdWidget(rotation: 0, type: _character),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.chevronRight),
                  onPressed: () => setState(
                    () => _character =
                        CharacterType.values[(_character.index + 1) % 3],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Audio Toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8DCB0),
                border: Border.all(color: const Color(0xFFD69736)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    AudioService.isMuted()
                        ? LucideIcons.volumeX
                        : LucideIcons.volume2,
                    color: const Color(0xFFF47E1B),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AudioService.isMuted() ? "AUDIO: OFF" : "AUDIO: ON",
                    style: GoogleFonts.vt323(
                      fontSize: 18,
                      color: const Color(0xFFF47E1B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() {
                          if (AudioService.isMuted()) {
                            AudioService.toggleMute();
                          }
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: !AudioService.isMuted()
                                ? const Color(0xFFF47E1B)
                                : Colors.transparent,
                            border: !AudioService.isMuted()
                                ? null
                                : Border.all(color: const Color(0xFFD69736)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "ON",
                            style: GoogleFonts.vt323(
                              fontSize: 16,
                              color: !AudioService.isMuted()
                                  ? Colors.white
                                  : const Color(0xFFD69736),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => setState(() {
                          if (!AudioService.isMuted()) {
                            AudioService.toggleMute();
                          }
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AudioService.isMuted()
                                ? const Color(0xFFF47E1B)
                                : Colors.transparent,
                            border: AudioService.isMuted()
                                ? null
                                : Border.all(color: const Color(0xFFD69736)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "OFF",
                            style: GoogleFonts.vt323(
                              fontSize: 16,
                              color: AudioService.isMuted()
                                  ? Colors.white
                                  : const Color(0xFFD69736),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _toggleBtn(
                    "CLASSIC",
                    _gameMode == GameMode.classic,
                    () => setState(() => _gameMode = GameMode.classic),
                  ),
                ),
                Expanded(
                  child: _toggleBtn(
                    "MATH",
                    _gameMode == GameMode.math,
                    () => setState(() => _gameMode = GameMode.math),
                  ),
                ),
                Expanded(
                  child: _toggleBtn(
                    "SPELL",
                    _gameMode == GameMode.spelling,
                    () => setState(() => _gameMode = GameMode.spelling),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _toggleBtn(
                    "EASY",
                    _difficulty == Difficulty.easy,
                    () => setState(() => _difficulty = Difficulty.easy),
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _toggleBtn(
                    "MED",
                    _difficulty == Difficulty.medium,
                    () => setState(() => _difficulty = Difficulty.medium),
                    color: Colors.amber,
                  ),
                ),
                Expanded(
                  child: _toggleBtn(
                    "HARD",
                    _difficulty == Difficulty.hard,
                    () => setState(() => _difficulty = Difficulty.hard),
                    color: Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1CB6CF),
                      padding: const EdgeInsets.all(12),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScoresScreen(),
                        ),
                      );
                    },
                    icon: const Icon(LucideIcons.trophy, color: Colors.white),
                    label: Text(
                      "SCORES",
                      style: GoogleFonts.vt323(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF53C02C),
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: _startGame,
                    icon: const Icon(LucideIcons.play, color: Colors.white),
                    label: Text(
                      "PLAY",
                      style: GoogleFonts.vt323(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleBtn(
    String text,
    bool active,
    VoidCallback onTap, {
    Color color = const Color(0xFFF47E1B),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? color : Colors.transparent,
          border: Border.all(
            color: active ? Colors.black : const Color(0xFFA68340),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: GoogleFonts.vt323(
            fontSize: 20,
            color: active ? Colors.white : const Color(0xFFA68340),
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverScreen() {
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFCF8DC),
          border: Border.all(width: 4, color: const Color(0xFFD69736)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "GAME OVER",
              style: GoogleFonts.vt323(
                fontSize: 50,
                color: const Color(0xFFF47E1B),
                shadows: [const Shadow(offset: Offset(2, 2))],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8DCB0),
                border: Border.all(color: const Color(0xFFD69736)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SCORE",
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "$_score",
                        style: GoogleFonts.vt323(
                          fontSize: 30,
                          color: const Color(0xFFF47E1B),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "BEST",
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "$_highScore",
                        style: GoogleFonts.vt323(
                          fontSize: 30,
                          color: const Color(0xFFF47E1B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF53C02C),
                    ),
                    onPressed: () {
                      setState(() => _gameState = GameState.playing);
                      _startGame();
                    },
                    child: Text(
                      "RETRY",
                      style: GoogleFonts.vt323(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1CB6CF),
                    ),
                    onPressed: _resetGame,
                    child: Text(
                      "MENU",
                      style: GoogleFonts.vt323(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
