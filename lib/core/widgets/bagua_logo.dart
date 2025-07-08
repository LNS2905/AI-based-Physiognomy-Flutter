import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'dart:math' as math;

/// Bagua-inspired logo widget for the AI Physiognomy app
/// Implements traditional Eight Trigrams design with modern aesthetics
class BaguaLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? primaryColor;
  final Color? secondaryColor;

  const BaguaLogo({
    super.key,
    this.size = 56.0,
    this.showText = true,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bagua Symbol
        CustomPaint(
          size: Size(size, size),
          painter: BaguaPainter(
            primaryColor: primaryColor ?? AppColors.primary,
            secondaryColor: secondaryColor ?? AppColors.textPrimary,
          ),
        ),
        
        if (showText) ...[
          const SizedBox(height: 8),
          // App Name
          Text(
            'AI Physiognomy',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: size * 0.25,
              color: primaryColor ?? AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }
}

/// Custom painter for the Bagua symbol
class BaguaPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  BaguaPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Draw octagonal frame (Bagua structure)
    _drawOctagonalFrame(canvas, center, radius);
    
    // Draw central Yin-Yang symbol
    _drawYinYang(canvas, center, radius * 0.4);
    
    // Draw trigram lines (simplified)
    _drawTrigramLines(canvas, center, radius);
  }

  void _drawOctagonalFrame(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final path = Path();
    const sides = 8;
    
    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi) / sides - math.pi / 2;
      final x = center.dx + radius * 0.9 * math.cos(angle);
      final y = center.dy + radius * 0.9 * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    canvas.drawPath(path, paint);
  }

  void _drawYinYang(Canvas canvas, Offset center, double radius) {
    // Yin (black) half
    final yinPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;
    
    // Yang (white) half  
    final yangPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    // Draw Yin half
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      math.pi,
      true,
      yinPaint,
    );
    
    // Draw Yang half
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      true,
      yangPaint,
    );
    
    // Draw small circles
    final smallRadius = radius * 0.15;
    
    // Yin dot (white on black side)
    canvas.drawCircle(
      Offset(center.dx, center.dy - radius * 0.5),
      smallRadius,
      yangPaint,
    );
    
    // Yang dot (black on white side)
    canvas.drawCircle(
      Offset(center.dx, center.dy + radius * 0.5),
      smallRadius,
      yinPaint,
    );
    
    // Draw curved divider
    final curvePaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(center.dx, center.dy - radius * 0.5),
      radius * 0.5,
      yangPaint,
    );
    
    canvas.drawCircle(
      Offset(center.dx, center.dy + radius * 0.5),
      radius * 0.5,
      curvePaint,
    );
  }

  void _drawTrigramLines(Canvas canvas, Offset center, double radius) {
    final linePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw simplified trigram lines at 8 positions
    for (int i = 0; i < 8; i++) {
      final angle = (i * 2 * math.pi) / 8 - math.pi / 2;
      final startRadius = radius * 0.95;
      final endRadius = radius * 0.75;
      
      final startX = center.dx + startRadius * math.cos(angle);
      final startY = center.dy + startRadius * math.sin(angle);
      final endX = center.dx + endRadius * math.cos(angle);
      final endY = center.dy + endRadius * math.sin(angle);
      
      // Draw three short lines for each trigram position
      for (int j = 0; j < 3; j++) {
        final lineOffset = (j - 1) * 4.0;
        final perpAngle = angle + math.pi / 2;
        
        final lineStartX = startX + lineOffset * math.cos(perpAngle);
        final lineStartY = startY + lineOffset * math.sin(perpAngle);
        final lineEndX = endX + lineOffset * math.cos(perpAngle);
        final lineEndY = endY + lineOffset * math.sin(perpAngle);
        
        canvas.drawLine(
          Offset(lineStartX, lineStartY),
          Offset(lineEndX, lineEndY),
          linePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Simplified Bagua icon for smaller spaces
class BaguaIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const BaguaIcon({
    super.key,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: SimpleBaguaPainter(
        color: color ?? AppColors.primary,
      ),
    );
  }
}

/// Simplified painter for icon usage
class SimpleBaguaPainter extends CustomPainter {
  final Color color;

  SimpleBaguaPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw octagon
    final path = Path();
    const sides = 8;
    
    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi) / sides - math.pi / 2;
      final x = center.dx + radius * 0.8 * math.cos(angle);
      final y = center.dy + radius * 0.8 * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Draw center circle
    canvas.drawCircle(center, radius * 0.3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
