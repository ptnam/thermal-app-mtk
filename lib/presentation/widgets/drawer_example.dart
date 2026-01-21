import 'package:flutter/material.dart';
import 'package:camera_viewer/presentation/widgets/app_drawer_service.dart';

/// Widget ví dụ cho cách sử dụng AppDrawerService
/// Bạn có thể sử dụng trong bất kỳ màn hình nào
class DrawerExampleWidget extends StatelessWidget {
  const DrawerExampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Cách 1: Sử dụng IconButton
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            AppDrawerService.openDrawer();
          },
        ),
        
        // Cách 2: Sử dụng ElevatedButton
        ElevatedButton(
          onPressed: () {
            AppDrawerService.openDrawer();
          },
          child: const Text('Mở Menu'),
        ),
        
        // Cách 3: Sử dụng FloatingActionButton
        FloatingActionButton(
          onPressed: () {
            AppDrawerService.toggleDrawer();
          },
          child: const Icon(Icons.menu),
        ),
        
        // Cách 4: Sử dụng GestureDetector với bất kỳ widget nào
        GestureDetector(
          onTap: () {
            AppDrawerService.openDrawer();
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Tap để mở drawer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

/// Mixin để thêm chức năng drawer vào bất kỳ StatefulWidget nào
mixin DrawerMixin<T extends StatefulWidget> on State<T> {
  void openDrawer() {
    AppDrawerService.openDrawer();
  }

  void closeDrawer() {
    AppDrawerService.closeDrawer();
  }

  void toggleDrawer() {
    AppDrawerService.toggleDrawer();
  }

  bool get isDrawerOpen => AppDrawerService.isDrawerOpen();
}
