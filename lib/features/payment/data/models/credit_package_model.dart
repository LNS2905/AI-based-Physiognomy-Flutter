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
class PaymentSessionRequest extends Equatable {
  final List<StripeLineItem> lineItems;
  final String mode;

  const PaymentSessionRequest({
    required this.lineItems,
    this.mode = 'payment',
  });

  factory PaymentSessionRequest.fromJson(Map<String, dynamic> json) =>
      PaymentSessionRequest(
        lineItems: (json['lineItems'] as List<dynamic>)
            .map((e) => StripeLineItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        mode: json['mode'] as String? ?? 'payment',
      );

  Map<String, dynamic> toJson() => {
        'lineItems': lineItems.map((e) => e.toJson()).toList(),
        'mode': mode,
      };

  @override
  List<Object?> get props => [lineItems, mode];
}

/// Stripe Line Item Model
class StripeLineItem extends Equatable {
  final StripePriceData priceData;
  final int quantity;

  const StripeLineItem({
    required this.priceData,
    this.quantity = 1,
  });

  factory StripeLineItem.fromJson(Map<String, dynamic> json) => StripeLineItem(
        priceData: StripePriceData.fromJson(
            json['price_data'] as Map<String, dynamic>),
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      );

  Map<String, dynamic> toJson() => {
        'price_data': priceData.toJson(),
        'quantity': quantity,
      };

  @override
  List<Object?> get props => [priceData, quantity];
}

/// Stripe Price Data Model
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
      StripePriceData(
        currency: json['currency'] as String,
        productData: StripeProductData.fromJson(
            json['product_data'] as Map<String, dynamic>),
        unitAmount: (json['unit_amount'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'currency': currency,
        'product_data': productData.toJson(),
        'unit_amount': unitAmount,
      };

  @override
  List<Object?> get props => [currency, productData, unitAmount];
}

/// Stripe Product Data Model
class StripeProductData extends Equatable {
  final String name;

  const StripeProductData({required this.name});

  factory StripeProductData.fromJson(Map<String, dynamic> json) =>
      StripeProductData(name: json['name'] as String);

  Map<String, dynamic> toJson() => {'name': name};

  @override
  List<Object?> get props => [name];
}

/// Payment Session Response Model
@JsonSerializable()
class PaymentSessionResponse extends Equatable {
  final String id;
  final String? url;
  final int? amountTotal;
  final String? currency;
  final String? clientSecret;
  final int? amount;

  const PaymentSessionResponse({
    required this.id,
    this.url,
    this.amountTotal,
    this.currency,
    this.clientSecret,
    this.amount,
  });

  factory PaymentSessionResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentSessionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentSessionResponseToJson(this);

  @override
  List<Object?> get props => [id, url, amountTotal, currency, clientSecret, amount];
}
