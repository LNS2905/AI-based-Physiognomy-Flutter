/// Survey question model
class SurveyQuestionModel {
  final String id;
  final String title;
  final String subtitle;
  final List<SurveyOptionModel> options;
  final SurveyQuestionType type;
  final bool isRequired;

  const SurveyQuestionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.type,
    this.isRequired = true,
  });

  factory SurveyQuestionModel.fromJson(Map<String, dynamic> json) {
    return SurveyQuestionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      options: (json['options'] as List<dynamic>)
          .map((option) => SurveyOptionModel.fromJson(option as Map<String, dynamic>))
          .toList(),
      type: SurveyQuestionType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => SurveyQuestionType.singleChoice,
      ),
      isRequired: json['isRequired'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'options': options.map((option) => option.toJson()).toList(),
      'type': type.name,
      'isRequired': isRequired,
    };
  }

  SurveyQuestionModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    List<SurveyOptionModel>? options,
    SurveyQuestionType? type,
    bool? isRequired,
  }) {
    return SurveyQuestionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      options: options ?? this.options,
      type: type ?? this.type,
      isRequired: isRequired ?? this.isRequired,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SurveyQuestionModel &&
        other.id == id &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.type == type &&
        other.isRequired == isRequired;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, subtitle, type, isRequired);
  }

  @override
  String toString() {
    return 'SurveyQuestionModel(id: $id, title: $title, subtitle: $subtitle, type: $type, isRequired: $isRequired)';
  }
}

/// Survey option model
class SurveyOptionModel {
  final String id;
  final String text;
  final String? value;

  const SurveyOptionModel({
    required this.id,
    required this.text,
    this.value,
  });

  factory SurveyOptionModel.fromJson(Map<String, dynamic> json) {
    return SurveyOptionModel(
      id: json['id'] as String,
      text: json['text'] as String,
      value: json['value'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'value': value,
    };
  }

  SurveyOptionModel copyWith({
    String? id,
    String? text,
    String? value,
  }) {
    return SurveyOptionModel(
      id: id ?? this.id,
      text: text ?? this.text,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SurveyOptionModel &&
        other.id == id &&
        other.text == text &&
        other.value == value;
  }

  @override
  int get hashCode {
    return Object.hash(id, text, value);
  }

  @override
  String toString() {
    return 'SurveyOptionModel(id: $id, text: $text, value: $value)';
  }
}

/// Survey question types
enum SurveyQuestionType {
  singleChoice,
  multipleChoice,
  text,
  number,
  rating,
}
