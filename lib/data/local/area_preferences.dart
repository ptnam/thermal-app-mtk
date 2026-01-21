import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera_viewer/domain/entities/area_tree.dart';

/// Service lưu trữ thông tin khu vực đã chọn
class AreaPreferences {
  static const String _selectedAreaKey = 'selected_area';
  static const String _selectedAreaIdKey = 'selected_area_id';

  final SharedPreferences _prefs;

  AreaPreferences(this._prefs);

  /// Lưu khu vực đã chọn
  Future<void> saveSelectedArea(AreaTree area) async {
    final areaJson = jsonEncode(_areaToJson(area));
    await _prefs.setString(_selectedAreaKey, areaJson);
    await _prefs.setInt(_selectedAreaIdKey, area.id);
  }

  /// Lấy khu vực đã chọn
  Future<AreaTree?> getSelectedArea() async {
    final areaJson = _prefs.getString(_selectedAreaKey);
    if (areaJson == null) return null;

    try {
      final Map<String, dynamic> json = jsonDecode(areaJson);
      return _areaFromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Lấy ID khu vực đã chọn (để load lại từ API nếu cần)
  int? getSelectedAreaId() {
    return _prefs.getInt(_selectedAreaIdKey);
  }

  /// Kiểm tra đã chọn khu vực chưa
  bool hasSelectedArea() {
    return _prefs.containsKey(_selectedAreaKey);
  }

  /// Xóa khu vực đã chọn
  Future<void> clearSelectedArea() async {
    await _prefs.remove(_selectedAreaKey);
    await _prefs.remove(_selectedAreaIdKey);
  }

  /// Convert AreaTree to JSON (simplified for storage)
  Map<String, dynamic> _areaToJson(AreaTree area) {
    return {
      'uniqueId': area.uniqueId,
      'parentId': area.parentId,
      'name': area.name,
      'code': area.code,
      'id': area.id,
      'mapType': area.mapType,
      'photoPath': area.photoPath,
      'longitude': area.longitude,
      'latitude': area.latitude,
      'zoom': area.zoom,
      'note': area.note,
      'levelName': area.levelName,
      'status': area.status,
      'displayStatus': area.displayStatus,
      'createdAt': area.createdAt.toIso8601String(),
      'updatedAt': area.updatedAt?.toIso8601String(),
      'deletedAt': area.deletedAt?.toIso8601String(),
      'cameraCount': area.cameras.length,
      'childrenCount': area.children.length,
    };
  }

  /// Convert JSON to AreaTree (basic info only, without nested children)
  AreaTree _areaFromJson(Map<String, dynamic> json) {
    return AreaTree(
      uniqueId: json['uniqueId'] ?? '',
      parentId: json['parentId'],
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      id: json['id'] ?? 0,
      mapType: json['mapType'] ?? '',
      photoPath: json['photoPath'],
      longitude: (json['longitude'] ?? 0).toDouble(),
      latitude: (json['latitude'] ?? 0).toDouble(),
      zoom: json['zoom'] ?? 10,
      note: json['note'],
      levelName: json['levelName'],
      children: const [],
      cameras: const [],
      status: json['status'] ?? 'active',
      displayStatus: json['displayStatus'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'])
          : null,
    );
  }
}
