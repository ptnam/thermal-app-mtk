import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:camera_viewer/core/constants/icons.dart';
import 'package:camera_viewer/core/constants/colors.dart';
import 'package:camera_viewer/presentation/widgets/app_drawer_service.dart';

/// Modern gradient app bar used across all screens
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showMenuButton;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? leading;
  final double elevation;

  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showMenuButton = true,
    this.showBackButton = false,
    this.onBackPressed,
    this.leading,
    this.elevation = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
          ],
        ),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.line.withOpacity(0.15),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Leading widget
              if (leading != null)
                leading!
              else if (showBackButton)
                _AppBarIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: onBackPressed ?? () => Navigator.of(context).pop(),
                )
              else if (showMenuButton)
                _AppBarIconButton(
                  svgIcon: AppIcons.icMenu,
                  onTap: () => AppDrawerService.openDrawer(),
                ),

              const SizedBox(width: 8),

              // Title
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Actions
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  final IconData? icon;
  final String? svgIcon;
  final VoidCallback onTap;
  final Color? color;

  const _AppBarIconButton({
    this.icon,
    this.svgIcon,
    required this.onTap,
    this.color,
  });

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
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Center(
            child: svgIcon != null
                ? SvgPicture.asset(
                    svgIcon!,
                    colorFilter: ColorFilter.mode(
                      color ?? Colors.white,
                      BlendMode.srcIn,
                    ),
                    width: 22,
                    height: 22,
                  )
                : Icon(
                    icon,
                    color: color ?? Colors.white,
                    size: 22,
                  ),
          ),
        ),
      ),
    );
  }
}

/// App bar icon button for actions
class AppBarActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final int? badgeCount;

  const AppBarActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _AppBarIconButton(
          icon: icon,
          onTap: onTap,
          color: color,
        ),
        if (badgeCount != null && badgeCount! > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B6B).withOpacity(0.4),
                    blurRadius: 4,
                  ),
                ],
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Center(
                child: Text(
                  badgeCount! > 99 ? '99+' : badgeCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
