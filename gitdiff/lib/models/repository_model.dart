import 'package:hive/hive.dart';
import '../services/ai_analysis_service.dart';

part 'repository_model.g.dart';

// Main Repository Model
@HiveType(typeId: 0)
class RepositoryModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String fullName;

  @HiveField(3)
  String? description;

  @HiveField(4)
  String htmlUrl;

  @HiveField(5)
  String cloneUrl;

  @HiveField(6)
  String gitUrl;

  @HiveField(7)
  String sshUrl;

  @HiveField(8)
  int stargazersCount;

  @HiveField(9)
  int watchersCount;

  @HiveField(10)
  int forksCount;

  @HiveField(11)
  int openIssuesCount;

  @HiveField(12)
  String? language;

  @HiveField(13)
  String? license;

  @HiveField(14)
  DateTime createdAt;

  @HiveField(15)
  DateTime updatedAt;

  @HiveField(16)
  DateTime? pushedAt;

  @HiveField(17)
  int size; // in KB

  @HiveField(18)
  String defaultBranch;

  @HiveField(19)
  bool isPrivate;

  @HiveField(20)
  bool isFork;

  @HiveField(21)
  bool hasIssues;

  @HiveField(22)
  bool hasProjects;

  @HiveField(23)
  bool hasWiki;

  @HiveField(24)
  bool hasPages;

  @HiveField(25)
  bool hasDownloads;

  @HiveField(26)
  int networkCount;

  @HiveField(27)
  int subscribersCount;

  @HiveField(28)
  OwnerModel owner;

  @HiveField(29)
  List<String>? topics;

  @HiveField(30)
  String? homepage;

  @HiveField(31)
  DateTime cachedAt;

  @HiveField(32)
  Map<String, int>? languages; // Language breakdown with bytes (not percentages)

  @HiveField(33)
  List<ContributorModel>? contributors;

  @HiveField(34)
  List<CommitActivityModel>? commitActivity;

  @HiveField(35)
  String? readmeContent;

  @HiveField(36)
  AIInsightsModel? aiInsights;

  RepositoryModel({
    required this.id,
    required this.name,
    required this.fullName,
    this.description,
    required this.htmlUrl,
    required this.cloneUrl,
    required this.gitUrl,
    required this.sshUrl,
    required this.stargazersCount,
    required this.watchersCount,
    required this.forksCount,
    required this.openIssuesCount,
    this.language,
    this.license,
    required this.createdAt,
    required this.updatedAt,
    this.pushedAt,
    required this.size,
    required this.defaultBranch,
    required this.isPrivate,
    required this.isFork,
    required this.hasIssues,
    required this.hasProjects,
    required this.hasWiki,
    required this.hasPages,
    required this.hasDownloads,
    required this.networkCount,
    required this.subscribersCount,
    required this.owner,
    this.topics,
    this.homepage,
    required this.cachedAt,
    this.languages,
    this.contributors,
    this.commitActivity,
    this.readmeContent,
    this.aiInsights,
  });

  factory RepositoryModel.fromJson(Map<String, dynamic> json) {
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
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'full_name': fullName,
      'description': description,
      'html_url': htmlUrl,
      'clone_url': cloneUrl,
      'git_url': gitUrl,
      'ssh_url': sshUrl,
      'stargazers_count': stargazersCount,
      'watchers_count': watchersCount,
      'forks_count': forksCount,
      'open_issues_count': openIssuesCount,
      'language': language,
      'license': license != null ? {'name': license} : null,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'pushed_at': pushedAt?.toIso8601String(),
      'size': size,
      'default_branch': defaultBranch,
      'private': isPrivate,
      'fork': isFork,
      'has_issues': hasIssues,
      'has_projects': hasProjects,
      'has_wiki': hasWiki,
      'has_pages': hasPages,
      'has_downloads': hasDownloads,
      'network_count': networkCount,
      'subscribers_count': subscribersCount,
      'owner': owner.toJson(),
      'topics': topics,
      'homepage': homepage,
    };
  }

  // Helper methods
  bool get isCacheExpired {
    return DateTime.now().difference(cachedAt).inHours > 1;
  }

  String get cacheKey => fullName;

  double get activityScore {
    final daysSinceLastPush = pushedAt != null
        ? DateTime.now().difference(pushedAt!).inDays
        : 365;
    final recentActivity = daysSinceLastPush < 30 ? 1.0 : 0.5;
    final popularityScore = (stargazersCount + forksCount) / 1000;
    return (recentActivity + popularityScore).clamp(0.0, 5.0);
  }
}

