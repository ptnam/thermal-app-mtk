import 'package:hive/hive.dart';
import 'user.dart';

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    return User(id: id, name: name);
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
  }
}
