import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:camera_viewer/presentation/widgets/common/common_widgets.dart';

import '../../../domain/entities/camera_stream.dart';
import '../../bloc/camera/camera_stream_bloc.dart';
import '../../../core/config/app_config.dart';
import '../../../di/injection.dart';

/// Camera Stream Page - Modern UI with better controls
class CameraStreamPageNew extends StatefulWidget {
  final int cameraId;
  final String cameraName;

  const CameraStreamPageNew({
    super.key,
    required this.cameraId,
    required this.cameraName,
  });

  @override
  State<CameraStreamPageNew> createState() => _CameraStreamPageNewState();
}

class _CameraStreamPageNewState extends State<CameraStreamPageNew>
    with TickerProviderStateMixin {
  late CameraStreamBloc _cameraStreamBloc;
  late AppConfig _appConfig;
  VideoPlayerController? _videoController;
  bool _isFullScreen = false;
  bool _showControls = true;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _appConfig = getIt<AppConfig>();
    _cameraStreamBloc = CameraStreamBloc(getCameraStreamUseCase: getIt());
    _cameraStreamBloc.add(FetchCameraStreamEvent(cameraId: widget.cameraId));

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  Future<void> _initializeVideo(String streamUrl) async {
    final hlsUrl = '${_appConfig.streamUrl}$streamUrl';

    try {
      _videoController?.dispose();
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(hlsUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false,
        ),
        httpHeaders: {
          'User-Agent': 'Mozilla/5.0',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
        },
      );

      await _videoController!.initialize();

      if (mounted) {
        setState(() {});
        _videoController!.play();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải video: ${e.toString()}'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            if (!_isFullScreen) _buildHeader(context),
            Expanded(
              child: BlocBuilder<CameraStreamBloc, CameraStreamState>(
                bloc: _cameraStreamBloc,
                builder: (context, state) {
                  if (state is CameraStreamLoading) {
                    return const LoadingStateWidget(
                      message: 'Đang tải stream...',
                    );
                  }

                  if (state is CameraStreamError) {
                    return ErrorStateWidget(
                      message: state.message,
                      onRetry: () {
                        _cameraStreamBloc.add(
                          FetchCameraStreamEvent(cameraId: widget.cameraId),
                        );
                      },
                    );
                  }

                  if (state is CameraStreamLoaded) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_videoController == null) {
                        _initializeVideo(
                          state.cameraStream.streamUrl ??
                              state.cameraStream.cameraName,
                        );
                      }
                    });

                    return _buildStreamContent(context, state.cameraStream);
                  }

                  return const Center(
                    child: Text(
                      'Đang khởi tạo...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
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
          Expanded(
            child: Text(
              widget.cameraName,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _ActionButton(
            icon: Icons.refresh_rounded,
            onTap: () {
              _videoController?.dispose();
              _videoController = null;
              _cameraStreamBloc.add(
                FetchCameraStreamEvent(cameraId: widget.cameraId),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStreamContent(BuildContext context, CameraStream stream) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Player
          _buildVideoPlayer(stream),
          const SizedBox(height: 24),

          // Status Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildStatusCard(stream),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(CameraStream stream) {
    return GestureDetector(
      onTap: () {
        setState(() => _showControls = !_showControls);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child:
              _videoController != null && _videoController!.value.isInitialized
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_videoController!),
                    // Play/Pause overlay
                    AnimatedOpacity(
                      opacity: _showControls ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
                            ],
                          ),
                        ),
                        child: Center(child: _buildPlayButton()),
                      ),
                    ),
                    // Status indicator
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Fullscreen button
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: _toggleFullScreen,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _isFullScreen
                                ? Icons.fullscreen_exit_rounded
                                : Icons.fullscreen_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Container(
                  color: Colors.grey.shade100,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0088FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF0088FF),
                            ),
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Đang tải video...',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    final isPlaying = _videoController?.value.isPlaying ?? false;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isPlaying) {
            _videoController?.pause();
          } else {
            _videoController?.play();
          }
        });
      },
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0088FF).withOpacity(0.9),
              const Color(0xFF00D4FF).withOpacity(0.9),
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0088FF).withOpacity(0.4),
              blurRadius: 20,
            ),
          ],
        ),
        child: Icon(
          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 36,
        ),
      ),
    );
  }

  Widget _buildVideoControls() {
    return ModernCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ControlButton(
            icon: Icons.replay_10_rounded,
            label: '-10s',
            onTap: () {
              final position =
                  _videoController?.value.position ?? Duration.zero;
              _videoController?.seekTo(position - const Duration(seconds: 10));
            },
          ),
          _ControlButton(
            icon: _videoController?.value.isPlaying ?? false
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            label: _videoController?.value.isPlaying ?? false
                ? 'Tạm dừng'
                : 'Phát',
            isMain: true,
            onTap: () {
              setState(() {
                if (_videoController?.value.isPlaying ?? false) {
                  _videoController?.pause();
                } else {
                  _videoController?.play();
                }
              });
            },
          ),
          _ControlButton(
            icon: Icons.forward_10_rounded,
            label: '+10s',
            onTap: () {
              final position =
                  _videoController?.value.position ?? Duration.zero;
              _videoController?.seekTo(position + const Duration(seconds: 10));
            },
          ),
          _ControlButton(
            icon: Icons.fullscreen_rounded,
            label: 'Toàn màn',
            onTap: _toggleFullScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(CameraStream stream) {
    final isOnline = stream.status == 'online';

    return ModernCard(
      gradient: LinearGradient(
        colors: isOnline
            ? [Colors.green.withOpacity(0.05), Colors.white]
            : [Colors.orange.withOpacity(0.05), Colors.white],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isOnline
                    ? [
                        Colors.green.withOpacity(0.15),
                        Colors.green.withOpacity(0.08),
                      ]
                    : [
                        Colors.orange.withOpacity(0.15),
                        Colors.orange.withOpacity(0.08),
                      ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
              color: isOnline ? Colors.green : Colors.orange,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trạng thái kết nối',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  isOnline ? 'Đang trực tuyến' : 'Ngoại tuyến',
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(
            text: isOnline ? 'Online' : 'Offline',
            color: isOnline ? Colors.green : Colors.orange,
            isActive: isOnline,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onCopy,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (onCopy != null)
                  GestureDetector(
                    onTap: onCopy,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.copy_rounded, size: 14, color: color),
                          const SizedBox(width: 4),
                          Text(
                            'Copy',
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                  fontFamily: 'monospace',
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Đã sao chép vào clipboard'),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _videoController?.dispose();
    _cameraStreamBloc.close();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
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
          child: Icon(icon, color: Colors.grey.shade700, size: 22),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isMain;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isMain = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isMain ? 52 : 44,
            height: isMain ? 52 : 44,
            decoration: BoxDecoration(
              gradient: isMain
                  ? const LinearGradient(
                      colors: [Color(0xFF0088FF), Color(0xFF00D4FF)],
                    )
                  : null,
              color: isMain ? null : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(isMain ? 16 : 12),
              boxShadow: isMain
                  ? [
                      BoxShadow(
                        color: const Color(0xFF0088FF).withOpacity(0.3),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isMain ? Colors.white : Colors.grey.shade700,
              size: isMain ? 28 : 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
