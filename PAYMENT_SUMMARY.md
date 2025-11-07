# 💳 STRIPE PAYMENT - TÓM TẮT NHANH
## AI-based Physiognomy App

---

## 🎯 MÔ HÌNH KINH DOANH

### **Tính phí chỉ cho AI Chatbot**

```
✅ MIỄN PHÍ:
  • Phân tích khuôn mặt
  • Phân tích chỉ tay  
  • Phân tích tử vi

💰 TRẢ PHÍ:
  • AI Chatbot: 1 credit = 1 tin nhắn
```

---

## 💎 GÓI CREDITS

**Tỷ giá:** 1 USD = 25 credits

| Gói | Credits | Giá | Tặng thêm | Tổng | Trung bình/message |
|-----|---------|-----|-----------|------|-------------------|
| **Starter** | 50 | $2 (50K VND) | - | **50** | $0.04 |
| **Basic** | 125 | $5 (125K VND) | +25 | **150** | $0.033 |
| **Popular** ⭐ | 275 | $10 (250K VND) | +75 | **350** | $0.029 |
| **Premium** | 625 | $20 (500K VND) | +125 | **750** | $0.027 |

### 🎁 User mới: **5 credits miễn phí** (5 tin nhắn thử)

---

## 🏗️ KI KIẾN TRÚC BACKEND

### Database Changes

```sql
-- Update users table
ALTER TABLE users 
ADD COLUMN credits INTEGER DEFAULT 5;  -- 5 free credits

-- Insert credit packages
INSERT INTO credit_packages (name, credits, bonus_credits, price_usd, price_vnd) VALUES
('Starter', 50, 0, 2, 50000),
('Basic', 125, 25, 5, 125000),
('Popular', 275, 75, 10, 250000),
('Premium', 625, 125, 20, 500000);
```

### API Endpoints

```typescript
// NEW endpoints
GET  /payment/packages          // Get credit packages
POST /payment/create-checkout   // Create Stripe checkout
POST /payment/webhook           // Stripe webhook
GET  /payment/transactions/me   // User transactions

// UPDATE existing endpoint
POST /chat/send-message
  → Before sending: Check credits >= 1
  → Deduct 1 credit
  → Send to AI
  → If AI fails: Refund 1 credit
```

---

## 📱 FRONTEND IMPLEMENTATION

### New Files to Create

```
lib/features/payment/
├── data/
│   ├── models/
│   │   ├── credit_package_model.dart      ✨ NEW
│   │   ├── transaction_model.dart         ✨ NEW
│   │   └── checkout_session_model.dart    ✨ NEW
│   └── repositories/
│       └── payment_repository.dart        ✨ NEW
├── presentation/
│   ├── providers/
│   │   └── payment_provider.dart          ✨ NEW
│   ├── pages/
│   │   ├── credit_packages_page.dart      ✨ NEW
│   │   └── transaction_history_page.dart  ✨ NEW
│   └── widgets/
│       ├── credit_display_widget.dart     ✨ NEW
│       ├── package_card_widget.dart       ✨ NEW
│       └── insufficient_credits_dialog.dart ✨ NEW
```

### Update Existing Files

```dart
// 1. Update user_model.dart
@JsonSerializable()
class UserModel {
  final int? credits;  // ✨ ADD THIS
  // ... existing fields
}

// 2. Update chat page - wrap send button
CreditGuardWrapper(
  requiredCredits: 1,
  onProceed: () => _sendMessage(),
  child: IconButton(icon: Icon(Icons.send)),
)

// 3. Update profile page - add credit card
Card(
  child: Row(
    children: [
      Text('Credits: ${user.credits}'),
      ElevatedButton(
        onPressed: () => context.push('/payment/packages'),
        child: Text('Nạp'),
      ),
    ],
  ),
)
```

### Dependencies

```yaml
# pubspec.yaml - ADD THESE
dependencies:
  flutter_stripe: ^10.2.0
  flutter_inappwebview: ^6.0.0
  flutter_dotenv: ^5.1.0
```

---

## 🔄 USER FLOW

### 1️⃣ Top-up Credits

```
User Profile
    ↓
View Credits: 5
    ↓
Click "Nạp"
    ↓
Select Package (e.g., $5 = 150 credits)
    ↓
Stripe Checkout (WebView)
    ↓
Payment Success
    ↓
Credits Updated: 155
```

