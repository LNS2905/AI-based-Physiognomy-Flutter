import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'auth_models.dart'; // Import for Gender enum

part 'user_model.g.dart';

/// Helper function to convert id from JSON (can be int or String)
String _idFromJson(dynamic value) {
  // Debug: Converting ID from JSON
  if (value is int) {
    return value.toString();
  } else if (value is String) {
    return value;
  } else if (value == null) {
    throw ArgumentError('ID must be int or String, got Null');
  } else {
    throw ArgumentError('ID must be int or String, got ${value.runtimeType}');
  }
}

/// Helper function to convert id to JSON
dynamic _idToJson(String id) => id;

/// Helper function to convert age from JSON (can be int or double)
double _ageFromJson(dynamic value) {
  if (value is int) {
    return value.toDouble();
  } else if (value is double) {
    return value;
  } else if (value is String) {
    return double.tryParse(value) ?? 0.0;
  } else {
    return 0.0;
  }
}

/// Helper function to convert age to JSON
dynamic _ageToJson(double age) => age;

/// User data model
@JsonSerializable()
class UserModel extends Equatable {
  @JsonKey(fromJson: _idFromJson, toJson: _idToJson)
  final String id;
  final String? username;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  @JsonKey(fromJson: _ageFromJson, toJson: _ageToJson)
  final double age;
  final Gender gender;
  final String? avatar;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.age,
    required this.gender,
    this.avatar,
    this.createdAt,
    this.updatedAt,
  });

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Get full name
  String get fullName => '$firstName $lastName';

  /// Get display name
  String get displayName => fullName.isNotEmpty ? fullName : email;

  /// Copy with method
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    double? age,
    Gender? gender,
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        firstName,
        lastName,
        phone,
        age,
        gender,
        avatar,
        createdAt,
        updatedAt,
      ];
}
