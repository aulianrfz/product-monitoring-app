import 'package:hive_flutter/hive_flutter.dart';
import 'package:task/core/config/app_config.dart';
import 'package:task/core/models/sync_model.dart';
import 'package:task/core/services/sync_services.dart';
import 'package:task/features/attendance/data/datasources/attendance_local_datasource.dart';
import 'package:task/features/attendance/data/datasources/attendance_remote_datasource.dart';
import 'package:task/features/attendance/data/models/attendance_model.dart';
import 'package:task/features/attendance/data/repositories/attendance_repository.dart';
import 'package:task/features/product/data/datasources/product_local_datasource.dart';
import 'package:task/features/product/data/datasources/product_remote_datasource.dart';
import 'package:task/features/product/data/models/product_model.dart';
import 'package:task/features/product/data/repositories/product_repository.dart';
import 'package:task/features/promo/data/datasources/promo_local_datasource.dart';
import 'package:task/features/promo/data/datasources/promo_remote_datasource.dart';
import 'package:task/features/promo/data/models/promo_model.dart';
import 'package:task/features/promo/data/repositories/promo_repository.dart';
import 'package:task/features/store/data/datasources/store_local_datasource.dart';
import 'package:task/features/store/data/datasources/store_remote_datasource.dart';
import 'package:task/features/store/data/models/store_model.dart';
import 'package:task/features/store/data/repositories/store_repository.dart';

class ServiceLocator {
  static late StoreRepository storeRepository;
  static late ProductRepository productRepository;
  static late PromoRepository promoRepository;
  static late AttendanceRepository attendanceRepository;
  static late SyncManager syncManager;

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(StoreAdapter());
    Hive.registerAdapter(ProductAdapter());
    Hive.registerAdapter(PromoAdapter());
    Hive.registerAdapter(SyncStatusAdapter());
    Hive.registerAdapter(AttendanceAdapter());

    attendanceRepository = AttendanceRepository(
      remoteDataSource: AttendanceRemoteDataSourceImpl(baseUrl: AppConfig.baseUrl),
      localDataSource: AttendanceLocalDataSourceImpl(),
    );

    storeRepository = StoreRepository(
      remoteDataSource: StoreRemoteDataSourceImpl(baseUrl: AppConfig.baseUrl),
      localDataSource: StoreLocalDataSourceImpl(),
    );

    productRepository = ProductRepository(
      remoteDataSource: ProductRemoteDataSourceImpl(baseUrl: AppConfig.baseUrl),
      localDataSource: ProductLocalDataSourceImpl(),
    );

    promoRepository = PromoRepository(
      remoteDataSource: PromoRemoteDataSourceImpl(baseUrl: AppConfig.baseUrl),
      localDataSource: PromoLocalDataSourceImpl(),
    );

    syncManager = SyncManager(repositories: [
      promoRepository,
      attendanceRepository,
    ]);
  }
}
