import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/di/service_locator.dart';
import 'core/services/sync_services.dart';
import 'features/authentication/data/models/user_model.dart';
import 'features/authentication/presentation/viewmodels/auth_viewmodel.dart';
import 'features/authentication/presentation/viewmodels/login_viewmodel.dart';
import 'features/authentication/presentation/views/login_view.dart';
import 'features/attendance/presentation/viewmodels/attendance_viewmodel.dart';
import 'features/attendance/presentation/views/attendance_view.dart';
import 'features/store/presentation/viewmodels/store_viewmodel.dart';
import 'features/store/presentation/views/store_list_view.dart';
import 'features/store/presentation/views/store_detail_view.dart';
import 'features/product/presentation/viewmodels/product_viewmodel.dart';
import 'features/product/presentation/views/product_list_view.dart';
import 'features/promo/presentation/viewmodels/promo_viewmodel.dart';
import 'features/promo/presentation/views/promo_list_view.dart';
import 'features/store/data/models/store_model.dart';
import 'features/authentication/data/datasources/auth_remote_datasources.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServiceLocator.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => AttendanceViewModel(repository: ServiceLocator.attendanceRepository)),
        ChangeNotifierProvider(create: (_) => StoreViewModel(repository: ServiceLocator.storeRepository)),
        ChangeNotifierProvider(create: (_) => ProductViewModel(repository: ServiceLocator.productRepository)),
        ChangeNotifierProvider(create: (_) => PromoViewModel(repository: ServiceLocator.promoRepository, syncManager: ServiceLocator.syncManager)),
        ChangeNotifierProvider(create: (_) => AuthViewModel(authService: AuthService())),
      ],
      child: MyApp(syncManager: ServiceLocator.syncManager),
    ),
  );
}

class MyApp extends StatefulWidget {
  final SyncManager syncManager;
  const MyApp({super.key, required this.syncManager});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    widget.syncManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    if (authViewModel.isChecking) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'Panda Biru Monitoring',
      debugShowCheckedModeBanner: false,

      home: authViewModel.isLoggedIn
          ? FutureBuilder<User?>(
        future: _loadUserFromPrefs(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final user = snapshot.data!;

          context.read<LoginViewModel>().setUser(user);

          widget.syncManager.startMonitoring(user.token);

          return AttendanceView(user: user);
        },
      )
          : const LoginScreen(),
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/absensi':
        final user = settings.arguments as User;
        return MaterialPageRoute(
          builder: (_) => AttendanceView(user: user),
        );
      case '/stores':
        final user = settings.arguments as User;
        return MaterialPageRoute(builder: (_) => StoreListView(user: user));
      case '/store-detail':
        final store = settings.arguments as Store;
        return MaterialPageRoute(builder: (_) => StoreDetailView(store: store));
      case '/products':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ProductListView(user: args['user'], store: args['store']),
        );
      case '/promos':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PromoListView(store: args['store'], user: args['user']),
        );
      default:
        return null;
    }
  }

  Future<User?> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final name = prefs.getString('name');
    final email = prefs.getString('email') ?? '';
    final id = prefs.getInt('id') ?? 0;

    if (token != null && name != null) {
      return User(id: id, name: name, email: email, token: token);
    }
    return null;
  }

}
