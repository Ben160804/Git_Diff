import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_screen_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/repo_info_card_widget.dart';
import '../models/repository_model.dart';
import '../controllers/theme_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Wait for AI service to be ready + extra seconds
    _waitForServices();
  }

  Future<void> _waitForServices() async {
    // Wait for AI service initialization + extra buffer time
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'Loading Dashboard...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Please wait while we prepare the repository analysis tools',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final DashboardController dashboardController = Get.put(DashboardController());
    final HomeScreenController homeController = Get.find<HomeScreenController>();

    // Listen to repository updates from HomeScreenController
    ever(homeController.repositoryModel, (RepositoryModel? repository) {
      if (repository != null) {
        dashboardController.onRepositoryUpdated(repository);
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Repository Dashboard',
          style: TextStyle(color: Theme.of(context).appBarTheme.foregroundColor),
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: dashboardController.refreshDashboard,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'clear':
                  dashboardController.clearAllData();
                  break;
                case 'export':
                  Get.snackbar("Info", "Export feature coming soon!");
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Clear All Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export Data'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (dashboardController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            dashboardController.refreshDashboard();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Repository Card (if available)
                Obx(() {
                  final currentRepo = homeController.repositoryModel.value;
                  if (currentRepo != null) {
                    return Column(
                      children: [
                        _buildComparisonSection(currentRepo),
                        const SizedBox(height: 24),
                        _buildCurrentRepositorySection(currentRepo, dashboardController),
                      ],
                    );
                  }
                  return _buildEmptyCurrentRepositorySection();
                }),

                const SizedBox(height: 24),

                // Current Repository Timeline
                // _buildCurrentRepositoryTimeline(homeController.repositoryModel.value),

                const SizedBox(height: 24),

                // Filter Section
                _buildFilterSection(dashboardController),

                const SizedBox(height: 16),

                // Repositories List
                _buildRepositoriesList(dashboardController),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildComparisonSection(RepositoryModel currentRepo) {
    final TextEditingController compareController = TextEditingController();
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final isMediumScreen = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
        
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isSmallScreen ? 16 : isMediumScreen ? 18 : 20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.08),
                blurRadius: isSmallScreen ? 8 : 10,
                offset: Offset(0, isSmallScreen ? 3 : 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.compare_arrows,
                    size: isSmallScreen ? 20 : 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Expanded(
                    child: Text(
                      'Compare Repositories',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Text(
                'Compare "${currentRepo.fullName}" with another repository',
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 : 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              
              // Responsive layout for input and button
              if (isSmallScreen)
                // Stack vertically on small screens
                Column(
                  children: [
                    TextField(
                      controller: compareController,
                      decoration: InputDecoration(
                        hintText: 'Enter GitHub repository link (e.g., https://github.com/flutter/flutter)',
                        hintStyle: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: Theme.of(context).inputDecorationTheme.border?.borderSide ?? BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: Theme.of(context).inputDecorationTheme.enabledBorder?.borderSide ?? BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: Theme.of(context).inputDecorationTheme.focusedBorder?.borderSide ?? BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        prefixIcon: Icon(
                          Icons.link,
                          color: Theme.of(context).colorScheme.primary,
                          size: 18,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final compareRepo = compareController.text.trim();
                          if (compareRepo.isNotEmpty) {
                            Get.toNamed('/comparison', arguments: {
                              'repo1': currentRepo,
                              'repo2Input': compareRepo,
                            });
                          } else {
                            Get.snackbar(
                              'Error',
                              'Please enter a repository link to compare',
                              backgroundColor: Colors.red[100],
                              colorText: Colors.red[800],
                            );
                          }
                        },
                        icon: Icon(
                          Icons.compare_arrows,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 18,
                        ),
                        label: Text(
                          'Compare',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          elevation: 4,
                          shadowColor: Theme.of(context).shadowColor.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                // Side by side on larger screens
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: compareController,
                        decoration: InputDecoration(
                          hintText: 'Enter GitHub repository link (e.g., https://github.com/flutter/flutter)',
                          hintStyle: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: Theme.of(context).inputDecorationTheme.border?.borderSide ?? BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: Theme.of(context).inputDecorationTheme.enabledBorder?.borderSide ?? BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: Theme.of(context).inputDecorationTheme.focusedBorder?.borderSide ?? BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.link,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                    SizedBox(width: isMediumScreen ? 10 : 12),
                    Container(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final compareRepo = compareController.text.trim();
                          if (compareRepo.isNotEmpty) {
                            Get.toNamed('/comparison', arguments: {
                              'repo1': currentRepo,
                              'repo2Input': compareRepo,
                            });
                          } else {
                            Get.snackbar(
                              'Error',
                              'Please enter a repository link to compare',
                              backgroundColor: Colors.red[100],
                              colorText: Colors.red[800],
                            );
                          }
                        },
                        icon: Icon(
                          Icons.compare_arrows,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 20,
                        ),
                        label: Text(
                          'Compare',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          elevation: 4,
                          shadowColor: Theme.of(context).shadowColor.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentRepositorySection(RepositoryModel repository, DashboardController dashboardController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Current Repository',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    dashboardController.isRepositoryFavorite(repository)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: dashboardController.isRepositoryFavorite(repository)
                        ? Colors.red
                        : Colors.grey,
                  ),
                  onPressed: () => dashboardController.toggleRepositoryFavorite(repository),
                ),
                IconButton(
                  icon: Icon(
                    dashboardController.isCardExpanded.value
                        ? Icons.expand_less
                        : Icons.expand_more,
                  ),
                  onPressed: dashboardController.toggleCardExpansion,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: dashboardController.isCardExpanded.value
              ? RepositoryInfoCard(
            repository: repository,
            showFullDetails: true,
          )
              : _buildCollapsedRepositoryCard(repository),
        )),
      ],
    );
  }

  Widget _buildEmptyCurrentRepositorySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search,
            size: 48,
            color: Colors.blue[300],
          ),
          const SizedBox(height: 12),
          Text(
            'No Repository Selected',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search for a repository from the home screen to see it here',
            style: TextStyle(
              color: Colors.blue[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedRepositoryCard(RepositoryModel repository) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(repository.owner.avatarUrl),
            backgroundColor: Colors.grey[300],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  repository.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (repository.description != null)
                  Text(
                    repository.description!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber[700]),
                  const SizedBox(width: 4),
                  Text(
                    _formatNumber(repository.stargazersCount),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.call_split, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatNumber(repository.forksCount),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(DashboardController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Repository History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: FilterType.values.map((filterType) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Obx(() => FilterChip(
                  label: Text(_getFilterLabel(filterType)),
                  selected: controller.selectedFilterType.value == filterType,
                  onSelected: (_) => controller.setFilterType(filterType),
                  selectedColor: Colors.blue[100],
                  checkmarkColor: Colors.blue[800],
                )),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRepositoriesList(DashboardController controller) {
    return Obx(() {
      final filteredRepos = controller.getFilteredRepositories();

      if (filteredRepos.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.inbox,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No repositories found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Search for repositories from the home screen to see them here',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filteredRepos.length,
        itemBuilder: (context, index) {
          final repository = filteredRepos[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: RepositoryInfoCard(
              repository: repository,
              showFullDetails: false,
              onTap: () => _showRepositoryDetails(context, repository, controller),
            ),
          );
        },
      );
    });
  }

  void _showRepositoryDetails(BuildContext context, RepositoryModel repository, DashboardController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Repository Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              controller.isRepositoryFavorite(repository)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: controller.isRepositoryFavorite(repository)
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                            onPressed: () => controller.toggleRepositoryFavorite(repository),
                          ),
                        ],
                      ),
                      RepositoryInfoCard(
                        repository: repository,
                        showFullDetails: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFilterLabel(FilterType filterType) {
    switch (filterType) {
      case FilterType.all:
        return 'All';
      case FilterType.favorites:
        return 'Favorites';
      case FilterType.recent:
        return 'Recent';
      case FilterType.starred:
        return 'Most Starred';
      case FilterType.forks:
        return 'Forks Only';
      case FilterType.withContributors:
        return 'With Contributors';
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}