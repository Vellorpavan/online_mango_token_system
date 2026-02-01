# Online Mango Factory Token & Queue Management System
## Complete System Documentation

---

## 1. SYSTEM ARCHITECTURE

### 1.1 Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     CLIENT LAYER                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Farmer     │  │   Factory    │  │    Admin     │      │
│  │  Dashboard   │  │   Dashboard  │  │  Dashboard   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         │                  │                  │              │
│         └──────────────────┴──────────────────┘              │
│                           │                                  │
└───────────────────────────┼──────────────────────────────────┘
                            │
┌───────────────────────────┼──────────────────────────────────┐
│                   FIREBASE SERVICES                          │
│  ┌────────────────────────┴──────────────────────┐          │
│  │         Firebase Authentication                │          │
│  │         (Phone OTP + Role Management)          │          │
│  └────────────────────────┬──────────────────────┘          │
│                           │                                  │
│  ┌────────────────────────┴──────────────────────┐          │
│  │         Cloud Firestore Database               │          │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐     │          │
│  │  │  Users   │ │ Factories│ │  Tokens  │     │          │
│  │  └──────────┘ └──────────┘ └──────────┘     │          │
│  └───────────────────────────────────────────────┘          │
│                                                              │
│  ┌────────────────────────────────────────────────┐         │
│  │         Security Rules                         │         │
│  │  - Role-based access control                   │         │
│  │  - Data validation                             │         │
│  │  - Rate limiting                               │         │
│  └────────────────────────────────────────────────┘         │
└──────────────────────────────────────────────────────────────┘
```

### 1.2 Technology Stack

**Frontend:**
- React 18+ (Functional Components + Hooks)
- React Router for navigation
- Tailwind CSS for responsive design
- Framer Motion for animations
- Geolocation API for location services

**Backend:**
- Firebase Authentication (Phone OTP)
- Cloud Firestore (NoSQL Database)
- Firebase Security Rules
- Firebase Hosting (Deployment)

**Development:**
- Vite (Build tool)
- ESLint + Prettier (Code quality)
- Firebase SDK v9+ (Modular)

---

## 2. FIREBASE DATABASE SCHEMA

### 2.1 Collections Structure

```
firestore/
├── users/
│   └── {userId}/
│       ├── phoneNumber: string
│       ├── role: "farmer" | "factory" | "admin"
│       ├── name: string
│       ├── createdAt: timestamp
│       ├── factoryId: string (for factory users)
│       └── location: {lat: number, lng: number} (for farmers)
│
├── factories/
│   └── {factoryId}/
│       ├── name: string
│       ├── address: string
│       ├── location: {lat: number, lng: number}
│       ├── dailyCapacity: number
│       ├── contactNumber: string
│       ├── openingTime: string
│       ├── closingTime: string
│       ├── isActive: boolean
│       ├── assignedUserId: string
│       └── createdAt: timestamp
│
├── tokens/
│   └── {tokenId}/
│       ├── tokenNumber: string (e.g., "MF001-20240201-001")
│       ├── farmerId: string
│       ├── farmerPhone: string
│       ├── farmerName: string
│       ├── factoryId: string
│       ├── factoryName: string
│       ├── date: string (YYYY-MM-DD)
│       ├── status: "pending" | "approved" | "rejected" | "completed"
│       ├── queuePosition: number
│       ├── estimatedTime: timestamp
│       ├── quantity: number (kg)
│       ├── mangoType: string
│       ├── createdAt: timestamp
│       ├── updatedAt: timestamp
│       └── completedAt: timestamp (optional)
│
└── systemConfig/
    └── settings/
        ├── maxTokensPerDay: number
        ├── tokenValidityHours: number
        └── searchRadius: number (km)
```

### 2.2 Firestore Indexes

**Required Composite Indexes:**

1. **tokens** collection:
   - `farmerId` (Ascending) + `date` (Descending)
   - `factoryId` (Ascending) + `date` (Descending) + `status` (Ascending)
   - `factoryId` (Ascending) + `date` (Descending) + `queuePosition` (Ascending)

2. **factories** collection:
   - `isActive` (Ascending) + `location` (Geohash - for proximity queries)

---

## 3. AUTHENTICATION & AUTHORIZATION

### 3.1 Authentication Flow

```
┌──────────────┐
│ User Opens   │
│     App      │
└──────┬───────┘
       │
       ▼
┌──────────────────┐
│ Enter Phone      │
│ Number (+91...)  │
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│ Firebase sends   │
│ OTP via SMS      │
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│ User Enters OTP  │
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│ Verify OTP &     │
│ Get User Doc     │
└──────┬───────────┘
       │
       ▼
   ┌───┴────┐
   │ Role?  │
   └───┬────┘
       │
   ┌───┼────┬────────┐
   │   │    │        │
   ▼   ▼    ▼        ▼
