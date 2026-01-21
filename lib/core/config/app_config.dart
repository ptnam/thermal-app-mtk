/// App configuration and environment settings
abstract class AppConfig {
  String get apiBaseUrl;
  String get streamUrl;
  String get appName;
  bool get enableLogging;
  bool get enableLogBody;
  Duration get connectTimeout;
  Duration get receiveTimeout;
  
  bool get isProduction;
  bool get isDebug;
}

/// Development configuration
class DevConfig implements AppConfig {
  @override
  String get apiBaseUrl => 'https://thermal.infosysvietnam.com.vn:10253';
  
  @override
  String get streamUrl => 'https://thermal.infosysvietnam.com.vn:1984/api/stream.m3u8?src=';
  
  @override
  String get appName => 'Camera Vision (Dev)';
  
  @override
  bool get enableLogging => true;
  
  @override
  bool get enableLogBody => true;
  
  @override
  Duration get connectTimeout => const Duration(seconds: 30);
  
  @override
  Duration get receiveTimeout => const Duration(seconds: 30);
  
  @override
  bool get isProduction => false;
  
  @override
  bool get isDebug => true;
}

/// Production configuration
class ProdConfig implements AppConfig {
  @override
  String get apiBaseUrl => 'https://thermal.infosysvietnam.com.vn:10253';
  
  @override
  String get streamUrl => 'https://thermal.infosysvietnam.com.vn:1984/api/stream.m3u8?src=';
  
  @override
  String get appName => 'Camera Vision';
  
  @override
  bool get enableLogging => false;
  
  @override
  bool get enableLogBody => false;
  
  @override
  Duration get connectTimeout => const Duration(seconds: 15);
  
  @override
  Duration get receiveTimeout => const Duration(seconds: 15);
  
  @override
  bool get isProduction => true;
  
  @override
  bool get isDebug => false;
}

/// Staging configuration
class StagingConfig implements AppConfig {
  @override
  String get apiBaseUrl => 'https://thermal.infosysvietnam.com.vn:10253';
  
  @override
  String get streamUrl => 'https://thermal.infosysvietnam.com.vn:1984/api/stream.m3u8?src=';
  
  @override
  String get appName => 'Camera Vision (Staging)';
  
  @override
  bool get enableLogging => true;
  
  @override
  bool get enableLogBody => false;
  
  @override
  Duration get connectTimeout => const Duration(seconds: 25);
  
  @override
  Duration get receiveTimeout => const Duration(seconds: 25);
  
  @override
  bool get isProduction => false;
  
  @override
  bool get isDebug => false;
}

/// Config provider — returns appropriate config based on build flavor
class ConfigProvider {
  static AppConfig getConfig({String flavor = 'dev'}) {
    switch (flavor.toLowerCase()) {
      case 'prod':
      case 'production':
        return ProdConfig();
      case 'staging':
        return StagingConfig();
      case 'dev':
      default:
        return DevConfig();
    }
  }
}
