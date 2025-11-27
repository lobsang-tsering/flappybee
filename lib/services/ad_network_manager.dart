import 'ad_service.dart';
import 'google_admob_service.dart';
import 'unity_ad_service.dart';

/// Ad network types
enum AdNetwork {
  googleAdMob,
  unity,
  placeholder, // For testing
}

/// Manages ad network switching
class AdNetworkManager {
  static AdNetwork _currentNetwork = AdNetwork.googleAdMob; // Default

  /// Set the active ad network
  static void setAdNetwork(AdNetwork network) {
    _currentNetwork = network;
  }

  /// Get the current ad network
  static AdNetwork get currentNetwork => _currentNetwork;

  /// Get the ad service instance for the current network
  static AdService getAdService() {
    switch (_currentNetwork) {
      case AdNetwork.googleAdMob:
        return GoogleAdMobService();
      case AdNetwork.unity:
        return UnityAdService();
      case AdNetwork.placeholder:
        return _createPlaceholderService();
    }
  }

  /// Switch to Google AdMob
  static void switchToAdMob() {
    setAdNetwork(AdNetwork.googleAdMob);
  }

  /// Switch to Unity Ads
  static void switchToUnity() {
    setAdNetwork(AdNetwork.unity);
  }

  /// Switch to placeholder for testing
  static void switchToPlaceholder() {
    setAdNetwork(AdNetwork.placeholder);
  }

  // Placeholder service for testing (same as before)
  static AdService _createPlaceholderService() {
    return PlaceholderAdService();
  }
}

// Placeholder implementation (moved here to avoid circular imports)
class PlaceholderAdService implements AdService {
  bool _isInitialized = false;
  bool _hasLoadedAd = false;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isInitialized = true;
    print('✅ Placeholder ad service initialized (ready for testing)');
  }

  @override
  Future<bool> isRewardedAdAvailable() async {
    if (!_isInitialized) {
      print('❌ Ad service not initialized');
      return false;
    }

    // Always simulate ad loading successfully
    if (!_hasLoadedAd) {
      print('🔄 Simulating ad load...');
      await Future.delayed(const Duration(seconds: 1)); // Shorter delay for always available
      _hasLoadedAd = true;
      print('✅ Test ad loaded successfully');
    }

    return _hasLoadedAd;
  }

  @override
  Future<bool> showRewardedAd({
    required String rewardType,
    required int rewardAmount,
    required Function(String type, int amount) onRewardEarned,
    required Function(String error) onAdFailed,
  }) async {
    if (!_isInitialized) {
      onAdFailed('Ad service not initialized');
      return false;
    }

    // No frequency check for placeholder
    if (!_hasLoadedAd) {
      onAdFailed('No ad available. Try again in a moment.');
      return false;
    }

    print('🎬 Showing test rewarded ad...');
    print('⏱️ Simulating 3-second ad experience...');

    // Simulate ad watching (3 seconds with progress updates)
    for (int i = 1; i <= 3; i++) {
      await Future.delayed(const Duration(seconds: 1));
      print('📺 Ad progress: ${i}/3 seconds');
    }

    // Always succeed for testing
    final success = true; 

    if (success) {
      _hasLoadedAd = false; // Reset for next ad
      print('✅ Test ad completed successfully!');
      print('🎁 Delivering reward: $rewardAmount $rewardType');
      onRewardEarned(rewardType, rewardAmount);
      return true;
    } else {
      print('❌ Test ad failed (should not happen with success=true)');
      onAdFailed('Ad failed (placeholder should always succeed)');
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
    // No frequency tracking for placeholder
    print('📊 Ad shown recorded (placeholder: no tracking)');
  }

  @override
  void resetAdFrequency() {
    // No frequency tracking for placeholder
    print('🔄 Ad frequency reset (placeholder: no tracking)');
  }
}
