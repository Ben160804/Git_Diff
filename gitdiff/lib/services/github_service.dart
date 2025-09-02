import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/repository_model.dart';
import '../controllers/home_screen_controller.dart';
import 'ai_analysis_service.dart';

class GitHubService extends GetxService {
  final String baseUrl = "https://api.github.com";
  final Duration timeout = const Duration(seconds: 30);
  String? _githubToken;
  late final AIAnalysisService _aiService;
  
  @override
  void onInit() {
    super.onInit();
    print('=== GitHubService onInit ===');
    
    // Load GitHub token from environment
    _githubToken = dotenv.env['GITHUB_TOKEN'];
    if (_githubToken != null) {
      print('GitHub token loaded from environment');
    } else {
      print('WARNING: GITHUB_TOKEN not found in environment variables');
    }
    
    try {
      _aiService = AIAnalysisService();
      print('AI Service created successfully');
    } catch (e) {
      print('ERROR creating AI Service: $e');
    }
  }

  void setGitHubToken(String token) {
    _githubToken = token;
  }

  Map<String, String> get _headers {
    final headers = {
      'Accept': 'application/vnd.github.v3+json',
      'User-Agent': 'GDG-Dashboard-App/1.0',
    };
    if (_githubToken != null) {
      headers['Authorization'] = 'Bearer $_githubToken';
    }
    return headers;
  }

