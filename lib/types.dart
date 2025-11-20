import 'package:flutter/material.dart';

enum GameState { start, playing, gameOver }

enum GameMode { classic, math, spelling }

enum Difficulty { easy, medium, hard }

enum CharacterType { bird, bee, rocket }

enum EffectType { text, particle }

abstract class BaseProblem {
  final String id;
  final String correctAnswer;
  final String wrongAnswer;

  BaseProblem({
    required this.id,
    required this.correctAnswer,
    required this.wrongAnswer,
  });
}

class MathProblem extends BaseProblem {
  final String question;
  MathProblem({
    required super.id,
    required super.correctAnswer,
    required super.wrongAnswer,
    required this.question,
  });
}

class SpellingProblem extends BaseProblem {
  final String word;
  final int letterIndex;
  final int totalLength;

  SpellingProblem({
    required super.id,
    required super.correctAnswer,
    required super.wrongAnswer,
    required this.word,
    required this.letterIndex,
    required this.totalLength,
  });
}

class PipeData {
  final int id;
  double x;
  final double gapTop;
  final double gapBottom;
  final dynamic problem; // MathProblem or SpellingProblem
  bool passed;
  final bool correctIsTop;
  int visibilityDelay; // Frames to wait before showing the pipe visually

  PipeData({
    required this.id,
    required this.x,
    required this.gapTop,
    required this.gapBottom,
    required this.problem,
    this.passed = false,
    required this.correctIsTop,
    this.visibilityDelay = 0,
  });
}

class VisualEffect {
  final int id;
  final EffectType type;
  double x;
  double y;
  final String? text;
  final Color color;
  int life;
  double velocityX;
  double velocityY;
  final double scale;

  VisualEffect({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    this.text,
    required this.color,
    required this.life,
    this.velocityX = 0,
    this.velocityY = 0,
    this.scale = 1.0,
  });
}
