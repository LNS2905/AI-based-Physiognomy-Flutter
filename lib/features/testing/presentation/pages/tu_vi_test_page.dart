import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Test page for Tu Vi (Astrology) API
class TuViTestPage extends StatefulWidget {
  const TuViTestPage({super.key});

  @override
  State<TuViTestPage> createState() => _TuViTestPageState();
}

class _TuViTestPageState extends State<TuViTestPage> {
  final _formKey = GlobalKey<FormState>();
  final _dayController = TextEditingController(text: '15');
  final _monthController = TextEditingController(text: '8');
  final _yearController = TextEditingController(text: '1990');
  final _nameController = TextEditingController(text: 'Nguyễn Văn A');

  int _hourBranch = 1; // 1=Tý, 2=Sửu, ... 12=Hợi
  int _gender = 1; // 1 = Nam, -1 = Nữ
  bool _solarCalendar = true;
  int _timezone = 7; // UTC+7
  bool _isLoading = false;
  String? _result;
  String? _error;

  // Hour branch mapping
  final List<Map<String, dynamic>> _hourBranches = [
    {'value': 1, 'label': 'Tý (23h-01h)'},
    {'value': 2, 'label': 'Sửu (01h-03h)'},
    {'value': 3, 'label': 'Dần (03h-05h)'},
    {'value': 4, 'label': 'Mão (05h-07h)'},
    {'value': 5, 'label': 'Thìn (07h-09h)'},
    {'value': 6, 'label': 'Tỵ (09h-11h)'},
    {'value': 7, 'label': 'Ngọ (11h-13h)'},
    {'value': 8, 'label': 'Mùi (13h-15h)'},
    {'value': 9, 'label': 'Thân (15h-17h)'},
    {'value': 10, 'label': 'Dậu (17h-19h)'},
    {'value': 11, 'label': 'Tuất (19h-21h)'},
    {'value': 12, 'label': 'Hợi (21h-23h)'},
  ];

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String _getApiUrl() {
    // For Android Emulator, use 10.0.2.2 to access host machine's localhost
    // For iOS Simulator or physical devices, you need to use your computer's IP address

    // Uncomment the appropriate line based on your setup:
    return 'http://10.0.2.2:8000/charts'; // Android Emulator
    // return 'http://localhost:8000/charts'; // iOS Simulator (if running on Mac)
    // return 'http://192.168.1.XXX:8000/charts'; // Physical device (replace XXX with your computer's IP)
  }

  String _getBaseUrl() {
    final fullUrl = _getApiUrl();
    return fullUrl.replaceAll('/charts', '');
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });

    try {
      final requestBody = {
        'day': int.parse(_dayController.text),
        'month': int.parse(_monthController.text),
        'year': int.parse(_yearController.text),
        'hour_branch': _hourBranch,
        'gender': _gender,
        'name': _nameController.text,
        'solar_calendar': _solarCalendar,
        'timezone': _timezone,
      };

      print('Sending request: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(_getApiUrl()),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _result = const JsonEncoder.withIndent('  ').convert(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Lỗi ${response.statusCode}: ${response.body}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi kết nối: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Tử Vi API'),
        backgroundColor: const Color(0xFFFFC107),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Server info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API Server: ${_getBaseUrl()}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Đảm bảo server backend đang chạy',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '💡 Android Emulator: dùng 10.0.2.2',
                      style: TextStyle(fontSize: 10, color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Date inputs
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dayController,
                      decoration: const InputDecoration(
                        labelText: 'Ngày',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nhập ngày';
                        }
                        final day = int.tryParse(value);
                        if (day == null || day < 1 || day > 31) {
                          return 'Ngày không hợp lệ';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _monthController,
                      decoration: const InputDecoration(
                        labelText: 'Tháng',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nhập tháng';
                        }
                        final month = int.tryParse(value);
                        if (month == null || month < 1 || month > 12) {
                          return 'Tháng không hợp lệ';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      decoration: const InputDecoration(
                        labelText: 'Năm',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nhập năm';
                        }
                        final year = int.tryParse(value);
                        if (year == null || year < 1900 || year > 2100) {
                          return 'Năm không hợp lệ';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Hour branch dropdown
              DropdownButtonFormField<int>(
                value: _hourBranch,
                decoration: const InputDecoration(
                  labelText: 'Giờ sinh (Chi)',
                  border: OutlineInputBorder(),
                ),
                items: _hourBranches
                    .map((branch) => DropdownMenuItem<int>(
                          value: branch['value'] as int,
                          child: Text(branch['label'] as String),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _hourBranch = value);
                  }
                },
              ),

              const SizedBox(height: 16),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nhập tên';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Gender
              DropdownButtonFormField<int>(
                value: _gender,
                decoration: const InputDecoration(
                  labelText: 'Giới tính',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Nam')),
                  DropdownMenuItem(value: -1, child: Text('Nữ')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _gender = value);
                  }
                },
              ),

              const SizedBox(height: 16),

              // Calendar type
              SwitchListTile(
                title: const Text('Dương lịch'),
                subtitle: Text(_solarCalendar ? 'Đang dùng dương lịch' : 'Đang dùng âm lịch'),
                value: _solarCalendar,
                onChanged: (value) => setState(() => _solarCalendar = value),
              ),

              const SizedBox(height: 24),

              // Submit button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Lấy lá số tử vi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
              ),

              const SizedBox(height: 24),

              // Error message
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              // Result
              if (_result != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kết quả:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        _result!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
