# API Layer Documentation

## Overview

This document describes the API layer implementation for the Flutter Vision thermal monitoring application. The API layer follows Clean Architecture principles with a clear separation between data, domain, and presentation layers.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           PRESENTATION LAYER                                │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │ UserBloc │  │MachineBloc│ │SensorBloc│  │ RoleBloc │  │ThermalBloc│      │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘       │
└───────┼─────────────┼────────────┼─────────────┼─────────────┼──────────────┘
        │             │            │             │             │
┌───────▼─────────────▼────────────▼─────────────▼─────────────▼─────────────┐
│                            DOMAIN LAYER                                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │ IUserRepo    │  │ IMachineRepo │  │ ISensorRepo  │  │ IRoleRepo    │    │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │ UserEntity   │  │MachineEntity │  │ SensorEntity │  │ RoleEntity   │    │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘    │
└────────────────────────────────────────────────────────────────────────────┘
                                      │
┌─────────────────────────────────────▼───────────────────────────────────────┐
│                              DATA LAYER                                     │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐                 │
│  │ UserRepoImpl   │  │ MachineRepoImpl│  │ SensorRepoImpl │                 │
│  └───────┬────────┘  └───────┬────────┘  └───────┬────────┘                 │
│          │                   │                   │                          │
│  ┌───────▼────────┐  ┌───────▼────────┐  ┌───────▼────────┐                 │
│  │ UserApiService │  │MachineApiService│ │SensorApiService│                 │
│  └───────┬────────┘  └───────┬────────┘  └───────┬────────┘                 │
│          │                   │                   │                          │
│  ┌───────▼───────────────────▼───────────────────▼────────┐                 │
│  │                      ApiClient                          │                │
│  │              (Dio HTTP Client Wrapper)                  │                │
│  └─────────────────────────────────────────────────────────┘                │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Directory Structure

```
lib/
├── core/
│   └── error/
│       ├── api_error.dart           # API error types with freezed
│       └── failures.dart            # Domain layer failure types
│
├── data/
│   ├── mappers/
│   │   └── dto_mappers.dart         # DTO to Entity conversion extensions
│   │
│   ├── network/
│   │   ├── api_services.dart        # Barrel export for all services
│   │   ├── core/
│   │   │   ├── api_client.dart      # HTTP client wrapper
│   │   │   ├── api_response.dart    # Standard response wrapper
│   │   │   ├── base_dto.dart        # Common enums and base DTOs
│   │   │   └── paging_response.dart # Pagination wrapper
│   │   │
│   │   ├── user/
│   │   │   ├── user_api_service.dart
│   │   │   ├── user_endpoints.dart
│   │   │   └── dto/
│   │   │       └── user_dto.dart
│   │   │
│   │   ├── role/
│   │   │   ├── role_api_service.dart
│   │   │   ├── role_endpoints.dart
│   │   │   └── dto/
│   │   │       └── role_dto.dart
│   │   │
│   │   ├── machine/
│   │   │   ├── machine_api_service.dart
│   │   │   ├── machine_endpoints.dart
│   │   │   └── dto/
│   │   │       ├── machine_dto.dart
│   │   │       ├── machine_type_dto.dart
│   │   │       └── machine_part_dto.dart
│   │   │
│   │   ├── sensor/
│   │   │   ├── sensor_api_service.dart
│   │   │   ├── sensor_endpoints.dart
│   │   │   └── dto/
│   │   │       ├── sensor_dto.dart
│   │   │       └── sensor_type_dto.dart
│   │   │
│   │   ├── thermal_data/
│   │   │   ├── thermal_data_api_service.dart
│   │   │   ├── thermal_data_endpoints.dart
│   │   │   └── dto/
│   │   │       └── thermal_data_dto.dart
│   │   │
│   │   ├── camera/
│   │   │   ├── camera_api_service.dart
│   │   │   └── dto/
│   │   │       └── camera_dto.dart
│   │   │
│   │   ├── area/
│   │   │   ├── area_api_service.dart
│   │   │   ├── area_endpoints.dart
│   │   │   └── dto/
│   │   │       └── area_dto.dart
│   │   │
│   │   ├── notification/
│   │   │   ├── notification_api_service.dart
│   │   │   ├── notification_endpoints.dart
│   │   │   └── dto/
│   │   │       └── notification_dto.dart
│   │   │
│   │   ├── notification_channel/
│   │   │   ├── notification_settings_api_service.dart
│   │   │   └── dto/
│   │   │       └── notification_channel_dto.dart
│   │   │
│   │   ├── notification_group/
│   │   │   └── dto/
│   │   │       └── notification_group_dto.dart
│   │   │
│   │   ├── warning_event/
│   │   │   ├── warning_event_api_service.dart
│   │   │   └── dto/
│   │   │       └── warning_event_dto.dart
│   │   │
│   │   └── monitor_point/
│   │       ├── monitor_point_api_service.dart
│   │       └── dto/
│   │           └── monitor_point_dto.dart
│   │
│   └── repositories/
│       ├── repositories_impl.dart    # Barrel export
│       ├── user_repository_impl.dart
│       ├── role_repository_impl.dart
│       ├── machine_repository_impl.dart
│       ├── sensor_repository_impl.dart
│       └── thermal_data_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   ├── entities.dart             # Barrel export
│   │   ├── user_entity.dart
│   │   ├── role_entity.dart
│   │   ├── machine_entity.dart
│   │   ├── sensor_entity.dart
│   │   ├── camera_entity.dart
│   │   ├── area_entity.dart
│   │   ├── notification_entity.dart
│   │   └── thermal_data_entity.dart
│   │
│   └── repositories/
│       ├── repositories.dart         # Barrel export
│       ├── user_repository.dart
│       ├── role_repository.dart
│       ├── machine_repository.dart
│       ├── sensor_repository.dart
│       └── thermal_data_repository.dart
│
├── presentation/
│   └── bloc/
│       ├── blocs.dart                # Barrel export
│       ├── user/
│       │   ├── user_bloc.dart
│       │   ├── user_event.dart
│       │   └── user_state.dart
│       ├── role/
│       │   ├── role_bloc.dart
│       │   ├── role_event.dart
│       │   └── role_state.dart
│       ├── machine/
│       │   ├── machine_bloc.dart
│       │   ├── machine_event.dart
│       │   └── machine_state.dart
│       ├── sensor/
│       │   ├── sensor_bloc.dart
│       │   ├── sensor_event.dart
│       │   └── sensor_state.dart
│       └── thermal_data/
│           ├── thermal_data_bloc.dart
│           ├── thermal_data_event.dart
│           └── thermal_data_state.dart
│
└── di/
    ├── injection.dart                # Main DI configuration
    └── api_injection_module.dart     # API-specific DI module
```

