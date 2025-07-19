import 'dart:math';
import '../../../face_scan/data/models/cloudinary_analysis_response_model.dart';
import '../../../palm_scan/data/models/palm_analysis_response_model.dart';
import '../../../ai_conversation/data/models/conversation_model.dart';
import '../../../ai_conversation/data/models/chat_message_model.dart';
import '../models/history_item_model.dart';
import '../models/chat_history_model.dart';

/// Service for generating mock history data
class MockHistoryService {
  static final Random _random = Random();

  /// Generate mock face analysis history items
  static List<FaceAnalysisHistoryModel> generateMockFaceAnalysisHistory() {
    final items = <FaceAnalysisHistoryModel>[];
    final shapes = ['Oval', 'Round', 'Square', 'Heart', 'Diamond', 'Oblong'];
    final imageUrls = [
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400',
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
    ];

    for (int i = 0; i < 8; i++) {
      final shape = shapes[_random.nextInt(shapes.length)];
      final imageUrl = imageUrls[_random.nextInt(imageUrls.length)];
      final createdAt = DateTime.now().subtract(Duration(
        days: _random.nextInt(30),
        hours: _random.nextInt(24),
        minutes: _random.nextInt(60),
      ));

      // Create mock analysis response
      final analysisResponse = CloudinaryAnalysisResponseModel(
        status: 'success',
        message: 'Analysis completed successfully',
        userId: 'user_${i + 1}',
        processedAt: createdAt.toIso8601String(),
        annotatedImageUrl: imageUrl,
        analysis: CloudinaryAnalysisDataModel(
          metadata: CloudinaryMetadataModel(
            reportTitle: 'Face Analysis Report ${i + 1}',
            sourceFilename: 'face_${i + 1}.jpg',
            timestampUTC: createdAt.toIso8601String(),
          ),
          analysisResult: CloudinaryAnalysisResultModel(
            face: CloudinaryFaceModel(
              shape: CloudinaryFaceShapeModel(
                primary: shape,
                probabilities: {
                  'Oval': _random.nextDouble(),
                  'Round': _random.nextDouble(),
                  'Square': _random.nextDouble(),
                  'Heart': _random.nextDouble(),
                  'Diamond': _random.nextDouble(),
                  'Oblong': _random.nextDouble(),
                },
              ),
              proportionality: CloudinaryProportionalityModel(
                overallHarmonyScore: 0.7 + _random.nextDouble() * 0.3,
                harmonyScores: {
                  'facial_width_ratio': _random.nextDouble(),
                  'facial_height_ratio': _random.nextDouble(),
                  'eye_spacing_ratio': _random.nextDouble(),
                  'nose_width_ratio': _random.nextDouble(),
                  'mouth_width_ratio': _random.nextDouble(),
                },
                metrics: [],
              ),
            ),
          ),
          result: 'Face shape: $shape',
        ),
      );

      final item = FaceAnalysisHistoryModel.fromAnalysis(
        id: 'face_${i + 1}',
        analysisResult: analysisResponse,
        originalImageUrl: imageUrl,
        annotatedImageUrl: imageUrl,
        reportUrl: 'https://example.com/report_${i + 1}.pdf',
        metadata: {
          'analysis_version': '1.0.0',
          'device_type': 'mobile',
          'upload_source': _random.nextBool() ? 'camera' : 'gallery',
        },
      );

      items.add(item.copyWith(
        createdAt: createdAt,
        updatedAt: createdAt,
        isFavorite: _random.nextBool() && _random.nextDouble() < 0.3,
      ));
    }

    return items;
  }

