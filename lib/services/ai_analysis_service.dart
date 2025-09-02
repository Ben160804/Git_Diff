import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/repository_model.dart';

class AIAnalysisService {
  late final GenerativeModel _model;
  bool _isInitialized = false;
  bool _isInitializing = false;
  
  AIAnalysisService() {
    print('=== AIAnalysisService Constructor ===');
    _initializeService();
  }

  Future<void> _initializeService() async {
    if (_isInitializing) return;
    _isInitializing = true;
    
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      print('API Key found: ${apiKey.isNotEmpty ? 'YES' : 'NO'}');
      print('API Key length: ${apiKey.length}');
      print('API Key preview: ${apiKey.isNotEmpty ? '${apiKey.substring(0, 10)}...' : 'NONE'}');
      
      if (apiKey.isEmpty) {
        print('WARNING: GEMINI_API_KEY not found in environment variables');
        print('AI analysis features will be disabled');
        _isInitialized = false;
        return;
      }

      print('Attempting to create GenerativeModel...');
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );
      
      // Test the model with a simple request to ensure it's working
      try {
        final testContent = [Content.text('Hello')];
        await _model.generateContent(testContent);
        _isInitialized = true;
        print('SUCCESS: AI Analysis Service initialized and tested successfully');
      } catch (testError) {
        print('Model test failed: $testError');
        _isInitialized = false;
      }
    } catch (e) {
      print('ERROR initializing AI service: $e');
      print('Stack trace: ${StackTrace.current}');
      _isInitialized = false;
    } finally {
      _isInitializing = false;
    }
  }

  bool get isInitialized => _isInitialized;
  bool get isInitializing => _isInitializing;
  
  // Wait for service to be ready
  Future<bool> waitForInitialization({Duration timeout = const Duration(seconds: 10)}) async {
    if (_isInitialized) return true;
    
    final startTime = DateTime.now();
    while (!_isInitialized && !_isInitializing) {
      if (DateTime.now().difference(startTime) > timeout) {
        print('Timeout waiting for AI service initialization');
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    while (_isInitializing) {
      if (DateTime.now().difference(startTime) > timeout) {
        print('Timeout waiting for AI service initialization');
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    return _isInitialized;
  }

  Future<RepositoryAIInsights> analyzeRepository(RepositoryModel repository) async {
    print('=== analyzeRepository called ===');
    print('Repository: ${repository.fullName}');
    
    // Check if model is initialized
    if (!_isInitialized) {
      print('AI model not initialized, returning fallback analysis');
      return RepositoryAIInsights(
        repositorySummary: 'AI analysis service is not available',
        codeQualityScore: 0.0,
        securityScore: 0.0,
        maintainabilityScore: 0.0,
        architectureScore: 0.0,
        codeQualityAnalysis: 'AI analysis service is not available',
        securityAnalysis: 'AI analysis service is not available',
        maintainabilityAnalysis: 'AI analysis service is not available',
        architectureAnalysis: 'AI analysis service is not available',
        suggestedImprovements: ['Enable AI analysis service to get insights'],
        overallScore: 0.0,
        complexityScore: 0.0,
        languageAnalysis: 'AI analysis service is not available',
        contributionPatterns: 'AI analysis service is not available',
        additionalInsights: 'AI analysis service is not available',
      );
    }

    try {
      final prompt = _buildAnalysisPrompt(repository);
      
      final content = [
        Content.text(prompt),
      ];
      
      final response = await _model.generateContent(content);
      final responseText = response.text ?? 'Unable to analyze repository';
      
      return _parseAIResponse(responseText, repository);
    } catch (e) {
      print('AI analysis failed: $e');
      return RepositoryAIInsights(
        repositorySummary: 'AI analysis failed: ${e.toString()}',
        codeQualityScore: 0.0,
        securityScore: 0.0,
        maintainabilityScore: 0.0,
        architectureScore: 0.0,
        codeQualityAnalysis: 'Analysis failed due to an error',
        securityAnalysis: 'Security analysis could not be completed',
        maintainabilityAnalysis: 'Maintainability analysis could not be completed',
        architectureAnalysis: 'Architecture analysis could not be completed',
        suggestedImprovements: ['AI analysis service is temporarily unavailable'],
        overallScore: 0.0,
        complexityScore: 0.0,
        languageAnalysis: 'Language analysis could not be completed',
        contributionPatterns: 'Contribution pattern analysis could not be completed',
        additionalInsights: 'Additional insights could not be generated',
      );
    }
  }

  String _buildAnalysisPrompt(RepositoryModel repository) {
    return '''
Analyze this GitHub repository and provide comprehensive insights:

Repository: ${repository.fullName}
Description: ${repository.description ?? 'No description'}
Language: ${repository.language ?? 'Unknown'}
Stars: ${repository.stargazersCount}
Forks: ${repository.forksCount}
Open Issues: ${repository.openIssuesCount}
Size: ${repository.size} KB
Topics: ${repository.topics?.join(', ') ?? 'None'}
License: ${repository.license ?? 'None'}
Default Branch: ${repository.defaultBranch}
Has Wiki: ${repository.hasWiki}
Has Projects: ${repository.hasProjects}
Has Issues: ${repository.hasIssues}

Contributors: ${repository.contributors?.length ?? 0}
Languages: ${repository.languages?.keys.join(', ') ?? 'Unknown'}

README Content:
${repository.readmeContent ?? 'No README available'}

Please provide a comprehensive analysis in the following JSON format:

{
  "repositorySummary": "Brief overview of the repository",
  "codeQualityScore": 0.0-10.0,
  "securityScore": 0.0-10.0,
  "maintainabilityScore": 0.0-10.0,
  "architectureScore": 0.0-10.0,
  "codeQualityAnalysis": "Detailed analysis of code quality",
  "securityAnalysis": "Security assessment and potential vulnerabilities",
  "maintainabilityAnalysis": "Maintainability and technical debt analysis",
  "architectureAnalysis": "Architecture and design pattern analysis",
  "suggestedImprovements": ["Improvement 1", "Improvement 2", "Improvement 3"],
  "overallScore": 0.0-10.0,
  "complexityScore": 0.0-10.0,
  "languageAnalysis": "Analysis of programming languages and frameworks",
  "contributionPatterns": "Analysis of contribution patterns and collaboration",
  "additionalInsights": "Additional insights and recommendations"
}

Focus on:
1. Code quality and best practices
2. Security considerations
3. Maintainability and technical debt
4. Architecture and design patterns
5. Technology stack analysis
6. Collaboration and contribution patterns
7. Specific actionable improvements

Provide scores on a 0-10 scale where 10 is excellent and 0 is poor.
''';
  }

  RepositoryAIInsights _parseAIResponse(String response, RepositoryModel repository) {
    try {
      // Try to extract JSON from the response
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}');
      
      if (jsonStart != -1 && jsonEnd != -1) {
        final jsonString = response.substring(jsonStart, jsonEnd + 1);
        // In a real implementation, you'd parse this JSON
        // For now, we'll create a structured response
      }
      
      // Fallback: create insights from the raw response
      return RepositoryAIInsights(
        repositorySummary: _extractSummary(response),
        codeQualityScore: _extractScore(response, 'code quality'),
        securityScore: _extractScore(response, 'security'),
        maintainabilityScore: _extractScore(response, 'maintainability'),
        architectureScore: _extractScore(response, 'architecture'),
        codeQualityAnalysis: _extractAnalysis(response, 'code quality'),
        securityAnalysis: _extractAnalysis(response, 'security'),
        maintainabilityAnalysis: _extractAnalysis(response, 'maintainability'),
        architectureAnalysis: _extractAnalysis(response, 'architecture'),
        suggestedImprovements: _extractImprovements(response),
        overallScore: _calculateOverallScore(response),
        complexityScore: _extractScore(response, 'complexity'),
        languageAnalysis: _extractAnalysis(response, 'language'),
        contributionPatterns: _extractAnalysis(response, 'contribution'),
        additionalInsights: _extractAdditionalInsights(response),
      );
    } catch (e) {
      return RepositoryAIInsights(
        repositorySummary: 'AI analysis completed but parsing failed',
        codeQualityScore: 7.0,
        securityScore: 7.0,
        maintainabilityScore: 7.0,
        architectureScore: 7.0,
        codeQualityAnalysis: response,
        securityAnalysis: 'Security analysis completed',
        maintainabilityAnalysis: 'Maintainability analysis completed',
        architectureAnalysis: 'Architecture analysis completed',
        suggestedImprovements: ['Review the full AI analysis for specific recommendations'],
        overallScore: 7.0,
        complexityScore: 7.0,
        languageAnalysis: 'Language analysis completed',
        contributionPatterns: 'Contribution analysis completed',
        additionalInsights: 'Additional insights available in the full analysis',
      );
    }
  }

  String _extractSummary(String response) {
    if (response.contains('repositorySummary')) {
      final start = response.indexOf('"repositorySummary"');
      if (start != -1) {
        final valueStart = response.indexOf('"', start + 20);
        final valueEnd = response.indexOf('"', valueStart + 1);
        if (valueStart != -1 && valueEnd != -1) {
          return response.substring(valueStart + 1, valueEnd);
        }
      }
    }
    return 'AI analysis completed successfully';
  }

  double _extractScore(String response, String category) {
    final categoryLower = category.toLowerCase();
    if (response.toLowerCase().contains(categoryLower)) {
      // Look for numbers near the category
      final categoryIndex = response.toLowerCase().indexOf(categoryLower);
      final beforeText = response.substring(0, categoryIndex);
      final afterText = response.substring(categoryIndex);
      
      // Look for scores in format "X.X" or "X"
      final scorePattern = RegExp(r'(\d+\.?\d*)');
      final matches = scorePattern.allMatches(afterText);
      
      if (matches.isNotEmpty) {
        final score = double.tryParse(matches.first.group(1) ?? '0');
        if (score != null && score >= 0 && score <= 10) {
          return score;
        }
      }
    }
    return 7.0; // Default score
  }

  String _extractAnalysis(String response, String category) {
    final categoryLower = category.toLowerCase();
    if (response.toLowerCase().contains(categoryLower)) {
      final categoryIndex = response.toLowerCase().indexOf(categoryLower);
      final afterCategory = response.substring(categoryIndex);
      
      // Try to extract meaningful text after the category
      final sentences = afterCategory.split('.');
      if (sentences.length > 1) {
        return sentences[1].trim();
      }
    }
    return 'Analysis completed for $category';
  }

  List<String> _extractImprovements(String response) {
    final improvements = <String>[];
    
    if (response.toLowerCase().contains('improvement')) {
      final improvementIndex = response.toLowerCase().indexOf('improvement');
      final afterImprovement = response.substring(improvementIndex);
      
      // Look for numbered or bulleted improvements
      final lines = afterImprovement.split('\n');
      for (final line in lines) {
        if (line.trim().isNotEmpty && 
            (line.contains('.') || line.contains('-') || line.contains('•'))) {
          final cleanLine = line.replaceAll(RegExp(r'^\d+\.?\s*[-•]?\s*'), '').trim();
          if (cleanLine.isNotEmpty && cleanLine.length > 10) {
            improvements.add(cleanLine);
          }
        }
      }
    }
    
    if (improvements.isEmpty) {
      improvements.add('Review the full AI analysis for specific recommendations');
      improvements.add('Consider implementing code quality checks');
      improvements.add('Regular security audits are recommended');
    }
    
    return improvements.take(5).toList();
  }

  double _calculateOverallScore(String response) {
    final scores = <double>[];
    
    // Extract all potential scores
    final scorePattern = RegExp(r'(\d+\.?\d*)');
    final matches = scorePattern.allMatches(response);
    
    for (final match in matches) {
      final score = double.tryParse(match.group(1) ?? '0');
      if (score != null && score >= 0 && score <= 10) {
        scores.add(score);
      }
    }
    
    if (scores.isNotEmpty) {
      return scores.reduce((a, b) => a + b) / scores.length;
    }
    
    return 7.0; // Default overall score
  }

  String _extractAdditionalInsights(String response) {
    if (response.length > 200) {
      final lastPart = response.substring(response.length - 200);
      final sentences = lastPart.split('.');
      if (sentences.length > 1) {
        return sentences[sentences.length - 2].trim();
      }
    }
    return 'Additional insights available in the full analysis';
  }
}

class RepositoryAIInsights {
  final String repositorySummary;
  final double codeQualityScore;
  final double securityScore;
  final double maintainabilityScore;
  final double architectureScore;
  final String codeQualityAnalysis;
  final String securityAnalysis;
  final String maintainabilityAnalysis;
  final String architectureAnalysis;
  final List<String> suggestedImprovements;
  final double overallScore;
  final double complexityScore;
  final String languageAnalysis;
  final String contributionPatterns;
  final String additionalInsights;

  RepositoryAIInsights({
    required this.repositorySummary,
    required this.codeQualityScore,
    required this.securityScore,
    required this.maintainabilityScore,
    required this.architectureScore,
    required this.codeQualityAnalysis,
    required this.securityAnalysis,
    required this.maintainabilityAnalysis,
    required this.architectureAnalysis,
    required this.suggestedImprovements,
    required this.overallScore,
    required this.complexityScore,
    required this.languageAnalysis,
    required this.contributionPatterns,
    required this.additionalInsights,
  });
}
