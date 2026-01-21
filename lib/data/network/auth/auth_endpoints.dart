import '../core/endpoints.dart';

class AuthEndpoints extends Endpoints {
  AuthEndpoints(this.baseUrl);

  @override
  final String baseUrl;

  String get login => path('/api/Auth/login');

  String get logout => path('/api/Auth/logout');

  String get refresh => path('/api/Auth/refresh');

  String get profile => path('/api/Auth/myProfile');
}


