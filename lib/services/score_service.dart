import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Score record model
class ScoreRecord {
  final int score;
  final String mode; // 'classic', 'math', 'spelling'
  final String difficulty; // 'easy', 'medium', 'hard'
  final DateTime timestamp;

  ScoreRecord({
    required this.score,
    required this.mode,
    required this.difficulty,
    required this.timestamp,
  });

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'mode': mode,
      'difficulty': difficulty,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create from JSON
  factory ScoreRecord.fromJson(Map<String, dynamic> json) {
    return ScoreRecord(
      score: json['score'] as int,
      mode: json['mode'] as String,
      difficulty: json['difficulty'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// Score management service
/// Handles local persistence and score record management
class ScoreService {
  static const String _storageKey = 'flappybee_scores';
  static final List<ScoreRecord> _records = [];
  static bool _initialized = false;

  /// Initialize the score service (should be called once on app startup)
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final scoresJson = prefs.getStringList(_storageKey) ?? [];

      _records.clear();
      for (var json in scoresJson) {
        try {
          _records.add(ScoreRecord.fromJson(jsonDecode(json)));
        } catch (e) {
          print('Error parsing score record: $e');
        }
      }

      // Sort by timestamp (newest first)
      _records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _initialized = true;
    } catch (e) {
      print('Error initializing score service: $e');
      _initialized = true;
    }
  }

  /// Save a score record and return whether it's a new record
  static Future<bool> saveScore({
    required int score,
    required String mode,
    required String difficulty,
  }) async {
    try {
      final record = ScoreRecord(
        score: score,
        mode: mode,
        difficulty: difficulty,
        timestamp: DateTime.now(),
      );

      _records.insert(0, record); // Add to top (newest first)
      await _persistRecords();

      // Check if it's the best score
      return score == _getBestScore(mode, difficulty);
    } catch (e) {
      print('Error saving score: $e');
      return false;
    }
  }

  /// Get the best score for a specific mode and difficulty
  static int _getBestScore(String mode, String difficulty) {
    final modeRecords = _records
        .where((r) => r.mode == mode && r.difficulty == difficulty)
        .toList();

    if (modeRecords.isEmpty) return 0;
    return modeRecords.map((r) => r.score).reduce((a, b) => a > b ? a : b);
  }

  /// Get the best score for a mode (across all difficulties)
  static int getBestScoreForMode(String mode) {
    final modeRecords = _records.where((r) => r.mode == mode).toList();
    if (modeRecords.isEmpty) return 0;
    return modeRecords.map((r) => r.score).reduce((a, b) => a > b ? a : b);
  }

  /// Get all score records
  static List<ScoreRecord> getAllRecords() {
    return List.unmodifiable(_records);
  }

  /// Get score records for a specific mode
  static List<ScoreRecord> getRecordsByMode(String mode) {
    return _records.where((r) => r.mode == mode).toList();
  }

  /// Get top N records overall
  static List<ScoreRecord> getTopRecords({int limit = 10}) {
    final sorted = List<ScoreRecord>.from(_records)
      ..sort((a, b) => b.score.compareTo(a.score));
    return sorted.take(limit).toList();
  }

  /// Clear all records (for testing)
  static Future<void> clearAllRecords() async {
    try {
      _records.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      print('Error clearing records: $e');
    }
  }

  /// Persist records to shared preferences
  static Future<void> _persistRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scoresJson = _records.map((r) => jsonEncode(r.toJson())).toList();
      await prefs.setStringList(_storageKey, scoresJson);
    } catch (e) {
      print('Error persisting records: $e');
    }
  }
}
