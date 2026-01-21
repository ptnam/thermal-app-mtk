import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_vision/core/constants/icons.dart';
import 'package:flutter_vision/core/constants/colors.dart';
import 'package:flutter_vision/presentation/bloc/user/user_bloc.dart';
import 'package:flutter_vision/presentation/bloc/user/user_event.dart';
import 'package:flutter_vision/presentation/bloc/user/user_state.dart';
import 'package:flutter_vision/presentation/widgets/app_drawer_service.dart';
import 'package:flutter_vision/presentation/widgets/user_avatar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load current user khi widget được khởi tạo
    context.read<UserBloc>().add(const LoadCurrentUserEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 8 + 1), // toolbar height + spacing + border
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.line.withOpacity(0.32),
                width: 1,
              ),
            ),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: InkWell(
          onTap: () {
            AppDrawerService.openDrawer();
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SvgPicture.asset(
              AppIcons.icMenu,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
              width: 24,
              height: 24,
            ),
          ),
        ),
        actions: [
          BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              if (state.profileStatus == UserStatus.loading) { 
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }

              final user = state.currentUser;
              final userName = user?.fullName ?? user?.userName ?? 'Unknown';
              final userRole = user?.roleName ?? user?.role?.name ?? 'User';
              final avatarUrl = user?.avatarUrl;

              return Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userRole,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: UserAvatar(
                      avatarUrl: avatarUrl,
                      name: userName,
                      radius: 20,
                      borderColor: Colors.white,
                      borderWidth: 2,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(16),
          child: SizedBox.shrink(),
        ),
      ),
    ),
  ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state.profileStatus == UserStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lỗi: ${state.errorMessage ?? "Không thể tải thông tin user"}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<UserBloc>().add(const LoadCurrentUserEvent());
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return const Center(
            child: Text('Home Page Content'),
          );
        },
      ),
    );
  }
}
