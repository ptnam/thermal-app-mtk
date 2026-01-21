import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera_viewer/presentation/bloc/user/user_bloc.dart';
import 'package:camera_viewer/presentation/bloc/user/user_event.dart';
import 'package:camera_viewer/presentation/bloc/user/user_state.dart';
import 'package:camera_viewer/presentation/bloc/area_selection/area_selection_bloc.dart';
import 'package:camera_viewer/presentation/bloc/area/area_bloc.dart';
import 'package:camera_viewer/presentation/widgets/app_drawer_service.dart';
import 'package:camera_viewer/presentation/widgets/user_avatar.dart';
import 'package:camera_viewer/presentation/navigation/main_shell.dart';
import 'package:camera_viewer/presentation/ui/area_selection/area_selection_screen.dart';
import 'package:camera_viewer/domain/entities/area_tree.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(const LoadCurrentUserEvent());
    // Load area tree để có thông tin đầy đủ
    _loadAreaData();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  void _loadAreaData() {
    try {
      context.read<AreaBloc>().add(const FetchAreaTreeEvent());
    } catch (e) {
      // Ignore if bloc is closed
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Hiển thị khu vực đang chọn
                      SelectedAreaHeader(
                        onChangeArea: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AreaSelectionScreen(canGoBack: true),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildWelcomeSection(context),
                      const SizedBox(height: 24),
                      _buildAreaInfo(context),
                      const SizedBox(height: 100), // Space for bottom nav
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          // Menu button
          _AppBarButton(
            icon: Icons.menu_rounded,
            onTap: () => AppDrawerService.openDrawer(),
          ),
          const Spacer(),
          // Logo/Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0088FF), Color(0xFF00D4FF)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.videocam_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Camera Vision',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          // User avatar
          BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              final user = state.currentUser;
              final userName = user?.fullName ?? user?.userName ?? 'User';
              final avatarUrl = user?.avatarUrl;

              return UserAvatar(
                avatarUrl: avatarUrl,
                name: userName,
                radius: 18,
                onTap: () => AppDrawerService.openDrawer(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        final user = state.currentUser;
        final userName = user?.fullName ?? user?.userName ?? 'User';
        final greeting = _getGreeting();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              userName,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Chào buổi sáng 👋';
    } else if (hour < 18) {
      return 'Chào buổi chiều 👋';
    } else {
      return 'Chào buổi tối 👋';
    }
  }

  Widget _buildAreaInfo(BuildContext context) {
    return BlocBuilder<AreaSelectionBloc, AreaSelectionState>(
      builder: (context, selectionState) {
        if (!selectionState.hasSelectedArea || selectionState.selectedArea == null) {
          return const SizedBox.shrink();
        }

        final selectedAreaId = selectionState.selectedArea!.id;

        return BlocBuilder<AreaBloc, AreaState>(
          builder: (context, areaState) {
            // Tìm area từ API data để có thông tin đầy đủ
            AreaTree? fullArea;
            if (areaState is AreaTreeLoaded) {
              fullArea = _findAreaById(areaState.areas, selectedAreaId);
            }

            // Fallback về area từ selection nếu không tìm thấy
            final area = fullArea ?? selectionState.selectedArea!;
            final cameraCount = area.cameras.length;
            final childAreaCount = area.children.length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thông tin khu vực',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.videocam_rounded,
                        label: 'Camera',
                        value: '$cameraCount',
                        gradient: const [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.location_on_rounded,
                        label: 'Khu vực con',
                        value: '$childAreaCount',
                        gradient: const [Color(0xFF11998e), Color(0xFF38ef7d)],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  AreaTree? _findAreaById(List<AreaTree> areas, int id) {
    for (final area in areas) {
      if (area.id == id) return area;
      final found = _findAreaByIdRecursive(area, id);
      if (found != null) return found;
    }
    return null;
  }

  AreaTree? _findAreaByIdRecursive(AreaTree area, int id) {
    if (area.id == id) return area;
    for (final child in area.children) {
      final found = _findAreaByIdRecursive(child, id);
      if (found != null) return found;
    }
    return null;
  }
}

class _AppBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AppBarButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.grey.shade700, size: 22),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradient;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradient[0].withOpacity(0.15),
            gradient[1].withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gradient[0].withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
