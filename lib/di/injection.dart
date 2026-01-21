import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'dart:io';

import '../core/config/app_config.dart';
import '../core/logger/app_logger.dart';
import '../data/local/storage/secure_token_storage.dart';
import '../data/local/storage/token_cache_secure.dart';

// API Services
import '../data/network/core/api_client.dart';
import '../data/network/core/base_url_provider.dart';
import '../data/network/auth/auth_api_service.dart';
import '../data/network/area/area_api_service.dart';
import '../data/network/camera/camera_api_service.dart';
import '../data/network/camera/camera_stream_api_service.dart';
import '../data/network/notification/notification_api_service.dart';
import '../data/network/user/user_api_service.dart';
import '../data/network/machine/machine_api_service.dart';
import '../data/network/sensor/sensor_api_service.dart';
import '../data/network/role/role_api_service.dart';
import '../data/network/thermal_data/thermal_data_api_service.dart';

// Repository Implementations
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/area_repository_impl.dart';
import '../data/repositories/camera_repository_impl.dart';
import '../data/repositories/notification_repository_impl.dart';
import '../data/repositories/user_repository_impl.dart';
import '../data/repositories/machine_repository_impl.dart';
import '../data/repositories/sensor_repository_impl.dart';
import '../data/repositories/role_repository_impl.dart';
import '../data/repositories/thermal_data_repository_impl.dart';

// Domain Repositories
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/area_repository.dart';
import '../domain/repositories/camera_repository.dart';
import '../domain/repositories/notification_repository.dart';
import '../domain/repositories/user_repository.dart';
import '../domain/repositories/machine_repository.dart';
import '../domain/repositories/sensor_repository.dart';
import '../domain/repositories/role_repository.dart';
import '../domain/repositories/thermal_data_repository.dart';

// Data Sources (legacy - may be removed later)
import '../data/datasources/area_remote_datasource.dart';
import '../data/datasources/area_local_datasource.dart';
import '../data/datasources/notification_remote_datasource.dart';
import '../data/datasources/camera_remote_datasource.dart';
import '../data/datasources/camera_local_datasource.dart';

// Use Cases
import '../domain/usecase/area_usecase.dart';
import '../domain/usecase/camera_usecase.dart';
import '../domain/usecase/notification_usecase.dart';

// BLoCs
import '../presentation/bloc/area/area_bloc.dart';
import '../presentation/bloc/camera/camera_stream_bloc.dart';
import '../presentation/bloc/notification/notification_bloc.dart';
import '../presentation/bloc/user/user_bloc.dart';
import '../presentation/bloc/machine/machine_bloc.dart';
import '../presentation/bloc/sensor/sensor_bloc.dart';
import '../presentation/bloc/role/role_bloc.dart';
import '../presentation/bloc/thermal_data/thermal_data_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (!getIt.isRegistered<bool>(instanceName: 'initialized')) {
    getIt.registerSingleton<bool>(true, instanceName: 'initialized');
  } else {
    return;
  }

  // Register config (environment-based)
  // Auto-detect: release builds use prod, debug builds use dev (or custom via FLAVOR)
  const customFlavor = String.fromEnvironment('FLAVOR', defaultValue: '');
  final flavor = customFlavor.isNotEmpty
      ? customFlavor
      : (kDebugMode ? 'dev' : 'prod');
  final config = ConfigProvider.getConfig(flavor: flavor);
  getIt.registerSingleton<AppConfig>(config);

  // Register logger
  getIt.registerSingleton<AppLogger>(
    AppLogger(
      tag: 'FlutterVision',
      enableLogging: config.enableLogging,
      enableLogBody: config.enableLogBody,
    ),
  );

  _registerNetworkLayer();
  _registerLocalLayer();
  _registerRepositories();
  _registerUseCases();
  _registerBlocs();

  // TODO: Uncomment when API layer is ready
  // Register all API layer dependencies
  // (UserApiService, MachineApiService, SensorApiService, ThermalDataApiService, etc.)
  // registerAllApiDependencies();
}

