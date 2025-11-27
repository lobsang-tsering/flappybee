import '../services/ad_network_manager.dart';

/// Configuration for ad network switching
class AdNetworkConfig {
  /// Set your preferred ad network here
  static void configureAdNetwork() {
    // Choose your ad network:

    // GOOGLE ADMOB TEST ADS - Real AdMob ads for testing
    AdNetworkManager.switchToAdMob();

    // FUTURE: Switch to AdMob when account approved AND SDK compatibility resolved
    // AdNetworkManager.switchToAdMob();

    // FUTURE: Switch to Unity when implemented
    // AdNetworkManager.switchToUnity();

    // The adService instance in main.dart will use this configuration
  }

  /// Get current ad network name for debugging
  static String getCurrentNetworkName() {
    switch (AdNetworkManager.currentNetwork) {
      case AdNetwork.googleAdMob:
        return 'Google AdMob';
      case AdNetwork.unity:
        return 'Unity Ads';
      case AdNetwork.placeholder:
        return 'Placeholder (Testing)';
    }
  }

  /// Quick network switching methods
  static void useAdMob() => AdNetworkManager.switchToAdMob();
  static void useUnity() => AdNetworkManager.switchToUnity();
  static void usePlaceholder() => AdNetworkManager.switchToPlaceholder();
}