  Future<RepositoryModel?> fetchRepository(String owner, String repo) async {
    try {
      final repoData = await _fetchRepoDetails(owner, repo);
      if (repoData == null) return null;

      final results = await Future.wait([
        _fetchContributors(owner, repo),
        _fetchCommitActivity(owner, repo),
        _fetchLanguages(owner, repo),
        _fetchReadme(owner, repo),
      ], eagerError: false);

      final contributors = results[0] as List<ContributorModel>?;
      final commitActivity = results[1] as List<CommitActivityModel>?;
      final languages = results[2] as Map<String, int>?;
      final readmeContent = results[3] as String?;

      // Create the repository model first
      final repository = RepositoryModel(
        id: repoData['id'],
        name: repoData['name'],
        fullName: repoData['full_name'],
        description: repoData['description'],
        htmlUrl: repoData['html_url'],
        cloneUrl: repoData['clone_url'],
        gitUrl: repoData['git_url'],
        sshUrl: repoData['ssh_url'],
        stargazersCount: repoData['stargazers_count'] ?? 0,
        watchersCount: repoData['watchers_count'] ?? 0,
        forksCount: repoData['forks_count'] ?? 0,
        openIssuesCount: repoData['open_issues_count'] ?? 0,
        networkCount: repoData['network_count'] ?? 0,
        subscribersCount: repoData['subscribers_count'] ?? 0,
        language: repoData['language'],
        license: repoData['license']?['name'],
        size: repoData['size'] ?? 0,
        defaultBranch: repoData['default_branch'] ?? 'main',
        createdAt: DateTime.parse(repoData['created_at']),
        updatedAt: DateTime.parse(repoData['updated_at']),
        pushedAt: repoData['pushed_at'] != null ? DateTime.parse(repoData['pushed_at']) : null,
        isPrivate: repoData['private'] ?? false,
        isFork: repoData['fork'] ?? false,
        hasIssues: repoData['has_issues'] ?? false,
        hasProjects: repoData['has_projects'] ?? false,
        hasWiki: repoData['has_wiki'] ?? false,
        hasPages: repoData['has_pages'] ?? false,
        hasDownloads: repoData['has_downloads'] ?? false,
        owner: OwnerModel.fromJson(repoData['owner']),
        topics: repoData['topics']?.cast<String>(),
        homepage: repoData['homepage'],
        cachedAt: DateTime.now(),
        languages: languages ?? <String, int>{},
        contributors: contributors ?? [],
        commitActivity: commitActivity ?? [],
        readmeContent: readmeContent ?? 'README not available',
        aiInsights: null,
      );

      // Perform AI analysis asynchronously
      _performAIAnalysis(repository);

      return repository;
    } catch (e, stackTrace) {
      print("Error fetching repository: $e");
      print("Stack trace: $stackTrace");
      _handleError(e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> _fetchRepoDetails(String owner, String repo) async {
    try {
      final url = '$baseUrl/repos/$owner/$repo';
      final response = await http.get(Uri.parse(url), headers: _headers).timeout(timeout);
      if (response.statusCode == 200) return jsonDecode(response.body);
      _handleHttpError(response.statusCode, owner, repo);
      return null;
    } catch (e) {
      print("Error fetching repo details: $e");
      return null;
    }
  }

  Future<List<ContributorModel>?> _fetchContributors(String owner, String repo) async {
    try {
      final url = '$baseUrl/repos/$owner/$repo/contributors?per_page=10';
      final response = await http.get(Uri.parse(url), headers: _headers).timeout(timeout);
      if (response.statusCode == 200) {
        final List<dynamic> contributorsJson = jsonDecode(response.body);
        return contributorsJson.map((json) => ContributorModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching contributors: $e");
      return [];
    }
  }

  Future<List<CommitActivityModel>?> _fetchCommitActivity(String owner, String repo, {int maxRetries = 3}) async {
    int retryCount = 0;
    while (retryCount < maxRetries) {
      try {
        final url = '$baseUrl/repos/$owner/$repo/stats/commit_activity';
        final response = await http.get(Uri.parse(url), headers: _headers).timeout(Duration(seconds: 60));
        if (response.statusCode == 200) {
          if (response.body.trim() == '[]') return [];
          final List<dynamic> activityJson = jsonDecode(response.body);
          return activityJson.map((json) => CommitActivityModel.fromJson(json)).toList();
        } else if (response.statusCode == 202) {
          retryCount++;
          await Future.delayed(Duration(seconds: 5 * retryCount));
        } else {
          return [];
        }
      } catch (e) {
        retryCount++;
        await Future.delayed(Duration(seconds: 2 * retryCount));
      }
    }
    return [];
  }

  Future<Map<String, int>?> _fetchLanguages(String owner, String repo) async {
    try {
      final url = '$baseUrl/repos/$owner/$repo/languages';
      final response = await http.get(Uri.parse(url), headers: _headers).timeout(timeout);
      if (response.statusCode == 200) {
        final Map<String, dynamic> raw = jsonDecode(response.body);
        return raw.map((key, value) => MapEntry(key, value as int));
      }
      return {};
    } catch (e) {
      print("Error fetching languages: $e");
      return {};
    }
  }

  Future<String?> _fetchReadme(String owner, String repo) async {
    try {
      final url = '$baseUrl/repos/$owner/$repo/readme';
      final response = await http.get(Uri.parse(url), headers: _headers).timeout(timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['content'] != null) return utf8.decode(base64Decode(data['content'].replaceAll('\n', '')));
      }
      return 'README not available';
    } catch (e) {
      print("Error fetching README: $e");
      return 'README not available';
    }
  }

  List<LanguageStatsModel> getLanguageStats(Map<String, int> languages) {
    if (languages.isEmpty) return [];
    return LanguageStatsModel.fromLanguageMap(languages);
  }

  Future<OwnerModel?> fetchUserDetails(String username) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/$username'), headers: _headers).timeout(timeout);
      if (response.statusCode == 200) return OwnerModel.fromJson(jsonDecode(response.body));
    } catch (e) {
      print("Error fetching user details: $e");
    }
    return null;
  }

  Future<List<RepositoryModel>> searchRepositories(String query, {int perPage = 10, String sort = 'stars', String order = 'desc'}) async {
    try {
      final url = '$baseUrl/search/repositories?q=${Uri.encodeComponent(query)}&per_page=$perPage&sort=$sort&order=$order';
      final response = await http.get(Uri.parse(url), headers: _headers).timeout(timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        return items.map((json) {
          return RepositoryModel(
            id: json['id'],
            name: json['name'],
            fullName: json['full_name'],
            description: json['description'],
            htmlUrl: json['html_url'],
            cloneUrl: json['clone_url'],
            gitUrl: json['git_url'],
            sshUrl: json['ssh_url'],
            stargazersCount: json['stargazers_count'] ?? 0,
            watchersCount: json['watchers_count'] ?? 0,
            forksCount: json['forks_count'] ?? 0,
            openIssuesCount: json['open_issues_count'] ?? 0,
            language: json['language'],
            license: json['license']?['name'],
            createdAt: DateTime.parse(json['created_at']),
            updatedAt: DateTime.parse(json['updated_at']),
            pushedAt: json['pushed_at'] != null ? DateTime.parse(json['pushed_at']) : null,
            size: json['size'] ?? 0,
            defaultBranch: json['default_branch'] ?? 'main',
            isPrivate: json['private'] ?? false,
            isFork: json['fork'] ?? false,
            hasIssues: json['has_issues'] ?? false,
            hasProjects: json['has_projects'] ?? false,
            hasWiki: json['has_wiki'] ?? false,
            hasPages: json['has_pages'] ?? false,
            hasDownloads: json['has_downloads'] ?? false,
            networkCount: json['network_count'] ?? 0,
            subscribersCount: json['subscribers_count'] ?? 0,
            owner: OwnerModel.fromJson(json['owner']),
            topics: json['topics']?.cast<String>(),
            homepage: json['homepage'],
            cachedAt: DateTime.now(),
          );
        }).toList();
      }
    } catch (e) {
      print("Error searching repositories: $e");
    }
    return [];
  }

  Future<Map<String, dynamic>?> getRateLimitInfo() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/rate_limit'), headers: _headers);
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {
      print("Error fetching rate limit info: $e");
    }
    return null;
  }

  void _handleHttpError(int statusCode, String owner, String repo) {
    switch (statusCode) {
      case 404:
        Get.snackbar('Repository Not Found', 'The repository $owner/$repo does not exist or is private.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
        break;
      case 403:
        Get.snackbar('API Rate Limit Exceeded', 'GitHub API rate limit exceeded. Try again later or add a GitHub token.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
        break;
      case 401:
        Get.snackbar('Authentication Failed', 'Invalid GitHub token. Please check your credentials.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
        break;
      default:
        Get.snackbar('API Error', 'GitHub API returned status code: $statusCode', snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
    }
  }

  void _handleError(dynamic error) {
    if (error is SocketException) {
      Get.snackbar('Network Error', 'Please check your internet connection and try again.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
    } else if (error is http.ClientException) {
      Get.snackbar('Connection Error', 'Failed to connect to GitHub API. Please try again.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
    } else {
      Get.snackbar('Unexpected Error', 'An unexpected error occurred. Please try again.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
    }
  }

  Future<void> _performAIAnalysis(RepositoryModel repository) async {
    print('=== _performAIAnalysis called ===');
    print('Repository: ${repository.fullName}');
    print('AI Service available: ${_aiService != null}');
    print('AI Service initialized: ${_aiService?.isInitialized ?? false}');
    
    // Prevent multiple AI analysis calls for the same repository
    if (repository.aiInsights != null) {
      print('AI analysis already completed for this repository, skipping...');
      return;
    }
    
    try {
      print('Starting AI analysis for repository: ${repository.fullName}');
      
      final aiInsights = await _aiService!.analyzeRepository(repository);
      print('AI insights received: ${aiInsights != null}');
      
      final aiModel = AIInsightsModel.fromAIInsights(aiInsights);
      print('AI model created successfully');

      // Update the repository with AI insights
      repository.aiInsights = aiModel;
      print('Repository updated with AI insights');
      
      print('AI analysis completed for repository: ${repository.fullName}');
      print('Overall Score: ${aiModel.overallScore}');
      print('Code Quality Score: ${aiModel.codeQualityScore}');
      print('Security Score: ${aiModel.securityScore}');
      
      // Force UI refresh by updating the repository model
      try {
        final homeController = Get.find<HomeScreenController>();
        homeController.refreshRepositoryWithAIInsights(repository);
        print('Repository model refreshed in UI');
      } catch (e) {
        print('Could not refresh repository model: $e');
      }
      
      // Show success notification
      Get.snackbar(
        'AI Analysis Complete',
        'Repository analysis completed successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('AI analysis failed for repository: ${repository.fullName}');
      print('Error: $e');
      print('Stack trace: ${StackTrace.current}');
      
      // Show error notification
      Get.snackbar(
        'AI Analysis Failed',
        'Failed to analyze repository. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