void _registerNetworkLayer() {
  final config = getIt<AppConfig>();
  final logger = getIt<AppLogger>();

  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: config.connectTimeout,
        sendTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
      ),
    );

    // Configure HttpClientAdapter to handle self-signed certificates on physical devices
    // This is necessary because physical devices validate SSL certificates strictly
    // while emulators may not enforce this
    try {
      final adapter = dio.httpClientAdapter;
      if (adapter is IOHttpClientAdapter) {
        adapter.onHttpClientCreate = (HttpClient client) {
          // WARNING: This disables certificate checks. Only use for development
          // with trusted internal servers. Do NOT enable in production.
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) {
                // Allow the internal domain or allow in debug mode
                return host == 'thermal.infosysvietnam.com.vn' || kDebugMode;
              };
          return client;
        };
        logger.info(
          'Configured IOHttpClientAdapter.badCertificateCallback for development',
        );
      }
    } catch (e) {
      logger.warning('Could not configure HTTP client adapter: $e');
    }

    // Note: Logging interceptor disabled for security (no request/response body logging)
    // Errors are logged via ApiClient only, not request bodies

    return dio;
  });

  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(getIt<Dio>(), logger: logger),
  );

  getIt.registerLazySingleton<BaseUrlProvider>(
    () => StaticBaseUrlProvider(config.apiBaseUrl),
  );

  // Auth API Service
  getIt.registerLazySingleton<AuthApiService>(
    () => AuthApiService(
      getIt<ApiClient>(),
      getIt<BaseUrlProvider>(),
      logger: logger,
    ),
  );

  // Area API Service
  getIt.registerLazySingleton<AreaApiService>(
    () => AreaApiService(
      getIt<ApiClient>(),
      getIt<BaseUrlProvider>(),
      logger: logger,
    ),
  );

  // Camera Stream API Service
  getIt.registerLazySingleton<CameraStreamApiService>(
    () => CameraStreamApiService(
      getIt<ApiClient>(),
      getIt<BaseUrlProvider>(),
      logger: logger,
    ),
  );

  // Camera API Service (for CRUD operations)
  getIt.registerLazySingleton<CameraApiService>(
    () => CameraApiService(
      getIt<ApiClient>(),
      getIt<BaseUrlProvider>(),
      logger: logger,
    ),
  );

  // Notification API Service
  getIt.registerLazySingleton<NotificationApiService>(
    () => NotificationApiService(
      getIt<ApiClient>(),
      getIt<BaseUrlProvider>(),
      logger: logger,
    ),
  );

  // User API Service
  getIt.registerLazySingleton<UserApiService>(
    () => UserApiService(
      getIt<ApiClient>(),
      getIt<BaseUrlProvider>(),
      logger: logger,
    ),
  );

  // Machine API Service
  getIt.registerLazySingleton<MachineApiService>(
    () => MachineApiService(
      getIt<ApiClient>(),
      getIt<BaseUrlProvider>(),
      logger: logger,
    ),
  );

  // Sensor API Service
  getIt.registerLazySingleton<SensorApiService>(
    () => SensorApiService(
      getIt<ApiClient>(),
      getIt<BaseUrlProvider>(),
      logger: logger,
    ),
  );

  // Role API Service
  getIt.registerLazySingleton<RoleApiService>(
    () => RoleApiService(
      getIt<ApiClient>(),
      getIt<BaseUrlProvider>(),
      logger: logger,
    ),
  );

  // Thermal Data API Service
  getIt.registerLazySingleton<ThermalDataApiService>(
    () => ThermalDataApiService(
      getIt<ApiClient>(),
      getIt<BaseUrlProvider>(),
      logger: logger,
    ),
  );
}

