import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/repository_model.dart';

class AIAnalysisWidget extends StatelessWidget {
  final AIInsightsModel? aiInsights;
  final bool isLoading;

  const AIAnalysisWidget({
    Key? key,
    this.aiInsights,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState(context);
    }

    if (aiInsights == null) {
      return _buildNoAnalysisState(context);
    }

    return _buildAnalysisContent(context);
  }

  Widget _buildLoadingState(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 600;
    
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Text(
            'AI Analysis in Progress...',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            'Analyzing repository code quality, security, and architecture',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              fontSize: isSmallScreen ? 12 : 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoAnalysisState(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 600;
    
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            Icons.psychology,
            size: isSmallScreen ? 40 : 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: isSmallScreen ? 10 : 12),
          Text(
            'AI Analysis Not Available',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            'AI analysis will be performed automatically when you fetch a repository',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              fontSize: isSmallScreen ? 12 : 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisContent(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 600;
    final isMediumScreen = mediaQuery.size.width >= 600 && mediaQuery.size.width < 1200;
    
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : isMediumScreen ? 18 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[600]!, Colors.purple[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: isSmallScreen ? 12 : 15,
            offset: Offset(0, isSmallScreen ? 4 : 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: Colors.white,
                size: isSmallScreen ? 20 : 24,
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Expanded(
                child: Text(
                  'AI Analysis',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 16 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 12,
                  vertical: isSmallScreen ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                ),
                child: Text(
                  '${aiInsights!.overallScore.toStringAsFixed(1)}/10',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          
          // Repository Summary
          _buildSummarySection(context),
          SizedBox(height: isSmallScreen ? 12 : 16),
          
          // Score Grid
          _buildScoreGrid(context),
          SizedBox(height: isSmallScreen ? 12 : 16),
          
          // Detailed Analysis
       //   _buildDetailedAnalysis(context),
          SizedBox(height: isSmallScreen ? 12 : 16),
          
          // Suggested Improvements
          _buildImprovementsSection(context),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 600;
    
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Repository Summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          MarkdownBody(
            data: aiInsights!.repositorySummary,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: isSmallScreen ? 12 : 14,
                height: 1.4,
              ),
              strong: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 12 : 14,
              ),
              em: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontStyle: FontStyle.italic,
                fontSize: isSmallScreen ? 12 : 14,
              ),
              code: TextStyle(
                color: Colors.yellow[200],
                backgroundColor: Colors.black.withOpacity(0.3),
                fontSize: isSmallScreen ? 11 : 13,
                fontFamily: 'monospace',
              ),
            ),
            shrinkWrap: true,
            softLineBreak: true,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreGrid(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 600;
    final isMediumScreen = mediaQuery.size.width >= 600 && mediaQuery.size.width < 1200;
    
    final scores = [
      {'label': 'Code Quality', 'score': aiInsights!.codeQualityScore, 'icon': Icons.code, 'color': Colors.green},
      {'label': 'Security', 'score': aiInsights!.securityScore, 'icon': Icons.security, 'color': Colors.red},
      {'label': 'Maintainability', 'score': aiInsights!.maintainabilityScore, 'icon': Icons.build, 'color': Colors.blue},
      {'label': 'Architecture', 'score': aiInsights!.architectureScore, 'icon': Icons.architecture, 'color': Colors.orange},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isSmallScreen ? 1 : 2,
        crossAxisSpacing: isSmallScreen ? 0 : 12,
        mainAxisSpacing: isSmallScreen ? 8 : 12,
        childAspectRatio: isSmallScreen ? 3.0 : 1.5,
      ),
      itemCount: scores.length,
      itemBuilder: (context, index) {
        final score = scores[index];
        return _buildScoreCard(
          context: context,
          label: score['label'] as String,
          score: score['score'] as double,
          icon: score['icon'] as IconData,
          color: score['color'] as Color,
        );
      },
    );
  }

  Widget _buildScoreCard({
    required BuildContext context,
    required String label,
    required double score,
    required IconData icon,
    required Color color,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 600;
    
    final scoreColor = score >= 8 ? Colors.green : score >= 6 ? Colors.orange : Colors.red;
    
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: isSmallScreen ? 18 : 24,
          ),
          SizedBox(width: isSmallScreen ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isSmallScreen ? 11 : 12,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isSmallScreen ? 4 : 6),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 6 : 8,
                    vertical: isSmallScreen ? 2 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
                  ),
                  child: Text(
                    score.toStringAsFixed(1),
                    style: TextStyle(
                      color: scoreColor,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 12 : 16,
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

  /*Widget _buildDetailedAnalysis(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 600;
    
    final analyses = [
      {'title': 'Code Quality', 'content': aiInsights!.codeQualityAnalysis, 'icon': Icons.code},
      {'title': 'Security', 'content': aiInsights!.securityAnalysis, 'icon': Icons.security},
      {'title': 'Maintainability', 'content': aiInsights!.maintainabilityAnalysis, 'icon': Icons.build},
      {'title': 'Architecture', 'content': aiInsights!.architectureAnalysis, 'icon': Icons.architecture},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Analysis',
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        ...analyses.map((analysis) => _buildAnalysisItem(
          context: context,
          title: analysis['title'] as String,
          content: analysis['content'] as String,
          icon: analysis['icon'] as IconData,
        )),
      ],
    );
  }
*/
  Widget _buildAnalysisItem({
    required BuildContext context,
    required String title,
    required String content,
    required IconData icon,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 600;
    
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: isSmallScreen ? 16 : 18,
              ),
              SizedBox(width: isSmallScreen ? 8 : 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 13 : 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 8 : 10),
          MarkdownBody(
            data: content,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: isSmallScreen ? 12 : 14,
                height: 1.4,
                letterSpacing: 0.2,
              ),
              strong: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 12 : 14,
              ),
              em: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontStyle: FontStyle.italic,
                fontSize: isSmallScreen ? 12 : 14,
              ),
              code: TextStyle(
                color: Colors.yellow[200],
                backgroundColor: Colors.black.withOpacity(0.3),
                fontSize: isSmallScreen ? 11 : 13,
                fontFamily: 'monospace',
              ),
            ),
            shrinkWrap: true,
            softLineBreak: true,
          ),
        ],
      ),
    );
  }

  Widget _buildImprovementsSection(BuildContext context) {
    if (aiInsights!.suggestedImprovements.isEmpty) {
      return const SizedBox.shrink();
    }

    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 600;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggested Improvements',
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: aiInsights!.suggestedImprovements.map((improvement) {
              return Padding(
                padding: EdgeInsets.only(bottom: isSmallScreen ? 8 : 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: isSmallScreen ? 6 : 7),
                      width: isSmallScreen ? 6 : 8,
                      height: isSmallScreen ? 6 : 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 10 : 14),
                    Expanded(
                      child: MarkdownBody(
                        data: improvement,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isSmallScreen ? 12 : 14,
                            height: 1.4,
                            letterSpacing: 0.1,
                          ),
                          strong: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                          em: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                          code: TextStyle(
                            color: Colors.yellow[200],
                            backgroundColor: Colors.black.withOpacity(0.3),
                            fontSize: isSmallScreen ? 11 : 13,
                            fontFamily: 'monospace',
                          ),
                        ),
                        shrinkWrap: true,
                        softLineBreak: true,
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
}
