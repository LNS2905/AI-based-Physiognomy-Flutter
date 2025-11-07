# STRIPE PAYMENT IMPLEMENTATION PLAN
## AI-based Physiognomy Flutter App

> **Mục tiêu:** Tích hợp hệ thống thanh toán Stripe credit-based vào app Physiognomy, dựa trên kiến trúc từ Badminton Academy App.

---

## 📋 TABLE OF CONTENTS

1. [Business Requirements](#1-business-requirements)
2. [System Architecture](#2-system-architecture)
3. [Backend Implementation](#3-backend-implementation)
4. [Frontend Implementation](#4-frontend-implementation)
5. [Testing Strategy](#5-testing-strategy)
6. [Deployment Plan](#6-deployment-plan)
7. [Timeline & Resources](#7-timeline--resources)

---

## 1. BUSINESS REQUIREMENTS

### 1.1 Use Cases

#### **UC1: Credit-Based Chat System**
- User mua credits để sử dụng AI Chatbot
- **Tính phí:**
  - **AI Chat (per message)**: 1 credit
  - **Face Analysis**: FREE (không tính phí)
  - **Palm Analysis**: FREE (không tính phí)
  - **Tử Vi Analysis**: FREE (không tính phí)

#### **UC2: Credit Top-up Flow**
- User xem số credits hiện tại trong Profile
- Chọn package credits để mua
- Thanh toán qua Stripe Checkout Session
- Credits được cộng tự động sau khi thanh toán thành công

#### **UC3: Transaction History**
- User xem lịch sử giao dịch (nạp/tiêu credits)
- Filter theo ngày, loại giao dịch
- Export transaction reports (optional)

### 1.2 Credit Packages

**Tỷ giá:** 1 USD = 25 credits (trung bình 20-30)

| Package | Credits | Giá (USD) | Giá (VND) | Bonus | Total Credits |
|---------|---------|-----------|-----------|-------|---------------|
| Starter | 50 | $2 | 50,000 | - | 50 |
| Basic | 125 | $5 | 125,000 | +25 (20%) | 150 |
| Popular | 275 | $10 | 250,000 | +75 (27%) | 350 |
| Premium | 625 | $20 | 500,000 | +125 (20%) | 750 |

**Chi phí trung bình:**
- $2 = ~50 tin nhắn chat
- $5 = ~150 tin nhắn chat
- $10 = ~350 tin nhắn chat
- $20 = ~750 tin nhắn chat

### 1.3 Free Trial
- User mới được tặng **5 free credits**
- Cho phép trải nghiệm chatbot (5 tin nhắn) trước khi mua

---

## 2. SYSTEM ARCHITECTURE

### 2.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    FLUTTER MOBILE APP                        │
├─────────────────────────────────────────────────────────────┤
│  Payment UI → PaymentProvider → PaymentRepository           │
│       ↓              ↓                    ↓                  │
│  WebView ←────── Stripe SDK ────────→ Backend API           │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                    BACKEND (Node.js/TypeScript)             │
├─────────────────────────────────────────────────────────────┤
│  Payment Controller → Payment Service → Stripe API          │
│         ↓                    ↓                               │
│  User Service ←────→ Database (PostgreSQL)                  │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Payment Flow Diagram

```
┌──────────┐                                              ┌──────────┐
│  User    │                                              │  Stripe  │
└────┬─────┘                                              └────┬─────┘
     │                                                          │
     │ 1. View Credits & Top-up                                │
     ├──────────→ Profile Page                                 │
     │                                                          │
     │ 2. Select Package                                       │
     ├──────────→ Package Selection Dialog                     │
     │                                                          │
     │ 3. Create Checkout Session                              │
     ├──────────→ Backend API                                  │
     │            POST /payment/create-checkout                │
     │                  │                                       │
     │                  │ 4. Create Session                    │
     │                  ├───────────────────────────────────→ │
     │                  │                                       │
     │                  │ 5. Return Session URL                │
     │                  ←───────────────────────────────────┐ │
     │                                                          │
     │ 6. Open Checkout Page                                   │
     ├──────────→ WebView (Stripe Checkout)                    │
     │                  │                                       │
     │                  │ 7. Process Payment                   │
     │                  ├───────────────────────────────────→ │
     │                  │                                       │
     │                  │ 8. Webhook: payment_intent.succeeded │
     │                  ←───────────────────────────────────┐ │
     │                  │                                       │
     │                  │ 9. Update Credits in DB              │
     │                  ├──────────→ Database                   │
     │                  │                                       │
     │ 10. Redirect to Success URL                             │
     │    /payment/success?session_id=xxx                      │
     ←──────────┤                                               │
     │                                                          │
     │ 11. Refresh User Info                                   │
     ├──────────→ GET /auth/me                                 │
     │                                                          │
     │ 12. Show Updated Credits                                │
     ←──────────┐                                               │
```

---

## 3. BACKEND IMPLEMENTATION

### 3.1 Database Schema Changes

#### **Table: users (Update existing)**
```sql
ALTER TABLE users 
ADD COLUMN credits INTEGER DEFAULT 5,  -- Free trial: 5 credits
ADD COLUMN total_spent DECIMAL(10,2) DEFAULT 0.00,
ADD COLUMN is_premium BOOLEAN DEFAULT FALSE,
ADD COLUMN premium_until TIMESTAMP NULL;

CREATE INDEX idx_users_credits ON users(credits);
```

#### **Table: transactions (New)**
```sql
CREATE TABLE transactions (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  transaction_type VARCHAR(20) NOT NULL CHECK (transaction_type IN ('CREDIT_IN', 'CREDIT_OUT')),
  amount INTEGER NOT NULL,  -- Credits amount
  balance_after INTEGER NOT NULL,  -- Credits balance after transaction
  description TEXT,
  stripe_payment_id VARCHAR(255),  -- Stripe payment intent ID
  stripe_session_id VARCHAR(255),  -- Stripe checkout session ID
  status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'COMPLETED', 'FAILED', 'REFUNDED')),
  metadata JSONB,  -- Store additional info (package info, analysis type, etc.)
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_transactions_user_id ON transactions(user_id);
CREATE INDEX idx_transactions_stripe_payment_id ON transactions(stripe_payment_id);
CREATE INDEX idx_transactions_created_at ON transactions(created_at DESC);
```

#### **Table: credit_packages (New)**
```sql
CREATE TABLE credit_packages (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  credits INTEGER NOT NULL,
  bonus_credits INTEGER DEFAULT 0,
  price_vnd DECIMAL(10,2) NOT NULL,
  price_usd DECIMAL(10,2) NOT NULL,
  stripe_price_id VARCHAR(255),  -- Stripe Price ID
  is_active BOOLEAN DEFAULT TRUE,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO credit_packages (name, credits, bonus_credits, price_vnd, price_usd, display_order) VALUES
('Starter', 50, 0, 50000, 2, 1),
('Basic', 125, 25, 125000, 5, 2),
('Popular', 275, 75, 250000, 10, 3),
('Premium', 625, 125, 500000, 20, 4);
```

### 3.2 API Endpoints

#### **POST /payment/create-checkout**
```typescript
// Request
{
  packageId: number;
  currency?: 'vnd' | 'usd'; // Default: 'vnd'
}

// Response
{
  code: 'OPERATION_SUCCESS',
  message: 'Checkout session created',
  data: {
    sessionId: string;
    url: string;
    amountTotal: number;
    currency: string;
    expiresAt: number;
  }
}
```

#### **POST /payment/webhook**
```typescript
// Stripe webhook endpoint
// Handles: checkout.session.completed, payment_intent.succeeded
```

#### **GET /payment/packages**
```typescript
// Response
{
  code: 'OPERATION_SUCCESS',
  data: Array<{
    id: number;
    name: string;
    credits: number;
    bonusCredits: number;
    priceVnd: number;
    priceUsd: number;
    totalCredits: number; // credits + bonusCredits
    displayOrder: number;
  }>
}
```

#### **GET /payment/transactions/me**
```typescript
// Query params
{
  pageIndex?: number;
  pageSize?: number;
  startDate?: string;
  endDate?: string;
  type?: 'CREDIT_IN' | 'CREDIT_OUT';
}

// Response (Paginated)
{
  code: 'OPERATION_SUCCESS',
  data: {
    items: Array<Transaction>,
    total: number,
    pageIndex: number,
    pageSize: number,
    totalPages: number
  }
}
```

#### **GET /users/me** (Update existing)
```typescript
// Add credits field to response
{
  code: 'OPERATION_SUCCESS',
  data: {
    ...existingUserFields,
    credits: number,
    totalSpent: number,
    isPremium: boolean,
    premiumUntil?: string
  }
}
```

#### **POST /chat/send-message** (Update existing - add credit check)
```typescript
// Request
{
  message: string;
  conversationId?: number;
}

// Before sending to AI:
// 1. Check user has credits >= 1
// 2. If yes, deduct 1 credit
// 3. Send message to AI
// 4. Save transaction record

// Response
{
  code: 'OPERATION_SUCCESS',
  data: {
    message: string;
    remainingCredits: number;
  }
}
```

### 3.3 Backend Services

#### **PaymentService** (New)
```typescript
class PaymentService {
  // Create Stripe Checkout Session
  async createCheckoutSession(userId: number, packageId: number, currency: string): Promise<CheckoutSession>;
  
  // Handle webhook events
  async handleWebhook(event: Stripe.Event): Promise<void>;
  
  // Process successful payment
  async processSuccessfulPayment(sessionId: string): Promise<void>;
  
  // Get user transactions
  async getUserTransactions(userId: number, filters: TransactionFilters): Promise<PaginatedTransactions>;
  
  // Get credit packages
  async getCreditPackages(): Promise<CreditPackage[]>;
}
```

#### **CreditService** (New)
```typescript
class CreditService {
  // Add credits to user (after purchase)
  async addCredits(userId: number, amount: number, stripeSessionId: string): Promise<User>;
  
  // Deduct credits (for analysis)
  async deductCredits(userId: number, amount: number, analysisType: string, analysisId?: number): Promise<User>;
  
  // Check if user has enough credits
  async hasEnoughCredits(userId: number, amount: number): Promise<boolean>;
  
  // Get user credit balance
  async getCreditBalance(userId: number): Promise<number>;
  
  // Create transaction record
  async createTransaction(data: CreateTransactionDto): Promise<Transaction>;
}
```

#### **Update ChatService Only**

**ChatService** - Add credit check before sending message
```typescript
async sendMessage(userId: number, message: string, conversationId?: number) {
  // 1. Check credits
  const user = await this.userService.findById(userId);
  if (user.credits < 1) {
    throw new InsufficientCreditsException(
      'Not enough credits. Please purchase more credits to continue chatting.'
    );
  }
  
  // 2. Deduct 1 credit BEFORE calling AI (prevent abuse)
  await this.creditService.deductCredits(userId, 1, 'chat');
  
  try {
    // 3. Send message to AI
    const aiResponse = await this.aiService.chat(message, conversationId);
    
    // 4. Save conversation
    const savedMessage = await this.conversationRepository.save({
      userId,
      conversationId,
      userMessage: message,
      aiResponse,
      creditsUsed: 1,
    });
    
    return {
      message: aiResponse,
      remainingCredits: user.credits - 1,
      messageId: savedMessage.id,
    };
  } catch (error) {
    // If AI call fails, refund the credit
    await this.creditService.addCredits(userId, 1, 'refund_failed_message');
    throw error;
  }
}
```

**FacialAnalysisService, PalmAnalysisService, TuViService**
```typescript
// NO CREDIT CHECK - These services remain FREE
async saveFacialAnalysis(userId: number, data: FacialAnalysisDto) {
  // Just save analysis without credit deduction
  return await this.repository.save(data);
}
```

### 3.4 Environment Variables

```bash
# .env
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
STRIPE_SUCCESS_URL=myapp://payment/success
STRIPE_CANCEL_URL=myapp://payment/cancel
```

---

## 4. FRONTEND IMPLEMENTATION

### 4.1 Project Structure

```
lib/
├── features/
│   ├── payment/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── credit_package_model.dart
│   │   │   │   ├── credit_package_model.g.dart
│   │   │   │   ├── transaction_model.dart
│   │   │   │   ├── transaction_model.g.dart
│   │   │   │   ├── checkout_session_model.dart
│   │   │   │   └── checkout_session_model.g.dart
│   │   │   ├── repositories/
│   │   │   │   └── payment_repository.dart
│   │   │   └── services/
│   │   │       └── stripe_service.dart
│   │   ├── domain/
│   │   │   └── enums/
│   │   │       └── transaction_type.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── payment_provider.dart
│   │       ├── pages/
│   │       │   ├── credit_packages_page.dart
│   │       │   └── transaction_history_page.dart
│   │       └── widgets/
│   │           ├── credit_display_widget.dart
│   │           ├── package_card_widget.dart
│   │           ├── transaction_list_item.dart
│   │           ├── insufficient_credits_dialog.dart
│   │           └── payment_webview.dart
│   └── profile/
│       └── presentation/
│           └── widgets/
│               └── credit_balance_card.dart  # New widget
└── core/
    ├── widgets/
    │   └── credit_guard_wrapper.dart  # Wrapper to check credits before action
    └── utils/
        └── credit_utils.dart
```

### 4.2 Dependencies Update

**pubspec.yaml**
```yaml
dependencies:
  # Existing dependencies...
  
  # Stripe & Payment
  flutter_stripe: ^10.2.0
  webview_flutter: ^4.7.0
  flutter_inappwebview: ^6.0.0
  
  # Environment config
  flutter_dotenv: ^5.1.0
```

### 4.3 Models

#### **CreditPackageModel**
```dart
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'credit_package_model.g.dart';

@JsonSerializable()
class CreditPackageModel extends Equatable {
  final int id;
  final String name;
  final int credits;
  
  @JsonKey(name: 'bonus_credits')
  final int bonusCredits;
  
  @JsonKey(name: 'price_vnd')
  final double priceVnd;
  
  @JsonKey(name: 'price_usd')
  final double priceUsd;
  
  @JsonKey(name: 'display_order')
  final int displayOrder;

  const CreditPackageModel({
    required this.id,
    required this.name,
    required this.credits,
    required this.bonusCredits,
    required this.priceVnd,
    required this.priceUsd,
    required this.displayOrder,
  });

  int get totalCredits => credits + bonusCredits;
  
  String get displayPrice => 'VND ${priceVnd.toStringAsFixed(0)}';
  
  String get bonusText => bonusCredits > 0 
      ? '+${bonusCredits} bonus' 
      : '';

  factory CreditPackageModel.fromJson(Map<String, dynamic> json) =>
      _$CreditPackageModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreditPackageModelToJson(this);

  @override
  List<Object?> get props => [id, name, credits, bonusCredits, priceVnd, priceUsd, displayOrder];
}
```

#### **TransactionModel**
```dart
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'transaction_model.g.dart';

enum TransactionType {
  @JsonValue('CREDIT_IN')
  creditIn,
  
  @JsonValue('CREDIT_OUT')
  creditOut,
}

enum TransactionStatus {
  @JsonValue('PENDING')
  pending,
  
  @JsonValue('COMPLETED')
  completed,
  
  @JsonValue('FAILED')
  failed,
  
  @JsonValue('REFUNDED')
  refunded,
}

@JsonSerializable()
class TransactionModel extends Equatable {
  final int id;
  
  @JsonKey(name: 'user_id')
  final int userId;
  
  @JsonKey(name: 'transaction_type')
  final TransactionType transactionType;
  
  final int amount;
  
  @JsonKey(name: 'balance_after')
  final int balanceAfter;
  
  final String? description;
  
  @JsonKey(name: 'stripe_payment_id')
  final String? stripePaymentId;
  
  @JsonKey(name: 'stripe_session_id')
  final String? stripeSessionId;
  
  final TransactionStatus status;
  
  final Map<String, dynamic>? metadata;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.transactionType,
    required this.amount,
    required this.balanceAfter,
    this.description,
    this.stripePaymentId,
    this.stripeSessionId,
    required this.status,
    this.metadata,
    required this.createdAt,
  });

  bool get isCreditIn => transactionType == TransactionType.creditIn;
  bool get isCompleted => status == TransactionStatus.completed;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  @override
  List<Object?> get props => [
    id, userId, transactionType, amount, balanceAfter, 
    description, stripePaymentId, status, createdAt
  ];
}
```

#### **CheckoutSessionModel**
```dart
import 'package:json_annotation/json_annotation.dart';

part 'checkout_session_model.g.dart';

@JsonSerializable()
class CheckoutSessionModel {
  @JsonKey(name: 'sessionId')
  final String sessionId;
  
  final String url;
  
  @JsonKey(name: 'amountTotal')
  final int amountTotal;
  
  final String currency;
  
  @JsonKey(name: 'expiresAt')
  final int expiresAt;

  const CheckoutSessionModel({
    required this.sessionId,
    required this.url,
    required this.amountTotal,
    required this.currency,
    required this.expiresAt,
  });

  factory CheckoutSessionModel.fromJson(Map<String, dynamic> json) =>
      _$CheckoutSessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$CheckoutSessionModelToJson(this);
}
```

#### **Update UserModel**
```dart
// Add to existing user_model.dart

@JsonSerializable()
class UserModel extends Equatable {
  // ... existing fields
  
  final int? credits;  // Add this
  
  @JsonKey(name: 'total_spent')
  final double? totalSpent;  // Add this
  
  @JsonKey(name: 'is_premium')
  final bool? isPremium;  // Add this
  
  @JsonKey(name: 'premium_until')
  final DateTime? premiumUntil;  // Add this

  const UserModel({
    // ... existing params
    this.credits,
    this.totalSpent,
    this.isPremium,
    this.premiumUntil,
  });
  
  // ... rest of implementation
}
```

### 4.4 Repository

#### **PaymentRepository**
```dart
import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../models/credit_package_model.dart';
import '../models/transaction_model.dart';
import '../models/checkout_session_model.dart';

class PaymentRepository {
  final ApiClient _apiClient;

  PaymentRepository(this._apiClient);

  /// Get all credit packages
  Future<ApiResult<List<CreditPackageModel>>> getCreditPackages() async {
    return _apiClient.get<List<CreditPackageModel>>(
      '/payment/packages',
      parser: (data) => (data as List)
          .map((item) => CreditPackageModel.fromJson(item))
          .toList(),
    );
  }

  /// Create checkout session
  Future<ApiResult<CheckoutSessionModel>> createCheckoutSession({
    required int packageId,
    String currency = 'vnd',
  }) async {
    return _apiClient.post<CheckoutSessionModel>(
      '/payment/create-checkout',
      data: {
        'packageId': packageId,
        'currency': currency,
      },
      parser: (data) => CheckoutSessionModel.fromJson(data),
    );
  }

  /// Get user transactions
  Future<ApiResult<List<TransactionModel>>> getTransactions({
    int pageIndex = 1,
    int pageSize = 20,
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
  }) async {
    final queryParams = <String, dynamic>{
      'pageIndex': pageIndex,
      'pageSize': pageSize,
    };

    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }
    if (type != null) {
      queryParams['type'] = type == TransactionType.creditIn 
          ? 'CREDIT_IN' 
          : 'CREDIT_OUT';
    }

    return _apiClient.get<List<TransactionModel>>(
      '/payment/transactions/me',
      queryParameters: queryParams,
      parser: (data) {
        final items = data['items'] as List;
        return items.map((item) => TransactionModel.fromJson(item)).toList();
      },
    );
  }

  /// Verify payment success (optional, for additional verification)
  Future<ApiResult<bool>> verifyPayment(String sessionId) async {
    return _apiClient.get<bool>(
      '/payment/verify/$sessionId',
      parser: (data) => data['verified'] as bool,
    );
  }
}
```

### 4.5 Provider

#### **PaymentProvider**
```dart
import 'package:flutter/material.dart';
import '../../../core/providers/base_provider.dart';
import '../data/repositories/payment_repository.dart';
import '../data/models/credit_package_model.dart';
import '../data/models/transaction_model.dart';
import '../data/models/checkout_session_model.dart';

class PaymentProvider extends BaseProvider {
  final PaymentRepository _repository;

  PaymentProvider(this._repository);

  List<CreditPackageModel> _packages = [];
  List<TransactionModel> _transactions = [];
  CheckoutSessionModel? _currentCheckoutSession;

  List<CreditPackageModel> get packages => _packages;
  List<TransactionModel> get transactions => _transactions;
  CheckoutSessionModel? get currentCheckoutSession => _currentCheckoutSession;

  /// Load credit packages
  Future<void> loadCreditPackages() async {
    final result = await executeApiOperation(
      () => _repository.getCreditPackages(),
      operationName: 'loadCreditPackages',
    );

    if (result != null) {
      _packages = result;
      notifyListeners();
    }
  }

  /// Create checkout session and return URL
  Future<CheckoutSessionModel?> createCheckoutSession({
    required int packageId,
    String currency = 'vnd',
  }) async {
    final result = await executeApiOperation(
      () => _repository.createCheckoutSession(
        packageId: packageId,
        currency: currency,
      ),
      operationName: 'createCheckoutSession',
    );

    if (result != null) {
      _currentCheckoutSession = result;
      notifyListeners();
      return result;
    }

    return null;
  }

  /// Load transaction history
  Future<void> loadTransactions({
    int pageIndex = 1,
    int pageSize = 20,
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
  }) async {
    final result = await executeApiOperation(
      () => _repository.getTransactions(
        pageIndex: pageIndex,
        pageSize: pageSize,
        startDate: startDate,
        endDate: endDate,
        type: type,
      ),
      operationName: 'loadTransactions',
    );

    if (result != null) {
      _transactions = result;
      notifyListeners();
    }
  }

  /// Verify payment success
  Future<bool> verifyPayment(String sessionId) async {
    final result = await executeApiOperation(
      () => _repository.verifyPayment(sessionId),
      operationName: 'verifyPayment',
      showLoading: false,
    );

    return result ?? false;
  }

  /// Clear current checkout session
  void clearCheckoutSession() {
    _currentCheckoutSession = null;
    notifyListeners();
  }
}
```

### 4.6 UI Components

#### **CreditDisplayWidget** (Show in AppBar/Profile)
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/auth/presentation/providers/enhanced_auth_provider.dart';

class CreditDisplayWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final bool showAddButton;

  const CreditDisplayWidget({
    Key? key,
    this.onTap,
    this.showAddButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EnhancedAuthProvider>(
      builder: (context, authProvider, child) {
        final credits = authProvider.currentUser?.credits ?? 0;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.stars,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  credits.toString(),
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (showAddButton) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.add_circle,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
```

#### **PackageCardWidget**
```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../data/models/credit_package_model.dart';

class PackageCardWidget extends StatelessWidget {
  final CreditPackageModel package;
  final VoidCallback onSelect;
  final bool isPopular;

  const PackageCardWidget({
    Key? key,
    required this.package,
    required this.onSelect,
    this.isPopular = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPopular ? AppColors.primary : AppColors.border,
            width: isPopular ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Popular badge
            if (isPopular)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'PHỔ BIẾN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Package name
                  Text(
                    package.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isPopular ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Credits info
                  Row(
                    children: [
                      Icon(Icons.stars, color: AppColors.accent, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        '${package.totalCredits} Credits',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  if (package.bonusCredits > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '(${package.credits} + ${package.bonusCredits} bonus)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        package.displayPrice,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: onSelect,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPopular 
                              ? AppColors.primary 
                              : AppColors.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Mua ngay'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### **InsufficientCreditsDialog**
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class InsufficientCreditsDialog extends StatelessWidget {
  final int requiredCredits;
  final int currentCredits;

  const InsufficientCreditsDialog({
    Key? key,
    required this.requiredCredits,
    required this.currentCredits,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shortage = requiredCredits - currentCredits;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 28),
          const SizedBox(width: 12),
          const Text('Không đủ Credits'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bạn cần $requiredCredits credits để sử dụng tính năng này.',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hiện tại',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '$currentCredits credits',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.arrow_forward, color: AppColors.textSecondary),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Cần thêm',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '$shortage credits',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Để sau'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.push('/payment/packages');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Nạp Credits'),
        ),
      ],
    );
  }
}
```

#### **PaymentWebView**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../core/theme/app_colors.dart';

class PaymentWebView extends StatefulWidget {
  final String url;
  final String successPath;
  final String cancelPath;

  const PaymentWebView({
    Key? key,
    required this.url,
    this.successPath = '/payment/success',
    this.cancelPath = '/payment/cancel',
  }) : super(key: key);

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  bool _isLoading = true;
  double _loadingProgress = 0.0;
  InAppWebViewController? _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Thanh toán'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onLoadStart: (controller, url) {
              setState(() => _isLoading = true);
            },
            onLoadStop: (controller, url) async {
              setState(() => _isLoading = false);

              if (url != null) {
                final uri = url.toString();
                
                // Check for success/cancel paths
                if (uri.contains(widget.successPath)) {
                  final sessionId = Uri.parse(uri).queryParameters['session_id'];
                  Navigator.of(context).pop({'success': true, 'sessionId': sessionId});
                } else if (uri.contains(widget.cancelPath)) {
                  Navigator.of(context).pop({'success': false});
                }
              }
            },
            onProgressChanged: (controller, progress) {
              setState(() => _loadingProgress = progress / 100);
            },
            initialSettings: InAppWebViewSettings(
              useShouldOverrideUrlLoading: true,
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
            ),
          ),

          // Loading indicator
          if (_isLoading)
            LinearProgressIndicator(
              value: _loadingProgress,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
        ],
      ),
    );
  }
}
```

### 4.7 Pages

#### **CreditPackagesPage**
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../auth/presentation/providers/enhanced_auth_provider.dart';
import '../providers/payment_provider.dart';
import '../widgets/package_card_widget.dart';
import '../widgets/credit_display_widget.dart';
import '../widgets/payment_webview.dart';

class CreditPackagesPage extends StatefulWidget {
  const CreditPackagesPage({Key? key}) : super(key: key);

  @override
  State<CreditPackagesPage> createState() => _CreditPackagesPageState();
}

class _CreditPackagesPageState extends State<CreditPackagesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PaymentProvider>().loadCreditPackages();
    });
  }

  Future<void> _handlePackageSelection(int packageId) async {
    final paymentProvider = context.read<PaymentProvider>();
    final authProvider = context.read<EnhancedAuthProvider>();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: LoadingIndicator()),
    );

    // Create checkout session
    final checkoutSession = await paymentProvider.createCheckoutSession(
      packageId: packageId,
    );

    // Dismiss loading
    if (mounted) Navigator.of(context).pop();

    if (checkoutSession != null) {
      // Open payment webview
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PaymentWebView(
            url: checkoutSession.url,
            successPath: '/payment/success',
            cancelPath: '/payment/cancel',
          ),
          fullscreenDialog: true,
        ),
      );

      if (result != null && result['success'] == true) {
        // Payment successful
        _showSuccessDialog();
        
        // Refresh user info to get updated credits
        await authProvider.refreshCurrentUser();
      }
    } else {
      // Show error
      _showErrorDialog('Không thể tạo phiên thanh toán. Vui lòng thử lại.');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 28),
            const SizedBox(width: 12),
            const Text('Thanh toán thành công!'),
          ],
        ),
        content: const Text(
          'Credits đã được cộng vào tài khoản của bạn.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop(); // Go back to profile
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.error, color: AppColors.error, size: 28),
            const SizedBox(width: 12),
            const Text('Lỗi'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nạp Credits'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: CreditDisplayWidget(
                showAddButton: false,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, child) {
          if (paymentProvider.isLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (paymentProvider.packages.isEmpty) {
            return const Center(
              child: Text('Không có gói credits nào.'),
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chọn gói Credits',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mua credits để sử dụng các tính năng phân tích',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Package list
              ...paymentProvider.packages.map((package) {
                final isPopular = package.name == 'Popular';
                return PackageCardWidget(
                  package: package,
                  isPopular: isPopular,
                  onSelect: () => _handlePackageSelection(package.id),
                );
              }).toList(),

              // Usage info
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: AppColors.primary),
                            const SizedBox(width: 8),
                            const Text(
                              'Sử dụng Credits',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildUsageItem('AI Chat (mỗi tin nhắn)', '1 credit'),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: AppColors.success, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Các tính năng phân tích hoàn toàn MIỄN PHÍ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 26),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• Phân tích khuôn mặt', 
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              Text('• Phân tích chỉ tay', 
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              Text('• Phân tích tử vi', 
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUsageItem(String feature, String cost) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(feature),
          Text(
            cost,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
```

#### **TransactionHistoryPage**
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../providers/payment_provider.dart';
import '../../data/models/transaction_model.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  TransactionType? _selectedType;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PaymentProvider>().loadTransactions();
    });
  }

  Future<void> _handleRefresh() async {
    await context.read<PaymentProvider>().loadTransactions(
      type: _selectedType,
    );
  }

  void _filterByType(TransactionType? type) {
    setState(() => _selectedType = type);
    context.read<PaymentProvider>().loadTransactions(type: type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lịch sử giao dịch'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<TransactionType?>(
            icon: const Icon(Icons.filter_list),
            onSelected: _filterByType,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('Tất cả'),
              ),
              const PopupMenuItem(
                value: TransactionType.creditIn,
                child: Text('Nạp credits'),
              ),
              const PopupMenuItem(
                value: TransactionType.creditOut,
                child: Text('Sử dụng credits'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, child) {
          if (paymentProvider.isLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (paymentProvider.transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có giao dịch nào',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: paymentProvider.transactions.length,
              itemBuilder: (context, index) {
                final transaction = paymentProvider.transactions[index];
                return _buildTransactionItem(transaction);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final isIn = transaction.isCreditIn;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isIn
              ? AppColors.success.withOpacity(0.1)
              : AppColors.error.withOpacity(0.1),
          child: Icon(
            isIn ? Icons.add : Icons.remove,
            color: isIn ? AppColors.success : AppColors.error,
          ),
        ),
        title: Text(
          transaction.description ?? 'Giao dịch',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          dateFormat.format(transaction.createdAt),
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isIn ? '+' : '-'}${transaction.amount}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isIn ? AppColors.success : AppColors.error,
              ),
            ),
            Text(
              'Còn: ${transaction.balanceAfter}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 4.8 Credit Guard Wrapper

**credit_guard_wrapper.dart** - Wrapper để check credits trước khi thực hiện action

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/presentation/providers/enhanced_auth_provider.dart';
import '../../features/payment/presentation/widgets/insufficient_credits_dialog.dart';

class CreditGuardWrapper extends StatelessWidget {
  final int requiredCredits;
  final Widget child;
  final VoidCallback onProceed;

  const CreditGuardWrapper({
    Key? key,
    required this.requiredCredits,
    required this.child,
    required this.onProceed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _checkAndProceed(context),
      child: child,
    );
  }

  void _checkAndProceed(BuildContext context) {
    final authProvider = context.read<EnhancedAuthProvider>();
    final currentCredits = authProvider.currentUser?.credits ?? 0;

    if (currentCredits >= requiredCredits) {
      onProceed();
    } else {
      showDialog(
        context: context,
        builder: (context) => InsufficientCreditsDialog(
          requiredCredits: requiredCredits,
          currentCredits: currentCredits,
        ),
      );
    }
  }
}
```

**Usage Example:**
```dart
// In chat page - check before sending message
CreditGuardWrapper(
  requiredCredits: 1,
  onProceed: () => _sendMessage(),
  child: IconButton(
    icon: Icon(Icons.send),
    onPressed: null, // CreditGuardWrapper handles tap
  ),
)

// Face/Palm/Tử Vi analysis - NO CREDIT CHECK needed (FREE)
ElevatedButton(
  onPressed: () => _startFaceScan(),
  child: Text('Phân tích khuôn mặt - MIỄN PHÍ'),
)
```

### 4.9 Update Profile Page

Add credit balance card to Profile page:

```dart
// In profile_page.dart, add to _buildProfileContent():

Column(
  children: [
    // Existing profile header
    const ProfileHeader(),
    
    // NEW: Credit Balance Card
    Consumer<EnhancedAuthProvider>(
      builder: (context, authProvider, child) {
        final credits = authProvider.currentUser?.credits ?? 0;
        
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Credits của bạn',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        credits.toString(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => context.push('/payment/packages'),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Nạp'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
    
    // Add to menu items
    ListTile(
      leading: Icon(Icons.receipt_long, color: AppColors.primary),
      title: const Text('Lịch sử giao dịch'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/payment/transactions'),
    ),
    
    // Existing profile stats and menu...
  ],
)
```

### 4.10 Routing Configuration

**Update go_router config:**

```dart
// In your router configuration
GoRoute(
  path: '/payment/packages',
  builder: (context, state) => const CreditPackagesPage(),
),
GoRoute(
  path: '/payment/transactions',
  builder: (context, state) => const TransactionHistoryPage(),
),
```

### 4.11 Stripe Initialization

**Create stripe_service.dart:**

```dart
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StripeService {
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
    
    Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
    Stripe.merchantIdentifier = 'merchant.ai.physiognomy';
    Stripe.urlScheme = 'aiphysiognomy';
    
    await Stripe.instance.applySettings();
  }
}
```

**Update main.dart:**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Stripe
  await StripeService.initialize();
  
  // ... existing initialization
  
  runApp(const MyApp());
}
```

**Create .env file:**

```bash
STRIPE_PUBLISHABLE_KEY=pk_test_your_key_here
```

---

## 5. TESTING STRATEGY

### 5.1 Backend Testing

#### **Unit Tests**
```typescript
describe('CreditService', () => {
  it('should add credits correctly', async () => {
    const user = await creditService.addCredits(userId, 100, sessionId);
    expect(user.credits).toBe(150); // 50 initial + 100
  });

  it('should throw error when deducting more credits than available', async () => {
    await expect(
      creditService.deductCredits(userId, 100, 'face')
    ).rejects.toThrow(InsufficientCreditsException);
  });
});

describe('PaymentService', () => {
  it('should create checkout session', async () => {
    const session = await paymentService.createCheckoutSession(userId, packageId, 'vnd');
    expect(session.url).toBeDefined();
  });

  it('should handle webhook correctly', async () => {
    const event = createMockWebhookEvent('checkout.session.completed');
    await paymentService.handleWebhook(event);
    // Verify credits were added
  });
});
```

#### **Integration Tests**
- Test full payment flow with Stripe test mode
- Test webhook handling
- Test concurrent credit transactions
- Test transaction rollback on failure

### 5.2 Frontend Testing

#### **Widget Tests**
```dart
testWidgets('CreditDisplayWidget shows correct credits', (tester) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<EnhancedAuthProvider>(
      create: (_) => mockAuthProvider,
      child: MaterialApp(home: CreditDisplayWidget()),
    ),
  );

  expect(find.text('100'), findsOneWidget);
});

testWidgets('InsufficientCreditsDialog shows shortage', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: InsufficientCreditsDialog(
        requiredCredits: 50,
        currentCredits: 30,
      ),
    ),
  );

  expect(find.text('20 credits'), findsOneWidget); // Shortage
});
```

#### **Integration Tests**
- Test complete top-up flow
- Test WebView payment handling
- Test credit deduction on analysis
- Test transaction history loading

### 5.3 Manual Testing Checklist

#### **Payment Flow**
- [ ] User can view credit packages
- [ ] Checkout session creates successfully
- [ ] WebView opens Stripe checkout
- [ ] Payment with test card succeeds
- [ ] Credits update after successful payment
- [ ] Payment cancellation works
- [ ] Multiple payments in sequence
- [ ] Network error handling

#### **Credit Usage**
- [ ] Credits deducted on AI chat (1 credit per message)
- [ ] Face analysis remains FREE (no credit check)
- [ ] Palm analysis remains FREE (no credit check)
- [ ] Tử vi analysis remains FREE (no credit check)
- [ ] Insufficient credits dialog appears when chatting
- [ ] Chat blocked when no credits
- [ ] Concurrent chat requests handled properly
- [ ] Credit refund on AI failure

#### **Transaction History**
- [ ] Transactions display correctly
- [ ] Filter by type works
- [ ] Date range filter works
- [ ] Pull to refresh works
- [ ] Pagination works (if implemented)

#### **Edge Cases**
- [ ] New user gets 5 free credits
- [ ] Credits display updates in real-time after chat
- [ ] Offline chat attempt shows error
- [ ] Session expiration during payment
- [ ] Webhook failure recovery
- [ ] AI timeout/failure refunds credit
- [ ] Race condition: multiple messages sent simultaneously

---

## 6. DEPLOYMENT PLAN

### 6.1 Backend Deployment Steps

1. **Prepare Environment**
```bash
# Production environment variables
STRIPE_SECRET_KEY=sk_live_...
STRIPE_PUBLISHABLE_KEY=pk_live_...
STRIPE_WEBHOOK_SECRET=whsec_live_...
STRIPE_SUCCESS_URL=aiphysiognomy://payment/success
STRIPE_CANCEL_URL=aiphysiognomy://payment/cancel
```

2. **Database Migration**
```bash
# Run migration scripts
npm run migration:run

# Seed credit packages
npm run seed:credit-packages
```

3. **Configure Stripe Dashboard**
- Create products and prices for each package
- Set up webhook endpoint: `https://api.yourapp.com/payment/webhook`
- Subscribe to events:
  - `checkout.session.completed`
  - `payment_intent.succeeded`
  - `payment_intent.payment_failed`

4. **Deploy Backend**
```bash
# Build
npm run build

# Deploy to production
npm run deploy:prod

# Verify webhook endpoint
curl https://api.yourapp.com/payment/webhook -v
```

5. **Test Webhook**
```bash
# Use Stripe CLI
stripe listen --forward-to https://api.yourapp.com/payment/webhook
stripe trigger checkout.session.completed
```

### 6.2 Frontend Deployment Steps

1. **Update Environment**
```bash
# .env
STRIPE_PUBLISHABLE_KEY=pk_live_...
```

2. **Build App**
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

3. **Configure Deep Links**

**Android (android/app/src/main/AndroidManifest.xml):**
```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data
    android:scheme="aiphysiognomy"
    android:host="payment" />
</intent-filter>
```

**iOS (ios/Runner/Info.plist):**
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>aiphysiognomy</string>
    </array>
  </dict>
</array>
```

4. **Submit to Stores**
- Update app description to mention in-app purchases
- Add payment screenshots
- Follow store guidelines for payment features

### 6.3 Rollout Strategy

#### **Phase 1: Beta Testing (1 week)**
- Release to 100 beta testers
- Monitor payment success rate
- Collect feedback on UX
- Fix critical bugs

#### **Phase 2: Soft Launch (2 weeks)**
- Release to 20% of users
- Monitor key metrics:
  - Payment success rate
  - Average transaction value
  - Credit usage patterns
  - Support ticket volume

#### **Phase 3: Full Launch**
- Roll out to 100% of users
- Announce via:
  - Push notification
  - In-app banner
  - Email/SMS campaign

### 6.4 Monitoring & Alerts

**Key Metrics to Monitor:**
- Payment success rate (target: >95%)
- Webhook delivery success (target: 100%)
- Credit balance accuracy
- Transaction processing time
- Error rates by type

**Set up alerts for:**
- Payment failure spike (>5% in 1 hour)
- Webhook delivery failure
- Credit balance mismatch
- High latency (>3s for checkout creation)

---

## 7. TIMELINE & RESOURCES

### 7.1 Development Timeline

| Phase | Tasks | Duration | Owner |
|-------|-------|----------|-------|
| **Phase 1: Backend Foundation** | | **2 weeks** | |
| Week 1 | - Database schema design<br>- Create tables and migrations<br>- Seed credit packages | 5 days | Backend Dev |
| Week 2 | - Implement CreditService<br>- Implement PaymentService<br>- API endpoints<br>- Unit tests | 5 days | Backend Dev |
| **Phase 2: Stripe Integration** | | **1 week** | |
| Week 3 | - Configure Stripe<br>- Implement webhook handler<br>- Test with Stripe test mode | 5 days | Backend Dev |
| **Phase 3: Frontend Core** | | **2 weeks** | |
| Week 4 | - Create models<br>- Payment repository<br>- Payment provider<br>- Unit tests | 5 days | Frontend Dev |
| Week 5 | - UI components<br>- Credit packages page<br>- Transaction history page<br>- WebView integration | 5 days | Frontend Dev |
| **Phase 4: Integration** | | **1 week** | |
| Week 6 | - Integrate credit checks in analysis<br>- Update profile page<br>- End-to-end testing | 5 days | Full Stack |
| **Phase 5: Testing & Polish** | | **1 week** | |
| Week 7 | - Integration testing<br>- Bug fixes<br>- Performance optimization<br>- Documentation | 5 days | QA + Dev |
| **Phase 6: Deployment** | | **1 week** | |
| Week 8 | - Beta deployment<br>- Production deployment<br>- Monitoring setup | 5 days | DevOps + Dev |

**Total Duration: 8 weeks**

### 7.2 Resource Requirements

#### **Development Team**
- **1x Backend Developer** (full-time, 6 weeks)
- **1x Frontend Developer** (full-time, 5 weeks)
- **1x QA Engineer** (full-time, 2 weeks)
- **1x DevOps Engineer** (part-time, 1 week)
- **1x Project Manager** (part-time, 8 weeks)

#### **External Services**
- **Stripe Account** (standard fees: 2.9% + $0.30 per transaction)
- **Cloud Infrastructure** (for backend hosting)
- **Monitoring Tools** (e.g., Sentry, DataDog)

### 7.3 Cost Estimation

#### **Development Costs**
| Role | Rate ($/hr) | Hours | Total |
|------|-------------|-------|-------|
| Backend Developer | $50 | 240 | $12,000 |
| Frontend Developer | $50 | 200 | $10,000 |
| QA Engineer | $40 | 80 | $3,200 |
| DevOps Engineer | $60 | 40 | $2,400 |
| Project Manager | $70 | 80 | $5,600 |
| **TOTAL** | | | **$33,200** |

#### **Operational Costs (Monthly)**
- Stripe fees: ~3% of revenue
- Cloud hosting: $100-500
- Monitoring: $50-200

---

## 8. RISKS & MITIGATION

### 8.1 Technical Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Payment failures | High | Medium | - Implement retry logic<br>- Clear error messages<br>- Support contact |
| Webhook delivery issues | High | Low | - Implement idempotency<br>- Manual reconciliation tool<br>- Monitoring alerts |
| Credit balance inconsistency | Critical | Low | - Transaction-based updates<br>- Audit logs<br>- Reconciliation cron job |
| Performance degradation | Medium | Medium | - Optimize queries<br>- Add caching<br>- Load testing |
| Security vulnerabilities | Critical | Low | - Webhook signature verification<br>- API rate limiting<br>- Regular security audits |

### 8.2 Business Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Low adoption rate | High | Medium | - Free trial credits<br>- Attractive package pricing<br>- Marketing campaign |
| User complaints about pricing | Medium | Medium | - Competitive pricing research<br>- Clear value communication<br>- Referral bonuses |
| Payment disputes/chargebacks | Medium | Low | - Clear terms of service<br>- Usage tracking<br>- Responsive support |
| Regulatory compliance | High | Low | - Legal review<br>- Privacy policy update<br>- GDPR compliance |

---

## 9. SUCCESS METRICS

### 9.1 KPIs to Track

#### **Revenue Metrics**
- Monthly Recurring Revenue (MRR)
- Average Revenue Per User (ARPU)
- Customer Lifetime Value (CLV)
- Conversion rate (free to paid)

**Targets:**
- MRR: $10,000 by Month 3
- ARPU: $5-10
- Conversion rate: >15%

#### **Engagement Metrics**
- Daily Active Users (DAU) with credits
- Credits spent per user
- Most popular features (by credit usage)
- Repeat purchase rate

**Targets:**
- 30% of users with >0 credits
- Average 50 credits spent per active user/week
- 40% repeat purchase rate

#### **Technical Metrics**
- Payment success rate: >95%
- Webhook delivery success: 100%
- API response time: <500ms p95
- Error rate: <1%

### 9.2 Analytics Implementation

**Track Events:**
```dart
// Analytics service
class PaymentAnalytics {
  static void trackPackageViewed(String packageName) {
    analytics.logEvent('package_viewed', parameters: {'package': packageName});
  }

  static void trackCheckoutStarted(String packageName, double price) {
    analytics.logEvent('checkout_started', parameters: {
      'package': packageName,
      'price': price,
    });
  }

  static void trackPaymentSuccess(String packageName, double price) {
    analytics.logEvent('payment_success', parameters: {
      'package': packageName,
      'price': price,
      'payment_method': 'stripe',
    });
  }

  static void trackCreditUsed(String feature, int credits) {
    analytics.logEvent('credit_used', parameters: {
      'feature': feature,
      'credits': credits,
    });
  }
}
```

---

## 10. POST-LAUNCH ROADMAP

### 10.1 Phase 2 Features (3 months after launch)

1. **Subscription Model**
   - Monthly/yearly subscriptions
   - Unlimited analysis for subscribers
   - Subscriber-only features

2. **Referral Program**
   - Give 50 credits for each referral
   - Referrer gets 25 credits

3. **Credit Expiration**
   - Credits expire after 1 year
   - Reminder notifications

4. **Premium Features**
   - Detailed analysis reports (PDF export)
   - Historical trend analysis
   - Priority support

### 10.2 Phase 3 Features (6 months after launch)

1. **Gift Cards**
   - Purchase credits as gifts
   - Redeem gift codes

2. **Promotional Campaigns**
   - Bonus credits on first purchase
   - Holiday specials
   - Bundle deals

3. **Analytics Dashboard**
   - User spending patterns
   - Revenue forecasting
   - Cohort analysis

---

## 11. SUPPORT & DOCUMENTATION

### 11.1 User Documentation

**FAQ Topics:**
- How to purchase credits?
- What happens if payment fails?
- Credit refund policy
- Security of payment information
- Credit usage breakdown

### 11.2 Support Channels

- **In-app chat**: For payment issues
- **Email**: support@yourapp.com
- **Phone**: For urgent payment disputes
- **Help center**: Step-by-step guides with screenshots

### 11.3 Refund Policy

```
REFUND POLICY

1. Unused credits can be refunded within 7 days of purchase
2. Credits already spent cannot be refunded
3. Contact support with receipt for refund request
4. Refunds processed within 5-7 business days
```

---

## CONCLUSION

Kế hoạch này cung cấp roadmap chi tiết để implement Stripe payment system vào AI-based Physiognomy Flutter app. Với timeline 8 tuần và budget ~$33K, bạn có thể build một hệ thống payment robust và scalable.

**Key Takeaways:**
- ✅ Credit-based chatbot: 1 credit = 1 message AI
- ✅ FREE analysis features: Face/Palm/Tử Vi không tính phí
- ✅ Affordable pricing: $2 = 50 messages, $10 = 350 messages
- ✅ 5 free credits cho user mới (5 tin nhắn thử nghiệm)
- ✅ Stripe Checkout Session đơn giản và secure
- ✅ Auto refund nếu AI call fails
- ✅ Clean architecture giúp maintain và scale dễ dàng

**Next Steps:**
1. Review và approve plan này
2. Set up Stripe account và configure test mode
3. Kick off Phase 1 (Backend Foundation)
4. Weekly progress reviews với stakeholders

---

**Document Version:** 1.0  
**Last Updated:** 2025-11-07  
**Author:** AI Development Team  
**Status:** Draft - Awaiting Approval
