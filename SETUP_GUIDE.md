# 🥭 Mango Factory Token System - Setup & Deployment Guide

## Quick Start (5 Minutes Setup)

### Step 1: Firebase Project Setup

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com/
   - Click "Add Project"
   - Enter project name: "Mango Factory System"
   - Disable Google Analytics (optional for MVP)
   - Click "Create Project"

2. **Enable Authentication**
   - In Firebase Console, go to "Authentication"
   - Click "Get Started"
   - Click on "Sign-in method" tab
   - Enable "Phone" provider
   - Click "Save"

3. **Create Firestore Database**
   - Go to "Firestore Database"
   - Click "Create database"
   - Select "Start in production mode"
   - Choose location (closest to your users, e.g., asia-south1)
   - Click "Enable"

4. **Deploy Security Rules**
   - In Firestore Database, go to "Rules" tab
   - Copy the contents of `firestore.rules` file
   - Paste into the rules editor
   - Click "Publish"

5. **Create Composite Indexes**
   - Go to "Firestore Database" → "Indexes" tab
   - Click "Add Index"
   - Create the following indexes:

   **Index 1: Tokens by Farmer**
   ```
   Collection: tokens
   Fields:
   - farmerId (Ascending)
   - createdAt (Descending)
   ```

   **Index 2: Tokens by Factory & Date**
   ```
   Collection: tokens
   Fields:
   - factoryId (Ascending)
   - date (Descending)
   - status (Ascending)
   ```

   **Index 3: Tokens by Factory & Queue**
   ```
   Collection: tokens
   Fields:
   - factoryId (Ascending)
   - date (Descending)
   - queuePosition (Ascending)
   ```

### Step 2: Update Firebase Configuration

1. In Firebase Console, go to Project Settings (gear icon)
2. Scroll down to "Your apps"
3. Click on the web icon (</>)
4. Register your app with a nickname (e.g., "Mango Factory Web")
5. Copy the firebaseConfig object
6. **IMPORTANT**: Replace the firebaseConfig in `index.html` (around line 138) with your config

Your config should look like this:
```javascript
const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_PROJECT_ID.appspot.com",
  messagingSenderId: "YOUR_MESSAGING_ID",
  appId: "YOUR_APP_ID",
  measurementId: "YOUR_MEASUREMENT_ID"
};
```

### Step 3: Add Sample Data

1. **Create Admin User**
   - Open `index.html` in a browser
   - Login with your phone number
   - Select role: "Admin"
   - Complete registration

2. **Add Sample Factories (Via Firestore Console)**
   - Go to Firestore Database → Data tab
   - Click "Start collection"
   - Collection ID: `factories`
   - Document ID: (auto-generated)
   - Add fields:

   ```javascript
   {
     "name": "Sunrise Mango Factory",
     "address": "Plot No. 123, GIDC Industrial Area, Valsad, Gujarat",
     "location": {
       "lat": 20.6093,
       "lng": 72.9342
     },
     "dailyCapacity": 100,
     "contactNumber": "+919876543210",
     "openingTime": "08:00",
     "closingTime": "18:00",
     "isActive": true,
     "createdAt": (use Firestore timestamp - click clock icon)
   }
   ```

   Add 2-3 factories with different locations for testing.

3. **Create Factory User Account**
   - Login with another phone number
   - Select role: "Factory User"
   - Complete registration
   - Go to Firestore → users collection
   - Find the factory user document
   - Add field: `factoryId` with value of one of your factory IDs

### Step 4: Local Testing

**Option A: Simple File Server**
```bash
# Using Python (if installed)
python3 -m http.server 8000

# OR using Node.js (if installed)
npx http-server -p 8000

# OR using PHP (if installed)
php -S localhost:8000
```

Then open: http://localhost:8000

**Option B: Just Open the File**
- Simply open `index.html` in Chrome/Firefox
- Note: Some features may require a proper web server

### Step 5: Test the System

1. **Test Farmer Flow**
   - Login with a new phone number
   - Select "Farmer" role
   - View nearby factories
   - Book a token
   - Check "My Tokens" tab

