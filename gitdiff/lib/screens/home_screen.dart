import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_screen_controller.dart';
import '../../controllers/theme_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeScreenController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(HomeScreenController());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 1200;
    
    final topSpacing = size.height * 0.08; // 8% of screen height
    final betweenTitleAndInput = size.height * 0.05; // 5%
    final bottomSpacing = size.height * 0.03;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'GIT DIFF',
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => Get.find<ThemeController>().toggleTheme(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16 : 24, 
            vertical: isSmallScreen ? 12 : 16
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: topSpacing),

              Text(
                "GIT DIFF",
                style: TextStyle(
                  fontSize: isSmallScreen ? size.height * 0.04 : size.height * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                  letterSpacing: isSmallScreen ? 1.0 : 1.5,
                ),
              ),

              SizedBox(height: betweenTitleAndInput),

              TextField(
                onChanged: controller.updateRepoInput,
                decoration: InputDecoration(
                  hintText: "Enter GitHub repo link here",
                  hintStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    fontSize: isSmallScreen ? 13 : 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: isSmallScreen ? 20 : 24,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 14 : 16, 
                    vertical: isSmallScreen ? 12 : 14
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 14),
                    borderSide: Theme.of(context).inputDecorationTheme.border?.borderSide ?? BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 14),
                    borderSide: Theme.of(context).inputDecorationTheme.enabledBorder?.borderSide ?? BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 14),
                    borderSide: Theme.of(context).inputDecorationTheme.focusedBorder?.borderSide ?? const BorderSide(color: Colors.blue, width: 1.5),
                  ),
                ),
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 : 14,
                ),
              ),

              SizedBox(height: isSmallScreen ? 20 : 24),

              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 14 : 16
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 14),
                    ),
                    elevation: 3,
                  ),
                  onPressed: controller.isLoading.value ? null : controller.fetchRepoData,
                  child: controller.isLoading.value
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: isSmallScreen ? 18 : 20,
                              height: isSmallScreen ? 18 : 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
                              ),
                            ),
                            SizedBox(width: isSmallScreen ? 10 : 12),
                            Text(
                              "Fetching Repository...",
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          "Fetch Repository Data",
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                )),
              ),
              
              // Show additional loading info
              Obx(() => controller.isLoading.value
                  ? Padding(
                      padding: EdgeInsets.only(top: isSmallScreen ? 12 : 16),
                      child: Column(
                        children: [
                          Text(
                            "This may take a few moments...",
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                              fontSize: isSmallScreen ? 13 : 14,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 6 : 8),
                          Text(
                            "• Fetching repository data\n• Analyzing code with AI\n• Processing insights",
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                              fontSize: isSmallScreen ? 11 : 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink()),

              const Spacer(),

              Padding(
                padding: EdgeInsets.only(bottom: bottomSpacing),
                child: Text(
                  "Paste a public GitHub repository link to get started.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontSize: isSmallScreen ? size.height * 0.015 : size.height * 0.017,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
