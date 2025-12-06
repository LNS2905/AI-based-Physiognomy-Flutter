import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/fixed_bottom_navigation.dart';

/// Home page inspired by Cracker Book design
/// Features: Yellow accent, rounded cards, friendly layout
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Header Section
                _buildHeader(context),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),

                        // Welcome Banner Section
                        _buildWelcomeBanner(context),

                        const SizedBox(height: 28),

                        // Feature Categories Section
                        _buildCategorySection(context),

                        const SizedBox(height: 28),

                        // Main Feature Cards Grid
                        _buildFeatureCardsGrid(context),

                        const SizedBox(height: 28),

                        // Daily News Carousel
                        _buildDailyNewsCarousel(context),

                        const SizedBox(height: 28),

                        // Quick Start Section
                        _buildQuickStartSection(context),

                        const SizedBox(
                            height: 120), // Space for bottom navigation
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Fixed Bottom Navigation
            FixedBottomNavigation(currentRoute: '/home'),
          ],
        ),
      ),
    );
  }

  /// Build header section with app name and profile
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        children: [
          // App Logo/Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tướng học AI',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Khám phá bản thân mỗi ngày',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Search & Profile Icons
          Row(
            children: [
              // Profile Button
              _buildHeaderIconButton(
                icon: Icons.person_outline_rounded,
                onTap: () => context.push('/profile'),
                isHighlighted: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build header icon button
  Widget _buildHeaderIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isHighlighted ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isHighlighted ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          color: isHighlighted ? AppColors.primaryDark : AppColors.textSecondary,
          size: 22,
        ),
      ),
    );
  }

  /// Build welcome banner
  Widget _buildWelcomeBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '✨ Khám phá ngay',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Khám phá\ncon người bạn',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'AI phân tích tướng mặt và chỉ tay để khám phá tính cách.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => context.push('/face-scanning'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Bắt đầu',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: AppColors.primaryDark,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Decorative shapes
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 15,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  // Main icon
                  Icon(
                    Icons.face_retouching_natural_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build category section (horizontal scroll)
  Widget _buildCategorySection(BuildContext context) {
    final categories = [
      {'icon': Icons.face_outlined, 'label': 'Khuôn mặt', 'color': AppColors.iconBgTeal},
      {'icon': Icons.back_hand_outlined, 'label': 'Chỉ tay', 'color': AppColors.iconBgPeach},
      {'icon': Icons.auto_awesome_outlined, 'label': 'Tử vi', 'color': AppColors.iconBgBlue},
      {'icon': Icons.chat_bubble_outline_rounded, 'label': 'AI Chat', 'color': AppColors.iconBgGreen},
      {'icon': Icons.history_rounded, 'label': 'Lịch sử', 'color': AppColors.iconBgPurple},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Danh mục',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index == categories.length - 1 ? 0 : 16,
                ),
                child: _buildCategoryItem(
                  context,
                  icon: category['icon'] as IconData,
                  label: category['label'] as String,
                  backgroundColor: category['color'] as Color,
                  onTap: () {
                    // Navigate based on category
                    switch (index) {
                      case 0:
                        context.push('/face-scanning');
                        break;
                      case 1:
                        context.push('/palm-scanning');
                        break;
                      case 2:
                        context.push('/tu-vi-input');
                        break;
                      case 3:
                        context.push('/ai-conversation');
                        break;
                      case 4:
                        context.push('/history');
                        break;
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Build category item
  Widget _buildCategoryItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 28,
              color: AppColors.textPrimary.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Build feature cards grid section with responsive design
  Widget _buildFeatureCardsGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    // Define feature cards data
    final featureCards = [
      {
        'icon': Icons.face_retouching_natural_rounded,
        'title': 'Quét khuôn mặt',
        'description': 'Phân tích nét mặt với AI',
        'route': '/face-scanning',
        'color': AppColors.cardTeal,
        'iconColor': AppColors.secondary,
      },
      {
        'icon': Icons.back_hand_rounded,
        'title': 'Quét chỉ tay',
        'description': 'Đọc vận mệnh qua lòng bàn tay',
        'route': '/palm-scanning',
        'color': AppColors.cardPeach,
        'iconColor': AppColors.accent,
      },
      {
        'icon': Icons.auto_awesome_rounded,
        'title': 'Lá Số Tử Vi',
        'description': 'Lập lá số theo ngày sinh',
        'route': '/tu-vi-input',
        'color': AppColors.cardBlue,
        'iconColor': AppColors.info,
      },
      {
        'icon': Icons.chat_bubble_rounded,
        'title': 'AI Chatbot',
        'description': 'Trò chuyện với trợ lý AI',
        'route': '/ai-conversation',
        'color': AppColors.cardGreen,
        'iconColor': AppColors.success,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tính năng chính',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isTablet ? 1.0 : 0.95,
            ),
            itemCount: featureCards.length,
            itemBuilder: (context, index) {
              final card = featureCards[index];
              return _buildFeatureCard(
                context,
                icon: card['icon'] as IconData,
                title: card['title'] as String,
                description: card['description'] as String,
                backgroundColor: card['color'] as Color,
                iconColor: card['iconColor'] as Color,
                onTap: () => context.push(card['route'] as String),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Build individual feature card
  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.border.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 26,
              ),
            ),
            const Spacer(),
            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Description
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Build daily news carousel section
  Widget _buildDailyNewsCarousel(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Sample news data
    final newsItems = [
      {
        'title': 'Tướng học AI - Xu hướng mới',
        'description': 'Khám phá cách công nghệ AI đang thay đổi cách chúng ta hiểu về tướng học.',
        'category': 'Công nghệ',
        'readTime': '3 phút',
        'color': AppColors.iconBgYellow,
      },
      {
        'title': 'Bí mật từ đường chỉ tay',
        'description': 'Những điều thú vị về việc đọc vận mệnh qua lòng bàn tay.',
        'category': 'Tâm linh',
        'readTime': '5 phút',
        'color': AppColors.iconBgTeal,
      },
      {
        'title': 'Tử Vi tuần mới',
        'description': 'Dự báo vận mệnh 12 cung hoàng đạo trong tuần này.',
        'category': 'Tử vi',
        'readTime': '4 phút',
        'color': AppColors.iconBgPeach,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tin tức & Bài viết',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/news'),
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: newsItems.length,
            itemBuilder: (context, index) {
              return Container(
                width: screenWidth * 0.75,
                margin: EdgeInsets.only(
                  right: index == newsItems.length - 1 ? 0 : 16,
                ),
                child: _buildNewsCard(context, newsItems[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Build individual news card
  Widget _buildNewsCard(BuildContext context, Map<String, dynamic> newsItem) {
    return GestureDetector(
      onTap: () => context.push('/news/1'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // News image/banner area
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: newsItem['color'] as Color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.article_outlined,
                  size: 32,
                  color: AppColors.textPrimary.withOpacity(0.4),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category and read time
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            newsItem['category'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          newsItem['readTime'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Title
                    Text(
                      newsItem['title'] as String,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build quick start section
  Widget _buildQuickStartSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.iconBgYellow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              color: AppColors.primaryDark,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bắt đầu ngay hôm nay',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Khám phá bản thân với công nghệ AI tiên tiến.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Arrow button
          GestureDetector(
            onTap: () => context.push('/face-scanning'),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.textOnPrimary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
