import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/repository_model.dart';
import 'ai_analysis_widget.dart';

class RepositoryInfoCard extends StatefulWidget {
  final RepositoryModel repository;
  final bool showFullDetails;
  final VoidCallback? onTap;

  const RepositoryInfoCard({
    Key? key,
    required this.repository,
    this.showFullDetails = true,
    this.onTap,
  }) : super(key: key);

  @override
  State<RepositoryInfoCard> createState() => _RepositoryInfoCardState();
}

class _RepositoryInfoCardState extends State<RepositoryInfoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(RepositoryInfoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Force rebuild when repository data changes (especially AI insights)
    if (oldWidget.repository.aiInsights != widget.repository.aiInsights) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 1200;
    final isLargeScreen = screenWidth >= 1200;
    
    // Responsive values
    final cardMargin = isSmallScreen ? 12.0 : isMediumScreen ? 16.0 : 20.0;
    final cardPadding = isSmallScreen ? 16.0 : isMediumScreen ? 20.0 : 24.0;
    final borderRadius = isSmallScreen ? 16.0 : isMediumScreen ? 20.0 : 24.0;
    final avatarRadius = isSmallScreen ? 20.0 : isMediumScreen ? 24.0 : 28.0;
    final headerSpacing = isSmallScreen ? 12.0 : isMediumScreen ? 16.0 : 20.0;
    final sectionSpacing = isSmallScreen ? 16.0 : isMediumScreen ? 20.0 : 24.0;
    final smallSpacing = isSmallScreen ? 8.0 : isMediumScreen ? 12.0 : 16.0;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: EdgeInsets.all(cardMargin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.08),
                    blurRadius: isSmallScreen ? 24 : 32,
                    offset: Offset(0, isSmallScreen ? 12 : 16),
                    spreadRadius: isSmallScreen ? -6 : -8,
                  ),
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.04),
                    blurRadius: isSmallScreen ? 12 : 16,
                    offset: Offset(0, isSmallScreen ? 6 : 8),
                    spreadRadius: isSmallScreen ? -2 : -4,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Padding(
                    padding: EdgeInsets.all(cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(avatarRadius, headerSpacing, isSmallScreen),
                        SizedBox(height: headerSpacing),
                        _buildDescription(isSmallScreen),
                        if (widget.showFullDetails) ...[
                          SizedBox(height: sectionSpacing),
                          _buildCommitTimeline(isSmallScreen, smallSpacing),
                          SizedBox(height: sectionSpacing),
                          _buildStatsGrid(isSmallScreen, smallSpacing),
                          SizedBox(height: headerSpacing),
                          _buildContributorsSection(isSmallScreen, smallSpacing),
                          SizedBox(height: headerSpacing),
                          _buildLanguagesSection(isSmallScreen, smallSpacing),
                          SizedBox(height: headerSpacing),
                          _buildTopicsSection(isSmallScreen, smallSpacing),
                          SizedBox(height: headerSpacing),
                          _buildAIAnalysisSection(isSmallScreen, smallSpacing),
                          SizedBox(height: sectionSpacing),
                          _buildActionsRow(isSmallScreen, smallSpacing),
                        ] else ...[
                          SizedBox(height: smallSpacing),
                          _buildMinimalStats(isSmallScreen),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(double avatarRadius, double spacing, bool isSmallScreen) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 2 : 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.purple.shade400],
            ),
          ),
          child: CircleAvatar(
            radius: avatarRadius,
            backgroundImage: NetworkImage(widget.repository.owner.avatarUrl),
            backgroundColor: Colors.grey.shade200,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    widget.repository.isPrivate ? Icons.lock : Icons.public,
                    size: isSmallScreen ? 12 : 14,
                    color: widget.repository.isPrivate ? Colors.amber : Colors.green,
                  ),
                  SizedBox(width: isSmallScreen ? 4 : 6),
                  Flexible(
                    child: Text(
                      widget.repository.fullName,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 1 : 2),
              Text(
                widget.repository.owner.login,
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _buildActivityIndicator(isSmallScreen),
      ],
    );
  }

  Widget _buildActivityIndicator(bool isSmallScreen) {
    final score = widget.repository.activityScore ?? 0.0;
    final color = score > 3 ? Colors.green : score > 1.5 ? Colors.orange : Colors.red;
    final intensity = (score / 5).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 12, 
        vertical: isSmallScreen ? 4 : 6
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isSmallScreen ? 6 : 8,
            height: isSmallScreen ? 6 : 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          SizedBox(width: isSmallScreen ? 4 : 6),
          Text(
            score.toStringAsFixed(1),
            style: TextStyle(
              color: color.shade700,
              fontSize: isSmallScreen ? 10 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(bool isSmallScreen) {
    if (widget.repository.description == null || widget.repository.description!.isEmpty) {
      return Container(
        padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Text(
          'No description available',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            fontSize: isSmallScreen ? 12 : 14,
          ),
        ),
      );
    }

    return Text(
      widget.repository.description!,
      style: TextStyle(
        fontSize: isSmallScreen ? 13 : 15,
        height: 1.5,
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w400,
      ),
      maxLines: widget.showFullDetails ? null : 2,
      overflow: widget.showFullDetails ? null : TextOverflow.ellipsis,
    );
  }

  Widget _buildCommitTimeline(bool isSmallScreen, double spacing) {
    if (widget.repository.commitActivity == null ||
        widget.repository.commitActivity!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Filter out weeks with 0 commits and take meaningful data points
    final commitData = widget.repository.commitActivity!
        .where((activity) => activity.total > 0)
        .toList();

    if (commitData.isEmpty) return const SizedBox.shrink();

    // Take only the most recent 6-8 weeks to prevent overflow
    final recentCommits = commitData.take(isSmallScreen ? 6 : 8).toList();
    final maxCommits = recentCommits.map((e) => e.total).reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.timeline, 
              size: isSmallScreen ? 16 : 18, 
              color: Colors.blue.shade600
            ),
            SizedBox(width: isSmallScreen ? 6 : 8),
            Text(
              'Recent Commit Activity',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 6 : 8, 
                vertical: isSmallScreen ? 3 : 4
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
              ),
              child: Text(
                '${recentCommits.length} weeks',
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 12,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: spacing),
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade50.withOpacity(0.5),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Column(
            children: recentCommits.asMap().entries.map((entry) {
              final index = entry.key;
              final activity = entry.value;
              final date = DateTime.fromMillisecondsSinceEpoch(activity.week * 1000);
              final month = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1];
              final day = date.day;
              final intensity = (activity.total / maxCommits).clamp(0.1, 1.0);
              
              return Padding(
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 3 : 4),
                child: Row(
                  children: [
                    // Timeline dot
                    Container(
                      width: isSmallScreen ? 8 : 10,
                      height: isSmallScreen ? 8 : 10,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    // Timeline line (except for last item)
                    if (index < recentCommits.length - 1)
                      Container(
                        width: 2,
                        height: isSmallScreen ? 20 : 24,
                        margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 6 : 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade200,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      )
                    else
                      SizedBox(width: isSmallScreen ? 14 : 18),
                    // Date and commit info
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 8 : 10,
                              vertical: isSmallScreen ? 4 : 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                            ),
                            child: Text(
                              '$month $day',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 10 : 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 8 : 12),
                          Expanded(
                            child: Row(
                              children: [
                                // Activity indicator bar
                                Container(
                                  width: isSmallScreen ? 40 : 50,
                                  height: isSmallScreen ? 6 : 8,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue.shade600.withOpacity(intensity),
                                        Colors.blue.shade400.withOpacity(intensity * 0.7),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(isSmallScreen ? 3 : 4),
                                  ),
                                ),
                                SizedBox(width: isSmallScreen ? 6 : 8),
                                // Commit count
                                Text(
                                  '${activity.total} commits',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 11 : 13,
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(bool isSmallScreen, double spacing) {
    final stats = [
      {'icon': Icons.star, 'value': widget.repository.stargazersCount, 'label': 'Stars', 'color': Colors.amber},
      {'icon': Icons.call_split, 'value': widget.repository.forksCount, 'label': 'Forks', 'color': Colors.blue},
      {'icon': Icons.visibility, 'value': widget.repository.watchersCount, 'label': 'Watchers', 'color': Colors.green},
      {'icon': Icons.bug_report, 'value': widget.repository.openIssuesCount, 'label': 'Issues', 'color': Colors.red},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repository Statistics',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 400) {
              // Stack vertically for very small screens
              return Column(
                children: stats.map((stat) => Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (stat['color'] as Color).withOpacity(0.08),
                        (stat['color'] as Color).withOpacity(0.03),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                    border: Border.all(
                      color: (stat['color'] as Color).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        stat['icon'] as IconData,
                        size: isSmallScreen ? 18 : 20,
                        color: stat['color'] as Color,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatNumber(stat['value'] as int),
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              stat['label'] as String,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 10 : 11,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              );
            } else {
              // Use grid layout for larger screens
              return Row(
                children: stats.map((stat) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: 8),
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          (stat['color'] as Color).withOpacity(0.08),
                          (stat['color'] as Color).withOpacity(0.03),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                      border: Border.all(
                        color: (stat['color'] as Color).withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          stat['icon'] as IconData,
                          size: isSmallScreen ? 18 : 20,
                          color: stat['color'] as Color,
                        ),
                        SizedBox(height: isSmallScreen ? 6 : 8),
                        Text(
                          _formatNumber(stat['value'] as int),
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          stat['label'] as String,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 11,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )).toList(),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildContributorsSection(bool isSmallScreen, double spacing) {
    if (widget.repository.contributors == null || widget.repository.contributors!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort contributors by contribution count
    final sortedContributors = widget.repository.contributors!.toList()
      ..sort((a, b) => b.contributions.compareTo(a.contributions));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Contributors',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Column(
            children: sortedContributors.take(isSmallScreen ? 3 : 5).map((contributor) {
              final contributionPercentage = (contributor.contributions / 
                sortedContributors.first.contributions * 100).clamp(0.0, 100.0);
              
              return Padding(
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 4 : 6),
                child: Row(
                  children: [
                    // Contributor avatar
                    Container(
                      width: isSmallScreen ? 32 : 36,
                      height: isSmallScreen ? 32 : 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                      ),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(contributor.avatarUrl),
                        backgroundColor: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 8 : 12),
                    // Contributor info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contributor.login,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '${contributor.contributions} contributions',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 10 : 12,
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Contribution bar
                    Column(
                      children: [
                        Container(
                          width: isSmallScreen ? 40 : 50,
                          height: isSmallScreen ? 4 : 6,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(isSmallScreen ? 2 : 3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: contributionPercentage / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green.shade500,
                                    Colors.green.shade400,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(isSmallScreen ? 2 : 3),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '${contributionPercentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 8 : 10,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguagesSection(bool isSmallScreen, double spacing) {
    if (widget.repository.languages == null || widget.repository.languages!.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedLanguages = widget.repository.languages!.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final totalBytes = widget.repository.languages!.values.fold(0, (sum, bytes) => sum + bytes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Languages',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Column(
            children: sortedLanguages.take(5).map((entry) {
              final percentage = (entry.value / totalBytes * 100);
              final color = _getLanguageColor(entry.key);

              return Padding(
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 4 : 6),
                child: Row(
                  children: [
                    Container(
                      width: isSmallScreen ? 10 : 12,
                      height: isSmallScreen ? 10 : 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 8 : 12),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 11 : 13,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTopicsSection(bool isSmallScreen, double spacing) {
    if (widget.repository.topics == null || widget.repository.topics!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Topics',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        Wrap(
          spacing: isSmallScreen ? 6 : 8,
          runSpacing: isSmallScreen ? 6 : 8,
          children: widget.repository.topics!.take(isSmallScreen ? 4 : 6).map((topic) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 12, 
                vertical: isSmallScreen ? 4 : 6
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade50,
                    Colors.purple.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                topic,
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 12,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAIAnalysisSection(bool isSmallScreen, double spacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.psychology,
              size: isSmallScreen ? 16 : 18,
              color: Colors.purple.shade600,
            ),
            SizedBox(width: isSmallScreen ? 6 : 8),
            Text(
              'AI Analysis',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            if (widget.repository.aiInsights != null)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 10,
                  vertical: isSmallScreen ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                ),
                child: Text(
                  '${widget.repository.aiInsights!.overallScore.toStringAsFixed(1)}/10',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 10 : 12,
                    color: Colors.purple.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: spacing),
        AIAnalysisWidget(
          key: ValueKey('ai_analysis_${widget.repository.aiInsights?.generatedAt?.millisecondsSinceEpoch ?? 'null'}'),
          aiInsights: widget.repository.aiInsights,
          isLoading: _isAIAnalysisInProgress(),
        ),
      ],
    );
  }

  Widget _buildActionsRow(bool isSmallScreen, double spacing) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: isSmallScreen ? 44 : 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade600, Colors.blue.shade700],
              ),
              borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.2),
                  blurRadius: isSmallScreen ? 6 : 8,
                  offset: Offset(0, isSmallScreen ? 3 : 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _launchURL(widget.repository.htmlUrl),
                borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.open_in_new, 
                      color: Theme.of(context).colorScheme.onPrimary, 
                      size: isSmallScreen ? 16 : 18
                    ),
                    SizedBox(width: isSmallScreen ? 6 : 8),
                    Text(
                      'View on GitHub',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: isSmallScreen ? 8 : 12),
        Container(
          width: isSmallScreen ? 44 : 48,
          height: isSmallScreen ? 44 : 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _copyToClipboard(widget.repository.cloneUrl),
              borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
              child: Icon(
                Icons.content_copy,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: isSmallScreen ? 18 : 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMinimalStats(bool isSmallScreen) {
    return Row(
      children: [
        _buildMinimalStat(Icons.star, widget.repository.stargazersCount, Colors.amber, isSmallScreen),
        SizedBox(width: isSmallScreen ? 12 : 16),
        _buildMinimalStat(Icons.call_split, widget.repository.forksCount, Colors.blue, isSmallScreen),
        SizedBox(width: isSmallScreen ? 12 : 16),
        _buildMinimalStat(Icons.visibility, widget.repository.watchersCount, Colors.green, isSmallScreen),
        const Spacer(),
        if (widget.repository.topics?.isNotEmpty ?? false)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 6 : 8, 
              vertical: isSmallScreen ? 3 : 4
            ),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
            ),
            child: Text(
              widget.repository.topics!.first,
              style: TextStyle(
                fontSize: isSmallScreen ? 9 : 11,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMinimalStat(IconData icon, int value, Color color, bool isSmallScreen) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: isSmallScreen ? 14 : 16, color: color),
        SizedBox(width: isSmallScreen ? 3 : 4),
        Text(
          _formatNumber(value),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isSmallScreen ? 12 : 14,
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  Color _getLanguageColor(String language) {
    final colors = {
      'JavaScript': Colors.yellow.shade700,
      'TypeScript': Colors.blue.shade600,
      'Python': Colors.green.shade600,
      'Java': Colors.orange.shade700,
      'Dart': Colors.blue.shade400,
      'Swift': Colors.orange.shade600,
      'Kotlin': Colors.purple.shade600,
      'Go': Colors.cyan.shade600,
      'Rust': Colors.brown.shade600,
      'C++': Colors.pink.shade600,
      'C#': Colors.purple.shade700,
      'PHP': Colors.indigo.shade600,
      'Ruby': Colors.red.shade600,
      'HTML': Colors.orange.shade500,
      'CSS': Colors.blue.shade500,
      'Jupyter Notebook': Colors.orange.shade400,
    };

    return colors[language] ?? Colors.grey.shade600;
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Clone URL copied to clipboard'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green.shade600,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  bool _isAIAnalysisInProgress() {
    // Check if AI analysis is in progress by looking at the repository state
    // If aiInsights is null and the repository was recently fetched, show loading
    if (widget.repository.aiInsights == null) {
      final now = DateTime.now();
      final timeSinceCached = now.difference(widget.repository.cachedAt);
      // If cached within last 5 minutes and no AI insights, likely still analyzing
      // This gives more time for AI analysis to complete
      return timeSinceCached.inMinutes < 5;
    }
    return false;
  }
} 