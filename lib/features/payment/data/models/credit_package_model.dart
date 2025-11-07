import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'credit_package_model.g.dart';

/// Credit Package Model
@JsonSerializable()
class CreditPackageModel extends Equatable {
  final int id;
  final String name;
  final int credits;
  final int bonusCredits;
  final double priceUsd;
  final double priceVnd;
  final String? stripePriceId;
  final bool isActive;
  final int displayOrder;

  const CreditPackageModel({
    required this.id,
    required this.name,
    required this.credits,
    required this.bonusCredits,
    required this.priceUsd,
    required this.priceVnd,
    this.stripePriceId,
    required this.isActive,
    required this.displayOrder,
  });

  /// Total credits including bonus
  int get totalCredits => credits + bonusCredits;

  /// Check if package has bonus
  bool get hasBonus => bonusCredits > 0;

  /// Get price formatted as USD
  String get priceUsdFormatted => '\$${priceUsd.toStringAsFixed(2)}';

  /// Get price formatted as VND
  String get priceVndFormatted => '${priceVnd.toStringAsFixed(0)} VND';

  /// Check if this is the most popular package
  bool get isPopular => name == 'Popular';

  factory CreditPackageModel.fromJson(Map<String, dynamic> json) =>
      _$CreditPackageModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreditPackageModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        credits,
        bonusCredits,
        priceUsd,
        priceVnd,
        stripePriceId,
        isActive,
        displayOrder,
      ];
}

/// Payment Session Request Model
@JsonSerializable()
class PaymentSessionRequest extends Equatable {
  final List<StripeLineItem> lineItems;
  final String mode;

  const PaymentSessionRequest({
    required this.lineItems,
    this.mode = 'payment',
  });

  factory PaymentSessionRequest.fromJson(Map<String, dynamic> json) =>
      _$PaymentSessionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentSessionRequestToJson(this);

  @override
  List<Object?> get props => [lineItems, mode];
}

/// Stripe Line Item Model
@JsonSerializable()
class StripeLineItem extends Equatable {
  final StripePriceData priceData;
  final int quantity;

  const StripeLineItem({
    required this.priceData,
    this.quantity = 1,
  });

  factory StripeLineItem.fromJson(Map<String, dynamic> json) =>
      _$StripeLineItemFromJson(json);

  Map<String, dynamic> toJson() => _$StripeLineItemToJson(this);

  @override
  List<Object?> get props => [priceData, quantity];
}

/// Stripe Price Data Model
@JsonSerializable()
class StripePriceData extends Equatable {
  final String currency;
  final StripeProductData productData;
  final int unitAmount;

  const StripePriceData({
    required this.currency,
    required this.productData,
    required this.unitAmount,
  });

  factory StripePriceData.fromJson(Map<String, dynamic> json) =>
      _$StripePriceDataFromJson(json);

  Map<String, dynamic> toJson() => _$StripePriceDataToJson(this);

  @override
  List<Object?> get props => [currency, productData, unitAmount];
}

/// Stripe Product Data Model
@JsonSerializable()
class StripeProductData extends Equatable {
  final String name;

  const StripeProductData({required this.name});

  factory StripeProductData.fromJson(Map<String, dynamic> json) =>
      _$StripeProductDataFromJson(json);

  Map<String, dynamic> toJson() => _$StripeProductDataToJson(this);

  @override
  List<Object?> get props => [name];
}

/// Payment Session Response Model
@JsonSerializable()
class PaymentSessionResponse extends Equatable {
  final String id;
  final String url;
  final int? amountTotal;
  final String? currency;

  const PaymentSessionResponse({
    required this.id,
    required this.url,
    this.amountTotal,
    this.currency,
  });

  factory PaymentSessionResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentSessionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentSessionResponseToJson(this);

  @override
  List<Object?> get props => [id, url, amountTotal, currency];
}
