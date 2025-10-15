import 'package:hive/hive.dart';

part 'sync_model.g.dart';

@HiveType(typeId: 10)
class SyncStatus {
  @HiveField(0)
  final String type;

  @HiveField(1)
  final int id;

  @HiveField(2)
  final bool isSynced;

  SyncStatus({
    required this.type,
    required this.id,
    required this.isSynced,
  });

  String get key => '$type-$id';
}
