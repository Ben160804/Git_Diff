import 'package:get/get.dart';
import '../services/github_service.dart';
import '../models/repository_model.dart';
import '../screens/dashboard_screen.dart';
import 'package:hive/hive.dart';

class HomeScreenController extends GetxController {
  var repoInput = ''.obs;
  var repositoryModel = Rx<RepositoryModel?>(null);
  var isLoading = false.obs;
  late Box<RepositoryModel> repositoryBox;

  @override
  void onInit() async {
    super.onInit();
    repositoryBox = await Hive.openBox<RepositoryModel>('repositories');
  }

  void updateRepoInput(String value) {
    repoInput.value = value;
  }

  void fetchRepoData() async {
    final input = repoInput.value.trim();
    if (input.isEmpty) {
      Get.snackbar("Error", "Please enter a repository link");
      return;
    }

    final parts = parseRepoInput(input);
    if (parts == null) {
      Get.snackbar("Error", "Invalid repository link or name");
      return;
    }

    final owner = parts['owner']!;
    final repo = parts['repo']!;

    final cachedRepo = repositoryBox.get('$owner/$repo');
    if (cachedRepo != null) {
      repositoryModel.value = cachedRepo;
      printRepositoryModel(cachedRepo, isCached: true);
      Get.to(() => const DashboardScreen());
      return;
    }

    // Set loading state for new repository fetch
    isLoading.value = true;
    
    try {
      final freshRepo = await Get.find<GitHubService>().fetchRepository(owner, repo);

      if (freshRepo != null) {
        await repositoryBox.put('$owner/$repo', freshRepo);
        repositoryModel.value = freshRepo;
        printRepositoryModel(freshRepo, isCached: false);
        Get.to(() => const DashboardScreen());
      } else {
        Get.snackbar("Error", "Failed to fetch repo data");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch repo data");
    } finally {
      isLoading.value = false;
    }
  }

  void printRepositoryModel(RepositoryModel model, {bool isCached = false}) {
    void printField(String label, dynamic value) {
      print("$label: ${value ?? 'None'}");
    }

    print("===== ${isCached ? 'CACHED' : 'FETCHED'} REPOSITORY DATA =====");
    printField("ID", model.id);
    printField("Name", model.name);
    printField("Full Name", model.fullName);
    printField("Description", model.description);
    printField("Stars", model.stargazersCount);
    printField("Watchers", model.watchersCount);
    printField("Forks", model.forksCount);
    printField("Open Issues", model.openIssuesCount);
    printField("Network Count", model.networkCount);
    printField("Subscribers Count", model.subscribersCount);
    printField("License", model.license);
    printField("Default Branch", model.defaultBranch);
    printField("Size", model.size);
    printField("Private", model.isPrivate);
    printField("Fork", model.isFork);
    printField("Has Issues", model.hasIssues);
    printField("Has Projects", model.hasProjects);
    printField("Has Wiki", model.hasWiki);
    printField("Has Pages", model.hasPages);
    printField("Has Downloads", model.hasDownloads);
    printField("Homepage", model.homepage);
    printField("Readme Content", model.readmeContent);
    printField("Owner", model.owner.login);
    printField("Owner Avatar", model.owner.avatarUrl);
    printField("Owner URL", model.owner.htmlUrl);
    print("Topics: ${model.topics?.join(', ') ?? 'None'}");

    print("Contributors:");
    if (model.contributors != null && model.contributors!.isNotEmpty) {
      print("  Total Contributors: ${model.contributors!.length}");
      for (var c in model.contributors!) {
        print("  - ${c.login} (${c.contributions} contributions) - Type: ${c.type}");
      }
    } else {
      print("  None");
    }

    print("Commit Activity:");
    if (model.commitActivity != null && model.commitActivity!.isNotEmpty) {
      for (var a in model.commitActivity!) {
        print("  Week: ${DateTime.fromMillisecondsSinceEpoch(a.week * 1000)} | Commits: ${a.total}");
      }
    } else {
      print("  None");
    }

    print("Languages:");
    if (model.languages != null && model.languages!.isNotEmpty) {
      model.languages!.forEach((lang, bytes) {
        print("  $lang: $bytes bytes");
      });
    } else {
      print("  None");
    }

    print("AI Insights:");
    if (model.aiInsights != null) {
      printField("Repository Summary", model.aiInsights!.repositorySummary);
      printField("Language Analysis", model.aiInsights!.languageAnalysis);
      printField("Contribution Patterns", model.aiInsights!.contributionPatterns);
      printField("Additional Insights", model.aiInsights!.additionalInsights);
      printField("Complexity Score", model.aiInsights!.complexityScore);

      if (model.aiInsights!.suggestedImprovements != null &&
          model.aiInsights!.suggestedImprovements!.isNotEmpty) {
        print("Suggested Improvements:");
        for (var r in model.aiInsights!.suggestedImprovements!) {
          print("  - $r");
        }
      } else {
        print("Suggested Improvements: None");
      }
    } else {
      print("  None");
    }

    printField("Cached At", model.cachedAt);
    print("=====================================================");
  }

  Map<String, String>? parseRepoInput(String input) {
    try {
      if (input.contains('github.com')) {
        final uri = Uri.parse(input);
        final segments = uri.pathSegments;
        if (segments.length >= 2) {
          return {
            'owner': segments[0],
            'repo': segments[1].replaceAll('.git', ''),
          };
        }
      } else if (input.contains('/')) {
        final parts = input.split('/');
        if (parts.length == 2) {
          return {'owner': parts[0], 'repo': parts[1]};
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void refreshRepositoryWithAIInsights(RepositoryModel repository) {
    // Force UI refresh by updating the repository model
    repositoryModel.value = repository;
    
    // Also update the cache
    final key = '${repository.owner.login}/${repository.name}';
    repositoryBox.put(key, repository);
    
    print('Repository refreshed with AI insights in UI');
  }
}
