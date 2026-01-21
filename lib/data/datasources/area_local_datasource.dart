import '../../../core/logger/app_logger.dart';
import '../local/storage/token_cache_secure.dart';

/// Local data source for Area
/// Responsible for retrieving cached tokens for authorization
class AreaLocalDataSource {
  final TokenCacheAdapter _tokenCache;
  final AppLogger _logger;

  AreaLocalDataSource(
    this._tokenCache, {
    AppLogger? logger,
  }) : _logger = logger ?? AppLogger(tag: 'AreaLocalDataSource');

  /// Get cached access token for API authorization
  /// Returns null if no valid session exists
  Future<String?> getAccessToken() async {
    try {
      final tokens = await _tokenCache.read();
      if (tokens == null || tokens.accessToken.isEmpty) {
        _logger.warning('No valid access token found');
        return null;
      }
      return tokens.accessToken;
    } catch (e, st) {
      _logger.error('Failed to get access token', error: e, stackTrace: st);
      return null;
    }
  }

  /// Check if there's a valid cached session
  Future<bool> hasValidSession() async {
    try {
      return await _tokenCache.hasValidSession();
    } catch (e, st) {
      _logger.error('Failed to check session', error: e, stackTrace: st);
      return false;
    }
  }
}
