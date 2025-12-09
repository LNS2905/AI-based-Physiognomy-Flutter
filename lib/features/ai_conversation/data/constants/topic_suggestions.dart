/// Gợi ý câu hỏi theo chủ đề tử vi
class TopicSuggestions {
  static const Map<String, List<String>> suggestions = {
    'career': [
      'Khi nào là thời điểm tốt để thay đổi công việc?',
      'Tôi phù hợp với ngành nghề nào nhất?',
      'Vận sự nghiệp năm nay của tôi ra sao?',
    ],
    'love': [
      'Vận đào hoa của tôi năm nay thế nào?',
      'Tôi có nên kết hôn trong năm nay?',
      'Làm sao để cải thiện quan hệ tình cảm?',
    ],
    'money': [
      'Làm thế nào để cải thiện tài chính?',
      'Tôi có nên đầu tư trong giai đoạn này?',
      'Nguồn thu nhập nào phù hợp với tôi?',
    ],
    'health': [
      'Tôi cần chú ý vấn đề sức khỏe nào?',
      'Làm sao để cải thiện sức khỏe theo tử vi?',
      'Thời điểm nào cần đề phòng bệnh tật?',
    ],
    'family': [
      'Mối quan hệ gia đình của tôi thế nào?',
      'Làm sao để hòa thuận với người thân?',
      'Vận con cái của tôi ra sao?',
    ],
    'general': [
      'Vận mệnh tổng quan của tôi thế nào?',
      'Tôi nên làm gì để cải thiện vận mệnh?',
      'Điểm mạnh và yếu trong lá số của tôi?',
    ],
  };

  /// Keywords để detect chủ đề từ nội dung
  static const Map<String, List<String>> topicKeywords = {
    'career': ['công việc', 'nghề', 'sự nghiệp', 'tiền đồ', 'thăng tiến', 'quan lộc', 'việc làm'],
    'love': ['tình yêu', 'hôn nhân', 'vợ chồng', 'người yêu', 'đào hoa', 'phu thê', 'kết hôn', 'tình duyên'],
    'money': ['tiền', 'tài', 'đầu tư', 'kinh doanh', 'tài bạch', 'giàu', 'thu nhập'],
    'health': ['khỏe', 'bệnh', 'sức khỏe', 'thể chất', 'tật ách', 'ốm', 'y tế'],
    'family': ['con cái', 'cha mẹ', 'gia đình', 'anh em', 'tử tức', 'phụ mẫu', 'huynh đệ'],
  };

  /// Detect topic từ message content
  static String detectTopic(String content) {
    final lowerContent = content.toLowerCase();
    
    for (final entry in topicKeywords.entries) {
      for (final keyword in entry.value) {
        if (lowerContent.contains(keyword)) {
          return entry.key;
        }
      }
    }
    
    return 'general';
  }

  /// Get suggestions cho topic, random 2-3 items
  static List<String> getSuggestionsForTopic(String topic, {int count = 3}) {
    final topicSuggestions = suggestions[topic] ?? suggestions['general']!;
    final shuffled = List<String>.from(topicSuggestions)..shuffle();
    return shuffled.take(count).toList();
  }

  /// Get suggestions based on message content
  static List<String> getSuggestionsForMessage(String messageContent, {int count = 3}) {
    final topic = detectTopic(messageContent);
    return getSuggestionsForTopic(topic, count: count);
  }
}
