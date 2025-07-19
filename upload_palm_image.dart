import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Script để upload ảnh vân tay lên Cloudinary và tạo body request cho palm analysis API
/// 
/// Sử dụng: dart upload_palm_image.dart
void main() async {
  try {
    print('🚀 Bắt đầu xử lý ảnh vân tay...');
    
    // Đường dẫn đến file ảnh
    const imagePath = 'vantay.jpg';
    
    // Kiểm tra file tồn tại
    final file = File(imagePath);
    if (!file.existsSync()) {
      print('❌ Không tìm thấy file: $imagePath');
      return;
    }
    
    print('✅ Tìm thấy file ảnh: $imagePath');
    print('📏 Kích thước file: ${file.lengthSync()} bytes');
    
    // Thông tin Cloudinary từ constants
    const cloudinaryCloudName = 'dd0wymyqj';
    const cloudinaryApiKey = '389718786139835';
    const cloudinaryApiSecret = 'aS_7wWncQjOLpKRKnHEd0_dr07M';
    const uploadFolder = 'physiognomy_analysis';
    
    // Upload ảnh lên Cloudinary
    print('\n📤 Đang upload ảnh lên Cloudinary...');
    final uploadResult = await uploadToCloudinary(
      file,
      cloudinaryCloudName,
      cloudinaryApiKey,
      cloudinaryApiSecret,
      uploadFolder,
    );
    
    if (uploadResult == null) {
      print('❌ Upload thất bại');
      return;
    }
    
    print('✅ Upload thành công!');
    print('🔗 Public ID: ${uploadResult['public_id']}');
    print('🔗 Secure URL: ${uploadResult['secure_url']}');
    
    // Tạo signed URL cho private resource
    final signedUrl = generateSignedUrl(
      uploadResult['public_id'],
      cloudinaryCloudName,
      cloudinaryApiSecret,
    );
    
    print('🔐 Signed URL: $signedUrl');
    
    // Tạo body request cho palm analysis API
    final requestBody = createPalmAnalysisRequest(
      signedUrl,
      uploadFolder,
    );
    
    print('\n📋 Body request cho API palm analysis:');
    print('=' * 50);
    print(const JsonEncoder.withIndent('  ').convert(requestBody));
    print('=' * 50);
    
    // Test gọi API
    print('\n🧪 Test gọi API palm analysis...');
    await testPalmAnalysisAPI(requestBody);
    
  } catch (e, stackTrace) {
    print('❌ Lỗi: $e');
    print('Stack trace: $stackTrace');
  }
}

/// Upload ảnh lên Cloudinary
Future<Map<String, dynamic>?> uploadToCloudinary(
  File file,
  String cloudName,
  String apiKey,
  String apiSecret,
  String folder,
) async {
  try {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final publicId = 'palm_analysis_${timestamp}';
    
    // Tạo signature cho upload
    final paramsToSign = {
      'public_id': publicId,
      'timestamp': timestamp.toString(),
      'folder': folder,
      'type': 'private', // Upload as private để có thể tạo signed URL
    };
    
    final signature = generateUploadSignature(paramsToSign, apiSecret);
    
    // Tạo multipart request
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri);
    
    // Thêm file
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    
    // Thêm parameters
    request.fields.addAll({
      'api_key': apiKey,
      'timestamp': timestamp.toString(),
      'signature': signature,
      'public_id': publicId,
      'folder': folder,
      'type': 'private',
    });
    
    // Gửi request
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    
    if (response.statusCode == 200) {
      return json.decode(responseBody);
    } else {
      print('❌ Upload failed: ${response.statusCode}');
      print('Response: $responseBody');
      return null;
    }
  } catch (e) {
    print('❌ Upload error: $e');
    return null;
  }
}

/// Tạo signature cho Cloudinary upload
String generateUploadSignature(Map<String, String> params, String apiSecret) {
  // Sắp xếp parameters theo alphabet
  final sortedKeys = params.keys.toList()..sort();
  final paramString = sortedKeys
      .map((key) => '$key=${params[key]}')
      .join('&');
  
  // Tạo string để sign
  final stringToSign = '$paramString$apiSecret';
  
  // Tạo SHA1 hash (simplified - trong thực tế cần dùng crypto package)
  // Đây là implementation đơn giản, trong production nên dùng crypto package
  return stringToSign.hashCode.abs().toRadixString(16);
}

/// Tạo signed URL cho private resource
String generateSignedUrl(String publicId, String cloudName, String apiSecret) {
  final timestamp = DateTime.now().add(Duration(hours: 24)).millisecondsSinceEpoch ~/ 1000;
  
  // Tạo signature cho signed URL
  final stringToSign = 'public_id=$publicId&timestamp=$timestamp$apiSecret';
  final signature = stringToSign.hashCode.abs().toRadixString(16);
  
  return 'https://res.cloudinary.com/$cloudName/image/private/s--$signature--/v1/$publicId.jpg?timestamp=$timestamp';
}

/// Tạo body request cho palm analysis API
Map<String, dynamic> createPalmAnalysisRequest(String signedUrl, String folderPath) {
  return {
    'signed_url': signedUrl,
    'user_id': 'test_user_${DateTime.now().millisecondsSinceEpoch}',
    'timestamp': DateTime.now().toIso8601String(),
    'original_folder_path': folderPath,
  };
}

/// Test gọi API palm analysis
Future<void> testPalmAnalysisAPI(Map<String, dynamic> requestBody) async {
  try {
    const apiUrl = 'https://inspired-bear-emerging.ngrok-free.app/analyze-palm-cloudinary/';
    
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: json.encode(requestBody),
    );
    
    print('📊 Response Status: ${response.statusCode}');
    print('📊 Response Headers: ${response.headers}');
    
    if (response.statusCode == 200) {
      print('✅ API call thành công!');
      final responseData = json.decode(response.body);
      print('📄 Response data:');
      print(const JsonEncoder.withIndent('  ').convert(responseData));
    } else {
      print('❌ API call thất bại: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('❌ API call error: $e');
  }
}