### 2️⃣ Use AI Chat

```
AI Chat Page
    ↓
Type message
    ↓
Click Send
    ↓
Check: credits >= 1?
    ├─ YES → Deduct 1 credit → Send to AI → Show response
    └─ NO  → Show "Insufficient Credits" dialog
```

### 3️⃣ Free Analysis Features

```
Face/Palm/Tử Vi Analysis
    ↓
No credit check ✅
    ↓
Process analysis
    ↓
Show results (FREE)
```

---

## ⏱️ TIMELINE (8 WEEKS)

| Week | Tasks | Owner |
|------|-------|-------|
| **1-2** | Backend: Database, API, CreditService | Backend Dev |
| **3** | Stripe integration & webhooks | Backend Dev |
| **4-5** | Frontend: Models, providers, UI | Frontend Dev |
| **6** | Integration: Chat credit check | Full Stack |
| **7** | Testing & bug fixes | QA + Dev |
| **8** | Deployment & monitoring | DevOps |

---

## 💰 PRICING STRATEGY

### Why This Pricing Works

1. **Low entry barrier**: $2 for 50 messages (dễ quyết định mua)
2. **Incentive for bulk**: 20-27% bonus cho gói lớn
3. **Free trial**: 5 credits = 5 messages thử
4. **FREE core features**: Analysis không tính phí → user có giá trị trước khi trả tiền

### Revenue Projection

**Assumptions:**
- 10,000 users after 3 months
- 15% conversion rate (1,500 paying users)
- Average purchase: $7 (giữa Basic và Popular)

**Monthly Revenue:** 1,500 × $7 = **$10,500** (~260M VND)

---

## ✅ QUICK START CHECKLIST

### Backend (Week 1-3)
- [ ] Create migration: Add `credits` column to users
- [ ] Create `credit_packages` table
- [ ] Create `transactions` table
- [ ] Implement `CreditService.deductCredits()`
- [ ] Implement `PaymentService.createCheckoutSession()`
- [ ] Set up Stripe webhook endpoint
- [ ] Update `ChatService` to check credits

### Frontend (Week 4-5)
- [ ] Add `flutter_stripe` to pubspec.yaml
- [ ] Create `CreditPackageModel`
- [ ] Create `PaymentRepository`
- [ ] Create `PaymentProvider`
- [ ] Build `CreditPackagesPage`
- [ ] Build `CreditDisplayWidget`
- [ ] Update `UserModel` with credits field
- [ ] Wrap chat send button in `CreditGuardWrapper`

### Integration (Week 6)
- [ ] Test full payment flow
- [ ] Test credit deduction on chat
- [ ] Test insufficient credits dialog
- [ ] Test WebView checkout
- [ ] Test webhook credit update

### Deployment (Week 7-8)
- [ ] Configure Stripe production keys
- [ ] Set up webhook in Stripe dashboard
- [ ] Deploy backend
- [ ] Deploy frontend (APK/IPA)
- [ ] Monitor first transactions

---

## 🔒 SECURITY NOTES

### ✅ Best Practices Implemented

1. **Deduct BEFORE AI call**: Ngăn chặn abuse nếu AI call fails
2. **Auto refund on failure**: User không mất credits nếu AI lỗi
3. **Webhook signature verification**: Verify Stripe webhook authenticity
4. **Transaction logging**: Mọi credit change đều được log
5. **Idempotency**: Prevent duplicate credit additions

### 🚫 Security Risks Mitigated

- ❌ Race condition: Use database transactions
- ❌ Credit manipulation: Server-side validation only
- ❌ Payment bypass: No client-side credit updates
- ❌ Webhook spoofing: Verify Stripe signature

---

## 📊 METRICS TO TRACK

### Business Metrics
- [ ] Conversion rate (free → paid)
- [ ] Average credits purchased per user
- [ ] Monthly recurring revenue
- [ ] Churn rate
- [ ] Most popular package

### Technical Metrics
- [ ] Payment success rate (target: >95%)
- [ ] Webhook delivery success (target: 100%)
- [ ] Credit balance accuracy (audit daily)
- [ ] AI chat message latency
- [ ] Chat failure rate → refund rate

---

## 🎓 IMPLEMENTATION TIPS

### Backend Tips

