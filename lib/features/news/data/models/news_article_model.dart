import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'news_article_model.g.dart';

/// News article model for the application
@JsonSerializable()
class NewsArticleModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String content;
  final String category;
  final String author;
  final String? imageUrl;
  final DateTime publishedAt;
  final DateTime? updatedAt;
  final int readTime; // in minutes
  final List<String> tags;
  final bool isFeatured;
  final int viewCount;
  final int likeCount;

  const NewsArticleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.category,
    required this.author,
    this.imageUrl,
    required this.publishedAt,
    this.updatedAt,
    required this.readTime,
    this.tags = const [],
    this.isFeatured = false,
    this.viewCount = 0,
    this.likeCount = 0,
  });

  /// Create from JSON
  factory NewsArticleModel.fromJson(Map<String, dynamic> json) =>
      _$NewsArticleModelFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$NewsArticleModelToJson(this);

  /// Create a copy with updated fields
  NewsArticleModel copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? category,
    String? author,
    String? imageUrl,
    DateTime? publishedAt,
    DateTime? updatedAt,
    int? readTime,
    List<String>? tags,
    bool? isFeatured,
    int? viewCount,
    int? likeCount,
  }) {
    return NewsArticleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      category: category ?? this.category,
      author: author ?? this.author,
      imageUrl: imageUrl ?? this.imageUrl,
      publishedAt: publishedAt ?? this.publishedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      readTime: readTime ?? this.readTime,
      tags: tags ?? this.tags,
      isFeatured: isFeatured ?? this.isFeatured,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
    );
  }

  /// Sample news articles for demo
  static List<NewsArticleModel> getSampleArticles() {
    return [
      NewsArticleModel(
        id: '1',
        title: 'Đột phá AI mới nhất trong phân tích khuôn mặt',
        description: 'Các nhà nghiên cứu phát triển thuật toán mới để đánh giá tính cách chính xác hơn thông qua các nét mặt.',
        content: '''
# Đột phá AI mới nhất trong phân tích khuôn mặt

Trí tuệ nhân tạo tiếp tục cách mạng hóa lĩnh vực phân tích khuôn mặt, với các nhà nghiên cứu tại các trường đại học hàng đầu phát triển các thuật toán đột phá có thể đánh giá các đặc điểm tính cách với độ chính xác chưa từng có.

## Khoa học đằng sau phân tích khuôn mặt

Nghiên cứu về tướng học, thực hành đánh giá tính cách hoặc nhân cách từ các nét mặt, có nguồn gốc cổ xưa nhưng hiện đang được biến đổi bởi công nghệ AI hiện đại. Những đột phá gần đây trong học máy đã cho phép máy tính xác định các mẫu tinh tế trong cấu trúc khuôn mặt có tương quan với các đặc điểm tính cách.

### Những phát triển chính

1. **Nhận dạng mẫu nâng cao**: Các mạng nơ-ron mới có thể xác định các biểu hiện vi mô và sự bất đối xứng khuôn mặt mà trước đây không thể phát hiện được.

2. **Nhạy cảm văn hóa**: Các thuật toán hiện đại tính đến sự khác biệt văn hóa trong biểu hiện và nét mặt.

3. **Cân nhắc đạo đức**: Các nhà nghiên cứu đang thực hiện các hướng dẫn đạo đức nghiêm ngặt để ngăn chặn việc lạm dụng công nghệ này.

## Ứng dụng thực tế

Công nghệ này có các ứng dụng tiềm năng trong:
- Đánh giá sức khỏe tâm thần
- Tâm lý giáo dục
- Nhân sự
- An ninh và an toàn

## Nhìn về tương lai

Khi công nghệ này tiếp tục phát triển, điều quan trọng là phải cân bằng giữa đổi mới và trách nhiệm đạo đức, đảm bảo rằng phân tích khuôn mặt được hỗ trợ bởi AI phục vụ lợi ích tốt nhất của nhân loại trong khi tôn trọng quyền riêng tư và phẩm giá cá nhân.
        ''',
        category: 'Công nghệ',
        author: 'TS. Sarah Chen',
        imageUrl: 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=800',
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
        readTime: 3,
        tags: ['AI', 'Công nghệ', 'Nghiên cứu', 'Phân tích khuôn mặt'],
        isFeatured: true,
        viewCount: 1250,
        likeCount: 89,
      ),
      NewsArticleModel(
        id: '2',
        title: 'Hiểu về tướng học trong bối cảnh hiện đại',
        description: 'Cách các thực hành cổ xưa kết hợp với công nghệ tiên tiến để cung cấp hiểu biết về hành vi con người.',
        content: '''
# Hiểu về tướng học trong bối cảnh hiện đại

Nghệ thuật tướng học cổ xưa đang trải qua một sự phục hưng trong thời đại kỹ thuật số, khi công nghệ hiện đại thổi hồn mới vào các thực hành lâu đời về việc đọc tính cách thông qua các nét mặt.

## Góc nhìn lịch sử

Tướng học đã được thực hành hàng nghìn năm qua các nền văn hóa khác nhau:
- Các triết gia Hy Lạp cổ đại như Aristotle đã viết về phân tích khuôn mặt
- Y học cổ truyền Trung Quốc kết hợp việc đọc khuôn mặt
- Các học giả châu Âu thời trung cổ đã phát triển các phương pháp có hệ thống

## Tích hợp hiện đại

Cách tiếp cận ngày nay kết hợp:
- Trí tuệ truyền thống với phương pháp khoa học
- Nhạy cảm văn hóa với độ chính xác công nghệ
- Hướng dẫn đạo đức với ứng dụng thực tế

## Kết nối Bát Quái

Trong triết học Trung Quốc, Bát Quái (Tám Quẻ) cung cấp một khung để hiểu về sự cân bằng và hài hòa, có thể được áp dụng cho phân tích khuôn mặt:

### Tám khía cạnh
1. **Thiên (乾)** - Phẩm chất lãnh đạo
2. **Địa (坤)** - Bản chất nuôi dưỡng
3. **Lôi (震)** - Năng lượng năng động
4. **Phong (巽)** - Khả năng thích ứng
5. **Thủy (坎)** - Chiều sâu và trí tuệ
6. **Hỏa (離)** - Đam mê và sự rõ ràng
7. **Sơn (艮)** - Sự ổn định và kiên nhẫn
8. **Trạch (兌)** - Niềm vui và giao tiếp

## Cân nhắc đạo đức

Tướng học hiện đại phải giải quyết:
- Mối quan tâm về quyền riêng tư
- Thiên kiến văn hóa
- Sự đồng ý và minh bạch
- Sử dụng có trách nhiệm các hiểu biết

Tương lai của tướng học nằm trong việc tích hợp một cách tôn trọng trí tuệ cổ xưa với công nghệ hiện đại.
        ''',
        category: 'Khoa học',
        author: 'GS. Michael Zhang',
        imageUrl: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=800',
        publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
        readTime: 5,
        tags: ['Tướng học', 'Văn hóa', 'Triết học', 'Bát Quái'],
        isFeatured: false,
        viewCount: 892,
        likeCount: 67,
      ),
      NewsArticleModel(
        id: '3',
        title: 'Quyền riêng tư và đạo đức trong phân tích AI',
        description: 'Khám phá các cân nhắc đạo đức và biện pháp bảo mật trong phân tích tính cách được hỗ trợ bởi AI.',
        content: '''
# Quyền riêng tư và đạo đức trong phân tích AI

Khi phân tích tính cách được hỗ trợ bởi AI trở nên tinh vi hơn, tầm quan trọng của các cân nhắc đạo đức và bảo vệ quyền riêng tư chưa bao giờ lớn hơn thế.

## Nguyên tắc đạo đức cốt lõi

### 1. Sự đồng ý có thông tin
Người dùng phải hiểu đầy đủ:
- Dữ liệu nào đang được thu thập
- Nó sẽ được sử dụng như thế nào
- Ai có quyền truy cập vào nó
- Nó sẽ được lưu trữ trong bao lâu

### 2. Minh bạch
Các hệ thống AI nên:
- Có thể giải thích được trong việc ra quyết định
- Cởi mở về những hạn chế của chúng
- Rõ ràng về mức độ tin cậy

### 3. Công bằng và không phân biệt đối xử
- Các thuật toán phải được kiểm tra về thiên kiến
- Nhạy cảm văn hóa là điều cần thiết
- Đối xử bình đẳng bất kể xuất thân

## Biện pháp bảo vệ quyền riêng tư

### Bảo mật dữ liệu
- Mã hóa đầu cuối
- Giao thức lưu trữ an toàn
- Kiểm toán bảo mật thường xuyên
- Thu thập dữ liệu tối thiểu

### Kiểm soát người dùng
- Quyền xóa dữ liệu
- Khả năng sửa chữa thông tin
- Kiểm soát việc chia sẻ dữ liệu
- Cơ chế từ chối tham gia

## Tiêu chuẩn ngành

Các tổ chức hàng đầu đang phát triển:
- Hướng dẫn AI đạo đức
- Nguyên tắc bảo mật theo thiết kế
- Kiểm toán tuân thủ thường xuyên
- Chương trình giáo dục người dùng

## Con đường phía trước

Tương lai của phân tích AI phụ thuộc vào:
- Phát triển đạo đức liên tục
- Khung pháp lý mạnh mẽ
- Tự điều chỉnh ngành
- Nhận thức và giáo dục công chúng

Bằng cách ưu tiên đạo đức và quyền riêng tư, chúng ta có thể khai thác lợi ích của AI trong khi bảo vệ quyền và phẩm giá cá nhân.
        ''',
        category: 'Đạo đức',
        author: 'TS. Emily Rodriguez',
        imageUrl: 'https://images.unsplash.com/photo-1563986768609-322da13575f3?w=800',
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        readTime: 4,
        tags: ['Đạo đức', 'Quyền riêng tư', 'AI', 'Bảo mật'],
        isFeatured: false,
        viewCount: 654,
        likeCount: 45,
      ),
    ];
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        content,
        category,
        author,
        imageUrl,
        publishedAt,
        updatedAt,
        readTime,
        tags,
        isFeatured,
        viewCount,
        likeCount,
      ];
}
