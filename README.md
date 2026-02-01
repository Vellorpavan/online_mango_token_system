# 🥭 Mango Factory Token System

A modern, real-time token booking system for mango farmers and factories, built with Firebase and React.

## Features

### For Farmers 👨‍🌾
- **Date-based Booking**: Select delivery dates up to 7 days in advance
- **Live Capacity Tracking**: Real-time view of factory capacity and queue status
- **Smart Status Indicators**: 
  - 🟢 **FREE** - Factory is open and accepting bookings
  - 🟠 **FULL** - Factory has reached capacity for the day
  - 🔴 **CLOSED** - Factory is closed (holiday)
- **Visual Capacity Bar**: See at-a-glance how full the factory is
- **Token Management**: View and track all your bookings
- **Multiple Mango Varieties**: Support for Alphonso, Kesar, Dasheri, Langra, Chausa, Totapuri, and Banganapalli

### For Factory Managers 🏭
- **Multi-date Monitoring**: View and manage tokens for any date
- **Real-time Dashboard**: Live updates as farmers book slots
- **Status Management**: Approve, reject, or complete deliveries
- **Daily Statistics**: Track pending, approved, and completed tokens
- **Live Sync**: Automatic updates without page refresh

### For Admins 👑
- **Factory Management**: View all registered factories
- **User Management**: Monitor system users and their roles
- **System Overview**: Complete visibility into platform activity

## Technology Stack

- **Frontend**: React (via CDN), Tailwind CSS
- **Backend**: Firebase (Authentication, Firestore Database)
- **Authentication**: Phone OTP Authentication
- **Real-time Sync**: Firestore Real-time Listeners

## File Structure

```
.
├── index-enhanced.html      # Main production application (Enhanced UI)
├── index-premium.html       # Premium version with additional features
├── index.html              # Basic/original version
├── firestore.rules         # Firebase security rules
└── README.md               # This file
```

## Setup Instructions

### 1. Firebase Configuration

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable **Authentication** > **Phone** provider
3. Enable **Cloud Firestore** database
4. Update the Firebase config in `index-enhanced.html`:

```javascript
const firebaseConfig = {
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_AUTH_DOMAIN",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_STORAGE_BUCKET",
    messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
    appId: "YOUR_APP_ID"
};
```

### 2. Database Setup

#### Factories Collection
Create a `factories` collection with documents containing:
```json
{
  "name": "Factory Name",
  "contactNumber": "1234567890",
  "location": "City, State",
  "isActive": true,
  "openingTime": "08:00",
  "closingTime": "18:00",
  "dailyCapacity": 5000,
  "holidays": ["2026-02-05", "2026-02-10"]
}
```

#### Users Collection
Automatically created on registration with:
```json
{
  "name": "User Name",
  "phoneNumber": "+911234567890",
  "role": "farmer|factory|admin",
  "factoryId": "factory_doc_id" // For factory users
}
```

#### Tokens Collection
Created when farmers book slots:
```json
{
  "farmerId": "user_uid",
  "factoryId": "factory_id",
  "factoryName": "Factory Name",
  "farmerName": "Farmer Name",
  "farmerPhone": "+911234567890",
  "date": "2026-02-01",
  "tokenNumber": "FAC-1",
  "queuePosition": 1,
  "estimatedTime": "08:00",
  "quantity": 500,
  "mangoType": "Alphonso",
  "status": "pending|approved|rejected|completed",
  "createdAt": "Timestamp"
}
```

### 3. Firestore Security Rules

Deploy the security rules from `firestore.rules`:

```bash
firebase deploy --only firestore:rules
```

### 4. Running Locally

Simply open `index-enhanced.html` in a modern web browser:

```bash
# Windows
start index-enhanced.html

# Mac/Linux
open index-enhanced.html
```

Or use a local server:

```bash
python -m http.server 8080
```

Then navigate to `http://localhost:8080/index-enhanced.html`

## Developer Mode

For testing without OTP verification, use the **Development Tools (Bypass OTP)** section on the login screen:

1. Click **Farmer** to test farmer features
2. Click **Factory** to test factory management
3. Click **Admin** to test admin dashboard

## Features by Version

### index-enhanced.html (Recommended)
- ✅ Date selection with 7-day range
- ✅ Live capacity tracking
- ✅ Holiday and capacity status indicators
- ✅ Visual capacity progress bar
- ✅ Real-time Firebase sync
- ✅ Developer bypass tools
- ✅ Registration screen with role selection
- ✅ Premium glassmorphic UI

### index-premium.html
- ✅ Alternative premium design
- ✅ Basic date handling
- ✅ Standard token management

### index.html
- ✅ Basic token system
- ✅ Simple UI
- ✅ Core functionality

## Key Concepts

### Date Selection
Farmers can book delivery slots for any date within the next 7 days. The system shows:
- Number of tokens already booked for each date
- Total kilograms scheduled for delivery
- Factory status (Open/Full/Closed)

### Capacity Management
Each factory has a `dailyCapacity` (default: 5000 kg). When total bookings reach this limit, the system:
- Shows "FULL" status
- Prevents new bookings for that date
- Displays a visual capacity bar

### Holiday Management
Factories can define `holidays` as an array of date strings. On these dates:
- System shows "CLOSED" status
- Booking form is disabled
- Farmers are prompted to select another date

### Real-time Updates
Using Firestore's `onSnapshot` listeners:
- Queue positions update live
- Capacity bars refresh automatically
- Token statuses sync across all users
- No page refresh needed

## Common Tasks

### Adding a New Factory
1. Go to Firestore Console
2. Add document to `factories` collection
3. Set `isActive: true`
4. Configure `dailyCapacity` and `holidays`

### Setting Factory Holidays
Update the `holidays` array in factory document:
```javascript
holidays: ["2026-02-14", "2026-02-26", "2026-03-08"]
```

### Adjusting Daily Capacity
Update `dailyCapacity` in factory document (in kg):
```javascript
dailyCapacity: 7500  // 7500 kg per day
```

## Browser Compatibility

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## Security Notes

- Phone OTP authentication required for production
- Firestore rules enforce role-based access
- Factory users can only manage their own factory
- Farmers can only view/edit their own tokens

## Future Enhancements

- [ ] SMS notifications for token status changes
- [ ] Payment integration
- [ ] Advanced analytics dashboard
- [ ] Mobile app (React Native)
- [ ] Multilingual support (Hindi, Marathi, etc.)
- [ ] Location-based factory filtering
- [ ] Weather integration
- [ ] Price tracking

## Support

For issues or questions, please:
1. Check the Firebase Console for errors
2. Review browser console for client-side errors
3. Verify Firestore security rules are deployed
4. Ensure Firebase config is correct

## License

MIT License - Feel free to use and modify for your needs.

## Credits

Built with ❤️ for mango farmers and factories.