2. **Test Factory Flow**
   - Login as factory user
   - View pending tokens
   - Approve/Reject tokens
   - Mark as completed

3. **Test Admin Flow**
   - Login as admin
   - Add/Edit/Delete factories
   - View all users and tokens

---

## Production Deployment

### Option 1: Firebase Hosting (Recommended)

1. **Install Firebase CLI**
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**
   ```bash
   firebase login
   ```

3. **Initialize Firebase Hosting**
   ```bash
   firebase init hosting
   ```
   - Select your Firebase project
   - Public directory: enter `.` (current directory)
   - Configure as single-page app: Yes
   - Set up automatic builds: No
   - Don't overwrite index.html

4. **Deploy**
   ```bash
   firebase deploy --only hosting
   ```

5. **Access Your App**
   - Your app will be live at: https://YOUR_PROJECT_ID.web.app
   - Custom domain setup available in Firebase Console

### Option 2: Netlify

1. Create account at https://netlify.com
2. Drag and drop your `index.html` file
3. Site is live instantly!

### Option 3: Vercel

1. Create account at https://vercel.com
2. Import your project
3. Deploy with one click

---

## Testing Checklist

### Farmer Tests
- [ ] Phone login works
- [ ] Can see nearby factories
- [ ] Can book token
- [ ] Cannot book duplicate token for same factory/day
- [ ] Can see token status
- [ ] Queue position updates correctly

### Factory Tests
- [ ] Factory user can login
- [ ] Can see today's tokens
- [ ] Can approve tokens
- [ ] Can reject tokens
- [ ] Can mark as completed
- [ ] Cannot see other factories' tokens

### Admin Tests
- [ ] Can add new factory
- [ ] Can edit factory details
- [ ] Can delete factory
- [ ] Can assign factory users
- [ ] Can view all tokens

### Edge Cases
- [ ] Factory capacity limit works
- [ ] Duplicate token prevention works
- [ ] Invalid phone number rejected
- [ ] OTP verification works
- [ ] Role-based access enforced
- [ ] Offline handling (show error message)

---

## Troubleshooting

### Issue: "Firebase: Error (auth/invalid-phone-number)"
**Solution**: Ensure phone number is in format: +919876543210

### Issue: "Firebase: Error (auth/too-many-requests)"
**Solution**: You've exceeded SMS quota. Wait 1 hour or upgrade to Blaze plan.

### Issue: "Permission denied" when creating token
**Solution**: 
1. Check Firestore rules are deployed correctly
2. Ensure user document exists with correct role
3. Check browser console for detailed error

### Issue: OTP not received
**Solution**:
1. Check phone number is correct
2. Verify Phone Auth is enabled in Firebase Console
3. Check SMS quota hasn't been exceeded
4. Try after 2-3 minutes

### Issue: Factories not showing
**Solution**:
1. Ensure factories have `isActive: true`
2. Check location permissions in browser
3. Verify factories collection exists in Firestore

### Issue: "Cannot read property 'uid' of null"
**Solution**: User is not authenticated. Clear cookies and login again.

---

## Performance Optimization

### For 100+ Factories
```javascript
// Add pagination to factory list
const FACTORIES_PER_PAGE = 20;

// Use Firestore limit() and startAfter()
const q = query(
  factoriesRef,
  where('isActive', '==', true),
  limit(FACTORIES_PER_PAGE)
);
```

### For 1000+ Tokens/Day
```javascript
// Enable Firestore caching
const db = getFirestore(app);
enableIndexedDbPersistence(db);

// Use batch writes for updates
const batch = writeBatch(db);
tokens.forEach(token => {
  batch.update(doc(db, 'tokens', token.id), { status: 'completed' });
});
await batch.commit();
```

---

## Security Best Practices

### 1. Hide Firebase Config (Production)
Store config in environment variables:
```javascript
const firebaseConfig = {
  apiKey: process.env.REACT_APP_FIREBASE_API_KEY,
  authDomain: process.env.REACT_APP_FIREBASE_AUTH_DOMAIN,
  // ... rest of config
};
```

