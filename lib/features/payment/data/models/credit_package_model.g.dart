// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_package_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreditPackageModel _$CreditPackageModelFromJson(Map<String, dynamic> json) =>
    CreditPackageModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      credits: (json['credits'] as num).toInt(),
      bonusCredits: (json['bonusCredits'] as num).toInt(),
      priceUsd: (json['priceUsd'] as num).toDouble(),
      priceVnd: (json['priceVnd'] as num).toDouble(),
      stripePriceId: json['stripePriceId'] as String?,
      isActive: json['isActive'] as bool,
      displayOrder: (json['displayOrder'] as num).toInt(),
    );

Map<String, dynamic> _$CreditPackageModelToJson(CreditPackageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'credits': instance.credits,
      'bonusCredits': instance.bonusCredits,
      'priceUsd': instance.priceUsd,
      'priceVnd': instance.priceVnd,
      'stripePriceId': instance.stripePriceId,
      'isActive': instance.isActive,
      'displayOrder': instance.displayOrder,
    };

PaymentSessionResponse _$PaymentSessionResponseFromJson(
  Map<String, dynamic> json,
) => PaymentSessionResponse(
  id: json['id'] as String,
  url: json['url'] as String?,
  amountTotal: (json['amountTotal'] as num?)?.toInt(),
  currency: json['currency'] as String?,
  clientSecret: json['clientSecret'] as String?,
  amount: (json['amount'] as num?)?.toInt(),
);

Map<String, dynamic> _$PaymentSessionResponseToJson(
  PaymentSessionResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'amountTotal': instance.amountTotal,
  'currency': instance.currency,
  'clientSecret': instance.clientSecret,
  'amount': instance.amount,
};
