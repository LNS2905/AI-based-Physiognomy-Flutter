# 🏸 BADMINTON BACKEND - STRIPE PAYMENT FLOW ANALYSIS

## 📂 Project Structure

```
badminton-academy-be-Developing/
├── src/
│   ├── controllers/
│   │   ├── payment.controller.ts        // Payment endpoints (success/cancel)
│   │   └── user.controller.ts           // Recharge endpoints
│   ├── services/
│   │   ├── user.service.ts              // updateCredit(), recharge()
│   │   └── booking.service.ts           // createBooking() - deduct credits
│   ├── repositories/
│   │   ├── transaction.repository.ts    // Transaction CRUD
│   │   └── user.repository.ts           // User CRUD
│   ├── entities/
│   │   ├── transaction.ts               // Transaction model (IN/OUT)
│   │   ├── user.ts                      // User model (with credit field)
│   │   └── booking.ts                   // Booking model
│   ├── business_objects/
│   │   └── payment.ts                   // PaymentSessionRequest DTO
│   ├── utils/
│   │   └── payment/
│   │       └── stripe.ts                // Stripe utility functions
│   └── config/
│       └── environments/
│           └── environment.ts           // Stripe config
└── prisma/
    └── schema.prisma                    // Database schema
```

---

## 🗄️ DATABASE SCHEMA

### **User Table**
```prisma
model user {
  id                 Int                 @id @default(autoincrement())
  firstName          String
  lastName           String
  email              String              @unique
  phone              String
  credit             Float?              // ⭐ Credits balance
  
  // Relationships
  transactions       transaction[]
  booking            booking[]
}
```

### **Transaction Table**
```prisma
model transaction {
  id                Int      @id @default(autoincrement())
  transactionType   String   // "IN" or "OUT"
  transactionStatus Boolean
  creditAmount      Float
  stripePaymentId   String?  // ⭐ Stripe session ID
  userId            Int
  
  createAt          DateTime @default(now())
  updateAt          DateTime @updatedAt
  
  // Relationships
  user              user     @relation(fields: [userId], references: [id])
}
```

### **Booking Table**
```prisma
model booking {
  id             Int      @id @default(autoincrement())
  bookingStatus  Boolean
  classEntityId  Int
  transactionId  Int      // ⭐ Links to transaction
  userId         Int
  
  // Relationships
  user           user     @relation(fields: [userId], references: [id])
  classEntity    classEntity @relation(fields: [classEntityId], references: [id])
}
```

---

## 🔧 STRIPE UTILITY (stripe.ts)

### **StripeUtil Class**

```typescript
export class StripeUtil {
    private static readonly stripeInstance = new Stripe(config.stripe.secretKey, {
        typescript: true,
    });

    /**
     * Tạo Stripe Checkout Session
     * @param data - Line items (products to purchase)
     * @param userId - User ID for success/cancel redirect
     * @returns Stripe Checkout Session object
     */
    public static async requestSessionPayment(
        data: PaymentSessionRequest, 
        userId: number
    ): Promise<Stripe.Checkout.Session> {
        return await this.stripeInstance.checkout.sessions.create({
            line_items: data.lineItems,
            mode: data.mode, // 'payment' | 'subscription' | 'setup'
            success_url: `${config.stripe.baseUrl}/badminton/v1/payment/success?session_id={CHECKOUT_SESSION_ID}&userId=${userId}`,
            cancel_url: `${config.stripe.baseUrl}/badminton/v1/payment/cancel?userId=${userId}`
        });
    }

    /**
     * Retrieve Stripe Session by ID
     * @param sessionId - Stripe session ID
     * @returns Stripe Checkout Session details
     */
    public static async responseSessionPayment(
        sessionId: string
    ): Promise<Stripe.Response<Stripe.Checkout.Session>> {
        return await this.stripeInstance.checkout.sessions.retrieve(sessionId);
    }
}
```

**Key Points:**
- ✅ Uses Stripe Checkout Sessions (no webhook needed)
- ✅ Success URL includes `session_id` and `userId`
- ✅ Retrieve session to get payment details
- ⚠️ `requestPayment()` method exists but **NOT USED** (no backend callback)

---

## 💳 PAYMENT FLOW - TOP-UP CREDITS

### **Flow Diagram**

