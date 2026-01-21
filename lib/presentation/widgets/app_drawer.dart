import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vision/core/constants/colors.dart';
import 'package:flutter_vision/presentation/bloc/user/user_bloc.dart';
import 'package:flutter_vision/presentation/bloc/user/user_state.dart';
import 'package:flutter_vision/presentation/widgets/user_avatar.dart';
import 'package:flutter_vision/di/injection.dart';
import 'package:flutter_vision/domain/repositories/auth_repository.dart';
import 'package:flutter_vision/main.dart' as app_main;

/// Custom drawer widget có thể tái sử dụng
/// Sử dụng AppDrawerService để mở drawer từ bất kỳ đâu
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.drawerBackground,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              final user = state.currentUser;
              final userName = user?.fullName ?? user?.userName ?? 'User';
              final userRole = user?.roleName ?? user?.role?.name ?? 'Role';
              final avatarUrl = user?.avatarUrl;

              return DrawerHeader(
                decoration: BoxDecoration(
                  color: AppColors.drawerBackgroundHeader,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    UserAvatar(
                      avatarUrl: avatarUrl,
                      name: userName,
                      radius: 30,
                      borderColor: Colors.white,
                      borderWidth: 2,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userRole,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Camera'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to camera
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Thông báo'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to notifications
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Cài đặt'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Thông tin'),
            onTap: () {
              Navigator.pop(context);
              // Show info
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Đăng xuất', style: TextStyle(color: Colors.red),),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => _handleLogout(context),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    Navigator.pop(context); // Close dialog

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      final authRepository = getIt<AuthRepository>();
      await authRepository.logout();

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
      }

      // Use global navigator to go to login
      app_main.navigateToLogin();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã đăng xuất thành công'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        try {
          Navigator.of(context).pop(); // Close loading dialog
        } catch (_) {}

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đăng xuất: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