// ---------------------------
// LOCAL LAYER
// ---------------------------
void _registerLocalLayer() {
  final logger = getIt<AppLogger>();

  // Register token storage backend (using SecureTokenStorage)
  getIt.registerLazySingleton<TokenStorage>(
    () => SecureTokenStorage(logger: logger),
  );

  // Local token cache adapter (uses injected TokenStorage backend)
  getIt.registerLazySingleton<TokenCacheAdapter>(
    () => TokenCacheAdapter(getIt<TokenStorage>(), logger: logger),
  );
}

// ---------------------------
// REPOSITORIES
// ---------------------------
void _registerRepositories() {
  // Auth Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authApiService: getIt<AuthApiService>(),
      secureStorage: const FlutterSecureStorage(),
    ),
  );

  // Helper function to get access token from AuthRepository
  Future<String> getAccessToken() async {
    final authRepo = getIt<AuthRepository>();
    final tokens = await authRepo.read();
    return tokens?.accessToken ?? '';
  }

  // Area Repository
  getIt.registerLazySingleton<AreaRepository>(
    () => AreaRepositoryImpl(
      areaApiService: getIt<AreaApiService>(),
      getAccessToken: getAccessToken,
    ),
  );

  // Camera Repository
  getIt.registerLazySingleton<CameraRepository>(
    () => CameraRepositoryImpl(
      cameraStreamApiService: getIt<CameraStreamApiService>(),
      getAccessToken: getAccessToken,
    ),
  );

  // Notification Repository
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      notificationApiService: getIt<NotificationApiService>(),
      getAccessToken: getAccessToken,
    ),
  );

  // User Repository
  getIt.registerLazySingleton<IUserRepository>(
    () => UserRepositoryImpl(
      userApiService: getIt<UserApiService>(),
      getAccessToken: getAccessToken,
    ),
  );

  // Machine Repository
  getIt.registerLazySingleton<IMachineRepository>(
    () => MachineRepositoryImpl(
      machineApiService: getIt<MachineApiService>(),
      getAccessToken: getAccessToken,
    ),
  );

  // Sensor Repository
  getIt.registerLazySingleton<ISensorRepository>(
    () => SensorRepositoryImpl(
      sensorApiService: getIt<SensorApiService>(),
      getAccessToken: getAccessToken,
    ),
  );

  // Role Repository
  getIt.registerLazySingleton<IRoleRepository>(
    () => RoleRepositoryImpl(
      roleApiService: getIt<RoleApiService>(),
      getAccessToken: getAccessToken,
    ),
  );

  // Thermal Data Repository
  getIt.registerLazySingleton<IThermalDataRepository>(
    () => ThermalDataRepositoryImpl(
      thermalDataApiService: getIt<ThermalDataApiService>(),
      getAccessToken: getAccessToken,
    ),
  );

  // Legacy Data Sources (may be removed when all repos use new implementation)
  final logger = getIt<AppLogger>();

  // Area Remote Data Source
  getIt.registerLazySingleton<AreaRemoteDataSource>(
    () => AreaRemoteDataSource(getIt<AreaApiService>(), logger: logger),
  );

  // Area Local Data Source
  getIt.registerLazySingleton<AreaLocalDataSource>(
    () => AreaLocalDataSource(getIt<TokenCacheAdapter>(), logger: logger),
  );

  // Camera Local Data Source
  getIt.registerLazySingleton<CameraLocalDataSource>(
    () => CameraLocalDataSource(
      tokenStorage: getIt<TokenCacheAdapter>(),
      logger: logger,
    ),
  );

  // Camera Remote Data Source
  getIt.registerLazySingleton<CameraRemoteDataSource>(
    () => CameraRemoteDataSource(
      apiService: getIt<CameraStreamApiService>(),
      localDataSource: getIt<CameraLocalDataSource>(),
      errorMapper: null,
      logger: logger,
    ),
  );

  // Notification Remote Data Source
  getIt.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSource(
      apiService: getIt<NotificationApiService>(),
      tokenCache: getIt<TokenCacheAdapter>(),
      logger: logger,
    ),
  );
}