```
Mobile                     Backend                      Stripe
  │                           │                           │
  │ 1. POST /users/me/recharge │                          │
  ├──────────────────────────→ │                          │
  │   Body: {                  │                          │
  │     lineItems: [{          │                          │
  │       price_data: {        │                          │
  │         currency: "myr",   │                          │
  │         product_data: {    │                          │
  │           name: "100 credits" │                       │
  │         },                 │                          │
  │         unit_amount: 5000  │                          │
  │       },                   │                          │
  │       quantity: 1          │                          │
  │     }],                    │                          │
  │     mode: "payment"        │                          │
  │   }                        │                          │
  │                           │                          │
  │                           │ 2. Create Session        │
  │                           ├────────────────────────→ │
  │                           │   stripe.checkout.       │
  │                           │   sessions.create()      │
  │                           │                          │
  │                           │ 3. Session Object        │
  │                           ←────────────────────────┤ │
  │                           │   {                      │
  │                           │     id: "cs_xxx",        │
  │                           │     url: "checkout.stripe.com/..." │
  │                           │     amount_total: 5000   │
  │                           │   }                      │
  │                           │                          │
  │ 4. Return Session         │                          │
  ←──────────────────────────┤ │                          │
  │   { url: "..." }          │                          │
  │                           │                          │
  │ 5. Open WebView           │                          │
  │    (Stripe Checkout UI)   │                          │
  ├──────────────────────────────────────────────────→ │
  │                           │                          │
  │                           │                          │
  │ 6. User Completes Payment │                          │
  │                           │                          │
  │                           │ 7. Stripe Redirects      │
  │    /payment/success?      │                          │
  │    session_id=cs_xxx&     ←────────────────────────┤ │
  │    userId=123             │                          │
  │                           │                          │
  │                           │ 8. Retrieve Session      │
  │                           ├────────────────────────→ │
  │                           │   stripe.checkout.       │
  │                           │   sessions.retrieve()    │
  │                           │                          │
  │                           │ 9. Session Details       │
  │                           ←────────────────────────┤ │
  │                           │   {                      │
  │                           │     id: "cs_xxx",        │
  │                           │     amount_total: 5000,  │
  │                           │     payment_status: "paid" │
  │                           │   }                      │
  │                           │                          │
  │                           │ 10. Update Credits       │
  │                           │     user.credit += 50    │
  │                           │                          │
  │                           │ 11. Create Transaction   │
  │                           │     type: "IN"           │
  │                           │     amount: 50           │
  │                           │     stripePaymentId: "cs_xxx" │
  │                           │                          │
  │ 12. Redirect to App       │                          │
  ←──────────────────────────┤                          │
  │   "localhost:3000/success"│                          │
```

---

## 📝 CODE IMPLEMENTATION

### 1️⃣ **User Controller - Recharge Endpoint**

```typescript
// File: src/controllers/user.controller.ts

@Route("badminton/v1/users")
@controller("badminton/v1/users")
export class UserController {
    constructor(
        @inject("IUserService") private readonly userService: IUserService
    ) {}

    /**
     * Nạp tiền vào tài khoản của bản thân
     * @param data - Payment session request với line items
     * @param req - Request object chứa user email từ JWT
     * @returns Stripe Checkout Session (với URL)
     */
    @Post("/me/recharge")
    @Security("jwt") // Require authentication
    public async selfRecharge(
        @Body() data: PaymentSessionRequest,
        @Request() req: { user: UserEmail }
    ): Promise<GeneralResponse> {
        await validate(PaymentSessionRequest, data);
        return new GeneralResponse(
            SuccessCode.OPERATION_SUCCESS,
            await this.userService.recharge(data, req.user.email)
        );
    }
}
```

**Request Example:**
```json
POST /badminton/v1/users/me/recharge
Authorization: Bearer <JWT_TOKEN>

{
  "lineItems": [
    {
      "price_data": {
        "currency": "myr",
        "product_data": {
          "name": "100 Credits"
        },
        "unit_amount": 5000
      },
      "quantity": 1
    }
  ],
  "mode": "payment"
}
```

**Response:**
```json
{
  "code": "OPERATION_SUCCESS",
  "message": "Success",
  "data": {
    "id": "cs_test_a1B2c3D4e5F6...",
    "url": "https://checkout.stripe.com/c/pay/cs_test_...",
    "amount_total": 5000,
    "currency": "myr",
    "payment_status": "unpaid"
  }
}
```

---

### 2️⃣ **User Service - Recharge Logic**

