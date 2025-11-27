import 'dart:async';

import 'ad_service.dart';

// Placeholder implementation (moved here to avoid circular imports)
class UnityAdService implements AdService {
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isInitialized = true;
    print('Unity Ads service placeholder initialized');
  }

  @override
  Future<bool> isRewardedAdAvailable() async {
    if (!_isInitialized) return false;
    await Future.delayed(const Duration(milliseconds: 100));
    return true; // Always available
  }

  @override
  Future<bool> showRewardedAd({
    required String rewardType,
    required int rewardAmount,
    required Function(String type, int amount) onRewardEarned,
    required Function(String error) onAdFailed,
  }) async {
    // No frequency check for UnityAdService
    if (!_isInitialized) {
      onAdFailed('Unity Ads service not initialized');
      return false;
    }

    await Future.delayed(const Duration(seconds: 3));
    final success = true; // Always succeed

    if (success) {
      onRewardEarned(rewardType, rewardAmount);
      return true;
    } else {
      onAdFailed('Ad failed to load or was skipped (should not happen with success=true)');
      return false;
    }
  }

  @override
  Duration getTimeUntilNextAd() {
    return Duration.zero; // Always available
  }

  @override
  bool canShowAd() {
    return true; // Always available
  }

  @override
  void recordAdShown() {
    // No frequency tracking for UnityAdService
  }

  @override
  void resetAdFrequency() {
    // No frequency tracking for UnityAdService
  }
}
