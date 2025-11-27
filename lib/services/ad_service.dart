import 'dart:async';

/// Abstract ad service interface for rewarded video ads
abstract class AdService {
  /// Initialize the ad service
  Future<void> initialize();

  /// Check if a rewarded ad is available to show
  Future<bool> isRewardedAdAvailable();

  /// Show a rewarded ad and return success status
  Future<bool> showRewardedAd({
    required String rewardType,
    required int rewardAmount,
    required Function(String type, int amount) onRewardEarned,
    required Function(String error) onAdFailed,
  });

  /// Get time until next ad can be shown (for frequency control)
  Duration getTimeUntilNextAd();

  /// Check if player can watch another ad (frequency control)
  bool canShowAd();

  /// Record that an ad was shown (for frequency tracking)
  void recordAdShown();

  /// Reset ad frequency tracking (for testing or daily reset)
  void resetAdFrequency();
}

/// Reward types available in the game
enum RewardType {
  extraLife('extra_life', 'Extra Life'),
  continueGame('continue_game', 'Continue Game'),
  doubleCoins('double_coins', '2x Coins'),
  premiumCurrency('premium_currency', 'Premium Coins'),
  unlockCharacter('unlock_character', 'Unlock Character');

  const RewardType(this.key, this.displayName);
  final String key;
  final String displayName;
}

/// Concrete implementation of AdService (placeholder for actual ad network)
class PlaceholderAdService implements AdService {
  static const int _maxAdsPerHour = 5;
  static const Duration _adCooldown = Duration(minutes: 10);

  final List<DateTime> _adTimestamps = [];
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    // Simulate initialization delay
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
    print('AdService initialized (placeholder)');
  }

  @override
  Future<bool> isRewardedAdAvailable() async {
    if (!_isInitialized) return false;
    // Simulate ad availability (90% success rate)
    await Future.delayed(const Duration(milliseconds: 100));
    return DateTime.now().millisecondsSinceEpoch % 10 != 0;
  }

  @override
  Future<bool> showRewardedAd({
    required String rewardType,
    required int rewardAmount,
    required Function(String type, int amount) onRewardEarned,
    required Function(String error) onAdFailed,
  }) async {
    if (!canShowAd()) {
      onAdFailed('Ad frequency limit reached');
      return false;
    }

    final available = await isRewardedAdAvailable();
    if (!available) {
      onAdFailed('No ad available');
      return false;
    }

    // Simulate ad watching (3-5 seconds)
    final adDuration = Duration(seconds: 3 + (DateTime.now().millisecondsSinceEpoch % 3));
    await Future.delayed(adDuration);

    // Simulate 95% success rate
    final success = DateTime.now().millisecondsSinceEpoch % 20 != 0;

    if (success) {
      recordAdShown();
      onRewardEarned(rewardType, rewardAmount);
      return true;
    } else {
      onAdFailed('Ad failed to load or was skipped');
      return false;
    }
  }

  @override
  Duration getTimeUntilNextAd() {
    if (_adTimestamps.isEmpty) return Duration.zero;

    final now = DateTime.now();
    final lastAd = _adTimestamps.last;
    final timeSinceLastAd = now.difference(lastAd);

    if (timeSinceLastAd >= _adCooldown) return Duration.zero;

    return _adCooldown - timeSinceLastAd;
  }

  @override
  bool canShowAd() {
    final now = DateTime.now();

    // Remove timestamps older than 1 hour
    _adTimestamps.removeWhere((timestamp) => now.difference(timestamp) > const Duration(hours: 1));

    return _adTimestamps.length < _maxAdsPerHour;
  }

  @override
  void recordAdShown() {
    _adTimestamps.add(DateTime.now());
  }

  @override
  void resetAdFrequency() {
    _adTimestamps.clear();
  }
}

/// Global ad service instance (replace with actual ad network implementation)
// This is now defined in main.dart to avoid circular imports
