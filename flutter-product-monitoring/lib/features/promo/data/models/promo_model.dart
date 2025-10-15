import 'package:hive/hive.dart';

part 'promo_model.g.dart';

@HiveType(typeId: 3)
class Promo {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final int storeId;

  @HiveField(2)
  final int productId;

  @HiveField(3)
  final String productName;

  @HiveField(4)
  final double normalPrice;

  @HiveField(5)
  final double promoPrice;

  Promo({
    this.id,
    required this.storeId,
    required this.productId,
    required this.productName,
    required this.normalPrice,
    required this.promoPrice,
  });

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'store_id': storeId,
    'product_id': productId,
    'normal_price': normalPrice,
    'promo_price': promoPrice,
  };

  factory Promo.fromJson(Map<String, dynamic> json) => Promo(
    id: json['id'],
    storeId: json['store_id'],
    productId: json['product_id'],
    productName: json['product']['name'] ?? '',
    normalPrice: (json['normal_price'] as num).toDouble(),
    promoPrice: (json['promo_price'] as num).toDouble(),
  );
}
