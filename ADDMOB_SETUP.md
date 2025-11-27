# Google AdMob Setup Guide

## 🚀 Quick Setup

### 1. Get Your AdMob IDs

1. Go to [AdMob Console](https://admob.google.com)
2. Create/select your app
3. Create a **Rewarded Interstitial** ad unit
4. Note down your **App ID** and **Ad Unit ID**

### 2. Update Configuration Files

#### A. Update `lib/config/admob_config.dart`
```dart
class AdMobConfig {
  // Replace with your actual App ID
  static const String appId = 'ca-app-pub-1234567890123456~1234567890';

  // Replace with your actual Rewarded Interstitial Ad Unit ID
  static const String rewardedInterstitialAdUnitId = 'ca-app-pub-1234567890123456/1234567890';
}
```

#### B. Update `android/app/src/main/AndroidManifest.xml`
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-1234567890123456~1234567890"/>
```

#### C. Update `ios/Runner/Info.plist`
```xml
<!-- Add this key-value pair inside the <dict> tag -->
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-1234567890123456~1234567890</string>
```

### 3. Switch to Production Mode

Once testing is complete, update the `rewardedInterstitialUnitId` getter in `admob_config.dart`:

```dart
static String get rewardedInterstitialUnitId {
  return rewardedInterstitialAdUnitId; // Use production ID
}
```

## 📋 Your AdMob IDs

- **App ID**: `ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX` (used for both Android & iOS)
- **Rewarded Interstitial Unit ID**: `ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX`

## 🧪 Testing

### **Current Setup: Placeholder Ads (Active)**
The app is currently using **placeholder ads** for development and testing. These ads:
- ✅ **Always work** - No network issues or account approvals needed
- ✅ **Safe for development** - No AdMob policy violations
- ✅ **Real ad behavior** - Same user experience and functionality
- ✅ **Detailed logging** - Perfect for testing reward systems

### **Why Placeholder Ads?**
Google AdMob test ads were experiencing format compatibility issues. Placeholder ads provide the exact same testing experience with guaranteed reliability.

### **Google's Official Test Ad Units:**
- **Rewarded** (Currently Used): `ca-app-pub-3940256099942544/5354046379`
- **Rewarded Interstitial**: `ca-app-pub-3940256099942544/5224354917` (Alternative)
- **Interstitial**: `ca-app-pub-3940256099942544/4411468910`
- **Banner**: `ca-app-pub-3940256099942544/6300978111`

### **Switching Ad Networks for Testing:**

#### **Use Google Test Ads (Current - Recommended):**
```dart
// In lib/config/ad_network_config.dart
AdNetworkManager.switchToAdMob();
```

#### **Use Placeholder Ads (If Test Ads Don't Work):**
```dart
// In lib/config/ad_network_config.dart
AdNetworkManager.switchToPlaceholder();
```

#### **Use Unity Ads (When Implemented):**
```dart
// In lib/config/ad_network_config.dart
AdNetworkManager.switchToUnity();
```

### **Troubleshooting Test Ads:**

#### **If Test Ads Don't Load:**
1. **Check Network**: Test ads require internet connection
2. **Try Different Test Unit**: Switch to regular rewarded test ad:
   ```dart
   // In admob_config.dart, change:
   return testRewardedInterstitialAdUnitId;
   // To:
   return testRewardedAdUnitId;
   ```

3. **Use Placeholder Ads**: Guaranteed to work offline
4. **Check Device Logs**: Look for detailed error messages

#### **Expected Test Ad Behavior:**
- Shows "Test Ad" label
- Always loads successfully
- Provides real reward functionality
- No actual monetization

**Restart the app after changing any configuration.**

## ⚠️ Account Approval Required

### **Current Status: Account Not Approved Yet**
Your AdMob account needs approval before serving real ads. You'll see this error:
```
Account not approved yet. https://support.google.com/admob/answer/9905175#1
```

### **What to Do:**
1. **Complete Account Setup**: Follow all steps in AdMob console
2. **Wait for Approval**: Usually takes 24-48 hours
3. **Check Status**: Visit [AdMob Console](https://admob.google.com) regularly
4. **Switch to Production**: Once approved, change in `admob_config.dart`:
   ```dart
   return rewardedInterstitialAdUnitId; // Use production ads
   ```

## ⚠️ Important Notes

1. **Use test ads during development** - prevents policy violations
2. **Test on real devices** - emulators may not show ads properly
3. **Wait for account approval** before using production ad units
4. **Monitor approval status** in AdMob console

## 🔍 Troubleshooting

- **Ads not showing**: Check internet connection and wait for ad units to be active
- **Invalid requests**: Ensure App ID and Unit IDs are correct
- **Build errors**: Make sure `google_mobile_ads: ^5.1.0` is in `pubspec.yaml`

## 📞 Support

- [AdMob Help Center](https://support.google.com/admob)
- [Flutter AdMob Documentation](https://pub.dev/packages/google_mobile_ads)
