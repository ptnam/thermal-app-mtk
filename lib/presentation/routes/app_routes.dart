import 'package:flutter_vision/presentation/ui/camera/camera_page.dart';
import 'package:flutter_vision/presentation/ui/notification/notification_list_page.dart';
import 'package:flutter_vision/presentation/ui/setting/setting_page.dart';
import 'package:flutter_vision/presentation/ui/setting/api_test_page.dart';

class AppRoutes {
  static const camera = '/camera';
  static const notification = '/notification';
  static const setting = '/setting';
  static const apiTest = '/api-test';
  static const login = '/login';
}

final routes = {
  AppRoutes.camera: (_) => CameraPage(),
  AppRoutes.notification: (_) => NotificationListPage(),
  AppRoutes.setting: (_) => SettingPage(),
  AppRoutes.apiTest: (_) => const ApiTestPage(),
  // AppRoutes.main: (context) {
  //   return MultiBlocProvider(
  //     providers: [
  //       BlocProvider(
  //         create: (_) {
  //           return sl<BibleBloc>()..add(BibleInitEvent());
  //         },
  //       ),
  //     ],
  //     child: MainShell(),
  //   );
  // },
};