### 2. Add App Check (Prevents Abuse)
```javascript
import { initializeAppCheck, ReCaptchaV3Provider } from 'firebase/app-check';

const appCheck = initializeAppCheck(app, {
  provider: new ReCaptchaV3Provider('YOUR_RECAPTCHA_SITE_KEY'),
  isTokenAutoRefreshEnabled: true
});
```

### 3. Rate Limiting
Add Cloud Functions to limit:
- OTP requests: 3 per hour per phone
- Token creation: 5 per day per farmer
- API calls: 100 per minute per user

---

## Monitoring & Analytics

### Enable Firebase Analytics
```javascript
import { getAnalytics, logEvent } from 'firebase/analytics';

const analytics = getAnalytics(app);

// Track token bookings
logEvent(analytics, 'token_booked', {
  factory_id: factoryId,
  quantity: quantity
});
```

### Monitor Performance
1. Go to Firebase Console → Performance
2. Enable Performance Monitoring
3. Track:
   - Page load times
   - Network requests
   - User sessions

---

## Cost Estimation

### Free Tier Limits (Spark Plan)
- ✅ Phone Auth: 10,000 verifications/month
- ✅ Firestore: 50K reads, 20K writes, 20K deletes/day
- ✅ Hosting: 10 GB storage, 360 MB/day transfer
- ✅ Suitable for: 5-10 factories, 500 tokens/day

### Paid Tier (Blaze Plan)
**Estimated costs for 50 factories, 5000 tokens/day:**
- Phone Auth: ~₹3,500/month (35,000 verifications @ ₹0.10 each)
- Firestore: ~₹800/month (150K reads @ ₹0.36/100K)
- Hosting: ~₹200/month (2 GB storage, 10 GB transfer)
- **Total: ~₹4,500/month** ($55/month)

### Cost Optimization Tips
1. Cache factory data in localStorage (reduce reads)
2. Use batch operations (reduce write operations)
3. Compress images and assets (reduce hosting costs)
4. Implement pagination (reduce data transfer)

---

## Backup & Recovery

### Automatic Backups
1. Go to Firebase Console → Firestore Database
2. Click "Backups" tab
3. Enable automated daily backups
4. Set retention: 7 days

### Manual Export
```bash
# Install gcloud CLI
# Then export:
gcloud firestore export gs://YOUR_BUCKET_NAME/backups/$(date +%Y%m%d)
```

---

## Support Contacts

**Technical Issues:**
- Firebase Support: https://firebase.google.com/support
- Stack Overflow: Tag questions with `firebase` and `firestore`

**Project Documentation:**
- This README
- SYSTEM_DOCUMENTATION.md
- Firebase Documentation: https://firebase.google.com/docs

---

## Next Steps (Post-MVP)

### Phase 2 Enhancements
- [ ] SMS notifications for token updates
- [ ] WhatsApp integration
- [ ] Multiple language support
- [ ] Payment gateway integration
- [ ] Mobile app (React Native)

### Phase 3 Enterprise Features
- [ ] Analytics dashboard
- [ ] Farmer ratings system
- [ ] Quality grading integration
- [ ] Government database sync
- [ ] Blockchain verification
- [ ] AI demand prediction

---

## License

This project is developed for educational and commercial use.

**For College Projects:**
- ✅ Free to use and modify
- ✅ Must credit original author in documentation
- ✅ Can be submitted as final year project

**For Commercial Deployment:**
- ✅ Free to deploy and use
- ✅ No licensing fees
- ✅ Custom development support available

---

## Success Metrics

### Key Performance Indicators (KPIs)
- **Time Saved**: Target 2-3 days → 0 days
- **User Adoption**: 70% farmers in 3 months
- **Token Processing**: 50 farmers/factory/day
- **System Uptime**: 99.5%
- **User Satisfaction**: 4.5/5 stars

### Tracking Dashboard
Create monthly reports tracking:
1. Total tokens generated
2. Average wait time reduction
3. Factory capacity utilization
4. User growth rate
5. System performance metrics

---

**Version:** 1.0
**Last Updated:** February 2026
**Created By:** Claude (Anthropic AI)
**Built For:** College Projects / Startups / Real Deployment

🥭 Happy Farming! 🥭
