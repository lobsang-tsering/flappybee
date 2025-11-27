/// Google AdMob configuration
class AdMobConfig {
  // 🔴 IMPORTANT: Replace with your actual AdMob App ID from AdMob console
  // This should be in format: ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX
  // Used for both Android (AndroidManifest.xml) and iOS (Info.plist)
  static const String appId = 'ca-app-pub-8210268149200707~9765054814';

  // 🔴 IMPORTANT: Replace with your actual Rewarded Interstitial Ad Unit ID
  // This should be in format: ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX
  static const String rewardedInterstitialAdUnitId =
      'ca-app-pub-8210268149200707/1726890492';

  // Official Google Test Ad Unit IDs for development (always work, safe to use)
  // Currently using regular Rewarded ads (more reliable than Rewarded Interstitial)
  static const String testRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5354046379'; // Currently used

  // Alternative test ad units (for different ad formats):
  static const String testRewardedInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/5224354917'; // Alternative
  static const String testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/4411468910'; // Interstitial
  static const String testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111'; // Banner

  // Environment-based ad unit selection
  static String get rewardedInterstitialUnitId {
    // GOOGLE ADMOB TEST ADS - Official test units from Google
    // These provide REAL visual ads for development testing
    // TODO: Switch to production when AdMob account approved
    // For production (after approval): return rewardedInterstitialAdUnitId;
    // For development testing: return testRewardedAdUnitId

    return testRewardedInterstitialAdUnitId; // Using official Google test ads
  }

  // Test device IDs for development (add your device IDs here)
  // To find your device ID, check AdMob console logs or use:
  // AdMob SDK will log: "To get test ads on this device, call: request.testDevices = [DEVICE_ID]"
  static const List<String> testDeviceIds = [
    // Your iPhone device ID (automatically detected by AdMob)
    '83ad0923d8a935645c9aa37b716321ab',
    // Add more test device IDs here as needed
  ];

  // Ad request configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  static const Duration adLoadTimeout = Duration(seconds: 10);
}
