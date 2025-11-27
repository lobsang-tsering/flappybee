import 'ad_service.dart';
import 'ad_network_manager.dart';

/// Global ad service instance
/// This separates the instance from main.dart for better architecture
final AdService adService = AdNetworkManager.getAdService();

