import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera_viewer/core/constants/colors.dart';
import 'package:camera_viewer/di/injection.dart';
import 'package:camera_viewer/presentation/widgets/common/common_widgets.dart';
import 'package:camera_viewer/presentation/bloc/area_selection/area_selection_bloc.dart';

import '../../bloc/notification/notification_bloc.dart';

class NotificationListPageNew extends StatefulWidget {
  const NotificationListPageNew({super.key});

  @override
  State<NotificationListPageNew> createState() =>
      _NotificationListPageNewState();
}

class _NotificationListPageNewState extends State<NotificationListPageNew>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String _selectedFilter = 'all';

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
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationBloc>(
      create: (_) {
        final bloc = NotificationBloc(
          getNotificationsUseCase: getIt(),
          getNotificationDetailUseCase: getIt(),
          logger: getIt(),
        );
        _loadNotifications(bloc);
        return bloc;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildAreaInfo(context),
              _buildFilterChips(context),
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

  void _loadNotifications(NotificationBloc bloc) {
    final now = DateTime.now();
    final areaState = context.read<AreaSelectionBloc>().state;

    Map<String, dynamic> params = {
      'page': 1,
      'pageSize': 20,
      'fromTime': now.subtract(const Duration(days: 7)).toIso8601String(),
    };

    // Filter by selected area
    if (areaState.hasSelectedArea && areaState.selectedArea != null) {
      params['areaId'] = areaState.selectedArea!.id;
    }

    bloc.add(LoadNotificationsEvent(queryParameters: params));
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B6B).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_rounded,
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
                  'Sự cố',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Cảnh báo & thông báo hệ thống',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          Builder(
            builder: (context) => _ActionButton(
              icon: Icons.refresh_rounded,
              onTap: () => _loadNotifications(context.read<NotificationBloc>()),
            ),
          ),
        ],
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
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B6B).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: const Color(0xFFFF6B6B),
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _FilterChip(
            label: 'Tất cả',
            icon: Icons.list_rounded,
            isSelected: _selectedFilter == 'all',
            onTap: () => setState(() => _selectedFilter = 'all'),
          ),
          _FilterChip(
            label: 'Chưa xử lý',
            icon: Icons.pending_rounded,
            isSelected: _selectedFilter == 'pending',
            color: Colors.orange,
            onTap: () => setState(() => _selectedFilter = 'pending'),
          ),
          _FilterChip(
            label: 'Đã xử lý',
            icon: Icons.check_circle_rounded,
            isSelected: _selectedFilter == 'resolved',
            color: Colors.green,
            onTap: () => setState(() => _selectedFilter = 'resolved'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        if (state is NotificationLoading) {
          return const LoadingStateWidget(
            message: 'Đang tải danh sách sự cố...',
          );
        }

        if (state is NotificationError) {
          return ErrorStateWidget(
            message: state.message,
            onRetry: () => _loadNotifications(context.read<NotificationBloc>()),
          );
        }

        if (state is NotificationListLoaded) {
          var items = state.list.items;

          // Filter by status
          if (_selectedFilter != 'all') {
            items = items.where((item) {
              final status = item.statusObject?.code?.toLowerCase() ?? '';
              return status == _selectedFilter;
            }).toList();
          }

          if (items.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.notifications_off_rounded,
              title: 'Không có thông báo',
              subtitle: _selectedFilter == 'all'
                  ? 'Chưa có sự cố nào được ghi nhận'
                  : 'Không có sự cố nào ở trạng thái này',
              onRetry: () =>
                  _loadNotifications(context.read<NotificationBloc>()),
            );
          }

          return RefreshIndicator(
            onRefresh: () async =>
                _loadNotifications(context.read<NotificationBloc>()),
            color: const Color(0xFFFF6B6B),
            backgroundColor: const Color(0xFF1E293B),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _NotificationCard(
                  item: items[index],
                  index: index,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => _NotificationDetailPageNew(
                          id: items[index].id,
                          dataTime: items[index].dataTime,
                        ),
                      ),
                    );
                  },
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

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? const Color(0xFF0088FF);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      chipColor.withOpacity(0.2),
                      chipColor.withOpacity(0.1),
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? chipColor.withOpacity(0.5)
                  : Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? chipColor : Colors.grey.shade500,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? chipColor : Colors.grey.shade700,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatefulWidget {
  final dynamic item;
  final int index;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.item,
    required this.index,
    required this.onTap,
  });

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300 + (widget.index * 50).clamp(0, 500)),
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
    final statusColor = _getStatusColor(widget.item.statusObject?.code);
    final resultColor = _getResultColor(widget.item.compareResultObject?.code);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(opacity: _fadeAnimation.value, child: child),
        );
      },
      child: ModernCard(
        margin: const EdgeInsets.only(bottom: 12),
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        resultColor.withOpacity(0.2),
                        resultColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: resultColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.warningEventName ?? 'Thông báo',
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.item.areaName ?? 'N/A',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  text: widget.item.statusObject?.name ?? 'N/A',
                  color: statusColor,
                  isActive: false,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Details row
            Row(
              children: [
                _DetailChip(
                  icon: Icons.settings_input_component_rounded,
                  label: widget.item.machineName ?? 'N/A',
                ),
                const SizedBox(width: 10),
                _DetailChip(
                  icon: Icons.thermostat_rounded,
                  label:
                      '${widget.item.componentValue?.toStringAsFixed(1) ?? 'N/A'}°C',
                  color: resultColor,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Footer
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: resultColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: resultColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.assessment_rounded,
                        size: 14,
                        color: resultColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.item.compareResultObject?.name ?? 'N/A',
                        style: TextStyle(
                          color: resultColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.item.formattedDate ?? 'N/A',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? code) {
    switch (code) {
      case 'Pending':
        return Colors.orange;
      case 'Resolved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getResultColor(String? code) {
    switch (code) {
      case 'Good':
        return Colors.green;
      case 'Bad':
        return Colors.red;
      case 'Warning':
        return Colors.orange;
      default:
        return const Color(0xFF0088FF);
    }
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _DetailChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? Colors.grey.shade600;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: chipColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Notification Detail Page - Modern UI
class _NotificationDetailPageNew extends StatelessWidget {
  final String id;
  final String? dataTime;

  const _NotificationDetailPageNew({required this.id, this.dataTime});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationBloc>(
      create: (_) {
        final bloc = NotificationBloc(
          getNotificationsUseCase: getIt(),
          getNotificationDetailUseCase: getIt(),
          logger: getIt(),
        );
        bloc.add(LoadNotificationDetailEvent(id: id, dataTime: dataTime ?? ''));
        return bloc;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Container(
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.grey.shade700,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Chi tiết sự cố',
                          style: TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: BlocBuilder<NotificationBloc, NotificationState>(
                    builder: (context, state) {
                      if (state is NotificationLoading) {
                        return const LoadingStateWidget(
                          message: 'Đang tải chi tiết...',
                        );
                      }

                      if (state is NotificationError) {
                        return ErrorStateWidget(message: state.message);
                      }

                      if (state is NotificationDetailLoaded) {
                        return _buildDetailContent(context, state.item);
                      }

                      return const Center(
                        child: Text(
                          'Đang tải...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, dynamic item) {
    final statusColor = _getStatusColor(item.statusObject?.code);
    final resultColor = _getResultColor(item.compareResultObject?.code);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status header card
          ModernCard(
            gradient: LinearGradient(
              colors: [
                resultColor.withOpacity(0.15),
                resultColor.withOpacity(0.05),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            resultColor.withOpacity(0.3),
                            resultColor.withOpacity(0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: resultColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.warningEventName ?? 'Thông báo',
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              StatusBadge(
                                text: item.statusObject?.name ?? 'N/A',
                                color: statusColor,
                                isActive: false,
                              ),
                              const SizedBox(width: 8),
                              StatusBadge(
                                text: item.compareResultObject?.name ?? 'N/A',
                                color: resultColor,
                                isActive: false,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Info cards
          const SectionHeader(
            title: 'Thông tin chi tiết',
            icon: Icons.info_outline_rounded,
          ),
          ModernCard(
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.location_on_rounded,
                  label: 'Khu vực',
                  value: item.areaName ?? 'N/A',
                ),
                _DetailRow(
                  icon: Icons.settings_input_component_rounded,
                  label: 'Thiết bị',
                  value: item.machineName ?? 'N/A',
                ),
                _DetailRow(
                  icon: Icons.thermostat_rounded,
                  label: 'Nhiệt độ',
                  value:
                      '${item.componentValue?.toStringAsFixed(1) ?? 'N/A'}°C',
                ),
                _DetailRow(
                  icon: Icons.schedule_rounded,
                  label: 'Thời gian',
                  value: item.formattedDate ?? 'N/A',
                  showDivider: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? code) {
    switch (code) {
      case 'Pending':
        return Colors.orange;
      case 'Resolved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getResultColor(String? code) {
    switch (code) {
      case 'Good':
        return Colors.green;
      case 'Bad':
        return Colors.red;
      case 'Warning':
        return Colors.orange;
      default:
        return const Color(0xFF0088FF);
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF0088FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF0088FF), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(color: Colors.grey.shade200, height: 1),
      ],
    );
  }
}