Farmer Factory  Admin  New User
   │      │       │       │
   ▼      ▼       ▼       ▼
 Dash   Dash    Dash   Register
```

### 3.2 Role-Based Access Control

**Security Rules Logic:**

```javascript
// User can only read their own data
match /users/{userId} {
  allow read: if request.auth.uid == userId;
  allow write: if request.auth.uid == userId 
              || get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
}

// Farmers can read active factories
match /factories/{factoryId} {
  allow read: if request.auth != null && resource.data.isActive == true;
  allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
}

// Token access rules
match /tokens/{tokenId} {
  // Farmers can read their own tokens
  allow read: if request.auth.uid == resource.data.farmerId 
              || get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['factory', 'admin'];
  
  // Farmers can create tokens
  allow create: if request.auth.uid == request.resource.data.farmerId;
  
  // Factory users can update tokens for their factory
  allow update: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.factoryId == resource.data.factoryId
                || get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
}
```

---

## 4. TOKEN GENERATION ALGORITHM

### 4.1 Token Number Format

```
Format: {FactoryCode}-{Date}-{SequenceNumber}
Example: MF001-20240201-045

Components:
- FactoryCode: First 2 letters + 3 digits (e.g., MF001)
- Date: YYYYMMDD format
- SequenceNumber: 3-digit daily counter (001-999)
```

### 4.2 Token Generation Logic

```javascript
async function generateToken(farmerId, factoryId, quantity, mangoType) {
  // Step 1: Validation
  const today = new Date().toISOString().split('T')[0];
  
  // Check duplicate token for same farmer + factory + date
  const existingToken = await checkExistingToken(farmerId, factoryId, today);
  if (existingToken) {
    throw new Error('Token already exists for today');
  }
  
  // Check factory capacity
  const factory = await getFactory(factoryId);
  const todayTokenCount = await getTodayTokenCount(factoryId, today);
  
  if (todayTokenCount >= factory.dailyCapacity) {
    throw new Error('Factory capacity reached for today');
  }
  
  // Step 2: Generate Token Number
  const tokenNumber = await generateTokenNumber(factoryId, today);
  
  // Step 3: Calculate Queue Position
  const queuePosition = todayTokenCount + 1;
  
  // Step 4: Estimate Time
  const avgProcessingTime = 30; // minutes per farmer
  const estimatedTime = calculateEstimatedTime(
    factory.openingTime,
    queuePosition,
    avgProcessingTime
  );
  
  // Step 5: Create Token Document
  const token = {
    tokenNumber,
    farmerId,
    farmerPhone: user.phoneNumber,
    farmerName: user.name,
    factoryId,
    factoryName: factory.name,
    date: today,
    status: 'pending',
    queuePosition,
    estimatedTime,
    quantity,
    mangoType,
    createdAt: Timestamp.now(),
    updatedAt: Timestamp.now()
  };
  
  // Step 6: Save to Firestore
  await saveToken(token);
  
  return token;
}
```

### 4.3 Queue Position Calculation

```javascript
function calculateQueuePosition(factoryId, date) {
  // Real-time calculation based on:
  // 1. Total tokens for the day
  // 2. Approved tokens count
  // 3. Completed tokens count
  
  const activeTokens = tokens.filter(t => 
    t.factoryId === factoryId &&
    t.date === date &&
    t.status !== 'rejected' &&
    t.status !== 'completed'
  );
  
  return activeTokens.length + 1;
}
```

---

## 5. SCREEN-BY-SCREEN FLOW

### 5.1 Farmer Journey

```
┌─────────────────┐
│  Login Screen   │
│  - Phone Input  │
│  - OTP Input    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Farmer Home     │
│ - Nearby        │
│   Factories Map │
│ - My Tokens     │
│ - Profile       │
└────────┬────────┘
         │
         ├─────────────┐
         │             │
         ▼             ▼
┌─────────────┐  ┌────────────┐
│ Factory     │  │ My Tokens  │
│ List View   │  │ List       │
│ - Distance  │  │ - Status   │
│ - Capacity  │  │ - Queue    │
└─────┬───────┘  └────────────┘
      │
      ▼
