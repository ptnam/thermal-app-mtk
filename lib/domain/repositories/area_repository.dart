import 'package:dartz/dartz.dart';

import '../../core/error/failure.dart';
import '../entities/area_tree.dart';

/// Repository interface for Area operations
/// Abstracts data sources (remote API, local cache)
abstract class AreaRepository {
  /// Get complete area tree hierarchy with cameras
  Future<Either<Failure, List<AreaTree>>> getAreaTreeWithCameras();

  /// Get single area by ID
  Future<Either<Failure, AreaTree>> getAreaById(int id);
}
