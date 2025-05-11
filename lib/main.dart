import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movie_test_app/core/routes/app_routes.dart';
import 'package:movie_test_app/core/theme/app_theme.dart';
import 'package:movie_test_app/core/utils/navigation_service.dart';
import 'package:movie_test_app/core/utils/performance_monitor.dart';
import 'package:movie_test_app/core/utils/service_locator.dart';
import 'package:movie_test_app/core/utils/responsive_size_util.dart';
import 'package:movie_test_app/features/movies/presentation/providers/movie_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  final PerformanceMonitor _performanceMonitor = PerformanceMonitor();

  @override
  void initState() {
    super.initState();

    if (const bool.fromEnvironment('dart.vm.product') == false) {
      _performanceMonitor.startMonitoring(this);
    }
  }

  @override
  void dispose() {
    _performanceMonitor.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MovieProvider())],
      child: MaterialApp(
        navigatorKey: NavigationService.navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Movie App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        builder: (context, child) {
          // Initialize responsive size util here
          ResponsiveSizeUtil.init(context);

          // Return the child with appropriate text scaling
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.0, // Lock text scaling
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
