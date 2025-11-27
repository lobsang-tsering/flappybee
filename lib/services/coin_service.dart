import 'package:shared_preferences/shared_preferences.dart';

/// Coin management service
/// Handles local persistence of the player's coin balance.
class CoinService {
  static const String _storageKey = 'flappybee_coins';
  static int _coins = 0;
  static bool _initialized = false;

  /// Initialize the coin service (should be called once on app startup)
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _coins = prefs.getInt(_storageKey) ?? 0;
      _initialized = true;
    } catch (e) {
      print('Error initializing CoinService: $e');
      _initialized = true;
    }
  }

  /// Get the current coin balance
  static int getCoins() {
    return _coins;
  }

  /// Add coins to the balance
  static Future<void> addCoins(int amount) async {
    if (amount <= 0) return;

    try {
      _coins += amount;
      await _persistCoins();
    } catch (e) {
      print('Error adding coins: $e');
    }
  }

  /// Persist the coin balance to shared preferences
  static Future<void> _persistCoins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_storageKey, _coins);
    } catch (e) {
      print('Error persisting coins: $e');
    }
  }
}
