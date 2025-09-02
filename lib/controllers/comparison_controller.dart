import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/repository_model.dart';
import '../services/github_service.dart';

class ComparisonController extends GetxController {
  // Observable variables
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final repo1 = Rx<RepositoryModel?>(null);
  final repo2 = Rx<RepositoryModel?>(null);
  final comparisonData = <String, dynamic>{}.obs;
  
  // Services
  late final GitHubService _githubService;
  
  @override
  void onInit() {
    super.onInit();
    print('=== Comparison Controller onInit ===');
    
    try {
      _githubService = Get.find<GitHubService>();
      print('GitHub service found successfully');
    } catch (e) {
      print('Error finding GitHub service: $e');
      errorMessage.value = 'Failed to initialize GitHub service: $e';
      return;
    }
    
    // Get arguments from navigation
    final arguments = Get.arguments as Map<String, dynamic>?;
    print('Navigation arguments: $arguments');
    
    if (arguments != null) {
      try {
        repo1.value = arguments['repo1'] as RepositoryModel;
        final repo2Input = arguments['repo2Input'] as String;
        
        print('Repo1: ${repo1.value?.fullName}');
        print('Repo2Input: $repo2Input');
        
        // Test URL parsing
        _testUrlParsing(repo2Input);
        
        _fetchSecondRepository(repo2Input);
      } catch (e) {
        print('Error processing arguments: $e');
        errorMessage.value = 'Invalid arguments: $e';
      }
    } else {
      print('No arguments provided');
      errorMessage.value = 'No repository data provided for comparison';
    }
    
    print('=== End Comparison Controller onInit ===');
  }
  
  void _testUrlParsing(String input) {
    print('=== Testing URL Parsing ===');
    print('Input: $input');
    
    if (input.contains('github.com')) {
      final uri = Uri.tryParse(input);
      print('Parsed URI: $uri');
      if (uri != null) {
        print('Host: ${uri.host}');
        print('Path: ${uri.path}');
        print('Path segments: ${uri.pathSegments}');
        print('Query: ${uri.query}');
      }
    } else {
      print('Not a GitHub URL');
    }
    print('=== End URL Parsing Test ===');
  }
  
