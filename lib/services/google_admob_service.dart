import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_service.dart';
import '../config/admob_config.dart';

/// Google AdMob implementation of AdService using Rewarded Ads
class GoogleAdMobService implements AdService {
  bool _isInitialized = false;
  RewardedAd? _rewardedAd;
  bool _isAdLoading = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize AdMob SDK
      await MobileAds.instance.initialize();

      // Set up targeting options with test devices
      final requestConfiguration = RequestConfiguration(
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.unspecified,
        testDeviceIds: AdMobConfig.testDeviceIds,
      );
      await MobileAds.instance.updateRequestConfiguration(requestConfiguration);

      _isInitialized = true;
      print(
        'Google AdMob service initialized with test devices: ${AdMobConfig.testDeviceIds}',
      );

      // Preload the first ad
      _loadRewardedAd();
    } catch (e) {
      print('Error initializing AdMob: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isRewardedAdAvailable() async {
    if (!_isInitialized) {
      print('AdMob not initialized');
      return false;
    }

    // Simply check if we have a loaded ad
    final hasAd = _rewardedAd != null;
    print('📊 Ad availability check: hasAd=$hasAd, isLoading=$_isAdLoading');

    // If we don't have an ad and we're not loading, try to load one
    if (!hasAd && !_isAdLoading) {
      print('No ad available and not loading, attempting to load...');
      _loadRewardedAd();
    }

    return hasAd;
  }

  @override
  Future<bool> showRewardedAd({
    required String rewardType,
    required int rewardAmount,
    required Function(String type, int amount) onRewardEarned,
    required Function(String error) onAdFailed,
  }) async {
    if (!_isInitialized) {
      onAdFailed('AdMob not initialized');
      return false;
    }

    if (!canShowAd()) {
      onAdFailed('Ad frequency limit reached');
      return false;
    }

    // Ensure we have a loaded ad
    if (_rewardedAd == null) {
      onAdFailed('No ad available');
      return false;
    }

    try {
      // Show the ad
      await _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          onRewardEarned(rewardType, rewardAmount);
        },
      );

      return true;
    } catch (e) {
      print('Error showing rewarded ad: $e');
      onAdFailed('Failed to show ad: $e');
      return false;
    }
  }

  Future<bool> _loadRewardedAd() async {
    if (_isAdLoading) {
      print('⏳ Ad already loading, skipping...');
      return false;
    }

    if (_rewardedAd != null) {
      print('✅ Ad already loaded, skipping...');
      return true;
    }

    _isAdLoading = true;

    try {
      final adUnitId = AdMobConfig.rewardedInterstitialUnitId;
      print('🔄 Loading rewarded ad with unit ID: $adUnitId');

      await RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            _rewardedAd = ad;
            _isAdLoading = false;
            print('✅ Rewarded ad loaded successfully');

            // Set up ad event callbacks
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                print('📺 Ad showed fullscreen content');
              },
              onAdDismissedFullScreenContent: (ad) {
                print('❌ Ad dismissed fullscreen content');
                ad.dispose();
                _rewardedAd = null;
                // Load next ad after a short delay
                Future.delayed(const Duration(seconds: 1), () {
                  _loadRewardedAd();
                });
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                print('❌ Ad failed to show fullscreen content: $error');
                ad.dispose();
                _rewardedAd = null;
                _isAdLoading = false;
              },
              onAdImpression: (ad) {
                print('👀 Ad impression recorded');
              },
              onAdClicked: (ad) {
                print('👆 Ad clicked');
              },
            );
          },
          onAdFailedToLoad: (LoadAdError error) {
            _isAdLoading = false;
            print('❌ Rewarded ad failed to load:');
            print('  Code: ${error.code}');
            print('  Domain: ${error.domain}');
            print('  Message: ${error.message}');
            print('  Ad unit ID: $adUnitId');

            // Retry loading after a delay
            Future.delayed(AdMobConfig.retryDelay, () {
              if (!_isAdLoading && _rewardedAd == null) {
                _loadRewardedAd();
              }
            });
          },
        ),
      );

      return true;
    } catch (e) {
      _isAdLoading = false;
      print('❌ Exception loading rewarded ad: $e');
      return false;
    }
  }

  @override
  Duration getTimeUntilNextAd() {
    return Duration.zero;
  }

  @override
  bool canShowAd() {
    return true;
  }

  @override
  void recordAdShown() {
    // No frequency tracking for AdMob, always available
  }

  @override
  void resetAdFrequency() {
    // No frequency tracking for AdMob, always available
  }

  /// Clean up resources
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
