import 'dart:math';
import '../types.dart';
import 'question_provider.dart';

class MathQuestionProvider implements QuestionProvider {
  final List<MathProblem> _buffer = [];
  late Difficulty _difficulty;
  final Random _random = Random();

  @override
  void configure(Difficulty difficulty) {
    _difficulty = difficulty;
    _buffer.clear();
  }

  @override
  void fetchQuestions() {
    // Pre-fill buffer with 10 questions
    for (int i = 0; i < 10; i++) {
      _buffer.add(_generateMathProblem());
    }
  }

  @override
  MathProblem getNextQuestion() {
    // Auto-refill when buffer is low
    if (_buffer.length < 5) {
      fetchQuestions();
    }

    if (_buffer.isEmpty) {
      return _generateMathProblem();
    }

    return _buffer.removeAt(0);
  }

  MathProblem _generateMathProblem() {
    late int correctAnswer;
    late String question;

    if (_difficulty == Difficulty.easy) {
      // ────── EASY: Only addition, numbers 1–10 → max answer = 20 ──────
      final a = _random.nextInt(10) + 1; // 1–10
      final b = _random.nextInt(10) + 1; // 1–10
      correctAnswer = a + b;
      question = '$a + $b';
    } else if (_difficulty == Difficulty.medium) {
      // ────── MEDIUM: Addition or subtraction (always positive result) ──────
      final a = _random.nextInt(19) + 1; // 1–19
      final b = _random.nextInt(19) + 1; // 1–19

      if (_random.nextBool()) {
        // Addition
        correctAnswer = a + b;
        question = '$a + $b';
      } else {
        // Subtraction – ensure positive result
        final bigger = max(a, b);
        final smaller = min(a, b);
        correctAnswer = bigger - smaller;
        question = '$bigger - $smaller';
      }
    } else {
      // ────── HARD: Add, subtract, multiply (small tables), exact division ──────
      final operation = _random.nextInt(4);

      if (operation == 0) {
        // Addition (1–50)
        final a = _random.nextInt(49) + 1;
        final b = _random.nextInt(49) + 1;
        correctAnswer = a + b;
        question = '$a + $b';
      } else if (operation == 1) {
        // Subtraction (positive result)
        final a = _random.nextInt(49) + 1;
        final b = _random.nextInt(49) + 1;
        final bigger = max(a, b);
        final smaller = min(a, b);
        correctAnswer = bigger - smaller;
        question = '$bigger - $smaller';
      } else if (operation == 2) {
        // Multiplication – only 1–10 tables (easy & common)
        final a = _random.nextInt(10) + 1; // 1–10
        final b = _random.nextInt(10) + 1; // 1–10
        correctAnswer = a * b;
        question = '$a × $b';
      } else {
        // Division – always exact, quotient 1–15
        final divisor = _random.nextInt(9) + 2; // 2–10 (avoid ÷1)
        final quotient = _random.nextInt(15) + 1; // 1–15
        final dividend = divisor * quotient;
        correctAnswer = quotient;
        question = '$dividend ÷ $divisor';
      }
    }

    // ────── Generate a plausible wrong answer (close but different) ──────
    int wrongAnswer = correctAnswer;
    while (wrongAnswer == correctAnswer || wrongAnswer <= 0) {
      wrongAnswer =
          correctAnswer + _random.nextInt(11) - 5; // ±0 to ±5, but not equal
    }
    if (wrongAnswer <= 0) wrongAnswer = correctAnswer + 1;

    return MathProblem(
      id: "${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(10000)}",
      question: question,
      correctAnswer: correctAnswer.toString(),
      wrongAnswer: wrongAnswer.toString(),
    );
  }
}
