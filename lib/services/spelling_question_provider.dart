import 'dart:math';
import 'package:english_words/english_words.dart';
import '../types.dart';
import 'question_provider.dart';

/// English word spelling question provider implementation
/// Follows the Single Responsibility Principle - only handles spelling question generation
class SpellingQuestionProvider implements QuestionProvider {
  final List<String> _buffer = [];
  late Difficulty _difficulty;
  final Random _random = Random();

  @override
  void configure(Difficulty difficulty) {
    _difficulty = difficulty;
    _buffer.clear();
  }

  @override
  void fetchQuestions() {
    for (int i = 0; i < 15; i++) {
      _buffer.add(_generateRandomWord());
    }
  }

  @override
  String getNextQuestion() {
    if (_buffer.length < 5) fetchQuestions();
    if (_buffer.isEmpty) {
      return _generateRandomWord();
    }
    return _buffer.removeAt(0);
  }

  String _generateRandomWord() {
    final filteredNouns = _filterNounsByDifficulty();
    if (filteredNouns.isEmpty) {
      return nouns[_random.nextInt(nouns.length)].toUpperCase();
    }
    return filteredNouns[_random.nextInt(filteredNouns.length)];
  }

  List<String> _filterNounsByDifficulty() {
    final List<String> filtered = [];

    if (_difficulty == Difficulty.easy) {
      // Easy: 3-4 letter words
      for (var word in nouns) {
        if (word.length >= 3 && word.length <= 4) {
          filtered.add(word.toUpperCase());
        }
      }
    } else if (_difficulty == Difficulty.medium) {
      // Medium: 5-6 letter words
      for (var word in nouns) {
        if (word.length >= 5 && word.length <= 6) {
          filtered.add(word.toUpperCase());
        }
      }
    } else {
      // Hard: 7+ letter words
      for (var word in nouns) {
        if (word.length >= 7) {
          filtered.add(word.toUpperCase());
        }
      }
    }

    return filtered;
  }
}