  Future<void> _fetchSecondRepository(String repoInput) async {
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      String owner;
      String repo;
      
      // Parse repository input - handle both GitHub URLs and owner/repo format
      if (repoInput.contains('github.com')) {
        // Handle GitHub URLs
        final uri = Uri.tryParse(repoInput);
        if (uri != null && uri.host == 'github.com') {
          final pathSegments = uri.pathSegments.where((segment) => segment.isNotEmpty).toList();
          print('Path segments after filtering: $pathSegments');
          
          if (pathSegments.length >= 2) {
            owner = pathSegments[0];
            repo = pathSegments[1];
            
            // Remove any trailing .git extension from repo name
            if (repo.endsWith('.git')) {
              repo = repo.substring(0, repo.length - 4);
            }
            
            print('Extracted - Owner: $owner, Repo: $repo');
          } else {
            throw Exception('Invalid GitHub URL format. Expected: https://github.com/owner/repository');
          }
        } else {
          throw Exception('Invalid GitHub URL format. Expected: https://github.com/owner/repository');
        }
      } else {
        // Handle direct owner/repo format (for backward compatibility)
        final parts = repoInput.split('/').where((part) => part.isNotEmpty).toList();
        print('Split parts after filtering: $parts');
        
        if (parts.length != 2) {
          throw Exception('Invalid repository format. Use: https://github.com/owner/repository or owner/repository');
        }
        owner = parts[0].trim();
        repo = parts[1].trim();
        
        // Remove any trailing .git extension from repo name
        if (repo.endsWith('.git')) {
          repo = repo.substring(0, repo.length - 4);
        }
        
        print('Extracted - Owner: $owner, Repo: $repo');
      }
      
      if (owner.isEmpty || repo.isEmpty) {
        throw Exception('Invalid repository format. Owner and repository names cannot be empty.');
      }
      
      print('Final - Owner: $owner, Repo: $repo');
      print('Calling GitHub service to fetch repository...');
      
      // Fetch repository data with timeout
      final repository = await _githubService.fetchRepository(owner, repo)
          .timeout(const Duration(seconds: 30));
      
      if (repository == null) {
        throw Exception('Repository not found or is private');
      }
      
      print('Repository fetched successfully: ${repository.fullName}');
      repo2.value = repository;
      
      // Generate comparison data
      _generateComparisonData();
      
    } catch (e) {
      print('Error in _fetchSecondRepository: $e');
      errorMessage.value = e.toString();
      
      // Show error snackbar
      Get.snackbar(
        'Error',
        'Failed to fetch repository: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  void _generateComparisonData() {
    if (repo1.value == null || repo2.value == null) return;
    
    final repo1Data = repo1.value!;
    final repo2Data = repo2.value!;
    
    // Basic repository comparison
    comparisonData['basic'] = {
      'stars': {
        'repo1': repo1Data.stargazersCount,
        'repo2': repo2Data.stargazersCount,
        'winner': repo1Data.stargazersCount > repo2Data.stargazersCount ? 'repo1' : 'repo2',
      },
      'forks': {
        'repo1': repo1Data.forksCount,
        'repo2': repo2Data.forksCount,
        'winner': repo1Data.forksCount > repo2Data.forksCount ? 'repo1' : 'repo2',
      },
      'watchers': {
        'repo1': repo1Data.watchersCount,
        'repo2': repo2Data.watchersCount,
        'winner': repo1Data.watchersCount > repo2Data.watchersCount ? 'repo1' : 'repo2',
      },
      'issues': {
        'repo1': repo1Data.openIssuesCount,
        'repo2': repo2Data.openIssuesCount,
        'winner': repo1Data.openIssuesCount < repo2Data.openIssuesCount ? 'repo1' : 'repo2',
      },
      'size': {
        'repo1': repo1Data.size,
        'repo2': repo2Data.size,
        'winner': repo1Data.size < repo2Data.size ? 'repo1' : 'repo2',
      },
    };
    
    // Language comparison
    comparisonData['languages'] = {
      'repo1': repo1Data.language ?? 'Unknown',
      'repo2': repo2Data.language ?? 'Unknown',
      'same': (repo1Data.language ?? '') == (repo2Data.language ?? ''),
    };
    
    // Contributors comparison
    comparisonData['contributors'] = {
      'repo1': repo1Data.contributors?.length ?? 0,
      'repo2': repo2Data.contributors?.length ?? 0,
      'winner': (repo1Data.contributors?.length ?? 0) > (repo2Data.contributors?.length ?? 0) ? 'repo1' : 'repo2',
    };
    
    // AI Insights comparison (if available)
    if (repo1Data.aiInsights != null && repo2Data.aiInsights != null) {
      comparisonData['aiInsights'] = {
        'overallScore': {
          'repo1': repo1Data.aiInsights!.overallScore,
          'repo2': repo2Data.aiInsights!.overallScore,
          'winner': repo1Data.aiInsights!.overallScore > repo2Data.aiInsights!.overallScore ? 'repo1' : 'repo2',
        },
        'codeQuality': {
          'repo1': repo1Data.aiInsights!.codeQualityScore,
          'repo2': repo2Data.aiInsights!.codeQualityScore,
          'winner': repo1Data.aiInsights!.codeQualityScore > repo2Data.aiInsights!.codeQualityScore ? 'repo1' : 'repo2',
        },
        'security': {
          'repo1': repo1Data.aiInsights!.securityScore,
          'repo2': repo2Data.aiInsights!.securityScore,
          'winner': repo1Data.aiInsights!.securityScore > repo2Data.aiInsights!.securityScore ? 'repo1' : 'repo2',
        },
        'maintainability': {
          'repo1': repo1Data.aiInsights!.maintainabilityScore,
          'repo2': repo2Data.aiInsights!.maintainabilityScore,
          'winner': repo1Data.aiInsights!.maintainabilityScore > repo2Data.aiInsights!.maintainabilityScore ? 'repo1' : 'repo2',
        },
        'architecture': {
          'repo1': repo1Data.aiInsights!.architectureScore,
          'repo2': repo2Data.aiInsights!.architectureScore,
          'winner': repo1Data.aiInsights!.architectureScore > repo2Data.aiInsights!.architectureScore ? 'repo1' : 'repo2',
        },
      };
    }
    
    // Activity comparison
    comparisonData['activity'] = {
      'repo1': repo1Data.activityScore ?? 0.0,
      'repo2': repo2Data.activityScore ?? 0.0,
      'winner': (repo1Data.activityScore ?? 0.0) > (repo2Data.activityScore ?? 0.0) ? 'repo1' : 'repo2',
    };
  }
  
  String getComparisonWinner(String category, String subcategory) {
    try {
      final data = comparisonData[category];
      if (data is Map && data[subcategory] is Map) {
        return data[subcategory]['winner'] ?? 'tie';
      }
      return 'tie';
    } catch (e) {
      return 'tie';
    }
  }
  
  bool isComparisonReady() {
    return repo1.value != null && repo2.value != null && !isLoading.value;
  }
  
  void refreshComparison() {
    if (repo2.value != null) {
      final repo2Input = '${repo2.value!.owner.login}/${repo2.value!.name}';
      _fetchSecondRepository(repo2Input);
    }
  }
}
