import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

/// Home page that matches the Figma wireframe design
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            _buildHeader(context),

            // Search Bar
            _buildSearchBar(context),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Feature Cards Grid
                    _buildFeatureCardsGrid(context),

                    const SizedBox(height: 24),

                    // Banner Section
                    _buildBannerSection(context),

                    const SizedBox(height: 24),

                    // Daily News Carousel
                    _buildDailyNewsCarousel(context),

                    const SizedBox(height: 24),

                    // Additional Content
                    _buildAdditionalContent(context),

                    const SizedBox(height: 100), // Space for bottom navigation
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  /// Build header section with navigation and profile
  Widget _buildHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Menu/Navigation Icon
          Container(
            width: isTablet ? 48 : 40,
            height: isTablet ? 48 : 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(
              Icons.menu,
              color: AppColors.textSecondary,
              size: isTablet ? 24 : 20,
            ),
          ),

          SizedBox(width: isTablet ? 16 : 12),

          // Title/Logo Area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tướng học AI',
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Khám phá những hiểu biết của bạn',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Profile/Settings Icons
          Row(
            children: [
              Container(
                width: isTablet ? 48 : 40,
                height: isTablet ? 48 : 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textSecondary,
                  size: isTablet ? 24 : 20,
                ),
              ),
              SizedBox(width: isTablet ? 12 : 8),
              GestureDetector(
                onTap: () => context.push('/profile'),
                child: Container(
                  width: isTablet ? 48 : 40,
                  height: isTablet ? 48 : 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: AppColors.textSecondary,
                    size: isTablet ? 24 : 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build search bar section
  Widget _buildSearchBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      margin: EdgeInsets.all(isTablet ? 20 : 16),
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical: isTablet ? 16 : 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: isTablet ? 24 : 20,
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Text(
              'Tìm kiếm tính năng, kết quả...',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: AppColors.textHint,
              ),
            ),
          ),
          Container(
            width: isTablet ? 40 : 32,
            height: isTablet ? 40 : 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.tune,
              color: AppColors.textSecondary,
              size: isTablet ? 20 : 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Build banner section
  Widget _buildBannerSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Khám phá con người thật của bạn',
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: isTablet ? 12 : 8),
                Text(
                  'Phân tích tướng học được hỗ trợ bởi AI tiên tiến để mở khóa những hiểu biết về tính cách và đặc điểm của bạn.',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: isTablet ? 20 : 16),
                ElevatedButton(
                  onPressed: () => context.push('/face-scanning'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24 : 20,
                      vertical: isTablet ? 14 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Bắt đầu phân tích',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: isTablet ? 20 : 16),
          Expanded(
            flex: 1,
            child: Container(
              height: isTablet ? 120 : 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.face_retouching_natural,
                size: isTablet ? 60 : 50,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build daily news carousel section
  Widget _buildDailyNewsCarousel(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    // Sample news data
    final newsItems = [
      {
        'title': 'Đột phá AI mới nhất trong phân tích khuôn mặt',
        'description': 'Các nhà nghiên cứu phát triển thuật toán mới để đánh giá tính cách chính xác hơn thông qua các nét mặt.',
        'category': 'Công nghệ',
        'readTime': '3 phút đọc',
      },
      {
        'title': 'Hiểu về tướng học trong bối cảnh hiện đại',
        'description': 'Cách các thực hành cổ xưa kết hợp với công nghệ tiên tiến để cung cấp hiểu biết về hành vi con người.',
        'category': 'Khoa học',
        'readTime': '5 phút đọc',
      },
      {
        'title': 'Quyền riêng tư và đạo đức trong phân tích AI',
        'description': 'Khám phá các cân nhắc đạo đức và biện pháp bảo mật trong phân tích tính cách được hỗ trợ bởi AI.',
        'category': 'Đạo đức',
        'readTime': '4 phút đọc',
      },
      {
        'title': 'Câu chuyện thành công: Trải nghiệm người dùng thực tế',
        'description': 'Khám phá cách người dùng của chúng tôi đã có được những hiểu biết có giá trị về bản thân thông qua phân tích AI.',
        'category': 'Câu chuyện',
        'readTime': '6 phút đọc',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tin tức hàng ngày',
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.push('/news');
                },
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: isTablet ? 220 : 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
            itemCount: newsItems.length,
            itemBuilder: (context, index) {
              return Container(
                width: screenWidth * 0.8, // 80% of screen width
                margin: EdgeInsets.only(
                  right: index == newsItems.length - 1 ? 0 : 12,
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
  Widget _buildNewsCard(BuildContext context, Map<String, String> newsItem) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to news detail page
            // For demo, we'll use the first article ID
            context.push('/news/1');
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // News image placeholder
          Container(
            height: isTablet ? 100 : 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.article_outlined,
                size: isTablet ? 40 : 32,
                color: AppColors.textHint,
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and read time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          newsItem['category'] ?? '',
                          style: TextStyle(
                            fontSize: isTablet ? 12 : 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        newsItem['readTime'] ?? '',
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isTablet ? 8 : 6),

                  // Title
                  Text(
                    newsItem['title'] ?? '',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: isTablet ? 6 : 4),

                  // Description
                  Expanded(
                    child: Text(
                      newsItem['description'] ?? '',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build feature cards grid section
  Widget _buildFeatureCardsGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    if (isTablet) {
      // For tablets, show 6 cards in a 2x3 grid
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
        children: [
          _buildFeatureCard(
            context,
            icon: Icons.face_retouching_natural,
            title: 'Quét khuôn mặt',
            description: 'Phân tích các nét mặt',
            onTap: () => context.push('/face-scanning'),
          ),
          _buildFeatureCard(
            context,
            icon: Icons.back_hand,
            title: 'Quét vân tay',
            description: 'Phân tích đường chỉ tay',
            onTap: () => context.push('/palm-scanning'),
          ),
          _buildFeatureCard(
            context,
            icon: Icons.chat_bubble_outline,
            title: 'Chatbot AI',
            description: 'Trò chuyện với trợ lý AI',
            onTap: () => context.push('/chatbot'),
          ),
          _buildFeatureCard(
            context,
            icon: Icons.analytics_outlined,
            title: 'Kết quả',
            description: 'Xem kết quả phân tích',
            onTap: () => context.push('/result'),
          ),
          _buildFeatureCard(
            context,
            icon: Icons.person_outline,
            title: 'Hồ sơ',
            description: 'Quản lý hồ sơ của bạn',
            onTap: () => context.push('/profile'),
          ),
          _buildFeatureCard(
            context,
            icon: Icons.help_outline,
            title: 'Hướng dẫn',
            description: 'Hướng dẫn sử dụng',
            onTap: () => context.push('/user-guide'),
          ),
        ],
      );
    } else {
      // For mobile, show cards in a 2x2 grid
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildFeatureCard(
                  context,
                  icon: Icons.face_retouching_natural,
                  title: 'Quét khuôn mặt',
                  description: 'Phân tích các nét mặt',
                  onTap: () => context.push('/face-scanning'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFeatureCard(
                  context,
                  icon: Icons.back_hand,
                  title: 'Quét vân tay',
                  description: 'Phân tích đường chỉ tay',
                  onTap: () => context.push('/palm-scanning'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFeatureCard(
                  context,
                  icon: Icons.chat_bubble_outline,
                  title: 'AI Chatbot',
                  description: 'Trò chuyện với trợ lý AI',
                  onTap: () => context.push('/ai-conversation'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFeatureCard(
                  context,
                  icon: Icons.history,
                  title: 'Lịch sử',
                  description: 'Xem lịch sử phân tích',
                  onTap: () => context.push('/history'),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  /// Build individual feature card
  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Build content sections with images and text
  Widget _buildContentSections(BuildContext context) {
    return const SizedBox.shrink(); // Remove content sections
  }



  /// Build additional content section
  Widget _buildAdditionalContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bắt đầu ngay hôm nay',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bắt đầu hành trình khám phá bản thân với phân tích tướng học được hỗ trợ bởi AI tiên tiến của chúng tôi.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.push('/face-scanning'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Bắt đầu quét'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push('/demographics'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Tìm hiểu thêm'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build bottom navigation bar
  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        currentIndex: 0,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.face_outlined),
            activeIcon: Icon(Icons.face),
            label: 'Quét',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Trò chuyện',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              context.push('/face-scanning');
              break;
            case 2:
              context.push('/ai-conversation');
              break;
            case 3:
              context.push('/profile');
              break;
          }
        },
      ),
    );
  }
}
