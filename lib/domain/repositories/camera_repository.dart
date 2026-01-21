import 'package:dartz/dartz.dart';

import '../../core/error/failure.dart';
import '../entities/camera_stream.dart';

/// Repository interface for Camera operations
abstract class CameraRepository {
  /// Get camera stream by camera ID
  /// [cameraId] - ID của camera
  /// Returns: Either Failure or CameraStream
  Future<Either<Failure, CameraStream>> getCameraStream({required int cameraId});
}