## API Services

### UserApiService

Handles user profile, authentication-related user operations, and user CRUD.

```dart
final userService = getIt<UserApiService>();

// Get current user profile
final result = await userService.getProfile();

// Get paginated user list
final users = await userService.getUserList(
  page: 1,
  pageSize: 20,
  keyword: 'admin',
  roleId: 1,
);

// Create user
final newUser = await userService.createUser(
  userName: 'newuser',
  email: 'user@example.com',
  password: 'securePassword123',
  fullName: 'New User',
);

// Update user
await userService.updateUser(id: 1, fullName: 'Updated Name');

// Delete user
await userService.deleteUser(1);

// Change password
await userService.changePassword(
  currentPassword: 'oldPass',
  newPassword: 'newPass123',
);
```

### MachineApiService

Handles machine, machine type, and machine part operations.

```dart
final machineService = getIt<MachineApiService>();

// Machines
final allMachines = await machineService.getAllMachines();
final machineList = await machineService.getMachineList(page: 1, areaId: 5);
final machine = await machineService.getMachineById(1);
await machineService.createMachine(name: 'New Machine', areaId: 1);
await machineService.updateMachine(id: 1, name: 'Updated');
await machineService.deleteMachine(1);

// Machine Types
final types = await machineService.getAllMachineTypes();
await machineService.createMachineType(name: 'New Type');

// Machine Parts (Tree structure)
final partTree = await machineService.getMachinePartTree();
await machineService.createMachinePart(name: 'New Part', parentId: 1);
```

### ThermalDataApiService

Handles thermal monitoring data for dashboards and charts.

```dart
final thermalService = getIt<ThermalDataApiService>();

// Dashboard data
final dashboard = await thermalService.getDashboardData(
  areaId: 1,
  fromDate: DateTime.now().subtract(Duration(days: 7)),
  toDate: DateTime.now(),
);

// Paginated list
final dataList = await thermalService.getThermalDataList(
  page: 1,
  machineComponentId: 5,
  level: 'warning',
);

// Chart data for single component
final chart = await thermalService.getChartData(
  machineComponentId: 1,
  fromDate: startDate,
  toDate: endDate,
  interval: '1h',
);

// Multi-component chart
final charts = await thermalService.getMultiChartData(
  machineComponentIds: [1, 2, 3],
  fromDate: startDate,
  toDate: endDate,
);

// Latest reading
final latest = await thermalService.getLatestData(machineComponentId: 1);
```

## BLoC Usage

### UserBloc

```dart
// Provide the BLoC
BlocProvider<UserBloc>(
  create: (_) => getIt<UserBloc>()..add(const LoadCurrentUserEvent()),
  child: MyWidget(),
)

// Use in widget
BlocBuilder<UserBloc, UserState>(
  builder: (context, state) {
    if (state.profileStatus == UserStatus.loading) {
      return CircularProgressIndicator();
    }
    if (state.profileStatus == UserStatus.success) {
      return Text(state.currentUser?.fullName ?? '');
    }
    return Text('Error: ${state.errorMessage}');
  },
)

// Dispatch events
context.read<UserBloc>().add(const LoadUserListEvent(page: 1));
context.read<UserBloc>().add(CreateUserEvent(
  userName: 'newuser',
  email: 'email@test.com',
  password: 'password123',
));
```