// ---------------------------
// USE CASES
// ---------------------------
void _registerUseCases() {
  // Area Use Cases
  getIt.registerLazySingleton<GetAreaTreeWithCamerasUseCase>(
    () => GetAreaTreeWithCamerasUseCase(getIt<AreaRepository>()),
  );

  getIt.registerLazySingleton<GetAreaByIdUseCase>(
    () => GetAreaByIdUseCase(getIt<AreaRepository>()),
  );

  // Camera Use Cases
  getIt.registerLazySingleton<GetCameraStreamUseCase>(
    () => GetCameraStreamUseCase(getIt<CameraRepository>()),
  );

  // Notification Use Cases
  getIt.registerLazySingleton<GetNotificationsUseCase>(
    () => GetNotificationsUseCase(getIt<NotificationRepository>()),
  );

  getIt.registerLazySingleton<GetNotificationDetailUseCase>(
    () => GetNotificationDetailUseCase(getIt<NotificationRepository>()),
  );
}

// ---------------------------
// BLOCS
// ---------------------------
void _registerBlocs() {
  final logger = getIt<AppLogger>();

  // Area BLoC
  getIt.registerLazySingleton<AreaBloc>(
    () => AreaBloc(
      getAreaTreeUseCase: getIt<GetAreaTreeWithCamerasUseCase>(),
      getAreaByIdUseCase: getIt<GetAreaByIdUseCase>(),
    ),
  );

  // Camera Stream BLoC
  getIt.registerLazySingleton<CameraStreamBloc>(
    () => CameraStreamBloc(
      getCameraStreamUseCase: getIt<GetCameraStreamUseCase>(),
    ),
  );

  // Notification BLoC (factory to create fresh instance per page)
  getIt.registerFactory<NotificationBloc>(
    () => NotificationBloc(
      getNotificationsUseCase: getIt<GetNotificationsUseCase>(),
      getNotificationDetailUseCase: getIt<GetNotificationDetailUseCase>(),
      logger: logger,
    ),
  );

  // User BLoC
  getIt.registerFactory<UserBloc>(
    () => UserBloc(
      userRepository: getIt<IUserRepository>(),
      logger: logger,
    ),
  );

  // Machine BLoC
  getIt.registerFactory<MachineBloc>(
    () => MachineBloc(
      machineRepository: getIt<IMachineRepository>(),
      logger: logger,
    ),
  );

  // Sensor BLoC
  getIt.registerFactory<SensorBloc>(
    () => SensorBloc(
      sensorRepository: getIt<ISensorRepository>(),
    ),
  );

  // Role BLoC
  getIt.registerFactory<RoleBloc>(
    () => RoleBloc(
      roleRepository: getIt<IRoleRepository>(),
    ),
  );

  // Thermal Data BLoC
  getIt.registerFactory<ThermalDataBloc>(
    () => ThermalDataBloc(
      thermalDataRepository: getIt<IThermalDataRepository>(),
      logger: logger,
    ),
  );
}

/// Reset BLoC instances when logging out
void resetBlocInstances() {
  // Close and reset BLoCs that maintain state
  if (getIt.isRegistered<AreaBloc>()) {
    getIt<AreaBloc>().close();
    getIt.unregister<AreaBloc>();
  }

  if (getIt.isRegistered<CameraStreamBloc>()) {
    getIt<CameraStreamBloc>().close();
    getIt.unregister<CameraStreamBloc>();
  }

  // Re-register BLoCs with fresh instances
  getIt.registerLazySingleton<AreaBloc>(
    () => AreaBloc(
      getAreaTreeUseCase: getIt<GetAreaTreeWithCamerasUseCase>(),
      getAreaByIdUseCase: getIt<GetAreaByIdUseCase>(),
    ),
  );

  getIt.registerLazySingleton<CameraStreamBloc>(
    () => CameraStreamBloc(
      getCameraStreamUseCase: getIt<GetCameraStreamUseCase>(),
    ),
  );
}
