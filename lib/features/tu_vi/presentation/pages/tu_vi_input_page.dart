import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/tu_vi_chart_request.dart';
import '../providers/tu_vi_provider.dart';
import '../../../auth/presentation/providers/enhanced_auth_provider.dart';
import '../../../auth/data/models/auth_models.dart' as auth_models;

/// Input page for creating Tu Vi chart
class TuViInputPage extends StatefulWidget {
  const TuViInputPage({super.key});

  @override
  State<TuViInputPage> createState() => _TuViInputPageState();
}

class _TuViInputPageState extends State<TuViInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  // Scroll controllers for date pickers
  late FixedExtentScrollController _dayScrollController;
  late FixedExtentScrollController _monthScrollController;
  late FixedExtentScrollController _yearScrollController;

  // Selected date values
  int _selectedDay = 1;
  int _selectedMonth = 1;
  int _selectedYear = 2000;

  int _selectedHourBranch = 1;
  int _selectedGender = 1;
  bool _isSolarCalendar = true;
  bool _isForSelf = true;

  // Date ranges
  static const int _minYear = 1900;
  static const int _maxYear = 2100;

  @override
  void initState() {
    super.initState();

    // Initialize with current date
    final now = DateTime.now();
    _selectedDay = now.day;
    _selectedMonth = now.month;
    _selectedYear = now.year;

    // Initialize scroll controllers
    _dayScrollController =
        FixedExtentScrollController(initialItem: _selectedDay - 1);
    _monthScrollController =
        FixedExtentScrollController(initialItem: _selectedMonth - 1);
    _yearScrollController =
        FixedExtentScrollController(initialItem: _selectedYear - _minYear);

    // Auto-fill user info if default is self
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isForSelf) {
        _fillUserInfo();
      }
    });
  }

  void _fillUserInfo() {
    final authProvider =
        Provider.of<EnhancedAuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      setState(() {
        if (user.firstName != null || user.lastName != null) {
          _nameController.text = user.fullName;
        }

        if (user.gender != null) {
          _selectedGender = user.gender == auth_models.Gender.male ? 1 : -1;
        }
      });
    }
  }

  void _clearUserInfo() {
    setState(() {
      _nameController.clear();
      _selectedGender = 1; // Default to Male
    });
  }

  // Hour branch mapping
  final List<Map<String, dynamic>> _hourBranches = [
    {'value': 1, 'label': 'Tý', 'time': '23h-01h'},
    {'value': 2, 'label': 'Sửu', 'time': '01h-03h'},
    {'value': 3, 'label': 'Dần', 'time': '03h-05h'},
    {'value': 4, 'label': 'Mão', 'time': '05h-07h'},
    {'value': 5, 'label': 'Thìn', 'time': '07h-09h'},
    {'value': 6, 'label': 'Tỵ', 'time': '09h-11h'},
    {'value': 7, 'label': 'Ngọ', 'time': '11h-13h'},
    {'value': 8, 'label': 'Mùi', 'time': '13h-15h'},
    {'value': 9, 'label': 'Thân', 'time': '15h-17h'},
    {'value': 10, 'label': 'Dậu', 'time': '17h-19h'},
    {'value': 11, 'label': 'Tuất', 'time': '19h-21h'},
    {'value': 12, 'label': 'Hợi', 'time': '21h-23h'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _dayScrollController.dispose();
    _monthScrollController.dispose();
    _yearScrollController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_selectedYear, _selectedMonth, _selectedDay),
      firstDate: DateTime(_minYear),
      lastDate: DateTime(_maxYear),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDay = picked.day;
        _selectedMonth = picked.month;
        _selectedYear = picked.year;

        // Update scroll controllers
        _dayScrollController.jumpToItem(_selectedDay - 1);
        _monthScrollController.jumpToItem(_selectedMonth - 1);
        _yearScrollController.jumpToItem(_selectedYear - _minYear);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = Provider.of<TuViProvider>(context, listen: false);

    final request = TuViChartRequest(
      day: _selectedDay,
      month: _selectedMonth,
      year: _selectedYear,
      hourBranch: _selectedHourBranch,
      gender: _selectedGender,
      name: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : null,
      solarCalendar: _isSolarCalendar,
      timezone: 7,
    );

    // Validate request
    final validationError = provider.validateRequest(request);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Create chart
    final chart = await provider.createChart(request);

    if (mounted) {
      if (chart != null) {
        // Navigate to result page
        context.push('/tu-vi-result/${chart.id}');
      } else if (provider.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Đã xảy ra lỗi'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Build a scroll wheel picker - compact flat design
  Widget _buildScrollPicker({
    required String label,
    required List<String> items,
    required int selectedIndex,
    required FixedExtentScrollController controller,
    required ValueChanged<int> onChanged,
    double itemWidth = 60,
  }) {
    const double itemHeight = 32.0;
    const double containerHeight = 96.0; // Show 3 items

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Label
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        // Picker container
        Container(
          width: itemWidth,
          height: containerHeight,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            children: [
              // Center highlight
              Positioned(
                top: 32,
                left: 4,
                right: 4,
                child: Container(
                  height: itemHeight,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              // Flat scroll view using useMagnifier for flat appearance
              ListWheelScrollView.useDelegate(
                controller: controller,
                itemExtent: itemHeight,
                perspective: 0.0001, // Nearly flat
                diameterRatio: 100, // Very large = flat
                useMagnifier: false,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: onChanged,
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: items.length,
                  builder: (context, index) {
                    final isSelected = index == selectedIndex;
                    return Container(
                      height: itemHeight,
                      alignment: Alignment.center,
                      child: Text(
                        items[index],
                        style: TextStyle(
                          fontSize: isSelected ? 16 : 13,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w400,
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TuViProvider>(context);

    // Generate picker items
    final dayItems =
        List.generate(31, (index) => (index + 1).toString().padLeft(2, '0'));
    final monthItems =
        List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));
    final yearItems = List.generate(
        _maxYear - _minYear + 1, (index) => (_minYear + index).toString());

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: AppBar(
        title: const Text(
          'Lập Lá Số Tử Vi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.info,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Nhập thông tin để lập lá số tử vi của bạn',
                        style: TextStyle(
                          color: AppColors.info,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Self/Other Toggle
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isForSelf = true;
                            _fillUserInfo();
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _isForSelf
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _isForSelf
                                ? [
                                    BoxShadow(
                                      color: AppColors.shadowYellow,
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_rounded,
                                size: 20,
                                color: _isForSelf
                                    ? AppColors.textOnPrimary
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Bản thân',
                                style: TextStyle(
                                  fontWeight: _isForSelf
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: _isForSelf
                                      ? AppColors.textOnPrimary
                                      : AppColors.textSecondary,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isForSelf = false;
                            _clearUserInfo();
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: !_isForSelf
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: !_isForSelf
                                ? [
                                    BoxShadow(
                                      color: AppColors.shadowYellow,
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_rounded,
                                size: 20,
                                color: !_isForSelf
                                    ? AppColors.textOnPrimary
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Người khác',
                                style: TextStyle(
                                  fontWeight: !_isForSelf
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: !_isForSelf
                                      ? AppColors.textOnPrimary
                                      : AppColors.textSecondary,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Main Form Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Title - Personal Info
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.iconBgYellow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.primaryDark,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Thông tin cá nhân',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Name input
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Họ và tên',
                        hintText: 'VD: Nguyễn Văn A',
                        prefixIcon: Icon(
                          Icons.badge_outlined,
                          color: AppColors.textSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              BorderSide(color: AppColors.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        hintStyle: TextStyle(color: AppColors.textHint),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),

                    const SizedBox(height: 20),

                    // Divider
                    Divider(color: AppColors.divider, height: 1),
                    const SizedBox(height: 20),

                    // Section Title - Birth Info
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.iconBgTeal,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.cake_outlined,
                            color: AppColors.secondaryDark,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Ngày sinh',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        // Calendar picker button
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: AppColors.iconBgYellow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderYellow),
                          ),
                          child: IconButton(
                            onPressed: () => _selectDate(context),
                            icon: Icon(
                              Icons.calendar_month_rounded,
                              color: AppColors.primaryDark,
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Scroll Wheel Date Pickers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Day picker
                        Expanded(
                          child: _buildScrollPicker(
                            label: 'Ngày',
                            items: dayItems,
                            selectedIndex: _selectedDay - 1,
                            controller: _dayScrollController,
                            onChanged: (index) {
                              setState(() {
                                _selectedDay = index + 1;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Month picker
                        Expanded(
                          child: _buildScrollPicker(
                            label: 'Tháng',
                            items: monthItems,
                            selectedIndex: _selectedMonth - 1,
                            controller: _monthScrollController,
                            onChanged: (index) {
                              setState(() {
                                _selectedMonth = index + 1;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Year picker
                        Expanded(
                          flex: 2,
                          child: _buildScrollPicker(
                            label: 'Năm',
                            items: yearItems,
                            selectedIndex: _selectedYear - _minYear,
                            controller: _yearScrollController,
                            onChanged: (index) {
                              setState(() {
                                _selectedYear = _minYear + index;
                              });
                            },
                            itemWidth: 80,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Hour branch dropdown
                    DropdownButtonFormField<int>(
                      value: _selectedHourBranch,
                      decoration: InputDecoration(
                        labelText: 'Giờ sinh',
                        prefixIcon: Icon(
                          Icons.schedule_rounded,
                          color: AppColors.textSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              BorderSide(color: AppColors.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                      ),
                      dropdownColor: AppColors.surface,
                      items: _hourBranches
                          .map((branch) => DropdownMenuItem<int>(
                                value: branch['value'] as int,
                                child: Text(
                                  '${branch['label']} (${branch['time']})',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedHourBranch = value);
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    // Divider
                    Divider(color: AppColors.divider, height: 1),
                    const SizedBox(height: 20),

                    // Section Title - Gender
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.iconBgPeach,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.wc_rounded,
                            color: AppColors.accentDark,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Giới tính',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Gender selection - Modern Style
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedGender = 1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: _selectedGender == 1
                                    ? AppColors.iconBgBlue
                                    : AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _selectedGender == 1
                                      ? AppColors.info
                                      : AppColors.border,
                                  width: _selectedGender == 1 ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.male_rounded,
                                    color: _selectedGender == 1
                                        ? AppColors.info
                                        : AppColors.textSecondary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Nam',
                                    style: TextStyle(
                                      fontWeight: _selectedGender == 1
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: _selectedGender == 1
                                          ? AppColors.info
                                          : AppColors.textSecondary,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedGender = -1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: _selectedGender == -1
                                    ? AppColors.iconBgPeach
                                    : AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _selectedGender == -1
                                      ? AppColors.accent
                                      : AppColors.border,
                                  width: _selectedGender == -1 ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.female_rounded,
                                    color: _selectedGender == -1
                                        ? AppColors.accent
                                        : AppColors.textSecondary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Nữ',
                                    style: TextStyle(
                                      fontWeight: _selectedGender == -1
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: _selectedGender == -1
                                          ? AppColors.accent
                                          : AppColors.textSecondary,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Calendar type toggle card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _isSolarCalendar
                          ? AppColors.iconBgYellow
                          : AppColors.iconBgPurple,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _isSolarCalendar
                          ? Icons.wb_sunny_rounded
                          : Icons.nightlight_round,
                      color: _isSolarCalendar
                          ? AppColors.primaryDark
                          : Colors.purple.shade400,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    'Loại lịch',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    _isSolarCalendar
                        ? 'Dương lịch (Gregorian)'
                        : 'Âm lịch (Lunar)',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  trailing: Switch(
                    value: _isSolarCalendar,
                    onChanged: (value) =>
                        setState(() => _isSolarCalendar = value),
                    activeThumbColor: AppColors.primary,
                    activeTrackColor: AppColors.primaryLight,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Submit button
              Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowYellow,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: provider.isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: AppColors.textOnPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: provider.isLoading
                      ? SizedBox(
                          height: 26,
                          width: 26,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.textOnPrimary,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 26,
                              color: AppColors.textOnPrimary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Lập Lá Số',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textOnPrimary,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Note
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 16,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Lá số sẽ được lưu tự động',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