### MachineBloc

```dart
// Load all machines and types
context.read<MachineBloc>()
  ..add(const LoadAllMachinesEvent())
  ..add(const LoadAllMachineTypesEvent())
  ..add(const LoadMachinePartTreeEvent());

// Filter machines
context.read<MachineBloc>().add(MachineFilterChangedEvent(
  searchKeyword: 'motor',
  areaId: 1,
  machineTypeId: 2,
));

// Create machine
context.read<MachineBloc>().add(CreateMachineEvent(
  name: 'New Machine',
  areaId: 1,
  machineTypeId: 1,
  componentPartIds: [1, 2, 3],
));
```

## Dependency Injection

### Registration

Add to `injection.dart`:

```dart
import 'api_injection_module.dart';

Future<void> configureDependencies() async {
  // ... existing registrations ...
  
  _registerNetworkLayer();
  _registerLocalLayer();
  
  // Register all API dependencies
  registerAllApiDependencies();
  
  _registerRepositories();
  _registerUseCases();
  _registerBlocs();
}
```

### Usage

```dart
// Get instances
final userService = getIt<UserApiService>();
final userRepository = getIt<IUserRepository>();
final userBloc = getIt<UserBloc>();
```

## Error Handling

### API Errors

```dart
result.fold(
  (error) => error.when(
    network: (message) => showSnackBar('Network error: $message'),
    unauthorized: (message) => navigateToLogin(),
    forbidden: (message) => showSnackBar('Access denied'),
    notFound: (message) => showSnackBar('Not found'),
    server: (code, message) => showSnackBar('Server error: $message'),
    unknown: (message) => showSnackBar('Unknown error'),
  ),
  (data) => processData(data),
);
```

### Domain Failures

```dart
result.fold(
  (failure) {
    if (failure is NetworkFailure) {
      // Handle network issues
    } else if (failure is UnauthorizedFailure) {
      // Redirect to login
    } else if (failure is ValidationFailure) {
      // Show validation errors
    }
  },
  (entity) => useEntity(entity),
);
```

## Testing

### API Service Tests

```dart
void main() {
  late UserApiService service;
  late MockApiClient mockClient;
  
  setUp(() {
    mockClient = MockApiClient();
    service = UserApiService(
      apiClient: mockClient,
      baseUrlProvider: MockBaseUrlProvider(),
    );
  });
  
  test('getProfile returns user', () async {
    when(() => mockClient.get(any())).thenAnswer(
      (_) async => Right({'data': {'id': 1, 'userName': 'test'}}),
    );
    
    final result = await service.getProfile();
    
    expect(result.isRight(), true);
  });
}
```

### BLoC Tests

```dart
blocTest<UserBloc, UserState>(
  'emits [loading, success] when loadCurrentUser succeeds',
  build: () {
    when(() => mockRepo.getCurrentUser())
        .thenAnswer((_) async => Right(testUser));
    return UserBloc(userRepository: mockRepo);
  },
  act: (bloc) => bloc.add(const LoadCurrentUserEvent()),
  expect: () => [
    isA<UserState>().having((s) => s.profileStatus, 'status', UserStatus.loading),
    isA<UserState>().having((s) => s.profileStatus, 'status', UserStatus.success),
  ],
);
```

## Backend API Reference

The Flutter API layer maps to the following ASP.NET Core controllers:

| Flutter Service | Backend Controller |
|-----------------|-------------------|
| UserApiService | UsersController |
| RoleApiService | RolesController |
| MachineApiService | MachinesController, MachineTypesController, MachinePartsController |
| SensorApiService | SensorsController, SensorTypesController |
| ThermalDataApiService | ThermalDataController, DashboardController |
| CameraApiService | CamerasController, CameraSettingsController |
| AreaApiService | AreasController |
| NotificationApiService | NotificationsController |
| NotificationSettingsApiService | NotificationChannelsController, NotificationGroupsController |
| WarningEventApiService | WarningEventsController |
| MonitorPointApiService | MonitorPointsController |

## Contributing

When adding new API endpoints:

1. Create DTO in `data/network/<module>/dto/`
2. Add endpoint to `<module>_endpoints.dart`
3. Add method to `<module>_api_service.dart`
4. Create/update entity in `domain/entities/`
5. Add to repository interface in `domain/repositories/`
6. Implement in repository impl in `data/repositories/`
7. Add mapper extension in `data/mappers/dto_mappers.dart`
8. Add BLoC events/state/bloc in `presentation/bloc/<module>/`
9. Register in DI module
10. Write unit tests
