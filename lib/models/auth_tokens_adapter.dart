import 'package:hive/hive.dart';
import '../domain/entities/auth_tokens.dart';

class AuthTokensAdapter extends TypeAdapter<AuthTokens> {
  @override
  final int typeId = 1; // keep previous type id for compatibility

  @override
  AuthTokens read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuthTokens(
      accessToken: fields[0] as String? ?? '',
      refreshToken: fields[1] as String? ?? '',
      tokenType: fields[2] as String? ?? 'Bearer',
      expiresIn: fields[3] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, AuthTokens obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.accessToken)
      ..writeByte(1)
      ..write(obj.refreshToken)
      ..writeByte(2)
      ..write(obj.tokenType)
      ..writeByte(3)
      ..write(obj.expiresIn);
  }
}
