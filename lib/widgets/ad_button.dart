import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../services/ad_service.dart';
import '../services/ad_service_instance.dart';

/// Rewarded ad button widget following best practices
class AdButton extends StatefulWidget {
  final RewardType rewardType;
  final int rewardAmount;
  final String? customTitle;
  final String? customSubtitle;
  final VoidCallback? onRewardEarned;
  final VoidCallback? onAdFailed;
  final bool showFrequencyInfo;

  const AdButton({
    super.key,
    required this.rewardType,
    required this.rewardAmount,
    this.customTitle,
    this.customSubtitle,
    this.onRewardEarned,
    this.onAdFailed,
    this.showFrequencyInfo = false,
  });

  @override
  State<AdButton> createState() => _AdButtonState();
}

class _AdButtonState extends State<AdButton> with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _isAvailable = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _checkAvailability();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAvailability() async {
    print('🔍 Checking ad availability...');
    final available = await adService.isRewardedAdAvailable();
    print('📊 Ad availability: $available');
    if (mounted) {
      setState(() => _isAvailable = available);
    }
  }

  Future<void> _showAd() async {
    if (!adService.canShowAd()) {
      _showFrequencyLimitDialog();
      return;
    }

    setState(() => _isLoading = true);

    final success = await adService.showRewardedAd(
      rewardType: widget.rewardType.key,
      rewardAmount: widget.rewardAmount,
      onRewardEarned: (type, amount) {
        widget.onRewardEarned?.call();
      },
      onAdFailed: (error) {
        _showErrorDialog(error);
        widget.onAdFailed?.call();
      },
    );

    if (mounted) {
      setState(() => _isLoading = false);
      await _checkAvailability();
    }
  }

  void _showFrequencyLimitDialog() {
    final timeUntilNext = adService.getTimeUntilNextAd();
    final minutes = timeUntilNext.inMinutes;
    final seconds = timeUntilNext.inSeconds % 60;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Too Many Ads'),
        content: Text(
          'You can watch another ad in ${minutes}m ${seconds}s.\n\n'
          'This helps maintain a great gaming experience!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ad Unavailable'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getRewardDisplayName(String type) {
    switch (type) {
      case 'extra_life':
        return 'Extra Lives';
      case 'continue_game':
        return 'Continues';
      case 'double_coins':
        return 'Coins (2x Multiplier)';
      case 'premium_currency':
        return 'Premium Coins';
      case 'unlock_character':
        return 'Character Unlocks';
      default:
        return 'Rewards';
    }
  }

  IconData _getRewardIcon() {
    switch (widget.rewardType) {
      case RewardType.extraLife:
        return LucideIcons.heart;
      case RewardType.continueGame:
        return LucideIcons.play;
      case RewardType.doubleCoins:
        return LucideIcons.coins;
      case RewardType.premiumCurrency:
        return LucideIcons.crown;
      case RewardType.unlockCharacter:
        return LucideIcons.user;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canShowAd = adService.canShowAd();
    final adAvailable = _isAvailable;
    final canShow = canShowAd && adAvailable;
    final timeUntilNext = adService.getTimeUntilNextAd();

    // Debug info
    print('🎯 Ad Button State - Can Show Ad: $canShowAd, Ad Available: $adAvailable, Final: $canShow');

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: canShow
              ? const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFFCCCCCC), Color(0xFFAAAAAA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: canShow ? Colors.amber.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child:           InkWell(
            onTap: canShow && !_isLoading ? _showAd : null,
            onLongPress: _checkAvailability, // Long press to refresh availability
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getRewardIcon(),
                        color: canShow ? Colors.white : Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.customTitle ?? 'Watch Ad',
                              style: GoogleFonts.vt323(
                                fontSize: 16,
                                color: canShow ? Colors.white : Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.customSubtitle ??
                                  '${widget.rewardAmount} ${_getRewardDisplayName(widget.rewardType.key)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: canShow ? Colors.white.withOpacity(0.9) : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      else
                        Icon(
                          LucideIcons.play,
                          color: canShow ? Colors.white : Colors.grey[600],
                          size: 16,
                        ),
                    ],
                  ),
                  if (widget.showFrequencyInfo && !canShow) ...[
                    const SizedBox(height: 8),
                    Text(
                      timeUntilNext.inMinutes > 0
                          ? 'Next ad in ${timeUntilNext.inMinutes}m ${timeUntilNext.inSeconds % 60}s'
                          : 'Ad unavailable',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
