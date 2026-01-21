import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vision/core/constants/themes.dart';
import 'package:flutter_vision/presentation/navigation/main_shell.dart';
import 'package:flutter_vision/presentation/bloc/user/user_bloc.dart';

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

  _navigatorKey = GlobalKey<NavigatorState>();
  runApp(MyApp(initialLoggedIn: hasSession, navigatorKey: _navigatorKey));
}

class MyApp extends StatelessWidget {
  final bool initialLoggedIn;
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({
    super.key,
    this.initialLoggedIn = false,
    required this.navigatorKey,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserBloc>(
          create: (context) => getIt<UserBloc>(),
        ),
        // Thêm các BLoC khác ở đây nếu cần
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Camera Vision',
        theme: AppTheme.darkTheme,
        navigatorKey: navigatorKey,
        routes: routes,
        home: initialLoggedIn
            ? const MainShell()
            : LoginScreen(authRepository: getIt<AuthRepository>()),
      ),
    );
  }
}

// Helper function to navigate to login from anywhere
void navigateToLogin() {
  _navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (context) => LoginScreen(
        authRepository: getIt<AuthRepository>(),
      ),
    ),
    (route) => false,
  );
}

