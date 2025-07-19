import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_based_physiognomy_flutter/features/face_scan/presentation/pages/analysis_results_page.dart';

void main() {
  group('AnalysisResultsPage', () {
    testWidgets('should only show annotated image when annotatedImagePath is provided', (WidgetTester tester) async {
      // Arrange
      const testAnnotatedImagePath = 'https://example.com/annotated.jpg';
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: AnalysisResultsPage(
            annotatedImagePath: testAnnotatedImagePath,
            reportImagePath: 'https://example.com/report.jpg', // Này sẽ bị bỏ qua
          ),
        ),
      );
      
      // Wait for the widget to settle
      await tester.pumpAndSettle();
      
      // Assert
      // Kiểm tra có hiển thị phần "Hình ảnh phân tích"
      expect(find.text('Hình ảnh phân tích'), findsOneWidget);
      
      // Kiểm tra có hiển thị "Ảnh đánh dấu đặc điểm"
      expect(find.text('Ảnh đánh dấu đặc điểm'), findsOneWidget);
      
      // Kiểm tra KHÔNG hiển thị "Báo cáo chi tiết"
      expect(find.text('Báo cáo chi tiết'), findsNothing);
    });

    testWidgets('should not show images section when no annotatedImagePath', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: AnalysisResultsPage(
            reportImagePath: 'https://example.com/report.jpg', // Này sẽ bị bỏ qua
          ),
        ),
      );
      
      // Wait for the widget to settle
      await tester.pumpAndSettle();
      
      // Assert
      // Kiểm tra KHÔNG hiển thị phần "Hình ảnh phân tích"
      expect(find.text('Hình ảnh phân tích'), findsNothing);
    });

    testWidgets('should show analysis results page with basic elements', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: AnalysisResultsPage(),
        ),
      );
      
      // Wait for the widget to settle
      await tester.pumpAndSettle();
      
      // Assert
      // Kiểm tra có hiển thị header với title
      expect(find.text('🎯 Phân tích tướng học AI'), findsOneWidget);
      
      // Kiểm tra có hiển thị action buttons
      expect(find.text('Lưu kết quả'), findsOneWidget);
      expect(find.text('Chia sẻ'), findsOneWidget);
      expect(find.text('Phân tích lại'), findsOneWidget);
    });
  });
}
