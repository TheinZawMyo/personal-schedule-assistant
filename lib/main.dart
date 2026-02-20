import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'models/timetable_entry.dart';
import 'models/settings_model.dart';
import 'services/notification_service.dart';
import 'providers/settings_provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'views/widgets/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize timezone data as early as possible
  tz.initializeTimeZones();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(ActivityCategoryAdapter());
  Hive.registerAdapter(RepeatCycleAdapter());
  Hive.registerAdapter(TimetableEntryAdapter());
  Hive.registerAdapter(SettingsModelAdapter());

  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();
  //await LocalNotificationService.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Personal Schedule Assistant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