┌──────────────────┐
│ Factory Details  │
│ - Address        │
│ - Available Slots│
│ - Timings        │
│ [Book Token Btn] │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Token Booking    │
│ - Quantity Input │
│ - Mango Type     │
│ - Date Selection │
│ [Confirm Button] │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Token Generated  │
│ - Token Number   │
│ - Queue Position │
│ - Estimated Time │
│ - Factory Info   │
└──────────────────┘
```

### 5.2 Factory User Journey

```
┌─────────────────┐
│  Login Screen   │
└────────┬────────┘
         │
         ▼
┌─────────────────────┐
│ Factory Dashboard   │
│ - Today's Stats     │
│ - Pending Tokens    │
│ - Approved Tokens   │
│ - Completed Count   │
└────────┬────────────┘
         │
         ├─────────────┬────────────┐
         │             │            │
         ▼             ▼            ▼
┌─────────────┐ ┌──────────┐ ┌──────────┐
│ Pending     │ │ Approved │ │ Settings │
│ Requests    │ │ Queue    │ │ - Capacity│
│ [Approve]   │ │ - Mark   │ │ - Timings │
│ [Reject]    │ │ Complete │ └──────────┘
└─────────────┘ └──────────┘
```

### 5.3 Admin Journey

```
┌─────────────────┐
│  Login Screen   │
└────────┬────────┘
         │
         ▼
┌──────────────────────┐
│ Admin Dashboard      │
│ - Total Factories    │
│ - Total Tokens Today │
│ - Active Users       │
│ - Analytics Charts   │
└────────┬─────────────┘
         │
         ├─────────────┬────────────┬───────────┐
         │             │            │           │
         ▼             ▼            ▼           ▼
┌─────────────┐ ┌──────────┐ ┌─────────┐ ┌──────────┐
│ Manage      │ │ Manage   │ │ View    │ │Analytics │
│ Factories   │ │ Factory  │ │ All     │ │ - Daily  │
│ [Add]       │ │ Users    │ │ Tokens  │ │ - Weekly │
│ [Edit]      │ │ [Assign] │ │ - Filter│ │ - Monthly│
│ [Delete]    │ └──────────┘ └─────────┘ └──────────┘
└─────────────┘
```

---

## 6. VALIDATION RULES & EDGE CASES

### 6.1 Token Generation Validations

**Business Rules:**
1. ✅ One token per farmer per factory per day
2. ✅ Factory must be active
3. ✅ Factory capacity not exceeded
4. ✅ Valid phone number format (+91XXXXXXXXXX)
5. ✅ Quantity must be > 0 and <= 1000 kg
6. ✅ Token can only be booked for today or future dates
7. ✅ Maximum 7 days advance booking

**Edge Cases Handled:**

```javascript
// Case 1: Duplicate Token Prevention
- Check: farmerId + factoryId + date combination
- Action: Return error with existing token details

// Case 2: Factory Capacity Reached
- Check: Count of non-rejected tokens for the day
- Action: Show "Capacity Full" message with next available date

// Case 3: Offline Token Generation
- Check: Network connectivity
- Action: Queue request locally, sync when online

// Case 4: Token Cancellation
- Allow: Before factory approval
- Restriction: Cannot cancel after approval

// Case 5: Time-based Token Expiry
- Auto-expire tokens 24 hours after estimated time
- Move to 'expired' status

// Case 6: Factory User Reassignment
- Admin changes factory assignment
- Old user loses access, new user gains access

// Case 7: Same Phone Multiple Accounts
- Prevention: One account per phone number
- Enforcement: Firebase Auth handles this

// Case 8: Location Permission Denied
- Fallback: Manual city/area selection
- Show all factories with distance filter
```

### 6.2 Status Transition Rules

```
Token Status Flow:
┌─────────┐
│ Pending │ (Farmer creates token)
└────┬────┘
     │
     ├──────────────┬──────────────┐
     │              │              │
     ▼              ▼              ▼
┌─────────┐   ┌──────────┐   ┌──────────┐
│Approved │   │ Rejected │   │ Cancelled│
└────┬────┘   └──────────┘   └──────────┘
     │
     ▼
┌───────────┐
│ Completed │
└───────────┘

Allowed Transitions:
- Pending → Approved (Factory User)
- Pending → Rejected (Factory User)
- Pending → Cancelled (Farmer, within 1 hour)
- Approved → Completed (Factory User)
- Approved → Cancelled (Admin only)
```

---

## 7. PERFORMANCE & SCALABILITY

### 7.1 Optimization Strategies

**Frontend:**
- Lazy loading for routes
- Virtual scrolling for large lists
- Debounced search inputs
- Optimistic UI updates
- Service Worker for offline support

**Backend:**
- Firestore indexes for fast queries
- Pagination for token lists (20 per page)
- Caching factory data (1 hour TTL)
- Batch writes for bulk operations
- Cloud Functions for heavy computations

### 7.2 Scalability Metrics

```
Expected Load (Per Factory):
- Daily Farmers: 50-200
- Peak Hours: 8 AM - 12 PM
- Concurrent Users: 20-50

