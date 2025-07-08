import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Action bar for news articles with like, bookmark, share, and comment actions
/// Designed with Bagua-inspired styling
class NewsActionBar extends StatelessWidget {
  final bool isLiked;
  final bool isBookmarked;
  final VoidCallback onLike;
  final VoidCallback onBookmark;
  final VoidCallback onShare;
  final VoidCallback onComment;

  const NewsActionBar({
    super.key,
    required this.isLiked,
    required this.isBookmarked,
    required this.onLike,
    required this.onBookmark,
    required this.onShare,
    required this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
            icon: isLiked ? Icons.favorite : Icons.favorite_outline,
            label: 'Like',
            isActive: isLiked,
            onTap: onLike,
            activeColor: AppColors.accent,
          ),
          _buildDivider(),
          _buildActionButton(
            icon: isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
            label: 'Save',
            isActive: isBookmarked,
            onTap: onBookmark,
            activeColor: AppColors.primary,
          ),
          _buildDivider(),
          _buildActionButton(
            icon: Icons.share_outlined,
            label: 'Share',
            isActive: false,
            onTap: onShare,
            activeColor: AppColors.secondary,
          ),
          _buildDivider(),
          _buildActionButton(
            icon: Icons.comment_outlined,
            label: 'Comment',
            isActive: false,
            onTap: onComment,
            activeColor: AppColors.info,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required Color activeColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? activeColor : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? activeColor : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.border,
    );
  }
}

/// Enhanced action bar with additional features
class EnhancedNewsActionBar extends StatefulWidget {
  final bool isLiked;
  final bool isBookmarked;
  final int likeCount;
  final int commentCount;
  final VoidCallback onLike;
  final VoidCallback onBookmark;
  final VoidCallback onShare;
  final VoidCallback onComment;

  const EnhancedNewsActionBar({
    super.key,
    required this.isLiked,
    required this.isBookmarked,
    required this.likeCount,
    required this.commentCount,
    required this.onLike,
    required this.onBookmark,
    required this.onShare,
    required this.onComment,
  });

  @override
  State<EnhancedNewsActionBar> createState() => _EnhancedNewsActionBarState();
}

class _EnhancedNewsActionBarState extends State<EnhancedNewsActionBar>
    with TickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late AnimationController _bookmarkAnimationController;
  late Animation<double> _likeScaleAnimation;
  late Animation<double> _bookmarkScaleAnimation;

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _bookmarkAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _likeScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _likeAnimationController,
      curve: Curves.elasticOut,
    ));

    _bookmarkScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _bookmarkAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    _bookmarkAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.surfaceVariant,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Like button with animation
            Expanded(
              child: _buildEnhancedActionButton(
                icon: widget.isLiked ? Icons.favorite : Icons.favorite_outline,
                label: 'Like',
                count: widget.likeCount,
                isActive: widget.isLiked,
                activeColor: AppColors.accent,
                animation: _likeScaleAnimation,
                onTap: () {
                  widget.onLike();
                  if (widget.isLiked) {
                    _likeAnimationController.forward().then((_) {
                      _likeAnimationController.reverse();
                    });
                  }
                },
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Bookmark button with animation
            Expanded(
              child: _buildEnhancedActionButton(
                icon: widget.isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                label: 'Save',
                isActive: widget.isBookmarked,
                activeColor: AppColors.primary,
                animation: _bookmarkScaleAnimation,
                onTap: () {
                  widget.onBookmark();
                  if (widget.isBookmarked) {
                    _bookmarkAnimationController.forward().then((_) {
                      _bookmarkAnimationController.reverse();
                    });
                  }
                },
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Share button
            Expanded(
              child: _buildEnhancedActionButton(
                icon: Icons.share_outlined,
                label: 'Share',
                isActive: false,
                activeColor: AppColors.secondary,
                onTap: widget.onShare,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Comment button
            Expanded(
              child: _buildEnhancedActionButton(
                icon: Icons.comment_outlined,
                label: 'Comment',
                count: widget.commentCount,
                isActive: false,
                activeColor: AppColors.info,
                onTap: widget.onComment,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedActionButton({
    required IconData icon,
    required String label,
    int? count,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
    Animation<double>? animation,
  }) {
    Widget iconWidget = Icon(
      icon,
      size: 24,
      color: isActive ? activeColor : AppColors.textSecondary,
    );

    if (animation != null) {
      iconWidget = AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Transform.scale(
            scale: animation.value,
            child: child,
          );
        },
        child: iconWidget,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isActive ? Border.all(
            color: activeColor.withValues(alpha: 0.3),
            width: 1,
          ) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? activeColor : AppColors.textSecondary,
              ),
            ),
            if (count != null && count > 0) ...[
              const SizedBox(height: 2),
              Text(
                _formatCount(count),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: isActive ? activeColor : AppColors.textHint,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}