```typescript
// File: src/services/user.service.ts

@injectable()
export class UserService implements IUserService {
    constructor(
        @inject("IUserRepository") private userRepository: IUserRepository
    ) {}

    /**
     * Tạo Stripe Checkout Session cho user
     * @param data - Payment session request
     * @param email - User email (from JWT)
     * @returns Stripe Checkout Session
     */
    public async recharge(
        data: PaymentSessionRequest, 
        email: string
    ): Promise<Stripe.Checkout.Session> {
        // 1. Get user by email
        const user = await this.userRepository.getByEmail(email);
        if (!user || !user.id) {
            throw new ErrorResponseV2(ErrorCode.NOT_FOUND_USER);
        }
        
        // 2. Create Stripe Checkout Session with userId in redirect URLs
        return StripeUtil.requestSessionPayment(data, user.id);
    }
}
```

---

### 3️⃣ **Payment Controller - Success/Cancel Handlers**

```typescript
// File: src/controllers/payment.controller.ts

@Route("badminton/v1/payment")
@controller("badminton/v1/payment")
export class PaymentController {
    constructor(
        @inject("IUserService") private readonly userService: IUserService
    ) {}

    /**
     * Xử lý redirect sau khi thanh toán thành công
     * @param session_id - Stripe session ID (from URL)
     * @param userId - User ID (from URL)
     * @returns Redirect 302 to success page
     */
    @Get("/success")
    public async responseSessionPaymentS(
        @Query() session_id: string,
        @Query() userId: number,
        @Res() redirect: TsoaResponse<302, void>
    ): Promise<void> {
        // Update user credits based on session
        const user = await this.userService.updateCredit(session_id, userId);
        
        // Redirect to success/failure page
        const redirectUrl = user
            ? "http://localhost:3000/success"
            : "http://localhost:3000/failed-im-so-sad";
            
        return redirect(302, undefined, { Location: redirectUrl });
    }

    /**
     * Xử lý redirect khi user hủy thanh toán
     * @param userId - User ID (from URL)
     * @returns Redirect 302 to cancel page
     */
    @Get("/cancel")
    public async responseSessionPaymentC(
        @Query() userId: number,
        @Res() redirect: TsoaResponse<302, void>
    ): Promise<void> {
        return redirect(302, undefined, { 
            Location: "http://localhost:3000/cancel" 
        });
    }
}
```

---

### 4️⃣ **User Service - Update Credit Logic**

```typescript
// File: src/services/user.service.ts

@injectable()
export class UserService implements IUserService {
    constructor(
        @inject("IUserRepository") private userRepository: IUserRepository,
        @inject("ITransactionRepository") private transactionRepository: ITransactionRepository
    ) {}

    /**
     * Cộng credits vào user sau khi payment thành công
     * @param sessionId - Stripe session ID
     * @param userId - User ID
     * @returns Updated user object
     */
    public async updateCredit(
        sessionId: string, 
        userId: number
    ): Promise<BaseUser> {
        // 1. Retrieve payment info from Stripe
        const paymentInfo = await StripeUtil.responseSessionPayment(sessionId);
        
        if (!paymentInfo || !paymentInfo.amount_total) {
            throw new ErrorResponseV2(ErrorCode.STRIPE_PAYMENT_INCOMPLETE);
        }

        // 2. Get user from database
        const user = await this.userRepository.getById(userId);
        if (!user || !user.id) {
            throw new ErrorResponseV2(ErrorCode.STRIPE_PAYMENT_INCOMPLETE);
        }

        // 3. Check if transaction already processed (prevent duplicate)
        const existingTransaction = await this.transactionRepository.getbyStripeId(
            paymentInfo.id
        );
        if (existingTransaction) {
            throw new ErrorResponseV2(ErrorCode.STRIPE_PAYMENT_COMPLETE);
        }

        // 4. Initialize credit if null
        if (!user.credit) {
            user.credit = 0;
        }

        // 5. Convert from cents to actual amount
        // Example: 5000 cents = 50 MYR = 50 credits (1:1 ratio)
        const creditAmount = paymentInfo.amount_total / 100;
        user.credit += creditAmount;

        // 6. Create transaction record (IN type)
        this.transactionRepository.create({
            transactionType: TransactionType.IN.toString(),
            transactionStatus: true,
            creditAmount: creditAmount,
            stripePaymentId: paymentInfo.id, // Store session ID
            userId: user.id
        });

        // 7. Update user credits in database
        return plainToClass(
            BaseUser, 
            await this.userRepository.update(user.id, { credit: user.credit })
        );
    }
}
```

