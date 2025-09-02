import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/repository_model.dart';

class DashboardController extends GetxController {
  // Observable variables
  final isCardExpanded = true.obs;
  final repositories = <RepositoryModel>[].obs;
  final favoriteRepositories = <String>[].obs; // Store repo keys
  final recentlyViewed = <RepositoryModel>[].obs;
  final selectedFilterType = FilterType.all.obs;
  final isLoading = false.obs;

  // Hive boxes
  late Box<RepositoryModel> repositoryBox;
  late Box<String> favoritesBox;

  // Dashboard stats
  final totalRepositories = 0.obs;
  final totalStars = 0.obs;
  final totalForks = 0.obs;
  final mostUsedLanguage = ''.obs;
  final totalContributors = 0.obs;
  final topContributor = ''.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeBoxes();
    loadDashboardData();
  }

  Future<void> _initializeBoxes() async {
    repositoryBox = await Hive.openBox<RepositoryModel>('repositories');
    favoritesBox = await Hive.openBox<String>('favorites');
  }

  void loadDashboardData() {
    isLoading.value = true;

    try {
      // Load all cached repositories
      final cachedRepos = repositoryBox.values.toList();
      repositories.assignAll(cachedRepos);

      // Load recently viewed (last 10, sorted by cache time)
      final recent = cachedRepos
          .where((repo) => repo.cachedAt != null)
          .toList()
        ..sort((a, b) => b.cachedAt!.compareTo(a.cachedAt!));

      recentlyViewed.assignAll(recent.take(10));

      // Load favorites
      final favoriteKeys = favoritesBox.values.toList();
      favoriteRepositories.assignAll(favoriteKeys);

      // Calculate dashboard stats
      _calculateDashboardStats();
    } catch (e) {
      Get.snackbar("Error", "Failed to load dashboard data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateDashboardStats() {
    if (repositories.isEmpty) {
      totalRepositories.value = 0;
      totalStars.value = 0;
      totalForks.value = 0;
      mostUsedLanguage.value = '';
      totalContributors.value = 0;
      topContributor.value = '';
      return;
    }

    totalRepositories.value = repositories.length;
    totalStars.value = repositories.fold<int>(
      0,
          (sum, repo) => sum + (repo.stargazersCount),
    );
    totalForks.value = repositories.fold<int>(
      0,
          (sum, repo) => sum + (repo.forksCount),
    );

    // Calculate total contributors across all repositories
    final allContributors = <String, int>{};
    for (final repo in repositories) {
      if (repo.contributors != null) {
        for (final contributor in repo.contributors!) {
          allContributors[contributor.login] = 
              (allContributors[contributor.login] ?? 0) + contributor.contributions;
        }
      }
    }
    
    totalContributors.value = allContributors.length;
    
    if (allContributors.isNotEmpty) {
      final topContributorEntry = allContributors.entries.reduce(
        (a, b) => a.value >= b.value ? a : b,
      );
      topContributor.value = topContributorEntry.key;
    } else {
      topContributor.value = '';
    }

    // Find most used language
    final languageCount = <String, int>{};
    for (final repo in repositories) {
      final language = repo.language;
      if (language != null && language.isNotEmpty) {
        languageCount[language] = (languageCount[language] ?? 0) + 1;
      }
    }

    if (languageCount.isNotEmpty) {
      final mostUsed = languageCount.entries.reduce(
            (a, b) => a.value >= b.value ? a : b,
      );
      mostUsedLanguage.value = mostUsed.key;
    } else {
      mostUsedLanguage.value = '';
    }
  }

  void toggleCardExpansion() {
    isCardExpanded.toggle();
  }

  Future<void> toggleRepositoryFavorite(RepositoryModel repository) async {
    final key = repository.fullName;

    if (favoriteRepositories.contains(key)) {
      favoriteRepositories.remove(key);
      await favoritesBox.delete(key);
      Get.snackbar(
        "Removed",
        "${repository.name} removed from favorites",
        duration: const Duration(seconds: 2),
      );
    } else {
      favoriteRepositories.add(key);
      await favoritesBox.put(key, key);
      Get.snackbar(
        "Added",
        "${repository.name} added to favorites",
        duration: const Duration(seconds: 2),
      );
    }
  }

  bool isRepositoryFavorite(RepositoryModel repository) {
    return favoriteRepositories.contains(repository.fullName);
  }

  void setFilterType(FilterType type) {
    selectedFilterType.value = type;
  }

  List<RepositoryModel> getFilteredRepositories() {
    switch (selectedFilterType.value) {
      case FilterType.favorites:
        return repositories
            .where((repo) => favoriteRepositories.contains(repo.fullName))
            .toList();
      case FilterType.recent:
        return recentlyViewed.toList();
      case FilterType.starred:
        return repositories
          ..sort((a, b) => b.stargazersCount.compareTo(a.stargazersCount));
      case FilterType.forks:
        return repositories.where((repo) => repo.isFork).toList();
      case FilterType.withContributors:
        return repositories
            .where((repo) => repo.contributors != null && repo.contributors!.isNotEmpty)
            .toList();
      case FilterType.all:
      default:
        return repositories.toList();
    }
  }

  void clearAllData() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'Are you sure you want to clear all cached repositories and favorites? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _performClearAllData();
              Get.back();
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performClearAllData() async {
    try {
      await repositoryBox.clear();
      await favoritesBox.clear();

      repositories.clear();
      favoriteRepositories.clear();
      recentlyViewed.clear();

      _calculateDashboardStats();

      Get.snackbar("Success", "All data cleared successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to clear data: $e");
    }
  }

  void refreshDashboard() {
    loadDashboardData();
    Get.snackbar("Refreshed", "Dashboard data updated");
  }

  void onRepositoryUpdated(RepositoryModel repository) {
    final index =
    repositories.indexWhere((repo) => repo.fullName == repository.fullName);
    if (index != -1) {
      repositories[index] = repository;
    } else {
      repositories.insert(0, repository);
    }

    recentlyViewed.removeWhere((repo) => repo.fullName == repository.fullName);
    recentlyViewed.insert(0, repository);
    if (recentlyViewed.length > 10) {
      recentlyViewed.removeLast();
    }

    _calculateDashboardStats();
  }

  @override
  void onClose() {
    super.onClose();
  }
}

enum FilterType { all, favorites, recent, starred, forks, withContributors }

class DashboardStats {
  final int totalRepos;
  final int totalStars;
  final int totalForks;
  final String mostUsedLanguage;

  const DashboardStats({
    this.totalRepos = 0,
    this.totalStars = 0,
    this.totalForks = 0,
    this.mostUsedLanguage = '',
  });
}