// Owner/User Model
@HiveType(typeId: 1)
class OwnerModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String login;

  @HiveField(2)
  String avatarUrl;

  @HiveField(3)
  String htmlUrl;

  @HiveField(4)
  String type; // "User" or "Organization"

  @HiveField(5)
  String? name;

  @HiveField(6)
  String? company;

  @HiveField(7)
  String? blog;

  @HiveField(8)
  String? location;

  @HiveField(9)
  String? email;

  @HiveField(10)
  String? bio;

  @HiveField(11)
  int? publicRepos;

  @HiveField(12)
  int? followers;

  @HiveField(13)
  int? following;

  OwnerModel({
    required this.id,
    required this.login,
    required this.avatarUrl,
    required this.htmlUrl,
    required this.type,
    this.name,
    this.company,
    this.blog,
    this.location,
    this.email,
    this.bio,
    this.publicRepos,
    this.followers,
    this.following,
  });

  factory OwnerModel.fromJson(Map<String, dynamic> json) {
    return OwnerModel(
      id: json['id'],
      login: json['login'],
      avatarUrl: json['avatar_url'],
      htmlUrl: json['html_url'],
      type: json['type'],
      name: json['name'],
      company: json['company'],
      blog: json['blog'],
      location: json['location'],
      email: json['email'],
      bio: json['bio'],
      publicRepos: json['public_repos'],
      followers: json['followers'],
      following: json['following'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'avatar_url': avatarUrl,
      'html_url': htmlUrl,
      'type': type,
      'name': name,
      'company': company,
      'blog': blog,
      'location': location,
      'email': email,
      'bio': bio,
      'public_repos': publicRepos,
      'followers': followers,
      'following': following,
    };
  }
}

// Contributor Model
@HiveType(typeId: 2)
class ContributorModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String login;

  @HiveField(2)
  String avatarUrl;

  @HiveField(3)
  String htmlUrl;

  @HiveField(4)
  int contributions;

  @HiveField(5)
  String type;

  ContributorModel({
    required this.id,
    required this.login,
    required this.avatarUrl,
    required this.htmlUrl,
    required this.contributions,
    required this.type,
  });

  factory ContributorModel.fromJson(Map<String, dynamic> json) {
    return ContributorModel(
      id: json['id'],
      login: json['login'],
      avatarUrl: json['avatar_url'],
      htmlUrl: json['html_url'],
      contributions: json['contributions'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'avatar_url': avatarUrl,
      'html_url': htmlUrl,
      'contributions': contributions,
      'type': type,
    };
  }
}

// Commit Activity Model (for weekly commit stats)
@HiveType(typeId: 3)
class CommitActivityModel extends HiveObject {
  @HiveField(0)
  int week; // Unix timestamp

  @HiveField(1)
  int total; // Total commits that week

  @HiveField(2)
  List<int> days; // Commits per day (Sun-Sat)

  CommitActivityModel({
    required this.week,
    required this.total,
    required this.days,
  });

  factory CommitActivityModel.fromJson(Map<String, dynamic> json) {
    return CommitActivityModel(
      week: json['week'],
      total: json['total'],
      days: (json['days'] as List).cast<int>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'week': week,
      'total': total,
      'days': days,
    };
  }

  DateTime get weekDate => DateTime.fromMillisecondsSinceEpoch(week * 1000);
}

// AI Insights Model
@HiveType(typeId: 4)
class AIInsightsModel extends HiveObject {
  @HiveField(0)
  String repositorySummary;

  @HiveField(1)
  double codeQualityScore;

  @HiveField(2)
  double securityScore;

  @HiveField(3)
  double maintainabilityScore;

  @HiveField(4)
  double architectureScore;

  @HiveField(5)
  String codeQualityAnalysis;

  @HiveField(6)
  String securityAnalysis;

  @HiveField(7)
  String maintainabilityAnalysis;

  @HiveField(8)
  String architectureAnalysis;

  @HiveField(9)
  List<String> suggestedImprovements;

  @HiveField(10)
  double overallScore;

  @HiveField(11)
  double complexityScore;

  @HiveField(12)
  String languageAnalysis;

  @HiveField(13)
  String contributionPatterns;

  @HiveField(14)
  String additionalInsights;

  @HiveField(15)
  DateTime generatedAt;

  AIInsightsModel({
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
    required this.generatedAt,
  });

