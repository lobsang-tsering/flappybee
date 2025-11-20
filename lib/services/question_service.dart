import 'dart:math';
import '../types.dart';
import 'math_question_provider.dart';
import 'spelling_question_provider.dart';

/// Main question service that manages both math and spelling questions
/// Follows the Facade Pattern and Dependency Inversion Principle
/// Delegates to specific providers based on game mode
class QuestionService {
  static final MathQuestionProvider _mathProvider = MathQuestionProvider();
  static final SpellingQuestionProvider _spellingProvider =
      SpellingQuestionProvider();

  static GameMode _currentMode = GameMode.math;

  /// Configure the question service with a game mode and difficulty
  static void configure(GameMode mode, Difficulty difficulty) {
    _currentMode = mode;
    _mathProvider.configure(difficulty);
    _spellingProvider.configure(difficulty);
  }

  /// Fetch and pre-buffer questions based on current game mode
  static void fetchProblems() {
    // If in classic mode we don't need to fetch problems
    if (_currentMode == GameMode.classic) return;

    if (_currentMode == GameMode.math) {
      _mathProvider.fetchQuestions();
    } else if (_currentMode == GameMode.spelling) {
      _spellingProvider.fetchQuestions();
    }
  }

  /// Get the next math problem
  static MathProblem getNextMathProblem() {
    return _mathProvider.getNextQuestion();
  }

  /// Get the next spelling word
  static String getNextSpellingWord() {
    return _spellingProvider.getNextQuestion();
  }

  /// Generate a random character different from the correct one
  /// Used for spelling question distractors
  static String generateDistractorChar(String correctChar) {
    const alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    String char = correctChar;
    final rand = Random();
    while (char == correctChar) {
      char = alphabet[rand.nextInt(alphabet.length)];
    }
    return char;
  }
}