**Key Logic:**
1. ✅ Retrieve Stripe session to get `amount_total`
2. ✅ Convert cents to credits (5000 cents → 50 credits)
3. ✅ Check duplicate using `stripePaymentId` (idempotency)
4. ✅ Create transaction record with type "IN"
5. ✅ Update user's credit balance

---

## 💸 BOOKING FLOW - DEDUCT CREDITS

### **Flow Diagram**

```
Mobile                     Backend                      Database
  │                           │                           │
  │ POST /booking/me          │                           │
  ├──────────────────────────→ │                          │
  │   Body: {                  │                          │
  │     classEntityId: 5,      │                          │
  │     amount: 20             │                          │
  │   }                        │                          │
  │                           │                          │
  │                           │ 1. Check user credits    │
  │                           ├────────────────────────→ │
  │                           │   user.credit >= 20?     │
  │                           │                          │
  │                           │ 2. Create Transaction    │
  │                           ├────────────────────────→ │
  │                           │   INSERT transaction     │
  │                           │   type: "OUT"            │
  │                           │   amount: 20             │
  │                           │                          │
  │                           │ 3. Create Booking        │
  │                           ├────────────────────────→ │
  │                           │   INSERT booking         │
  │                           │   transactionId: 123     │
  │                           │                          │
  │                           │ 4. Deduct Credits        │
  │                           ├────────────────────────→ │
  │                           │   UPDATE user            │
  │                           │   credit -= 20           │
  │                           │                          │
  │ Return booking            │                          │
  ←──────────────────────────┤                          │
```

---

### **Booking Service - Create Booking**

```typescript
// File: src/services/booking.service.ts

@injectable()
export class BookingService implements IBookingService {
    constructor(
        @inject("IBookingRepository") private bookingRepository: IBookingRepository,
        @inject("IUserRepository") private userRepository: IUserRepository,
        @inject("ITransactionRepository") private transactionRepository: ITransactionRepository,
        @inject("IClassEntityRepository") private classEntityRepository: IClassEntityRepository
    ) {}

    /**
     * Tạo booking và trừ credits của user
     * @param data - Booking data (classEntityId, amount)
     * @param email - User email (from JWT)
     * @returns Created booking
     */
    public async createBooking(
        data: CreateBookingDto, 
        email: string
    ): Promise<BaseBooking> {
        // 1. Get user by email
        const user = await this.userRepository.getByEmail(email);
        if (!user || !user.id) {
            throw new ErrorResponseV2(ErrorCode.NOT_FOUND_USER);
        }

        // 2. Check duplicate booking
        const existedClass = await this.bookingRepository.getByEmail(email);
        if (existedClass) {
            existedClass.forEach(booking => {
                if (booking.classEntityId == data.classEntityId) {
                    throw new ErrorResponseV2(ErrorCode.DUPLICATE_BOOKING);
                }
            });
        }

        // 3. Check if user has enough credits
        if (user.credit < data.amount) {
            throw new ErrorResponseV2(ErrorCode.INSUFFICIENT_CREDIT);
        }

        // 4. Validate class exists and not expired
        const classEntity = await this.classEntityRepository.getById(data.classEntityId);
        if (!classEntity || !classEntity.id) {
            throw new ErrorResponseV2(ErrorCode.NOT_FOUND_CLASS);
        }
        if (classEntity.bookingExpired < new Date()) {
            throw new ErrorResponseV2(ErrorCode.BOOKING_UNAVAILABLE);
        }

        // 5. Create transaction record (OUT type)
        const transaction = await this.transactionRepository.create({
            transactionType: TransactionType.OUT.toString(),
            transactionStatus: true,
            creditAmount: data.amount,
            userId: user.id
        });
        
        if (!transaction || !transaction.id) {
            throw new ErrorResponseV2(ErrorCode.SYSTEM_PAYMENT_INCOMPLETE);
        }

        // 6. Create booking linked to transaction
        const booking = await this.bookingRepository.create({
            bookingStatus: true,
            classEntityId: classEntity.id,
            transactionId: transaction.id,
            userId: user.id
        });
        
        if (!booking || !booking.id) {
            throw new ErrorResponseV2(ErrorCode.SYSTEM_PAYMENT_INCOMPLETE);
        }

        // 7. Deduct credits from user (no await - fire and forget)
        this.userRepository.update(user.id, { 
            credit: user.credit - data.amount 
        });

        return plainToClass(BaseBooking, booking);
    }

    /**
     * Hủy booking và hoàn lại credits
     * @param id - Booking ID
     * @returns Updated booking
     */
    public async cancelBooking(id: number): Promise<BaseBooking> {
        // 1. Get booking
        const booking = await this.bookingRepository.getById(id);
        if (!booking) {
            throw new ErrorResponseV2(ErrorCode.NOT_FOUND_BOOKING);
        }

        // 2. Get transaction
        const transaction = await this.transactionRepository.getById(
            booking.transactionId
        );
        if (!transaction) {
            throw new ErrorResponseV2(ErrorCode.NOT_FOUND_TRANST);
        }

        // 3. Get user
        const user = await this.userRepository.getById(transaction.userId);
        if (!user || !user.id) {
            throw new ErrorResponseV2(ErrorCode.NOT_FOUND_USER);
        }

        // 4. Refund credits
        user.credit += transaction.creditAmount;
        this.userRepository.update(user.id, { credit: user.credit });

        // 5. Create refund transaction (IN type)
        this.transactionRepository.create({
            transactionType: TransactionType.IN.toString(),
            transactionStatus: true,
            creditAmount: transaction.creditAmount,
            userId: user.id
        });

        // 6. Update booking status to cancelled
        return plainToClass(
            BaseBooking, 
            await this.bookingRepository.update(id, { bookingStatus: false })
        );
    }
}
```

