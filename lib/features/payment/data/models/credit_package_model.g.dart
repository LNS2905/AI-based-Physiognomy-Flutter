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

PaymentSessionRequest _$PaymentSessionRequestFromJson(
  Map<String, dynamic> json,
) => PaymentSessionRequest(
  lineItems: (json['lineItems'] as List<dynamic>)
      .map((e) => StripeLineItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  mode: json['mode'] as String? ?? 'payment',
);

Map<String, dynamic> _$PaymentSessionRequestToJson(
  PaymentSessionRequest instance,
) => <String, dynamic>{'lineItems': instance.lineItems, 'mode': instance.mode};

StripeLineItem _$StripeLineItemFromJson(Map<String, dynamic> json) =>
    StripeLineItem(
      priceData: StripePriceData.fromJson(
        json['priceData'] as Map<String, dynamic>,
      ),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$StripeLineItemToJson(StripeLineItem instance) =>
    <String, dynamic>{
      'priceData': instance.priceData,
      'quantity': instance.quantity,
    };

StripePriceData _$StripePriceDataFromJson(Map<String, dynamic> json) =>
    StripePriceData(
      currency: json['currency'] as String,
      productData: StripeProductData.fromJson(
        json['productData'] as Map<String, dynamic>,
      ),
      unitAmount: (json['unitAmount'] as num).toInt(),
    );

Map<String, dynamic> _$StripePriceDataToJson(StripePriceData instance) =>
    <String, dynamic>{
      'currency': instance.currency,
      'productData': instance.productData,
      'unitAmount': instance.unitAmount,
    };

StripeProductData _$StripeProductDataFromJson(Map<String, dynamic> json) =>
    StripeProductData(name: json['name'] as String);

Map<String, dynamic> _$StripeProductDataToJson(StripeProductData instance) =>
    <String, dynamic>{'name': instance.name};

PaymentSessionResponse _$PaymentSessionResponseFromJson(
  Map<String, dynamic> json,
) => PaymentSessionResponse(
  id: json['id'] as String,
  url: json['url'] as String,
  amountTotal: (json['amountTotal'] as num?)?.toInt(),
  currency: json['currency'] as String?,
);

Map<String, dynamic> _$PaymentSessionResponseToJson(
  PaymentSessionResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'amountTotal': instance.amountTotal,
  'currency': instance.currency,
};
