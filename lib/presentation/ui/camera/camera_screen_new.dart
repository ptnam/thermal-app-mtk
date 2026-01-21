import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera_viewer/presentation/widgets/common/common_widgets.dart';
import 'package:camera_viewer/presentation/bloc/area_selection/area_selection_bloc.dart';

import '../../../domain/entities/area_tree.dart';
import '../../../domain/entities/camera_entity.dart';
import '../../bloc/area/area_bloc.dart';
import 'camera_stream_page_new.dart';

/// Camera Screen - Modern UI with area filter
class CameraScreenNew extends StatefulWidget {
  const CameraScreenNew({super.key});

  @override
  State<CameraScreenNew> createState() => _CameraScreenNewState();
}

class _CameraScreenNewState extends State<CameraScreenNew>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  int? _lastAreaId;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Fetch area tree when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadCameras();
        _fadeController.forward();
      }
    });
  }

  void _loadCameras() {
    try {
      context.read<AreaBloc>().add(const FetchAreaTreeEvent());
    } catch (e) {
      // BLoC already closed, ignore
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AreaSelectionBloc, AreaSelectionState>(
      listener: (context, areaState) {
        // Khi khu vực thay đổi, refresh danh sách camera
        if (areaState.hasSelectedArea && areaState.selectedArea != null) {
          final newAreaId = areaState.selectedArea!.id;
          if (_lastAreaId != newAreaId) {
            _lastAreaId = newAreaId;
            _loadCameras();
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildSearchBar(context),
              _buildAreaInfo(context),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildContent(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          // Title with icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF8B5C)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B35).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.videocam_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Camera',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Xem trực tiếp camera',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          // Refresh button
          _ActionButton(icon: Icons.refresh_rounded, onTap: _loadCameras),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: 'Tìm kiếm camera...',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: Colors.grey.shade500,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value.toLowerCase());
          },
        ),
      ),
    );
  }

  Widget _buildAreaInfo(BuildContext context) {
    return BlocBuilder<AreaSelectionBloc, AreaSelectionState>(
      builder: (context, state) {
        if (!state.hasSelectedArea || state.selectedArea == null) {
          return const SizedBox.shrink();
        }

        final area = state.selectedArea!;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B35).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFF6B35).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: const Color(0xFFFF6B35),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Khu vực: ${area.name}',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: Colors.green, size: 8),
                    SizedBox(width: 4),
                    Text(
                      'Đang lọc',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return BlocBuilder<AreaBloc, AreaState>(
      builder: (context, state) {
        if (state is AreaLoading) {
          return const LoadingStateWidget(
            message: 'Đang tải danh sách camera...',
          );
        }

        if (state is AreaError) {
          return ErrorStateWidget(
            message: state.message,
            onRetry: _loadCameras,
          );
        }

        if (state is AreaTreeLoaded) {
          // Lọc theo khu vực đã chọn
          final filteredAreas = _filterBySelectedArea(state.areas);

          if (filteredAreas.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.videocam_off_rounded,
              title: 'Không tìm thấy camera',
              subtitle: 'Không có camera nào trong khu vực đã chọn',
              onRetry: _loadCameras,
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadCameras(),
            color: const Color(0xFFFF6B35),
            backgroundColor: const Color(0xFF1E293B),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: filteredAreas.length,
              itemBuilder: (context, index) {
                return _AnimatedAreaTreeTile(
                  area: filteredAreas[index],
                  index: index,
                  searchQuery: _searchQuery,
                );
              },
            ),
          );
        }

        return Center(
          child: Text(
            'Đang khởi tạo...',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        );
      },
    );
  }

  List<AreaTree> _filterBySelectedArea(List<AreaTree> areas) {
    final selectedAreaState = context.read<AreaSelectionBloc>().state;

    if (!selectedAreaState.hasSelectedArea ||
        selectedAreaState.selectedArea == null) {
      // Không có area được chọn => hiển thị tất cả
      return areas;
    }

    final selectedArea = selectedAreaState.selectedArea!;
    final selectedAreaId = selectedArea.id;

    // Tìm area tree chính xác từ danh sách API
    for (final area in areas) {
      final found = _findAreaById(area, selectedAreaId);
      if (found != null) {
        // Trả về chỉ area được chọn (không lấy parent)
        return [found];
      }
    }

    // Nếu không tìm thấy trong API response, sử dụng area đã lưu
    return [selectedArea];
  }

  AreaTree? _findAreaById(AreaTree area, int id) {
    if (area.id == id) return area;
    for (final child in area.children) {
      final found = _findAreaById(child, id);
      if (found != null) return found;
    }
    return null;
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.grey.shade600, size: 22),
        ),
      ),
    );
  }
}

