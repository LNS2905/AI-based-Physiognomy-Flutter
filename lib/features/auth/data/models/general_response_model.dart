import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'general_response_model.g.dart';

/// General API response wrapper model
@JsonSerializable(genericArgumentFactories: true)
class GeneralResponse<T> extends Equatable {
  final T data;
  final String code;
  final String message;

  const GeneralResponse({
    required this.data,
    required this.code,
    required this.message,
  });

  /// Create GeneralResponse from JSON
  factory GeneralResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$GeneralResponseFromJson(json, fromJsonT);

  /// Convert GeneralResponse to JSON
  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$GeneralResponseToJson(this, toJsonT);

  @override
  List<Object?> get props => [data, code, message];

  @override
  String toString() => 'GeneralResponse(data: $data, code: $code, message: $message)';
}