  factory AIInsightsModel.fromJson(Map<String, dynamic> json) {
    return AIInsightsModel(
      repositorySummary: json['repository_summary'] ?? '',
      codeQualityScore: json['code_quality_score']?.toDouble() ?? 0.0,
      securityScore: json['security_score']?.toDouble() ?? 0.0,
      maintainabilityScore: json['maintainability_score']?.toDouble() ?? 0.0,
      architectureScore: json['architecture_score']?.toDouble() ?? 0.0,
      codeQualityAnalysis: json['code_quality_analysis'] ?? '',
      securityAnalysis: json['security_analysis'] ?? '',
      maintainabilityAnalysis: json['maintainability_analysis'] ?? '',
      architectureAnalysis: json['architecture_analysis'] ?? '',
      suggestedImprovements: (json['suggested_improvements'] as List?)?.cast<String>() ?? [],
      overallScore: json['overall_score']?.toDouble() ?? 0.0,
      complexityScore: json['complexity_score']?.toDouble() ?? 0.0,
      languageAnalysis: json['language_analysis'] ?? '',
      contributionPatterns: json['contribution_patterns'] ?? '',
      additionalInsights: json['additional_insights'] ?? '',
      generatedAt: json['generated_at'] != null 
          ? DateTime.parse(json['generated_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'repository_summary': repositorySummary,
      'code_quality_score': codeQualityScore,
      'security_score': securityScore,
      'maintainability_score': maintainabilityScore,
      'architecture_score': architectureScore,
      'code_quality_analysis': codeQualityAnalysis,
      'security_analysis': securityAnalysis,
      'maintainability_analysis': maintainabilityAnalysis,
      'architecture_analysis': architectureAnalysis,
      'suggested_improvements': suggestedImprovements,
      'overall_score': overallScore,
      'complexity_score': complexityScore,
      'language_analysis': languageAnalysis,
      'contribution_patterns': contributionPatterns,
      'additional_insights': additionalInsights,
      'generated_at': generatedAt.toIso8601String(),
    };
  }

  bool get isExpired {
    return DateTime.now().difference(generatedAt).inDays > 1;
  }

  // Helper method to convert from RepositoryAIInsights
  factory AIInsightsModel.fromAIInsights(RepositoryAIInsights insights) {
    return AIInsightsModel(
      repositorySummary: insights.repositorySummary,
      codeQualityScore: insights.codeQualityScore,
      securityScore: insights.securityScore,
      maintainabilityScore: insights.maintainabilityScore,
      architectureScore: insights.architectureScore,
      codeQualityAnalysis: insights.codeQualityAnalysis,
      securityAnalysis: insights.securityAnalysis,
      maintainabilityAnalysis: insights.maintainabilityAnalysis,
      architectureAnalysis: insights.architectureAnalysis,
      suggestedImprovements: insights.suggestedImprovements,
      overallScore: insights.overallScore,
      complexityScore: insights.complexityScore,
      languageAnalysis: insights.languageAnalysis,
      contributionPatterns: insights.contributionPatterns,
      additionalInsights: insights.additionalInsights,
      generatedAt: DateTime.now(),
    );
  }
}

// Language Statistics Model (for detailed language breakdown)
@HiveType(typeId: 5)
class LanguageStatsModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int bytes;

  @HiveField(2)
  double percentage;

  @HiveField(3)
  String? color; // GitHub language color

  LanguageStatsModel({
    required this.name,
    required this.bytes,
    required this.percentage,
    this.color,
  });

  static List<LanguageStatsModel> fromLanguageMap(Map<String, dynamic> languages) {
    final totalBytes = languages.values.fold<int>(0, (sum, bytes) => sum + (bytes as int));

    return languages.entries.map((entry) {
      return LanguageStatsModel(
        name: entry.key,
        bytes: entry.value as int,
        percentage: ((entry.value as int) / totalBytes) * 100,
      );
    }).toList()..sort((a, b) => b.percentage.compareTo(a.percentage));
  }
}

// Repository Comparison Model (for advanced features)
@HiveType(typeId: 6)
class RepositoryComparisonModel extends HiveObject {
  @HiveField(0)
  RepositoryModel repo1;

  @HiveField(1)
  RepositoryModel repo2;

  @HiveField(2)
  DateTime comparedAt;

  @HiveField(3)
  Map<String, double>? comparisonMetrics; // Changed to Map<String, double> for Hive compatibility

  RepositoryComparisonModel({
    required this.repo1,
    required this.repo2,
    required this.comparedAt,
    this.comparisonMetrics,
  });

  Map<String, double> getComparisonData() {
    return {
      'stars_difference': (repo1.stargazersCount - repo2.stargazersCount).toDouble(),
      'forks_difference': (repo1.forksCount - repo2.forksCount).toDouble(),
      'size_difference': (repo1.size - repo2.size).toDouble(),
      'age_difference': repo1.createdAt.difference(repo2.createdAt).inDays.toDouble(),
      'activity_difference': repo1.activityScore - repo2.activityScore,
    };
  }
}