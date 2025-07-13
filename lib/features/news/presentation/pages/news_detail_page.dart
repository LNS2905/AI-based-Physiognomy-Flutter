import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bagua_logo.dart';
import '../../data/models/news_article_model.dart';
import '../widgets/news_content_renderer.dart';
import '../widgets/news_action_bar.dart';
import '../widgets/related_articles_section.dart';

/// News detail page with Bagua-inspired design
class NewsDetailPage extends StatefulWidget {
  final String articleId;

  const NewsDetailPage({
    super.key,
    required this.articleId,
  });

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  late ScrollController _scrollController;
  bool _isAppBarExpanded = true;
  NewsArticleModel? _article;
  bool _isLoading = true;
  bool _isLiked = false;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadArticle();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    const expandedHeight = 300.0;
    const collapsedHeight = kToolbarHeight;
    final currentHeight = expandedHeight - _scrollController.offset;
    final isExpanded = currentHeight > collapsedHeight + 50;

    if (_isAppBarExpanded != isExpanded) {
      setState(() {
        _isAppBarExpanded = isExpanded;
      });
    }
  }

  Future<void> _loadArticle() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));
    
    final articles = NewsArticleModel.getSampleArticles();
    final article = articles.firstWhere(
      (a) => a.id == widget.articleId,
      orElse: () => articles.first,
    );

    setState(() {
      _article = article;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (_article == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Không tìm thấy bài viết'),
        ),
        body: const Center(
          child: Text('Không tìm thấy bài viết'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildArticleHeader(),
                _buildArticleContent(),
                _buildActionBar(),
                _buildRelatedArticles(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300.0,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back,
            color: AppColors.textOnPrimary,
            size: 20,
          ),
        ),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.share,
              color: AppColors.textOnPrimary,
              size: 20,
            ),
          ),
          onPressed: _shareArticle,
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: AppColors.baguaGradient,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              if (_article!.imageUrl != null)
                Image.network(
                  _article!.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildImagePlaceholder(),
                )
              else
                _buildImagePlaceholder(),
              
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.textPrimary.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
              
              // Category badge
              Positioned(
                bottom: 20,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _article!.category.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.primaryDark,
      child: const Center(
        child: BaguaIcon(
          size: 80,
          color: AppColors.primaryLight,
        ),
      ),
    );
  }

  Widget _buildArticleHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            _article!.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            _article!.description,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Article meta info
          Row(
            children: [
              // Author avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    _article!.author.split(' ').map((e) => e[0]).join(),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _article!.author,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${DateFormat('MMM dd, yyyy').format(_article!.publishedAt)} • ${_article!.readTime} phút đọc',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Stats
              Row(
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatCount(_article!.viewCount),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.favorite_outline,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatCount(_article!.likeCount),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Tags
          if (_article!.tags.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _article!.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildArticleContent() {
    return NewsContentRenderer(
      content: _article!.content,
    );
  }

  Widget _buildActionBar() {
    return NewsActionBar(
      isLiked: _isLiked,
      isBookmarked: _isBookmarked,
      onLike: () {
        setState(() {
          _isLiked = !_isLiked;
        });
        HapticFeedback.lightImpact();
      },
      onBookmark: () {
        setState(() {
          _isBookmarked = !_isBookmarked;
        });
        HapticFeedback.lightImpact();
      },
      onShare: _shareArticle,
      onComment: () {
        // TODO: Implement comments
      },
    );
  }

  Widget _buildRelatedArticles() {
    final relatedArticles = NewsArticleModel.getSampleArticles()
        .where((article) => article.id != _article!.id)
        .take(3)
        .toList();

    return RelatedArticlesSection(
      articles: relatedArticles,
    );
  }

  void _shareArticle() {
    // TODO: Implement share functionality
    HapticFeedback.lightImpact();
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}