---

## ⚙️ ENVIRONMENT CONFIGURATION

### **.env File**

```bash
# Stripe Configuration
STRIPE_PUBLISHABLE_KEY=pk_test_51RAX9V4EHf4ag09n...
STRIPE_SECRET_KEY=sk_test_51RAX9V4EHf4ag09n...

# Base URL for redirects
STRIPE_BASE_URL_LOCAL=http://localhost:3005
STRIPE_BASE_URL_PRODUCTION=https://api.yourdomain.com

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/badminton

# JWT
JWT_SECRET=your_jwt_secret

# Language
LANG=en
```

### **Environment Config (environment.ts)**

```typescript
export interface StripeConfig {
    publishableKey: string;
    secretKey: string;
    baseUrl: string;
}

const config: Config = {
    stripe: {
        publishableKey: process.env.STRIPE_PUBLISHABLE_KEY || "",
        secretKey: process.env.STRIPE_SECRET_KEY || "",
        baseUrl: environment === 'development' 
            ? process.env.STRIPE_BASE_URL_LOCAL || ""
            : process.env.STRIPE_BASE_URL_PRODUCTION || "",
    },
    // ... other configs
};
```

---

## 🔐 SECURITY CONSIDERATIONS

### ✅ **Best Practices Implemented**

1. **Idempotency Check**
   ```typescript
   const existingTransaction = await this.transactionRepository.getbyStripeId(
       paymentInfo.id
   );
   if (existingTransaction) {
       throw new ErrorResponseV2(ErrorCode.STRIPE_PAYMENT_COMPLETE);
   }
   ```
   - Prevents duplicate credit additions
   - Uses Stripe session ID as unique identifier

2. **Server-Side Validation**
   - All credit checks done on backend
   - Mobile cannot manipulate credit balance
   - JWT authentication required

3. **Transaction Atomicity**
   - Transaction record created BEFORE credit update
   - Booking linked to transaction
   - Audit trail maintained

4. **Amount Conversion**
   ```typescript
   const creditAmount = paymentInfo.amount_total / 100;
   ```
   - Stripe amounts in cents
   - Convert to actual currency/credits

### ⚠️ **Potential Issues**

1. **No Webhook Verification**
   - Currently relying on redirect URLs
   - Vulnerable if user closes browser before redirect
   - **Solution:** Add Stripe webhook handler

2. **Fire-and-Forget Updates**
   ```typescript
   // No await - could fail silently
   this.userRepository.update(user.id, { credit: user.credit - data.amount });
   ```
   - Credit deduction not awaited
   - **Solution:** Use await and transaction rollback on failure

3. **Race Conditions**
   - Multiple simultaneous bookings could cause issues
   - **Solution:** Use database transactions with row locking

---

## 📊 TRANSACTION FLOW COMPARISON

### **Credit Top-Up (IN)**
```
1. User initiates payment
2. Backend creates Stripe session
3. User completes payment on Stripe
4. Stripe redirects to success URL
5. Backend retrieves session
6. Backend adds credits
7. Transaction created (type: IN)
```

