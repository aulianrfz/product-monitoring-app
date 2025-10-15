import 'package:hive/hive.dart';

part 'product_model.g.dart';

@HiveType(typeId: 1)
class Product {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String barcode;

  @HiveField(3)
  final String? size;

  @HiveField(4)
  final bool available;

  Product({
    required this.id,
    required this.name,
    required this.barcode,
    this.size,
    this.available = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      barcode: json['barcode'],
      size: json['size'],
      available: (json['available'] == 1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'size': size,
      'available': available ? 1 : 0,
    };
  }
}
