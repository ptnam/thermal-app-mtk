import '../network/auth/auth_api_service.dart';
import '../network/auth/dto/login_request_dto.dart';
import '../network/core/api_result.dart';
import '../network/auth/dto/auth_tokens_dto.dart';

class AuthRemoteDataSource {
  final AuthApiService _api;

  AuthRemoteDataSource(this._api);

  Future<ApiResult<AuthTokensDto>> login(LoginRequestDto request) =>
      _api.login(request);

  Future<ApiResult<void>> logout({required String accessToken}) =>
      _api.logout(accessToken: accessToken);
}

