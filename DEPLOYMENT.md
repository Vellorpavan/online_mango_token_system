# 🚀 Firebase Hosting Deployment Guide

## Prerequisites

You need to enable PowerShell script execution first:

```powershell
# Run PowerShell as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Step 1: Install Firebase Tools

```bash
npm install -g firebase-tools
```

## Step 2: Login to Firebase

```bash
firebase login
```

This will open a browser window for you to authenticate with your Google account.

## Step 3: Initialize Firebase (SKIP - Already Done!)

✅ We've already created the necessary configuration files:
- `firebase.json` - Hosting and Firestore config
- `firestore.indexes.json` - Database indexes
- `firestore.rules` - Security rules
- `public/` folder with your app files

**Note:** If you need to link this to your Firebase project, run:
```bash
firebase use --add
```
Then select your project from the list.

## Step 4: Deploy to Firebase Hosting

### Deploy Everything (Hosting + Rules)
```bash
firebase deploy
```

### Deploy Only Hosting
```bash
firebase deploy --only hosting
```

### Deploy Only Firestore Rules
```bash
firebase deploy --only firestore:rules
```

### Deploy Firestore Rules and Indexes
```bash
firebase deploy --only firestore
```

## 📁 Project Structure

```
mango-factory-token-system/
├── public/                      # Hosting files
│   ├── index-enhanced.html     # Main app (default)
│   ├── index-premium.html      # Premium version
│   └── index.html              # Basic version
├── firebase.json               # Firebase config
├── firestore.rules            # Database security rules
├── firestore.indexes.json     # Database indexes
└── .firebaserc               # Firebase project config (created after init)
```

## 🌐 After Deployment

Your app will be live at:
```
https://YOUR-PROJECT-ID.web.app
https://YOUR-PROJECT-ID.firebaseapp.com
```

### Access Different Versions:
- Main app: `https://YOUR-PROJECT-ID.web.app/`
- Premium: `https://YOUR-PROJECT-ID.web.app/index-premium.html`
- Basic: `https://YOUR-PROJECT-ID.web.app/index.html`

## 🔧 Quick Commands

```bash
# View hosting URL
firebase hosting:channel:list

# Deploy to preview channel (for testing)
firebase hosting:channel:deploy preview

# View logs
firebase deploy --debug

# Open Firebase console
firebase open hosting

# Check status
firebase projects:list
```

## 📝 Firestore Security

Before deploying, make sure:
1. ✅ Firestore rules are configured in `firestore.rules`
2. ✅ Phone authentication is enabled in Firebase Console
3. ✅ Your Firebase project has Firestore database created

Deploy rules:
```bash
firebase deploy --only firestore:rules
```

## 🎯 Deployment Checklist

- [ ] PowerShell execution policy enabled
- [ ] Firebase CLI installed (`npm install -g firebase-tools`)
- [ ] Logged in to Firebase (`firebase login`)
- [ ] Project linked (`firebase use --add`)
- [ ] Files copied to `public/` folder
- [ ] Firebase config updated in HTML files
- [ ] Firestore rules reviewed
- [ ] Ready to deploy! (`firebase deploy`)

## ⚡ Quick Deploy Script

Save this as `deploy.ps1`:

```powershell
# Build/Copy files
Copy-Item "index-enhanced.html" "public/index-enhanced.html" -Force
Copy-Item "index-premium.html" "public/index-premium.html" -Force
Copy-Item "index.html" "public/index.html" -Force

# Deploy
firebase deploy

Write-Host "✅ Deployment complete!"
```

Then run:
```powershell
.\deploy.ps1
```

## 🐛 Troubleshooting

### PowerShell Script Error
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Firebase Login Issues
```bash
firebase login --reauth
```

### Deployment Failed
```bash
firebase deploy --debug
```

### Wrong Project
```bash
firebase use --add
# Select correct project
```

## 📱 Next Steps After Deployment

1. Test the live URL
2. Configure custom domain (optional)
3. Set up SSL (automatic with Firebase)
4. Monitor usage in Firebase Console
5. Set up GitHub Actions for auto-deploy (optional)

---

**Current Status:**
✅ Firebase configuration created
✅ Public folder set up
✅ HTML files copied
🎯 Ready for `firebase deploy`!
