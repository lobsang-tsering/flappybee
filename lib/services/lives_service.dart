import 'package:shared_preferences/shared_preferences.dart';

/// Lives management service
/// Handles lives count, recovery timing, and persistence
class LivesService {
  static const String _livesKey = 'flappybee_lives';
  static const String _recoveryTimeKey = 'flappybee_recovery_time';
  static const String _maxLivesKey = 'flappybee_max_lives';
  static const String _lastActiveTimeKey = 'flappybee_last_active_time';

  static const int _defaultMaxLives = 5;
  static const Duration _recoveryDuration = Duration(minutes: 5); // 5 minutes recovery

  static int _currentLives = 0; // Will be loaded from prefs
  static int _maxLives = 0; // Will be loaded from prefs
  static DateTime? _recoveryTime;
  static bool _initialized = false;
  static SharedPreferences? _prefs;

  /// Update the last active time to now
  static Future<void> _updateLastActiveTime() async {
    try {
      if (_prefs != null) {
        await _prefs!.setInt(_lastActiveTimeKey, DateTime.now().millisecondsSinceEpoch);
      }
    } catch (e) {
      print('Error saving last active time: $e');
    }
  }

  /// Initialize the lives service (should be called once on app startup)
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();

      final wasFirstRun = !_prefs!.containsKey(_livesKey);

      _maxLives = _prefs!.getInt(_maxLivesKey) ?? _defaultMaxLives;
      _currentLives = _prefs!.getInt(_livesKey) ?? _defaultMaxLives;

      // Save default values on first run
      if (wasFirstRun) {
        await _saveLives();
        await _saveRecoveryTime();
      }

      final recoveryTimeMillis = _prefs!.getInt(_recoveryTimeKey);
      if (recoveryTimeMillis != null) {
        _recoveryTime = DateTime.fromMillisecondsSinceEpoch(recoveryTimeMillis);
      }

      // Check for inactivity and replenish lives if needed
      final lastActiveTimeMillis = _prefs!.getInt(_lastActiveTimeKey);
      if (lastActiveTimeMillis != null) {
        final lastActiveTime = DateTime.fromMillisecondsSinceEpoch(lastActiveTimeMillis);
        final difference = DateTime.now().difference(lastActiveTime);
        if (difference.inMinutes >= 30) {
          await replenishLives();
        }
      }

      // Fix corrupted save data: if lives are 0 but no recovery time, reset to default
      if (_currentLives <= 0 && _recoveryTime == null) {
        _currentLives = _defaultMaxLives;
      }

      // Check if recovery time has passed and replenish lives
      await _checkRecovery();
      await _updateLastActiveTime();

      _initialized = true;
    } catch (e) {
      print('Error initializing lives service: $e');
      // Ensure we have default values even on error
      _currentLives = _defaultMaxLives;
      _maxLives = _defaultMaxLives;
      _initialized = true;
    }
  }

  /// Get current lives count
  static int getCurrentLives() {
    return _currentLives;
  }

  /// Get maximum lives count
  static int getMaxLives() {
    return _maxLives;
  }

  /// Set maximum lives count (configurable)
  static Future<void> setMaxLives(int maxLives) async {
    _maxLives = maxLives;
    if (_currentLives > _maxLives) {
      _currentLives = _maxLives;
    }

    try {
      if (_prefs != null) {
        await _prefs!.setInt(_maxLivesKey, _maxLives);
        await _prefs!.setInt(_livesKey, _currentLives);
      }
    } catch (e) {
      print('Error saving max lives: $e');
    }
    await _updateLastActiveTime();
  }

  /// Check if player has lives available to play
  static bool hasLives() {
    return getCurrentLives() > 0;
  }

  /// Consume one life (called when player dies)
  static Future<bool> consumeLife() async {
    await _checkRecovery(); // Check if lives should be replenished first

    if (_currentLives <= 0) {
      return false; // No lives to consume
    }

    _currentLives--;

    // If lives are depleted, set recovery time ONLY if it's not already set
    if (_currentLives <= 0 && _recoveryTime == null) {
      _recoveryTime = DateTime.now().add(_recoveryDuration);
      await _saveRecoveryTime();
    }

    await _saveLives();
    await _updateLastActiveTime();
    return true;
  }

  /// Get remaining recovery time in seconds (null if no recovery needed)
  static int? getRemainingRecoverySeconds() {
    if (_recoveryTime == null) return null;
    final remaining = _recoveryTime!.difference(DateTime.now());
    if (remaining.isNegative) return 0;
    return remaining.inSeconds;
  }

  /// Get recovery time as formatted string (e.g., "5:00")
  static String? getRecoveryTimeFormatted() {
    final seconds = getRemainingRecoverySeconds();
    if (seconds == null || seconds <= 0) return null;

    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Check if recovery time has passed and replenish lives
  static Future<void> _checkRecovery() async {
    if (_recoveryTime != null && DateTime.now().isAfter(_recoveryTime!)) {
      _currentLives = _maxLives;
      _recoveryTime = null;
      await _saveLives();
      await _saveRecoveryTime();
    }
  }

  /// Add lives (for rewards, purchases, etc.)
  static Future<void> addLives(int amount) async {
    _currentLives = (_currentLives + amount).clamp(0, _maxLives);
    await _saveLives();
    await _updateLastActiveTime();
  }

  /// Force replenish all lives (for testing or admin purposes)
  static Future<void> replenishLives() async {
    _currentLives = _maxLives;
    _recoveryTime = null;
    await _saveLives();
    await _saveRecoveryTime();
    await _updateLastActiveTime();
  }

  /// Save current lives to persistent storage
  static Future<void> _saveLives() async {
    try {
      if (_prefs != null) {
        await _prefs!.setInt(_livesKey, _currentLives);
      }
    } catch (e) {
      print('Error saving lives: $e');
    }
  }

  /// Save recovery time to persistent storage
  static Future<void> _saveRecoveryTime() async {
    try {
      if (_prefs != null) {
        if (_recoveryTime != null) {
          await _prefs!.setInt(_recoveryTimeKey, _recoveryTime!.millisecondsSinceEpoch);
        } else {
          await _prefs!.remove(_recoveryTimeKey);
        }
      }
    } catch (e) {
      print('Error saving recovery time: $e');
    }
  }
}