  /// Generate mock palm analysis history items
  static List<PalmAnalysisHistoryModel> generateMockPalmAnalysisHistory() {
    final items = <PalmAnalysisHistoryModel>[];
    final palmImageUrls = [
      'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400',
      'https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca?w=400',
      'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?w=400',
    ];

    for (int i = 0; i < 6; i++) {
      final imageUrl = palmImageUrls[_random.nextInt(palmImageUrls.length)];
      final handsDetected = _random.nextInt(2) + 1;
      final createdAt = DateTime.now().subtract(Duration(
        days: _random.nextInt(45),
        hours: _random.nextInt(24),
        minutes: _random.nextInt(60),
      ));

      // Create mock palm analysis response
      final analysisResponse = PalmAnalysisResponseModel(
        status: 'success',
        message: 'Palm analysis completed successfully',
        userId: 'user_${i + 1}',
        processedAt: createdAt.toIso8601String(),
        handsDetected: handsDetected,
        processingTime: 3.0 + _random.nextDouble() * 2.0,
        analysisType: 'palm_reading',
        annotatedImageUrl: imageUrl,
        comparisonImageUrl: imageUrl,
        analysis: PalmAnalysisDataModel(
          handsDetected: handsDetected,
          handsData: [],
          measurements: {
            'palm_length': 120.0 + _random.nextDouble() * 40.0,
            'palm_width': 80.0 + _random.nextDouble() * 20.0,
            'finger_length_avg': 70.0 + _random.nextDouble() * 20.0,
          },
          palmLines: {
            'life_line': {
              'length': _random.nextDouble(),
              'depth': _random.nextDouble(),
              'clarity': _random.nextDouble(),
            },
            'heart_line': {
              'length': _random.nextDouble(),
              'depth': _random.nextDouble(),
              'clarity': _random.nextDouble(),
            },
            'head_line': {
              'length': _random.nextDouble(),
              'depth': _random.nextDouble(),
              'clarity': _random.nextDouble(),
            },
          },
          fingerAnalysis: {
            'thumb': {'length': _random.nextDouble(), 'flexibility': _random.nextDouble()},
            'index': {'length': _random.nextDouble(), 'flexibility': _random.nextDouble()},
            'middle': {'length': _random.nextDouble(), 'flexibility': _random.nextDouble()},
            'ring': {'length': _random.nextDouble(), 'flexibility': _random.nextDouble()},
            'pinky': {'length': _random.nextDouble(), 'flexibility': _random.nextDouble()},
          },
          metadata: MetadataModel(
            processingTime: 3.0,
            analysisTimestamp: createdAt.toIso8601String(),
          ),
        ),
        measurementsSummary: MeasurementsSummaryModel(
          totalHands: handsDetected,
          leftHands: handsDetected > 1 ? 1 : (_random.nextBool() ? 1 : 0),
          rightHands: handsDetected > 1 ? 1 : (_random.nextBool() ? 1 : 0),
          averageHandLength: 150.0 + _random.nextDouble() * 50.0,
          averagePalmWidth: 80.0 + _random.nextDouble() * 20.0,
          palmTypes: ['normal', 'square'],
          confidenceScores: {
            'overall': 0.8 + _random.nextDouble() * 0.2,
            'palm_lines': 0.7 + _random.nextDouble() * 0.3,
          },
        ),
      );

      final item = PalmAnalysisHistoryModel.fromAnalysis(
        id: 'palm_${i + 1}',
        analysisResult: analysisResponse,
        originalImageUrl: imageUrl,
        annotatedImageUrl: imageUrl,
        comparisonImageUrl: imageUrl,
        metadata: {
          'analysis_version': '1.0.0',
          'device_type': 'mobile',
          'upload_source': _random.nextBool() ? 'camera' : 'gallery',
        },
      );

      items.add(item.copyWith(
        createdAt: createdAt,
        updatedAt: createdAt,
        isFavorite: _random.nextBool() && _random.nextDouble() < 0.2,
      ));
    }

    return items;
  }

