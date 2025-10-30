import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/tu_vi_chart_request.dart';
import '../providers/tu_vi_provider.dart';

/// Input page for creating Tu Vi chart
class TuViInputPage extends StatefulWidget {
  const TuViInputPage({super.key});

  @override
  State<TuViInputPage> createState() => _TuViInputPageState();
}

class _TuViInputPageState extends State<TuViInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  int _selectedHourBranch = 1;
  int _selectedGender = 1;
  bool _isSolarCalendar = true;

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
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFFFFC107),
              onPrimary: Colors.black87,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = Provider.of<TuViProvider>(context, listen: false);

    final request = TuViChartRequest(
      day: _selectedDate.day,
      month: _selectedDate.month,
      year: _selectedDate.year,
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
          backgroundColor: Colors.red,
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
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TuViProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lập Lá Số Tử Vi'),
        backgroundColor: const Color(0xFFFFC107),
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info card
              Card(
                color: Colors.blue.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Nhập thông tin để lập lá số tử vi của bạn',
                          style: TextStyle(
                            color: Colors.blue.shade900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Name input
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Họ và tên',
                  hintText: 'VD: Nguyễn Văn A',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 16),

              // Date picker
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Ngày sinh',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Hour branch dropdown
              DropdownButtonFormField<int>(
                value: _selectedHourBranch,
                decoration: InputDecoration(
                  labelText: 'Giờ sinh',
                  prefixIcon: const Icon(Icons.access_time),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: _hourBranches
                    .map((branch) => DropdownMenuItem<int>(
                          value: branch['value'] as int,
                          child: Text(
                            '${branch['label']} (${branch['time']})',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedHourBranch = value);
                  }
                },
              ),

              const SizedBox(height: 16),

              // Gender selection
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Giới tính',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<int>(
                            title: const Text('Nam'),
                            value: 1,
                            groupValue: _selectedGender,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedGender = value);
                              }
                            },
                            contentPadding: EdgeInsets.zero,
                            activeColor: const Color(0xFFFFC107),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<int>(
                            title: const Text('Nữ'),
                            value: -1,
                            groupValue: _selectedGender,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedGender = value);
                              }
                            },
                            contentPadding: EdgeInsets.zero,
                            activeColor: const Color(0xFFFFC107),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Calendar type toggle
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: const Text(
                    'Loại lịch',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    _isSolarCalendar ? 'Dương lịch' : 'Âm lịch',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  value: _isSolarCalendar,
                  onChanged: (value) => setState(() => _isSolarCalendar = value),
                  activeColor: const Color(0xFFFFC107),
                  secondary: Icon(
                    _isSolarCalendar ? Icons.wb_sunny : Icons.nightlight_round,
                    color: const Color(0xFFFFC107),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: provider.isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black87),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Lập Lá Số',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Note
              Center(
                child: Text(
                  'Lá số sẽ được lưu tự động',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
