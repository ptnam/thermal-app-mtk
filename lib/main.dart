import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera_viewer/core/constants/themes.dart';
import 'package:camera_viewer/presentation/navigation/main_shell.dart';
import 'package:camera_viewer/presentation/bloc/user/user_bloc.dart';
import 'package:camera_viewer/presentation/bloc/area/area_bloc.dart';
import 'package:camera_viewer/presentation/bloc/area_selection/area_selection_bloc.dart';
import 'package:camera_viewer/presentation/ui/area_selection/area_selection_screen.dart';
import 'package:camera_viewer/data/local/area_preferences.dart';

import 'di/injection.dart';
// Hive initialization and adapters are handled by DI in `di/injection.dart`.
import 'presentation/ui/login/login_screen.dart';
import 'domain/repositories/auth_repository.dart';
import 'presentation/routes/app_routes.dart';

late GlobalKey<NavigatorState> _navigatorKey;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

  // Decide initial screen based on cached session
  final authRepo = getIt<AuthRepository>();
  final hasSession = await authRepo.hasValidSession();

  // Check if area is selected
  final areaPrefs = getIt<AreaPreferences>();
  final hasSelectedArea = areaPrefs.hasSelectedArea();

  _navigatorKey = GlobalKey<NavigatorState>();
  runApp(
    MyApp(
      initialLoggedIn: hasSession,
      hasSelectedArea: hasSelectedArea,
      navigatorKey: _navigatorKey,
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool initialLoggedIn;
  final bool hasSelectedArea;
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({
    super.key,
    this.initialLoggedIn = false,
    this.hasSelectedArea = false,
    required this.navigatorKey,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserBloc>(create: (context) => getIt<UserBloc>()),
        BlocProvider<AreaBloc>(create: (context) => getIt<AreaBloc>()),
        BlocProvider<AreaSelectionBloc>(
          create: (context) =>
              getIt<AreaSelectionBloc>()..add(const LoadSelectedAreaEvent()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Camera Vision',
        theme: AppTheme.darkTheme,
        navigatorKey: navigatorKey,
        routes: routes,
        home: _buildHomeScreen(),
      ),
    );
  }

  Widget _buildHomeScreen() {
    // Chưa đăng nhập -> Login
    if (!initialLoggedIn) {
      return LoginScreen(authRepository: getIt<AuthRepository>());
    }

    // Đã đăng nhập nhưng chưa chọn khu vực -> Màn hình chọn khu vực
    if (!hasSelectedArea) {
      return const AreaSelectionWrapper();
    }

    // Đã đăng nhập và đã chọn khu vực -> Main
    return const MainShell();
  }
}

/// Wrapper để handle navigation sau khi chọn khu vực
class AreaSelectionWrapper extends StatelessWidget {
  const AreaSelectionWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AreaSelectionBloc, AreaSelectionState>(
      listener: (context, state) {
        if (state.hasSelectedArea && state.selectedArea != null) {
          // Khi đã chọn khu vực, navigate tới MainShell
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainShell()),
            (route) => false,
          );
        }
      },
      child: const AreaSelectionScreen(canGoBack: false),
    );
  }
}

// Helper function to navigate to login from anywhere
void navigateToLogin() {
  _navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (context) =>
          LoginScreen(authRepository: getIt<AuthRepository>()),
    ),
    (route) => false,
  );
}

// Helper function to navigate to area selection
void navigateToAreaSelection() {
  _navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => const AreaSelectionWrapper()),
    (route) => false,
  );
}