/// Animated area tree tile
class _AnimatedAreaTreeTile extends StatefulWidget {
  final AreaTree area;
  final int index;
  final String searchQuery;

  const _AnimatedAreaTreeTile({
    required this.area,
    required this.index,
    required this.searchQuery,
  });

  @override
  State<_AnimatedAreaTreeTile> createState() => _AnimatedAreaTreeTileState();
}

class _AnimatedAreaTreeTileState extends State<_AnimatedAreaTreeTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300 + (widget.index * 50)),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 30,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasChildren = widget.area.children.isNotEmpty;
    final hasCameras = widget.area.cameras.isNotEmpty;
    final isExpandable = hasChildren || hasCameras;
    final matchesSearch =
        widget.searchQuery.isEmpty ||
        widget.area.name.toLowerCase().contains(widget.searchQuery);

    if (!matchesSearch && widget.searchQuery.isNotEmpty) {
      // Check if any child matches
      final hasMatchingChild = _hasMatchingDescendant(widget.area);
      if (!hasMatchingChild) return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(opacity: _fadeAnimation.value, child: child),
        );
      },
      child: Column(
        children: [
          ModernCard(
            margin: const EdgeInsets.only(bottom: 8),
            onTap: () {
              if (isExpandable) {
                setState(() => _isExpanded = !_isExpanded);
              }
            },
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: isExpandable
                        ? LinearGradient(
                            colors: [
                              const Color(0xFF0088FF).withOpacity(0.2),
                              const Color(0xFF00D4FF).withOpacity(0.1),
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              const Color(0xFFFF6B35).withOpacity(0.2),
                              const Color(0xFFFF8B5C).withOpacity(0.1),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isExpandable
                        ? Icons.folder_rounded
                        : Icons.videocam_rounded,
                    color: isExpandable
                        ? const Color(0xFF0088FF)
                        : const Color(0xFFFF6B35),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.area.name,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isExpandable) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF0088FF,
                            ).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${widget.area.children.length + widget.area.cameras.length} mục',
                            style: const TextStyle(
                              color: Color(0xFF0088FF),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Status & expand icon
                StatusBadge(
                  text: widget.area.status,
                  color: _getStatusColor(widget.area.status),
                  isActive: widget.area.status.toLowerCase() == 'active',
                ),
                if (isExpandable) ...[
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: Colors.grey.shade400,
                      size: 24,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Children
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Column(
                children: [
                  ...widget.area.children.map(
                    (child) => _AnimatedAreaTreeTile(
                      area: child,
                      index: 0,
                      searchQuery: widget.searchQuery,
                    ),
                  ),
                  ...widget.area.cameras.map(
                    (camera) => _CameraTile(
                      camera: camera,
                      searchQuery: widget.searchQuery,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasMatchingDescendant(AreaTree area) {
    for (final child in area.children) {
      if (child.name.toLowerCase().contains(widget.searchQuery)) return true;
      if (_hasMatchingDescendant(child)) return true;
    }
    for (final camera in area.cameras) {
      if (camera.name.toLowerCase().contains(widget.searchQuery)) return true;
    }
    return false;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'online':
        return Colors.green;
      case 'inactive':
      case 'offline':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

/// Camera tile
class _CameraTile extends StatelessWidget {
  final CameraEntity camera;
  final String searchQuery;

  const _CameraTile({required this.camera, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final matchesSearch =
        searchQuery.isEmpty || camera.name.toLowerCase().contains(searchQuery);

    if (!matchesSearch) return const SizedBox.shrink();

    return ModernCard(
      margin: const EdgeInsets.only(bottom: 8),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CameraStreamPageNew(
              cameraId: camera.id,
              cameraName: camera.name,
            ),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.videocam_rounded,
              color: Color(0xFFFF6B35),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  camera.name,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          StatusBadge(
            text: camera.isActive ? 'Online' : 'Offline',
            color: camera.isActive ? Colors.green : Colors.red,
            isActive: camera.isActive,
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.play_circle_filled_rounded,
            color: const Color(0xFFFF6B35).withOpacity(0.8),
            size: 28,
          ),
        ],
      ),
    );
  }
}
