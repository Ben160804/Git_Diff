// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RepositoryModelAdapter extends TypeAdapter<RepositoryModel> {
  @override
  final int typeId = 0;

  @override
  RepositoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RepositoryModel(
      id: fields[0] as int,
      name: fields[1] as String,
      fullName: fields[2] as String,
      description: fields[3] as String?,
      htmlUrl: fields[4] as String,
      cloneUrl: fields[5] as String,
      gitUrl: fields[6] as String,
      sshUrl: fields[7] as String,
      stargazersCount: fields[8] as int,
      watchersCount: fields[9] as int,
      forksCount: fields[10] as int,
      openIssuesCount: fields[11] as int,
      language: fields[12] as String?,
      license: fields[13] as String?,
      createdAt: fields[14] as DateTime,
      updatedAt: fields[15] as DateTime,
      pushedAt: fields[16] as DateTime?,
      size: fields[17] as int,
      defaultBranch: fields[18] as String,
      isPrivate: fields[19] as bool,
      isFork: fields[20] as bool,
      hasIssues: fields[21] as bool,
      hasProjects: fields[22] as bool,
      hasWiki: fields[23] as bool,
      hasPages: fields[24] as bool,
      hasDownloads: fields[25] as bool,
      networkCount: fields[26] as int,
      subscribersCount: fields[27] as int,
      owner: fields[28] as OwnerModel,
      topics: (fields[29] as List?)?.cast<String>(),
      homepage: fields[30] as String?,
      cachedAt: fields[31] as DateTime,
      languages: (fields[32] as Map?)?.cast<String, int>(),
      contributors: (fields[33] as List?)?.cast<ContributorModel>(),
      commitActivity: (fields[34] as List?)?.cast<CommitActivityModel>(),
      readmeContent: fields[35] as String?,
      aiInsights: fields[36] as AIInsightsModel?,
    );
  }

  @override
  void write(BinaryWriter writer, RepositoryModel obj) {
    writer
      ..writeByte(37)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.fullName)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.htmlUrl)
      ..writeByte(5)
      ..write(obj.cloneUrl)
      ..writeByte(6)
      ..write(obj.gitUrl)
      ..writeByte(7)
      ..write(obj.sshUrl)
      ..writeByte(8)
      ..write(obj.stargazersCount)
      ..writeByte(9)
      ..write(obj.watchersCount)
      ..writeByte(10)
      ..write(obj.forksCount)
      ..writeByte(11)
      ..write(obj.openIssuesCount)
      ..writeByte(12)
      ..write(obj.language)
      ..writeByte(13)
      ..write(obj.license)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt)
      ..writeByte(16)
      ..write(obj.pushedAt)
      ..writeByte(17)
      ..write(obj.size)
      ..writeByte(18)
      ..write(obj.defaultBranch)
      ..writeByte(19)
      ..write(obj.isPrivate)
      ..writeByte(20)
      ..write(obj.isFork)
      ..writeByte(21)
      ..write(obj.hasIssues)
      ..writeByte(22)
      ..write(obj.hasProjects)
      ..writeByte(23)
      ..write(obj.hasWiki)
      ..writeByte(24)
      ..write(obj.hasPages)
      ..writeByte(25)
      ..write(obj.hasDownloads)
      ..writeByte(26)
      ..write(obj.networkCount)
      ..writeByte(27)
      ..write(obj.subscribersCount)
      ..writeByte(28)
      ..write(obj.owner)
      ..writeByte(29)
      ..write(obj.topics)
      ..writeByte(30)
      ..write(obj.homepage)
      ..writeByte(31)
      ..write(obj.cachedAt)
      ..writeByte(32)
      ..write(obj.languages)
      ..writeByte(33)
      ..write(obj.contributors)
      ..writeByte(34)
      ..write(obj.commitActivity)
      ..writeByte(35)
      ..write(obj.readmeContent)
      ..writeByte(36)
      ..write(obj.aiInsights);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepositoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OwnerModelAdapter extends TypeAdapter<OwnerModel> {
  @override
  final int typeId = 1;

  @override
  OwnerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OwnerModel(
      id: fields[0] as int,
      login: fields[1] as String,
      avatarUrl: fields[2] as String,
      htmlUrl: fields[3] as String,
      type: fields[4] as String,
      name: fields[5] as String?,
      company: fields[6] as String?,
      blog: fields[7] as String?,
      location: fields[8] as String?,
      email: fields[9] as String?,
      bio: fields[10] as String?,
      publicRepos: fields[11] as int?,
      followers: fields[12] as int?,
      following: fields[13] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, OwnerModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.login)
      ..writeByte(2)
      ..write(obj.avatarUrl)
      ..writeByte(3)
      ..write(obj.htmlUrl)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.name)
      ..writeByte(6)
      ..write(obj.company)
      ..writeByte(7)
      ..write(obj.blog)
      ..writeByte(8)
      ..write(obj.location)
      ..writeByte(9)
      ..write(obj.email)
      ..writeByte(10)
      ..write(obj.bio)
      ..writeByte(11)
      ..write(obj.publicRepos)
      ..writeByte(12)
      ..write(obj.followers)
      ..writeByte(13)
      ..write(obj.following);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OwnerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ContributorModelAdapter extends TypeAdapter<ContributorModel> {
  @override
  final int typeId = 2;

  @override
  ContributorModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContributorModel(
      id: fields[0] as int,
      login: fields[1] as String,
      avatarUrl: fields[2] as String,
      htmlUrl: fields[3] as String,
      contributions: fields[4] as int,
      type: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ContributorModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.login)
      ..writeByte(2)
      ..write(obj.avatarUrl)
      ..writeByte(3)
      ..write(obj.htmlUrl)
      ..writeByte(4)
      ..write(obj.contributions)
      ..writeByte(5)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContributorModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CommitActivityModelAdapter extends TypeAdapter<CommitActivityModel> {
  @override
  final int typeId = 3;

  @override
  CommitActivityModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CommitActivityModel(
      week: fields[0] as int,
      total: fields[1] as int,
      days: (fields[2] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, CommitActivityModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.week)
      ..writeByte(1)
      ..write(obj.total)
      ..writeByte(2)
      ..write(obj.days);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommitActivityModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AIInsightsModelAdapter extends TypeAdapter<AIInsightsModel> {
  @override
  final int typeId = 4;

  @override
  AIInsightsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AIInsightsModel(
      repositorySummary: fields[0] as String,
      codeQualityScore: fields[1] as double,
      securityScore: fields[2] as double,
      maintainabilityScore: fields[3] as double,
      architectureScore: fields[4] as double,
      codeQualityAnalysis: fields[5] as String,
      securityAnalysis: fields[6] as String,
      maintainabilityAnalysis: fields[7] as String,
      architectureAnalysis: fields[8] as String,
      suggestedImprovements: (fields[9] as List).cast<String>(),
      overallScore: fields[10] as double,
      complexityScore: fields[11] as double,
      languageAnalysis: fields[12] as String,
      contributionPatterns: fields[13] as String,
      additionalInsights: fields[14] as String,
      generatedAt: fields[15] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AIInsightsModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.repositorySummary)
      ..writeByte(1)
      ..write(obj.codeQualityScore)
      ..writeByte(2)
      ..write(obj.securityScore)
      ..writeByte(3)
      ..write(obj.maintainabilityScore)
      ..writeByte(4)
      ..write(obj.architectureScore)
      ..writeByte(5)
      ..write(obj.codeQualityAnalysis)
      ..writeByte(6)
      ..write(obj.securityAnalysis)
      ..writeByte(7)
      ..write(obj.maintainabilityAnalysis)
      ..writeByte(8)
      ..write(obj.architectureAnalysis)
      ..writeByte(9)
      ..write(obj.suggestedImprovements)
      ..writeByte(10)
      ..write(obj.overallScore)
      ..writeByte(11)
      ..write(obj.complexityScore)
      ..writeByte(12)
      ..write(obj.languageAnalysis)
      ..writeByte(13)
      ..write(obj.contributionPatterns)
      ..writeByte(14)
      ..write(obj.additionalInsights)
      ..writeByte(15)
      ..write(obj.generatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIInsightsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LanguageStatsModelAdapter extends TypeAdapter<LanguageStatsModel> {
  @override
  final int typeId = 5;

  @override
  LanguageStatsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LanguageStatsModel(
      name: fields[0] as String,
      bytes: fields[1] as int,
      percentage: fields[2] as double,
      color: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LanguageStatsModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.bytes)
      ..writeByte(2)
      ..write(obj.percentage)
      ..writeByte(3)
      ..write(obj.color);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageStatsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RepositoryComparisonModelAdapter
    extends TypeAdapter<RepositoryComparisonModel> {
  @override
  final int typeId = 6;

  @override
  RepositoryComparisonModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RepositoryComparisonModel(
      repo1: fields[0] as RepositoryModel,
      repo2: fields[1] as RepositoryModel,
      comparedAt: fields[2] as DateTime,
      comparisonMetrics: (fields[3] as Map?)?.cast<String, double>(),
    );
  }

  @override
  void write(BinaryWriter writer, RepositoryComparisonModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.repo1)
      ..writeByte(1)
      ..write(obj.repo2)
      ..writeByte(2)
      ..write(obj.comparedAt)
      ..writeByte(3)
      ..write(obj.comparisonMetrics);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepositoryComparisonModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
