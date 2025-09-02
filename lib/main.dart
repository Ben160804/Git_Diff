import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gitdiff/screens/dashboard_screen.dart';
import 'package:gitdiff/screens/home_screen.dart';
import 'package:gitdiff/screens/comparison_screen.dart';
import 'package:gitdiff/services/github_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'models/repository_model.dart';
import 'controllers/theme_controller.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from assets
  print("Loading env file from assets...");
  bool envLoaded = false;
  
  try {
    await dotenv.load(fileName: ".env");
    print("SUCCESS: Env file loaded from assets!");

    envLoaded = true;
  } catch (e) {
    print("ERROR loading env file from assets: $e");
    print("Trying to continue without environment variables...");
  }
  
  if (!envLoaded) {
    print("WARNING: Could not load env file. AI features may not work.");
    print("Continuing without environment variables...");
  }
  
  await Hive.initFlutter();

  Hive.registerAdapter(RepositoryModelAdapter());
  Hive.registerAdapter(OwnerModelAdapter());
  Hive.registerAdapter(ContributorModelAdapter());
  Hive.registerAdapter(CommitActivityModelAdapter());
  Hive.registerAdapter(AIInsightsModelAdapter());
  Hive.registerAdapter(LanguageStatsModelAdapter());
  Hive.registerAdapter(RepositoryComparisonModelAdapter());

  await Hive.openBox<RepositoryModel>('repositories');
  Get.put(GitHubService());
  Get.put(ThemeController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    final Color seed = Colors.deepPurple;

    final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF7F7FA),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      cardColor: Colors.white,
      dividerColor: Colors.grey.shade300,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seed,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: seed, width: 1.5),
        ),
      ),
      useMaterial3: true,
    );

    final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardColor: const Color(0xFF1E1E1E),
      dividerColor: const Color(0xFF2A2A2A),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seed,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: seed, width: 1.5),
        ),
      ),
      useMaterial3: true,
    );

    return Obx(() => GetMaterialApp(
      title: 'GIT DIFF',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeController.themeMode,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const HomeScreen()),
        GetPage(name: '/dashboard', page: () => DashboardScreen()),
        GetPage(name: '/comparison', page: () => const ComparisonScreen()),
      ],
    ));
  }
}

