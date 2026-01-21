/// Camera API endpoints
class CameraEndpoints {
  final String baseUrl;

  CameraEndpoints(this.baseUrl);

  /// Get camera stream URL
  /// [cameraId] - ID của camera
  String cameraStream(int cameraId) => '$baseUrl/api/Cameras/stream/$cameraId';
}
