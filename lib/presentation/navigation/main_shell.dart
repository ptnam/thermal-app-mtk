import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera_viewer/presentation/navigation/bottom_navigation.dart';
import 'package:camera_viewer/presentation/ui/camera/camera_screen_new.dart';
import 'package:camera_viewer/presentation/ui/home/home_page.dart';
import 'package:camera_viewer/presentation/ui/notification/notification_list_page_new.dart';
import 'package:camera_viewer/presentation/ui/setting/setting_page_new.dart';
import 'package:camera_viewer/presentation/widgets/app_drawer.dart';
import 'package:camera_viewer/presentation/widgets/app_drawer_service.dart';
import 'package:camera_viewer/presentation/bloc/area_selection/area_selection_bloc.dart';
import 'package:camera_viewer/core/constants/colors.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => MainShellState();
}

/// Service để điều khiển tab từ bên ngoài (drawer)
class MainShellService {
  static MainShellState? _state;

  static void register(MainShellState state) {
    _state = state;
  }

  static void unregister() {
    _state = null;
  }

  static void navigateToTab(int index) {
    _state?.navigateToTab(index);
  }
}

class MainShellState extends State<MainShell> {
  int _index = 0;

  final _pages = [
    const HomePage(),
    const CameraScreenNew(),
    const NotificationListPageNew(),
    const SettingPageNew(),
  ];

  @override
  void initState() {
    super.initState();
    MainShellService.register(this);
  }

  @override
  void dispose() {
    MainShellService.unregister();
    super.dispose();
  }

  void navigateToTab(int index) {
    if (index >= 0 && index < _pages.length) {
      setState(() {
        _index = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AreaSelectionBloc, AreaSelectionState>(
      listener: (context, state) {
        // Khi chọn khu vực thành công, quay về màn hình chính
        if (state.hasSelectedArea && state.selectedArea != null) {
          // Refresh data nếu cần
        }
      },
      child: Scaffold(
        key: AppDrawerService.scaffoldKey,
        drawer: const AppDrawer(),
        body: Stack(
          children: [
            Positioned.fill(
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
      ),
    );
  }
}

/// Widget header hiển thị khu vực đang chọn
class SelectedAreaHeader extends StatelessWidget {
  final VoidCallback? onChangeArea;

  const SelectedAreaHeader({super.key, this.onChangeArea});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AreaSelectionBloc, AreaSelectionState>(
      builder: (context, state) {
        if (!state.hasSelectedArea || state.selectedArea == null) {
          return const SizedBox.shrink();
        }

        final area = state.selectedArea!;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.primaryDark,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Khu vực đang chọn',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      area.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onChangeArea != null)
                GestureDetector(
                  onTap: onChangeArea,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Đổi',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
