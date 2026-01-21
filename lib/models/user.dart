import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  User({required this.id, required this.name});

  @override
  String toString() => 'User(id: $id, name: $name)';
}