  /// Generate mock chat conversation history items
  static List<ChatHistoryModel> generateMockChatHistory() {
    final items = <ChatHistoryModel>[];
    
    final conversationTopics = [
      {
        'title': 'Giải thích kết quả phân tích khuôn mặt',
        'messages': <String>[
          'Bạn có thể giải thích kết quả phân tích khuôn mặt của tôi không?',
          'Tất nhiên! Dựa trên kết quả phân tích, khuôn mặt của bạn có dạng oval, đây là một trong những dạng khuôn mặt được đánh giá cao trong tướng học. Khuôn mặt oval thường biểu hiện sự cân bằng và hài hòa...',
          'Điều này có ý nghĩa gì trong tướng học?',
          'Trong tướng học, khuôn mặt oval được cho là biểu hiện của người có tính cách ôn hòa, dễ gần, và có khả năng giao tiếp tốt. Những người có khuôn mặt này thường có xu hướng...',
        ],
      },
      {
        'title': 'Hỏi về phân tích vân tay',
        'messages': <String>[
          'Tôi muốn biết thêm về phân tích vân tay',
          'Phân tích vân tay là một phần quan trọng trong tướng học. Các đường chỉ tay có thể tiết lộ nhiều thông tin về tính cách và vận mệnh của một người...',
          'Làm sao để đọc đường chỉ tay?',
          'Có ba đường chỉ tay chính: đường đời (life line), đường tim (heart line), và đường trí tuệ (head line). Mỗi đường có ý nghĩa riêng...',
        ],
      },
      {
        'title': 'So sánh kết quả phân tích',
        'messages': <String>[
          'Tôi có thể so sánh kết quả phân tích của mình với người khác không?',
          'Mỗi người có những đặc điểm riêng biệt, việc so sánh cần được thực hiện một cách khách quan. Tôi có thể giúp bạn hiểu rõ hơn về kết quả của mình...',
        ],
      },
      {
        'title': 'Câu hỏi về tướng học',
        'messages': <String>[
          'Tướng học có độ chính xác như thế nào?',
          'Tướng học là một nghệ thuật truyền thống có từ hàng ngàn năm. Mặc dù không phải là khoa học chính xác 100%, nhưng nó có thể cung cấp những góc nhìn thú vị về tính cách...',
          'Tôi nên tin vào kết quả này không?',
          'Kết quả phân tích nên được xem như một tham khảo thú vị chứ không phải là định mệnh tuyệt đối. Quan trọng nhất là bạn hiểu về bản thân và phát triển những điểm mạnh...',
        ],
      },
    ];

    for (int i = 0; i < conversationTopics.length; i++) {
      final topic = conversationTopics[i];
      final messages = <ChatMessageModel>[];
      final createdAt = DateTime.now().subtract(Duration(
        days: _random.nextInt(20),
        hours: _random.nextInt(24),
        minutes: _random.nextInt(60),
      ));

      var messageTime = createdAt;
      final topicMessages = topic['messages'] as List<String>;
      for (int j = 0; j < topicMessages.length; j++) {
        final isUser = j % 2 == 0;
        messageTime = messageTime.add(Duration(
          minutes: _random.nextInt(5) + 1,
          seconds: _random.nextInt(60),
        ));

        final message = isUser
            ? ChatMessageModel.user(
                id: 'msg_${i}_${j}',
                content: topicMessages[j],
              )
            : ChatMessageModel.ai(
                id: 'msg_${i}_${j}',
                content: topicMessages[j],
              );

        // Update timestamp to match the conversation flow
        messages.add(message.copyWith(timestamp: messageTime));
      }

      final conversation = ConversationModel(
        id: 'conv_${i + 1}',
        title: topic['title'] as String,
        messages: messages,
        createdAt: createdAt,
        updatedAt: messageTime,
        status: ConversationStatus.active,
        metadata: {
          'topic': topic['title'],
          'message_count': messages.length,
        },
      );

      final item = ChatHistoryModel.fromConversation(
        id: 'chat_${i + 1}',
        conversation: conversation,
        metadata: {
          'conversation_type': 'user_initiated',
          'device_type': 'mobile',
        },
      );

      items.add(item.copyWith(
        isFavorite: _random.nextBool() && _random.nextDouble() < 0.25,
      ));
    }

    return items;
  }

  /// Generate all mock history items
  static List<HistoryItemModel> generateAllMockHistory() {
    final allItems = <HistoryItemModel>[];
    
    allItems.addAll(generateMockFaceAnalysisHistory());
    allItems.addAll(generateMockPalmAnalysisHistory());
    allItems.addAll(generateMockChatHistory());

    // Sort by creation date (newest first)
    allItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return allItems;
  }

  /// Get random sample items for quick testing
  static List<HistoryItemModel> getSampleItems({int count = 5}) {
    final allItems = generateAllMockHistory();
    allItems.shuffle(_random);
    return allItems.take(count).toList();
  }
}
