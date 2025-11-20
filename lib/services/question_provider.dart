import '../types.dart';

/// Abstract base class for question providers
/// Follows the Interface Segregation Principle
abstract class QuestionProvider {
  /// Configure the provider with a specific difficulty level
  void configure(Difficulty difficulty);

  /// Pre-fetch/generate questions for the buffer
  void fetchQuestions();

  /// Get the next question from the buffer
  dynamic getNextQuestion();
}
