import 'package:hive/hive.dart';

part 'store_model.g.dart';

@HiveType(typeId: 0)
class Store {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String code;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String address;

  Store({
    required this.id,
    required this.code,
    required this.name,
    required this.address,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'address': address,
  };
}
