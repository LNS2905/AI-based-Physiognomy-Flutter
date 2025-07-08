import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget to render markdown-like content for news articles
/// Supports basic formatting like headers, paragraphs, and lists
class NewsContentRenderer extends StatelessWidget {
  final String content;

  const NewsContentRenderer({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _parseContent(content),
      ),
    );
  }

  List<Widget> _parseContent(String content) {
    final lines = content.split('\n');
    final widgets = <Widget>[];
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }
      
      // Headers
      if (line.startsWith('# ')) {
        widgets.add(_buildHeader1(line.substring(2)));
      } else if (line.startsWith('## ')) {
        widgets.add(_buildHeader2(line.substring(3)));
      } else if (line.startsWith('### ')) {
        widgets.add(_buildHeader3(line.substring(4)));
      }
      // Lists
      else if (line.startsWith('- ')) {
        widgets.add(_buildListItem(line.substring(2)));
      } else if (RegExp(r'^\d+\.').hasMatch(line)) {
        final match = RegExp(r'^\d+\.\s*(.*)').firstMatch(line);
        if (match != null) {
          widgets.add(_buildNumberedListItem(match.group(1) ?? ''));
        }
      }
      // Regular paragraphs
      else if (!line.startsWith('#') && !line.startsWith('-') && !RegExp(r'^\d+\.').hasMatch(line)) {
        widgets.add(_buildParagraph(line));
      }
    }
    
    return widgets;
  }

  Widget _buildHeader1(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildHeader2(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildHeader3(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, right: 12),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedListItem(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_getNumberFromText(text)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getNumberFromText(String text) {
    // This is a simple implementation - in a real app you'd track the number properly
    return 1;
  }
}

/// Enhanced content renderer with more features
class EnhancedNewsContentRenderer extends StatelessWidget {
  final String content;
  final TextStyle? baseTextStyle;
  final EdgeInsets? padding;

  const EnhancedNewsContentRenderer({
    super.key,
    required this.content,
    this.baseTextStyle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content sections with Bagua-inspired styling
          _buildContentSection(),
          
          const SizedBox(height: 32),
          
          // Reading progress indicator
          _buildReadingProgress(),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _parseEnhancedContent(content),
      ),
    );
  }

  Widget _buildReadingProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_stories,
            color: AppColors.textOnPrimary,
            size: 20,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'You\'ve reached the end of this article',
              style: TextStyle(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              '100%',
              style: TextStyle(
                color: AppColors.textOnPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _parseEnhancedContent(String content) {
    // Enhanced parsing with better formatting
    final lines = content.split('\n');
    final widgets = <Widget>[];
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      
      if (trimmedLine.isEmpty) {
        widgets.add(const SizedBox(height: 12));
        continue;
      }
      
      if (trimmedLine.startsWith('# ')) {
        widgets.add(_buildEnhancedHeader1(trimmedLine.substring(2)));
      } else if (trimmedLine.startsWith('## ')) {
        widgets.add(_buildEnhancedHeader2(trimmedLine.substring(3)));
      } else if (trimmedLine.startsWith('### ')) {
        widgets.add(_buildEnhancedHeader3(trimmedLine.substring(4)));
      } else if (trimmedLine.startsWith('- ')) {
        widgets.add(_buildEnhancedListItem(trimmedLine.substring(2)));
      } else {
        widgets.add(_buildEnhancedParagraph(trimmedLine));
      }
    }
    
    return widgets;
  }

  Widget _buildEnhancedHeader1(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 16),
      padding: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader2(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedHeader3(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildEnhancedParagraph(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: baseTextStyle ?? const TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildEnhancedListItem(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, right: 12),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
