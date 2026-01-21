import 'package:flutter/material.dart';
import 'package:flutter_vision/presentation/navigation/bottom_navigation.dart';
import 'package:flutter_vision/presentation/ui/camera/camera_page.dart';
import 'package:flutter_vision/presentation/ui/home/home_page.dart';
import 'package:flutter_vision/presentation/ui/notification/notification_list_page.dart';
import 'package:flutter_vision/presentation/ui/setting/setting_page.dart';
import 'package:flutter_vision/presentation/widgets/app_drawer.dart';
import 'package:flutter_vision/presentation/widgets/app_drawer_service.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _pages = [
    const HomePage(),
    const CameraPage(),
    const NotificationListPage(),
    const SettingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: AppDrawerService.scaffoldKey,
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          Positioned(
            child: IndexedStack(index: _index, children: _pages),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: BottomNavigation(
          currentIndex: _index,
          onTap: (i) {
            setState(() {
              _index = i;
            });
          },
        ),
      ),
    );
  }
}
