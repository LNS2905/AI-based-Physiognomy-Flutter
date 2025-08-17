import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/fixed_bottom_navigation.dart';
import '../widgets/user_guide_step_card.dart';

/// User Guide screen for face scanning feature
/// Displays step-by-step instructions following the Figma design
class UserGuidePage extends StatefulWidget {
  const UserGuidePage({super.key});

  @override
  State<UserGuidePage> createState() => _UserGuidePageState();
}

class _UserGuidePageState extends State<UserGuidePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: AppConstants.mediumAnimationDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Start fade animation
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            children: [
              // Main scrollable content
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Header Section
                    _buildHeader(context),

                    const SizedBox(height: 20),

                    // Steps Section
                    _buildStepsSection(),

                    // Add bottom padding to avoid footer overlap
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              
              // Fixed Bottom Navigation
              FixedBottomNavigation(currentRoute: '/user-guide'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Top navigation bar
          Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Title
              const Text(
                'Hướng dẫn',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Main title
          const Text(
            'HƯỚNG DẪN SỬ DỤNG',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // Step 1
          UserGuideStepCard(
            stepNumber: 1,
            title: 'Chụp ảnh selfie',
            description: 'Người chụp ảnh selfie\nvới camera điện thoại',
            imagePlaceholder: '[HÌNH ẢNH SELFIE]',
            onViewDetails: () => _showStepDetails(context, 1),
          ),

          const SizedBox(height: 30),

          // Step 2
          UserGuideStepCard(
            stepNumber: 2,
            title: 'Chọn vùng khuôn mặt',
            description: 'Giao diện chọn và\nphát hiện vùng khuôn mặt',
            imagePlaceholder: '[PHÂN TÍCH KHUÔN MẶT]',
            onViewDetails: () => _showStepDetails(context, 2),
          ),

          const SizedBox(height: 30),

          // Step 3
          UserGuideStepCard(
            stepNumber: 3,
            title: 'Kết quả phân tích AI',
            description: 'Kết quả và thông tin\nphân tích tướng học',
            imagePlaceholder: '[PHÂN TÍCH AI]',
            onViewDetails: () => _showStepDetails(context, 3),
          ),

          const SizedBox(height: 30),

          // Step 4
          UserGuideStepCard(
            stepNumber: 4,
            title: 'Tư vấn chuyên gia',
            description: 'Tư vấn chuyên gia\ntướng học chuyên nghiệp',
            imagePlaceholder: '[TƯ VẤN CHUYÊN GIA]',
            onViewDetails: () => _showStepDetails(context, 4),
          ),
        ],
      ),
    );
  }


  void _showStepDetails(BuildContext context, int stepNumber) {
    final stepDetails = _getStepDetails(stepNumber);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Title
              Text(
                'Step $stepNumber: ${stepDetails['title'] ?? 'Unknown Step'}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    stepDetails['details'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              
              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đã hiểu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, String> _getStepDetails(int stepNumber) {
    switch (stepNumber) {
      case 1:
        return {
          'title': 'Chụp ảnh selfie',
          'details': '''• Đặt khuôn mặt ở giữa khung hình camera
• Đảm bảo ánh sáng tốt - ánh sáng tự nhiên là tốt nhất
• Giữ khuôn mặt thẳng và nhìn thẳng vào camera
• Tháo kính, mũ hoặc bất cứ thứ gì che khuôn mặt
• Đảm bảo toàn bộ khuôn mặt hiển thị trong khung hình
• Giữ điện thoại ổn định và tránh ảnh bị mờ
• Chụp ảnh với biểu cảm tự nhiên để có kết quả tốt nhất''',
        };
      case 2:
        return {
          'title': 'Chọn vùng khuôn mặt',
          'details': '''• AI sẽ tự động phát hiện khuôn mặt trong ảnh
• Các đặc điểm khuôn mặt chính sẽ được làm nổi bật và phân tích
• Đảm bảo tất cả vùng khuôn mặt quan trọng đều hiển thị rõ ràng
• Hệ thống sẽ xác định mắt, mũi, miệng và đường viền khuôn mặt
• Nếu phát hiện thất bại, hãy chụp lại ảnh với ánh sáng tốt hơn
• Phân tích tập trung vào tỷ lệ và sự đối xứng của khuôn mặt
• Bước này đảm bảo phân tích tướng học chính xác''',
        };
      case 3:
        return {
          'title': 'Kết quả phân tích AI',
          'details': '''• Thuật toán AI tiên tiến phân tích các đặc điểm khuôn mặt của bạn
• Hệ thống kiểm tra tỷ lệ, sự đối xứng và đặc điểm khuôn mặt
• Kết quả bao gồm hiểu biết về tính cách dựa trên nguyên lý tướng học
• Phân tích bao gồm các đặc điểm như sự tự tin, sáng tạo và xu hướng xã hội
• Kết quả được trình bày theo định dạng dễ hiểu
• Mỗi đặc điểm đều có giải thích chi tiết
• Phân tích dựa trên nghiên cứu tướng học đã được thiết lập''',
        };
      case 4:
        return {
          'title': 'Tư vấn chuyên gia',
          'details': '''• Kết nối với các chuyên gia tướng học được chứng nhận
• Nhận giải thích chuyên nghiệp về kết quả phân tích của bạn
• Đặt câu hỏi về các đặc điểm hoặc đặc tính cụ thể
• Nhận lời khuyên và hiểu biết được cá nhân hóa
• Lên lịch các buổi tư vấn một-đối-một
• Hướng dẫn của chuyên gia giúp bạn hiểu kết quả tốt hơn
• Xác nhận chuyên nghiệp về các phát hiện phân tích AI''',
        };
      default:
        return {'title': 'Bước không xác định', 'details': 'Chi tiết bước không có sẵn.'};
    }
  }
}