### **Booking Payment (OUT)**
```
1. User creates booking
2. Backend checks credit balance
3. Transaction created (type: OUT)
4. Booking created
5. Credits deducted
```

---

## 🎯 KEY TAKEAWAYS FOR PHYSIOGNOMY APP

### **What to Adopt:**

1. ✅ **Stripe Checkout Session Pattern**
   - Simple, no webhook complexity
   - PCI compliant (Stripe handles card details)
   - Good for one-time payments

2. ✅ **Transaction Record System**
   - Every credit change logged
   - Audit trail with `stripePaymentId`
   - Easy to track user history

3. ✅ **Idempotency Check**
   - Prevent duplicate credit additions
   - Use Stripe session ID as unique key

4. ✅ **Redirect-Based Flow**
   - Works well for mobile WebView
   - No need for complex webhook setup

### **What to Improve:**

1. ⚠️ **Add Webhook Handler** (for reliability)
   ```typescript
   @Post("/webhook")
   public async handleWebhook(
       @Body() rawBody: Buffer,
       @Header("stripe-signature") signature: string
   ) {
       const event = stripe.webhooks.constructEvent(
           rawBody,
           signature,
           webhookSecret
       );
       
       if (event.type === 'checkout.session.completed') {
           // Update credits here as backup
       }
   }
   ```

2. ⚠️ **Use Database Transactions**
   ```typescript
   await prisma.$transaction(async (tx) => {
       await tx.transaction.create({...});
       await tx.user.update({...});
   });
   ```

3. ⚠️ **Add Retry Mechanism**
   - For failed credit updates
   - Manual reconciliation endpoint

---

## 🚀 IMPLEMENTATION CHECKLIST FOR PHYSIOGNOMY

### **Phase 1: Database Setup**
- [ ] Add `credits` column to `user` table (default 5)
- [ ] Create `transactions` table
- [ ] Create `credit_packages` table (optional)

### **Phase 2: Backend Services**
- [ ] Create `StripeUtil` class
- [ ] Implement `recharge()` in UserService
- [ ] Implement `updateCredit()` in UserService
- [ ] Implement `deductCredits()` in ChatService

### **Phase 3: Controllers**
- [ ] Create PaymentController (success/cancel)
- [ ] Add recharge endpoint to UserController
- [ ] Update ChatController to check credits

### **Phase 4: Testing**
- [ ] Test top-up flow with Stripe test cards
- [ ] Test insufficient credits error
- [ ] Test duplicate transaction prevention
- [ ] Test cancel booking refund

---

## 📝 EXAMPLE REQUEST/RESPONSE

### **1. Create Recharge Session**

**Request:**
```bash
POST /badminton/v1/users/me/recharge
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "lineItems": [
    {
      "price_data": {
        "currency": "usd",
        "product_data": {
          "name": "150 Credits"
        },
        "unit_amount": 500
      },
      "quantity": 1
    }
  ],
  "mode": "payment"
}
```

**Response:**
```json
{
  "code": "OPERATION_SUCCESS",
  "message": "Success",
  "data": {
    "id": "cs_test_a1B2c3D4e5F6g7H8i9J0kLmNoPqRsTuVwXyZ",
    "object": "checkout.session",
    "amount_total": 500,
    "currency": "usd",
    "payment_status": "unpaid",
    "status": "open",
    "url": "https://checkout.stripe.com/c/pay/cs_test_a1B2c3D4..."
  }
}
```

### **2. Payment Success Callback**

**Stripe Redirects to:**
```
http://localhost:3005/badminton/v1/payment/success?session_id=cs_test_a1B2c3D4e5F6g7H8i9J0kLmNoPqRsTuVwXyZ&userId=123
```

**Backend Actions:**
1. Retrieve session: `stripe.checkout.sessions.retrieve("cs_test_...")`
2. Get amount: `5 USD = 150 credits` (based on lineItem)
3. Update user: `user.credit += 150`
4. Create transaction: `type: "IN", amount: 150`
5. Redirect to: `http://localhost:3000/success`

---

## 🔗 USEFUL LINKS

- **Stripe Checkout Sessions Docs**: https://stripe.com/docs/payments/checkout
- **Stripe Test Cards**: https://stripe.com/docs/testing
- **Stripe API Reference**: https://stripe.com/docs/api/checkout/sessions

---

**Document Version:** 1.0  
**Analyzed Date:** 2025-11-07  
**Source:** `C:\Working\Code\Badminton\badminton-academy-be-Developing`  
**Status:** ✅ Complete Analysis
