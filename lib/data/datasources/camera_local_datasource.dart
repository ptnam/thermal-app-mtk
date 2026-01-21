import '../../core/logger/app_logger.dart';
import '../local/storage/token_cache_secure.dart';

/// Local data source for Camera Stream
/// Responsible for retrieving cached tokens for authorization
class CameraLocalDataSource {
  final TokenCacheAdapter tokenStorage;
  final AppLogger logger;

  CameraLocalDataSource({
    required this.tokenStorage,
    required this.logger,
  });

  /// Get cached access token for API authorization
  /// Returns null if no valid session exists
  Future<String?> getAccessToken() async {
    try {
      final tokens = await tokenStorage.read();
      
      if (tokens == null || tokens.accessToken.isEmpty) {
        logger.warning('CameraLocalDataSource: No valid access token found');
        return null;
      }
      
      
      return tokens.accessToken;
    } catch (e, st) {
      logger.error('CameraLocalDataSource: Failed to get access token', error: e, stackTrace: st);
      return null;
    }
  }

  /// Check if there's a valid cached session
  Future<bool> hasValidSession() async {
    try {
      return await tokenStorage.hasValidSession();
    } catch (e, st) {
      logger.error('CameraLocalDataSource: Failed to check session', error: e, stackTrace: st);
      return false;
    }
  }
}