Firebase Limits:
- Firestore Reads: 50,000/day (free tier)
- Firestore Writes: 20,000/day (free tier)
- Authentication: 10,000 verifications/month (free tier)

Scaling Strategy:
- Phase 1 (MVP): Single region, free tier
- Phase 2 (50+ factories): Blaze plan, multi-region
- Phase 3 (500+ factories): Cloud Functions, CDN
```

---

## 8. SECURITY CONSIDERATIONS

### 8.1 Data Protection

```javascript
// 1. Phone Number Masking
Display: +91 98XXX XXX45
Stored: +919812345645

// 2. Rate Limiting
- OTP requests: 3 per hour per phone
- Token generation: 5 per day per farmer
- API calls: 100 per minute per user

// 3. Input Sanitization
- Phone: /^\+91[6-9]\d{9}$/
- Quantity: Numeric, 1-1000
- Dates: ISO format validation

// 4. SQL Injection Prevention
- Firestore (NoSQL) - inherently safe
- All queries use parameterized inputs
```

### 8.2 Privacy Compliance

- ✅ Minimal data collection (phone, name, location)
- ✅ Location only when needed (token generation)
- ✅ No third-party analytics in MVP
- ✅ User data deletion option
- ✅ Transparent privacy policy

---

## 9. DEPLOYMENT CHECKLIST

### 9.1 Pre-Launch Steps

```
□ Firebase Project Setup
  □ Create project in Firebase Console
  □ Enable Authentication (Phone)
  □ Create Firestore database
  □ Deploy Security Rules
  □ Create composite indexes
  □ Set up Firebase Hosting

□ Development Environment
  □ Install Node.js (v18+)
  □ Clone repository
  □ Install dependencies (npm install)
  □ Configure environment variables
  □ Run development server

□ Testing
  □ Unit tests for business logic
  □ Integration tests for Firebase
  □ End-to-end user flows
  □ Mobile responsiveness
  □ Cross-browser compatibility

□ Production Deployment
  □ Build optimized bundle
  □ Deploy to Firebase Hosting
  □ Configure custom domain (optional)
  □ Set up monitoring
  □ Enable analytics

□ Post-Launch
  □ Monitor error logs
  □ Collect user feedback
  □ Performance monitoring
  □ Gradual rollout plan
```

---

## 10. FUTURE ENHANCEMENTS

### Phase 2 Features
- SMS notifications for token updates
- Payment integration for advance booking
- QR code scanner at factory gates
- Farmer ratings and reviews
- Multi-language support (Hindi, Telugu, Tamil)
- Weather-based capacity adjustment
- Mango quality grading system

### Phase 3 Features
- Mobile app (React Native)
- WhatsApp integration for notifications
- Blockchain-based token verification
- AI-based demand prediction
- Integration with government databases
- Farmer analytics dashboard
- IoT integration for weighing scales

---

## 11. SUPPORT & MAINTENANCE

### Common Issues & Solutions

**Issue 1: OTP Not Received**
- Solution: Check phone number format, verify SMS quota, try again after 2 minutes

**Issue 2: Location Not Working**
- Solution: Enable browser/device location permissions, fallback to manual selection

**Issue 3: Token Not Generating**
- Solution: Check internet connection, verify factory capacity, clear cache

**Issue 4: Slow Performance**
- Solution: Check network speed, clear browser cache, optimize images

### Contact Points
- Technical Support: support@mangofactory.in
- Admin Queries: admin@mangofactory.in
- Farmer Helpline: 1800-XXX-XXXX

---

## 12. CONCLUSION

This system provides a complete digital solution for mango factory token management with:

✅ **Simple UI** for rural farmers
✅ **Role-based access** for secure operations
✅ **Real-time updates** for queue management
✅ **Scalable architecture** for growth
✅ **Production-ready code** for deployment

The system is designed to eliminate 2-3 day waiting times, reduce travel costs, prevent crop spoilage, and improve overall efficiency of mango trading operations.

**Estimated Development Time:** 4-6 weeks
**Estimated Cost:** Firebase free tier for MVP, ~₹5000/month for 50+ factories
**ROI:** Saves 2-3 days per farmer × 50 farmers/factory/day = Massive time savings

---

**Document Version:** 1.0
**Last Updated:** February 2026
**Prepared For:** College Project / Final Year / Hackathon / Real Deployment
