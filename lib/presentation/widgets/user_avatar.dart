import 'package:flutter/material.dart';

/// Widget avatar hiện đại với gradient và hiệu ứng đẹp mắt
/// Hiển thị ảnh avatar hoặc chữ cái đầu của tên với gradient background
class UserAvatar extends StatefulWidget {
  final String? avatarUrl;
  final String name;
  final double radius;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;
  final List<Color>? gradientColors;
  final Color? textColor;
  final VoidCallback? onTap;
  final bool showOnlineIndicator;
  final bool isOnline;
  final bool enableAnimation;

  const UserAvatar({
    super.key,
    this.avatarUrl,
    required this.name,
    this.radius = 24,
    this.showBorder = true,
    this.borderColor,
    this.borderWidth = 2.5,
    this.gradientColors,
    this.textColor,
    this.onTap,
    this.showOnlineIndicator = false,
    this.isOnline = false,
    this.enableAnimation = true,
  });

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Lấy 2 chữ cái đầu của tên
  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.trim().substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  /// Tạo gradient đẹp mắt dựa trên tên
  List<Color> _getGradientColors(String name) {
    if (widget.gradientColors != null) return widget.gradientColors!;

    final gradients = [
      [const Color(0xFF667eea), const Color(0xFF764ba2)], // Purple blue
      [const Color(0xFFf093fb), const Color(0xFFF5576C)], // Pink
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)], // Blue cyan
      [const Color(0xFF43e97b), const Color(0xFF38f9d7)], // Green
      [const Color(0xFFfa709a), const Color(0xFFfee140)], // Pink yellow
      [const Color(0xFF30cfd0), const Color(0xFF330867)], // Teal purple
      [const Color(0xFFa8edea), const Color(0xFFfed6e3)], // Light pastel
      [const Color(0xFFff9a9e), const Color(0xFFfecfef)], // Soft pink
      [const Color(0xFFffecd2), const Color(0xFFfcb69f)], // Peach
      [const Color(0xFFa1c4fd), const Color(0xFFc2e9fb)], // Sky blue
    ];

    final hash = name.hashCode.abs();
    return gradients[hash % gradients.length];
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enableAnimation) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enableAnimation) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enableAnimation) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = _getGradientColors(widget.name);
    final borderColor = widget.borderColor ?? Theme.of(context).colorScheme.surface;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: widget.onTap != null ? _handleTapDown : null,
      onTapUp: widget.onTap != null ? _handleTapUp : null,
      onTapCancel: widget.onTap != null ? _handleTapCancel : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.onTap != null ? _scaleAnimation.value : 1.0,
            child: child,
          );
        },
        child: Stack(
          children: [
            // Avatar chính
            Container(
              width: widget.radius * 2,
              height: widget.radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: widget.showBorder
                      ? Border.all(
                          color: borderColor,
                          width: widget.borderWidth,
                        )
                      : null,
                ),
                child: ClipOval(
                  child: widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
                      ? Image.network(
                          widget.avatarUrl!,
                          fit: BoxFit.cover,
                          width: widget.radius * 2,
                          height: widget.radius * 2,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildGradientAvatar(gradientColors),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return _buildGradientAvatar(gradientColors);
                          },
                        )
                      : _buildGradientAvatar(gradientColors),
                ),
              ),
            ),

            // Online indicator
            if (widget.showOnlineIndicator)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: widget.radius * 0.35,
                  height: widget.radius * 0.35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isOnline ? const Color(0xFF4ade80) : Colors.grey.shade400,
                    border: Border.all(
                      color: borderColor,
                      width: widget.borderWidth * 0.6,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientAvatar(List<Color> gradientColors) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Center(
        child: Text(
          _getInitials(widget.name),
          style: TextStyle(
            color: widget.textColor ?? Colors.white,
            fontSize: widget.radius * 0.65,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