```typescript
// Tip 1: Use transactions for credit operations
async deductCredits(userId: number, amount: number) {
  return await this.db.transaction(async (trx) => {
    const user = await trx.users.findById(userId).forUpdate();
    
    if (user.credits < amount) {
      throw new InsufficientCreditsException();
    }
    
    user.credits -= amount;
    await trx.users.save(user);
    
    await trx.transactions.create({
      userId,
      type: 'CREDIT_OUT',
      amount,
      balanceAfter: user.credits,
    });
    
    return user;
  });
}

// Tip 2: Idempotent webhook handling
async handleCheckoutCompleted(session: Stripe.CheckoutSession) {
  const existingTx = await this.transactions.findOne({
    stripeSessionId: session.id,
  });
  
  if (existingTx) {
    console.log('Already processed session:', session.id);
    return;
  }
  
  // Process payment...
}
```

### Frontend Tips

```dart
// Tip 1: Show remaining credits after each message
class ChatProvider {
  Future<void> sendMessage(String message) async {
    final response = await _chatRepository.sendMessage(message);
    
    // Update credits in UI immediately
    _authProvider.updateCredits(response.remainingCredits);
    
    notifyListeners();
  }
}

// Tip 2: Optimistic UI for better UX
Future<void> _sendMessage() async {
  final tempMessage = Message(text: _controller.text, isUser: true);
  setState(() => _messages.add(tempMessage));
  
  try {
    final response = await _chatProvider.sendMessage(tempMessage.text);
    // Update with real response
  } catch (e) {
    // Revert on error
    setState(() => _messages.remove(tempMessage));
  }
}
```

---

## 🆘 TROUBLESHOOTING

### Common Issues

#### 1. Payment success but credits not added
**Cause:** Webhook không fire hoặc bị miss  
**Solution:** 
- Check webhook logs in Stripe dashboard
- Implement manual reconciliation API
- Add retry mechanism

#### 2. Credits deducted but AI call failed
**Cause:** AI timeout or error  
**Solution:**
- Auto refund implemented in `ChatService`
- Log for investigation
- Alert if refund rate > 5%

#### 3. User complains "not enough credits" but has balance
**Cause:** Race condition or caching issue  
**Solution:**
- Refresh user data from API
- Check transaction logs
- Investigate race conditions

#### 4. Stripe checkout not opening in WebView
**Cause:** Deep link configuration  
**Solution:**
- Verify AndroidManifest.xml intent filters
- Verify iOS URL scheme in Info.plist
- Test on both platforms

---

## 📞 SUPPORT & ROLLBACK PLAN

### If Something Goes Wrong

#### Rollback Plan
1. **Disable payment page**: Hide "Nạp" button in profile
2. **Make chat free temporarily**: Comment out credit check
3. **Refund affected users**: Use Stripe dashboard
4. **Fix issue**: Deploy hotfix
5. **Re-enable**: Gradual rollout (10% → 50% → 100%)

#### Emergency Contacts
- **Stripe Support**: support@stripe.com
- **On-call Dev**: [Your contact]
- **Database Admin**: [Your contact]

---

## 🚀 LAUNCH PLAN

### Phase 1: Soft Launch (Week 8)
- Enable for 10% of users
- Monitor for 3 days
- Collect feedback

### Phase 2: Beta Launch (Week 9)
- Enable for 50% of users
- Run promotion: "First purchase 50% bonus"
- Monitor conversion rate

### Phase 3: Full Launch (Week 10)
- Enable for 100% of users
- Push notification: "Gửi tin nhắn không giới hạn với credits"
- Monitor revenue

---

## 💡 FUTURE ENHANCEMENTS (Phase 2)

### After 3 Months
1. **Subscription model**: $10/month = unlimited chat
2. **Referral program**: Mời bạn = cả 2 được 25 credits
3. **Daily free message**: 1 message miễn phí mỗi ngày
4. **Premium analysis**: $1 = detailed PDF report
5. **Credit expiration**: Credits expire after 1 year

---

## 📄 DOCUMENT REFERENCES

- **Full Plan**: `STRIPE_PAYMENT_IMPLEMENTATION_PLAN.md` (70+ pages)
- **Badminton App Reference**: `C:\Working\Code\Badminton\badminton-academy-mobile-main\`
- **Stripe Docs**: https://stripe.com/docs/payments/checkout
- **Flutter Stripe**: https://pub.dev/packages/flutter_stripe

---

**Version:** 1.0  
**Last Updated:** 2025-11-07  
**Status:** Ready for Implementation ✅
