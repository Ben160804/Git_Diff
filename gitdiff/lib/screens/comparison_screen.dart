import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/comparison_controller.dart';
import '../models/repository_model.dart';
import '../widgets/ai_analysis_widget.dart';
import '../controllers/theme_controller.dart';

class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ComparisonController controller = Get.put(ComparisonController());
    
    // Get screen dimensions for responsive design
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 1200;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Repository Comparison',
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            color: Theme.of(context).appBarTheme.foregroundColor,
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
          Obx(() {
            if (controller.isComparisonReady()) {
              return IconButton(
                icon: Icon(
                  Icons.refresh,
                  size: isSmallScreen ? 20 : 24,
                ),
                onPressed: controller.refreshComparison,
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        // Debug information
        print('=== Comparison Screen State ===');
        print('isLoading: ${controller.isLoading.value}');
        print('errorMessage: ${controller.errorMessage.value}');
        print('repo1: ${controller.repo1.value?.fullName}');
        print('repo2: ${controller.repo2.value?.fullName}');
        print('isComparisonReady: ${controller.isComparisonReady()}');
        print('=== End State ===');
        
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: isSmallScreen ? 32 : 40,
                  height: isSmallScreen ? 32 : 40,
                  child: const CircularProgressIndicator(),
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Text(
                  'Fetching repository data...',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: isSmallScreen ? 48 : 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Text(
                  'Error',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 24 : 32),
                  child: Text(
                    controller.errorMessage.value,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 20 : 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12 : 16,
                          vertical: isSmallScreen ? 8 : 12,
                        ),
                      ),
                      child: Text(
                        'Go Back',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 14,
                        ),
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 12 : 16),
                    ElevatedButton(
                      onPressed: () {
                        // Try to refresh the comparison
                        final arguments = Get.arguments as Map<String, dynamic>?;
                        if (arguments != null) {
                          final repo2Input = arguments['repo2Input'] as String;
                          print('Manual retry with input: $repo2Input');
                          controller.refreshComparison();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12 : 16,
                          vertical: isSmallScreen ? 8 : 12,
                        ),
                      ),
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        if (!controller.isComparisonReady()) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: isSmallScreen ? 32 : 40,
                  height: isSmallScreen ? 32 : 40,
                  child: const CircularProgressIndicator(),
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Text(
                  'Loading comparison...',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 20 : 24),
                // Debug information
                Container(
                  margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 24),
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Debug Info:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 13 : 14,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 6 : 8),
                      Text(
                        'Repo1: ${controller.repo1.value?.fullName ?? 'null'}',
                        style: TextStyle(fontSize: isSmallScreen ? 11 : 12),
                      ),
                      Text(
                        'Repo2: ${controller.repo2.value?.fullName ?? 'null'}',
                        style: TextStyle(fontSize: isSmallScreen ? 11 : 12),
                      ),
                      Text(
                        'Error: ${controller.errorMessage.value.isEmpty ? 'None' : controller.errorMessage.value}',
                        style: TextStyle(fontSize: isSmallScreen ? 11 : 12),
                      ),
                      SizedBox(height: isSmallScreen ? 6 : 8),
                      ElevatedButton(
                        onPressed: () {
                          final arguments = Get.arguments as Map<String, dynamic>?;
                          if (arguments != null) {
                            final repo2Input = arguments['repo2Input'] as String;
                            print('Manual retry with input: $repo2Input');
                            controller.refreshComparison();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 10 : 12,
                            vertical: isSmallScreen ? 6 : 8,
                          ),
                        ),
                        child: Text(
                          'Manual Retry',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return _buildComparisonContent(context, controller, isSmallScreen, isMediumScreen);
      }),
    );
  }

  Widget _buildComparisonContent(BuildContext context, ComparisonController controller, bool isSmallScreen, bool isMediumScreen) {
    final repo1 = controller.repo1.value!;
    final repo2 = controller.repo2.value!;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      child: Column(
        children: [
          // Header with repository names
          _buildComparisonHeader(repo1, repo2, isSmallScreen, isMediumScreen),
          SizedBox(height: isSmallScreen ? 16 : 24),
          
          // Basic stats comparison
          _buildBasicStatsComparison(controller, isSmallScreen, isMediumScreen),
          SizedBox(height: isSmallScreen ? 16 : 24),
          
          // Side-by-side repository cards
          _buildRepositoryCards(repo1, repo2, isSmallScreen, isMediumScreen),
          SizedBox(height: isSmallScreen ? 16 : 24),
          
          // AI Insights comparison
          if (repo1.aiInsights != null && repo2.aiInsights != null)
            _buildAIInsightsComparison(controller, isSmallScreen, isMediumScreen),
        ],
      ),
    );
  }

  Widget _buildComparisonHeader(RepositoryModel repo1, RepositoryModel repo2, bool isSmallScreen, bool isMediumScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 12 : isMediumScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(Get.context!).shadowColor.withOpacity(0.2),
            blurRadius: isSmallScreen ? 10 : 15,
            offset: Offset(0, isSmallScreen ? 4 : 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.compare_arrows,
                color: Theme.of(Get.context!).colorScheme.onPrimaryContainer,
                size: isSmallScreen ? 20 : 24,
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Expanded(
                child: Text(
                  'Repository Comparison',
                  style: TextStyle(
                    color: Theme.of(Get.context!).colorScheme.onPrimaryContainer,
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          
          // Responsive layout for repository headers
          if (isSmallScreen)
            // Stack vertically on small screens
            Column(
              children: [
                _buildRepositoryHeader(repo1, Colors.blue[100]!, isSmallScreen),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.compare_arrows,
                    color: Colors.white,
                    size: isSmallScreen ? 16 : 20,
                  ),
                ),
                SizedBox(height: 12),
                _buildRepositoryHeader(repo2, Colors.green[100]!, isSmallScreen),
              ],
            )
          else
            // Side by side on larger screens
            Row(
              children: [
                Expanded(
                  child: _buildRepositoryHeader(repo1, Colors.blue[100]!, isSmallScreen),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: isMediumScreen ? 8 : 12),
                  padding: EdgeInsets.all(isMediumScreen ? 8 : 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.compare_arrows,
                    color: Colors.white,
                    size: isMediumScreen ? 18 : 20,
                  ),
                ),
                Expanded(
                  child: _buildRepositoryHeader(repo2, Colors.green[100]!, isSmallScreen),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildRepositoryHeader(RepositoryModel repo, Color bgColor, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        border: Border.all(color: Theme.of(Get.context!).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: isSmallScreen ? 20 : 24,
            backgroundImage: NetworkImage(repo.owner.avatarUrl),
            backgroundColor: Theme.of(Get.context!).colorScheme.surface,
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            repo.fullName,
            style: TextStyle(
              color: Theme.of(Get.context!).colorScheme.onSurfaceVariant,
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            repo.owner.login,
            style: TextStyle(
              color: Theme.of(Get.context!).colorScheme.onSurfaceVariant.withOpacity(0.8),
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicStatsComparison(ComparisonController controller, bool isSmallScreen, bool isMediumScreen) {
    final stats = [
      {'label': 'Stars', 'key': 'stars', 'icon': Icons.star, 'color': Colors.amber},
      {'label': 'Forks', 'key': 'forks', 'icon': Icons.call_split, 'color': Colors.blue},
      {'label': 'Watchers', 'key': 'watchers', 'icon': Icons.visibility, 'color': Colors.green},
      {'label': 'Open Issues', 'key': 'issues', 'icon': Icons.bug_report, 'color': Colors.red},
      {'label': 'Size (KB)', 'key': 'size', 'icon': Icons.storage, 'color': Colors.orange},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Statistics Comparison',
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(Get.context!).colorScheme.onBackground,
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isSmallScreen ? 1 : 2,
            crossAxisSpacing: isSmallScreen ? 0 : 16,
            mainAxisSpacing: isSmallScreen ? 12 : 16,
            childAspectRatio: isSmallScreen ? 2.5 : 1.8,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            final winner = controller.getComparisonWinner('basic', stat['key'] as String);
            
            return _buildStatComparisonCard(
              label: stat['label'] as String,
              icon: stat['icon'] as IconData,
              color: stat['color'] as Color,
              winner: winner,
              controller: controller,
              category: 'basic',
              subcategory: stat['key'] as String,
              isSmallScreen: isSmallScreen,
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatComparisonCard({
    required String label,
    required IconData icon,
    required Color color,
    required String winner,
    required ComparisonController controller,
    required String category,
    required String subcategory,
    required bool isSmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).colorScheme.surface,
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(Get.context!).shadowColor.withOpacity(0.1),
            blurRadius: isSmallScreen ? 8 : 10,
            offset: Offset(0, isSmallScreen ? 3 : 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: isSmallScreen ? 18 : 20),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(Get.context!).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Obx(() {
            final data = controller.comparisonData[category]?[subcategory];
            if (data == null) return const SizedBox.shrink();
            
            return Row(
              children: [
                Expanded(
                  child: _buildStatValue(
                    value: data['repo1'].toString(),
                    isWinner: winner == 'repo1',
                    color: Theme.of(Get.context!).colorScheme.primary,
                    isSmallScreen: isSmallScreen,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 6 : 8),
                Expanded(
                  child: _buildStatValue(
                    value: data['repo2'].toString(),
                    isWinner: winner == 'repo2',
                    color: Theme.of(Get.context!).colorScheme.secondary,
                    isSmallScreen: isSmallScreen,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatValue({
    required String value,
    required bool isWinner,
    required Color color,
    required bool isSmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 6 : 8,
        horizontal: isSmallScreen ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: isWinner ? color.withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
        border: Border.all(
          color: isWinner ? color : Colors.grey[300]!,
          width: isWinner ? 2 : 1,
        ),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: isSmallScreen ? 14 : 16,
          fontWeight: FontWeight.bold,
          color: isWinner ? color : Colors.grey[700],
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildRepositoryCards(RepositoryModel repo1, RepositoryModel repo2, bool isSmallScreen, bool isMediumScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Repository Information',
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        
        // Responsive layout for repository cards
        if (isSmallScreen)
          // Stack vertically on small screens
          Column(
            children: [
              _buildRepositoryCard(repo1, 'Repository 1', Colors.blue, isSmallScreen),
              SizedBox(height: 16),
              _buildRepositoryCard(repo2, 'Repository 2', Colors.green, isSmallScreen),
            ],
          )
        else
          // Side by side on larger screens
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildRepositoryCard(repo1, 'Repository 1', Colors.blue, isSmallScreen),
              ),
              SizedBox(width: isMediumScreen ? 12 : 16),
              Expanded(
                child: _buildRepositoryCard(repo2, 'Repository 2', Colors.green, isSmallScreen),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildRepositoryCard(RepositoryModel repo, String title, Color color, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).colorScheme.surface,
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(Get.context!).shadowColor.withOpacity(0.1),
            blurRadius: isSmallScreen ? 8 : 10,
            offset: Offset(0, isSmallScreen ? 3 : 4),
          ),
        ],
        border: Border.all(color: Theme.of(Get.context!).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.folder,
                  color: color,
                  size: isSmallScreen ? 16 : 20,
                ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(Get.context!).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          
          // Basic info
          _buildInfoRow('Name', repo.fullName, isSmallScreen),
          _buildInfoRow('Language', repo.language ?? 'Unknown', isSmallScreen),
          _buildInfoRow('Size', '${repo.size} KB', isSmallScreen),
          _buildInfoRow('Created', _formatDate(repo.createdAt), isSmallScreen),
          _buildInfoRow('Updated', _formatDate(repo.updatedAt), isSmallScreen),
          _buildInfoRow('License', repo.license ?? 'None', isSmallScreen),
          _buildInfoRow('Private', repo.isPrivate ? 'Yes' : 'No', isSmallScreen),
          _buildInfoRow('Fork', repo.isFork ? 'Yes' : 'No', isSmallScreen),
          
          SizedBox(height: isSmallScreen ? 12 : 16),
          
          // Topics
          if (repo.topics?.isNotEmpty ?? false) ...[
            Text(
              'Topics',
              style: TextStyle(
                fontSize: isSmallScreen ? 13 : 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Wrap(
              spacing: isSmallScreen ? 4 : 6,
              runSpacing: isSmallScreen ? 4 : 6,
              children: repo.topics!.take(isSmallScreen ? 3 : 5).map((topic) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 6 : 8,
                    vertical: isSmallScreen ? 3 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                  ),
                  child: Text(
                    topic,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 9 : 10,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 3 : 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isSmallScreen ? 60 : 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: isSmallScreen ? 11 : 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isSmallScreen ? 11 : 12,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsightsComparison(ComparisonController controller, bool isSmallScreen, bool isMediumScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Insights Comparison',
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        
        // AI Scores comparison
        _buildAIScoresComparison(controller, isSmallScreen, isMediumScreen),
        SizedBox(height: isSmallScreen ? 16 : 24),
        
        // Responsive layout for AI analysis widgets
        if (isSmallScreen)
          // Stack vertically on small screens
          Column(
            children: [
              _buildAIWidgetCard(
                controller.repo1.value!,
                'Repository 1',
                Colors.blue,
                isSmallScreen,
              ),
              SizedBox(height: 16),
              _buildAIWidgetCard(
                controller.repo2.value!,
                'Repository 2',
                Colors.green,
                isSmallScreen,
              ),
            ],
          )
        else
          // Side-by-side on larger screens
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildAIWidgetCard(
                  controller.repo1.value!,
                  'Repository 1',
                  Colors.blue,
                  isSmallScreen,
                ),
              ),
              SizedBox(width: isMediumScreen ? 12 : 16),
              Expanded(
                child: _buildAIWidgetCard(
                  controller.repo2.value!,
                  'Repository 2',
                  Colors.green,
                  isSmallScreen,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildAIScoresComparison(ComparisonController controller, bool isSmallScreen, bool isMediumScreen) {
    final scores = [
      {'label': 'Overall Score', 'key': 'overallScore'},
      {'label': 'Code Quality', 'key': 'codeQuality'},
      {'label': 'Security', 'key': 'security'},
      {'label': 'Maintainability', 'key': 'maintainability'},
      {'label': 'Architecture', 'key': 'architecture'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isSmallScreen ? 1 : 2,
        crossAxisSpacing: isSmallScreen ? 0 : 16,
        mainAxisSpacing: isSmallScreen ? 12 : 16,
        childAspectRatio: isSmallScreen ? 2.8 : 2.0,
      ),
      itemCount: scores.length,
      itemBuilder: (context, index) {
        final score = scores[index];
        final winner = controller.getComparisonWinner('aiInsights', score['key'] as String);
        
        return _buildStatComparisonCard(
          label: score['label'] as String,
          icon: Icons.psychology,
          color: Colors.purple,
          winner: winner,
          controller: controller,
          category: 'aiInsights',
          subcategory: score['key'] as String,
          isSmallScreen: isSmallScreen,
        );
      },
    );
  }

  Widget _buildAIWidgetCard(RepositoryModel repo, String title, Color color, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).colorScheme.surface,
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(Get.context!).shadowColor.withOpacity(0.1),
            blurRadius: isSmallScreen ? 8 : 10,
            offset: Offset(0, isSmallScreen ? 3 : 4),
          ),
        ],
        border: Border.all(color: Theme.of(Get.context!).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: color,
                size: isSmallScreen ? 16 : 20,
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          AIAnalysisWidget(
            key: ValueKey('ai_analysis_${repo.aiInsights?.generatedAt?.millisecondsSinceEpoch ?? 'null'}'),
            aiInsights: repo.aiInsights,
            isLoading: false,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
