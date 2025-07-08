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
        title: 'Latest AI Breakthrough in Facial Analysis',
        description: 'Researchers develop new algorithms for more accurate personality assessment through facial features.',
        content: '''
# Latest AI Breakthrough in Facial Analysis

Artificial Intelligence continues to revolutionize the field of facial analysis, with researchers at leading universities developing groundbreaking algorithms that can assess personality traits with unprecedented accuracy.

## The Science Behind Facial Analysis

The study of physiognomy, the practice of assessing character or personality from facial features, has ancient roots but is now being transformed by modern AI technology. Recent breakthroughs in machine learning have enabled computers to identify subtle patterns in facial structure that correlate with personality traits.

### Key Developments

1. **Enhanced Pattern Recognition**: New neural networks can identify micro-expressions and facial asymmetries that were previously undetectable.

2. **Cultural Sensitivity**: Modern algorithms account for cultural differences in facial expressions and features.

3. **Ethical Considerations**: Researchers are implementing strict ethical guidelines to prevent misuse of this technology.

## Real-World Applications

This technology has potential applications in:
- Mental health assessment
- Educational psychology
- Human resources
- Security and safety

## Looking Forward

As this technology continues to evolve, it's crucial to balance innovation with ethical responsibility, ensuring that AI-powered facial analysis serves humanity's best interests while respecting individual privacy and dignity.
        ''',
        category: 'Technology',
        author: 'Dr. Sarah Chen',
        imageUrl: 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=800',
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
        readTime: 3,
        tags: ['AI', 'Technology', 'Research', 'Facial Analysis'],
        isFeatured: true,
        viewCount: 1250,
        likeCount: 89,
      ),
      NewsArticleModel(
        id: '2',
        title: 'Understanding Physiognomy in Modern Context',
        description: 'How ancient practices meet cutting-edge technology to provide insights into human behavior.',
        content: '''
# Understanding Physiognomy in Modern Context

The ancient art of physiognomy is experiencing a renaissance in the digital age, as modern technology breathes new life into age-old practices of reading character through facial features.

## Historical Perspective

Physiognomy has been practiced for thousands of years across different cultures:
- Ancient Greek philosophers like Aristotle wrote about facial analysis
- Traditional Chinese medicine incorporates facial reading
- Medieval European scholars developed systematic approaches

## Modern Integration

Today's approach combines:
- Traditional wisdom with scientific methodology
- Cultural sensitivity with technological precision
- Ethical guidelines with practical applications

## The Bagua Connection

In Chinese philosophy, the Bagua (Eight Trigrams) provides a framework for understanding balance and harmony, which can be applied to facial analysis:

### The Eight Aspects
1. **Heaven (乾)** - Leadership qualities
2. **Earth (坤)** - Nurturing nature
3. **Thunder (震)** - Dynamic energy
4. **Wind (巽)** - Adaptability
5. **Water (坎)** - Depth and wisdom
6. **Fire (離)** - Passion and clarity
7. **Mountain (艮)** - Stability and patience
8. **Lake (兌)** - Joy and communication

## Ethical Considerations

Modern physiognomy must address:
- Privacy concerns
- Cultural biases
- Consent and transparency
- Responsible use of insights

The future of physiognomy lies in respectful integration of ancient wisdom with modern technology.
        ''',
        category: 'Science',
        author: 'Prof. Michael Zhang',
        imageUrl: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=800',
        publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
        readTime: 5,
        tags: ['Physiognomy', 'Culture', 'Philosophy', 'Bagua'],
        isFeatured: false,
        viewCount: 892,
        likeCount: 67,
      ),
      NewsArticleModel(
        id: '3',
        title: 'Privacy and Ethics in AI Analysis',
        description: 'Exploring the ethical considerations and privacy measures in AI-powered personality analysis.',
        content: '''
# Privacy and Ethics in AI Analysis

As AI-powered personality analysis becomes more sophisticated, the importance of ethical considerations and privacy protection has never been greater.

## Core Ethical Principles

### 1. Informed Consent
Users must fully understand:
- What data is being collected
- How it will be used
- Who has access to it
- How long it will be stored

### 2. Transparency
AI systems should be:
- Explainable in their decision-making
- Open about their limitations
- Clear about confidence levels

### 3. Fairness and Non-Discrimination
- Algorithms must be tested for bias
- Cultural sensitivity is essential
- Equal treatment regardless of background

## Privacy Protection Measures

### Data Security
- End-to-end encryption
- Secure storage protocols
- Regular security audits
- Minimal data collection

### User Control
- Right to data deletion
- Ability to correct information
- Control over data sharing
- Opt-out mechanisms

## Industry Standards

Leading organizations are developing:
- Ethical AI guidelines
- Privacy-by-design principles
- Regular compliance audits
- User education programs

## The Path Forward

The future of AI analysis depends on:
- Continued ethical development
- Strong regulatory frameworks
- Industry self-regulation
- Public awareness and education

By prioritizing ethics and privacy, we can harness the benefits of AI while protecting individual rights and dignity.
        ''',
        category: 'Ethics',
        author: 'Dr. Emily Rodriguez',
        imageUrl: 'https://images.unsplash.com/photo-1563986768609-322da13575f3?w=800',
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        readTime: 4,
        tags: ['Ethics', 'Privacy', 'AI', 'Security'],
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
