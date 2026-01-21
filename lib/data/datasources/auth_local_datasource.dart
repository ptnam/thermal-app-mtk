import '../local/storage/token_cache_secure.dart';

class AuthLocalDataSource {
  final TokenCacheSecure _cache;

  AuthLocalDataSource(this._cache);

  Future<void> clearTokens() => _cache.clear();

  Future<bool> hasValidSession() => _cache.hasValidSession();
}

