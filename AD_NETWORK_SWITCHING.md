# Ad Network Switching Guide

## 🎯 SOLID Architecture Benefits

The ad system is built with SOLID principles for maximum flexibility:

### ✅ Single Responsibility
- `AdService` interface: Only defines ad operations
- `GoogleAdMobService`: Only handles AdMob-specific logic
- `AdButton`: Only manages ad button UI
- Each class has one clear purpose

### ✅ Open/Closed
- New ad networks can be added without modifying existing code
- Just implement `AdService` interface
- Main app and UI remain unchanged

### ✅ Liskov Substitution
- Any `AdService` implementation can replace another seamlessly
- `GoogleAdMobService` and `UnityAdService` are interchangeable

### ✅ Interface Segregation
- `AdService` interface is focused and minimal
- No forced dependencies on unused methods

### ✅ Dependency Inversion
- Main app depends on `AdService` abstraction, not concrete implementations
- Easy to switch networks without touching business logic

## 🔄 Switching Ad Networks

### Method 1: Quick Switch (Recommended)

Edit `lib/config/ad_network_config.dart`:

```dart
static void configureAdNetwork() {
  // Change this line to switch networks:

  // For Google AdMob
  AdNetworkManager.switchToAdMob();

  // For Unity Ads (when ready)
  // AdNetworkManager.switchToUnity();

  // For testing/placeholder
  // AdNetworkManager.switchToPlaceholder();
}
```

### Method 2: Runtime Switch

Call anywhere in your code:

```dart
// Switch to Unity Ads
AdNetworkManager.switchToUnity();

// Switch back to AdMob
AdNetworkManager.switchToAdMob();
```

### Method 3: Direct Replacement

In `lib/main.dart`, change the adService instance:

```dart
// Instead of:
final AdService adService = AdNetworkManager.getAdService();

// Use directly:
final AdService adService = UnityAdService(); // For Unity
// or
final AdService adService = GoogleAdMobService(); // For AdMob
```

## 🚀 Adding New Ad Networks

1. **Create new service class:**
```dart
class NewAdNetworkService implements AdService {
  // Implement all AdService methods
  // Follow the same pattern as GoogleAdMobService
}
```

2. **Add to AdNetworkManager:**
```dart
enum AdNetwork {
  googleAdMob,
  unity,
  newNetwork, // Add here
  placeholder,
}

// In getAdService():
case AdNetwork.newNetwork:
  return NewAdNetworkService();
```

3. **Add switching method:**
```dart
static void switchToNewNetwork() {
  setAdNetwork(AdNetwork.newNetwork);
}
```

## 📋 Network-Specific Setup

### Google AdMob ✅ (Current)
- ✅ Config: `lib/config/admob_config.dart`
- ✅ Service: `lib/services/google_admob_service.dart`
- ✅ Android manifest updated
- 🔄 **Status**: Ready (using test IDs)

### Unity Ads 🔄 (Prepared)
- ✅ Service skeleton: `lib/services/unity_ad_service.dart`
- ❌ Dependency: Add `unity_ads_plugin` to pubspec.yaml
- ❌ Config: Create Unity config file
- ❌ iOS/Android setup: Add Unity App ID to manifests

### Any Ad Network 🔄 (Template Ready)
- ✅ Interface: `AdService` ready
- ✅ Architecture: SOLID compliant
- ✅ UI: `AdButton` works with any implementation
- ✅ Integration: 1-line change to switch

## 🧪 Testing Different Networks

```dart
// Test with placeholder (no real ads)
AdNetworkManager.switchToPlaceholder();

// Test with AdMob test ads
AdNetworkManager.switchToAdMob();

// Test with Unity (when implemented)
AdNetworkManager.switchToUnity();
```

## ⚡ Implementation Speed

**Switching between networks: 30 seconds**
1. Change one line in `ad_network_config.dart`
2. Rebuild app
3. Done!

**Adding new network: 10-15 minutes**
1. Implement `AdService` interface
2. Add to `AdNetworkManager`
3. Test integration
4. Done!

## 🎯 Why This Architecture Works

- **Zero breaking changes** when switching networks
- **Same UI/UX** regardless of ad network
- **Same reward system** works everywhere
- **Easy A/B testing** between networks
- **Future-proof** for new ad networks

The SOLID architecture ensures your ad system is as flexible as possible while maintaining clean, maintainable code.

