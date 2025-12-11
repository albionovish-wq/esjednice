# eSjednice - Complete Manual Setup Guide

This guide walks you through every manual step required to set up and configure eSjednice as a fully functional application.

## Table of Contents
1. [Firebase Project Setup](#firebase-project-setup)
2. [Firebase Firestore Configuration](#firebase-firestore-configuration)
3. [Firebase Authentication Setup](#firebase-authentication-setup)
4. [Firebase Storage Setup](#firebase-storage-setup)
5. [Security Rules Deployment](#security-rules-deployment)
6. [App Configuration](#app-configuration)
7. [Initial Data Setup](#initial-data-setup)
8. [Testing the Setup](#testing-the-setup)
9. [Troubleshooting](#troubleshooting)

---

## Firebase Project Setup

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **"Create a project"** or **"Add project"**
3. Enter project name: `eSjednice` (or your preferred name)
4. Accept Google Analytics terms
5. Select or create Google Analytics account
6. Click **"Create project"**
7. Wait for project creation (2-3 minutes)

### Step 2: Verify Project Settings

After creation, you should see your project dashboard.

**Note project details:**
- **Project ID**: (e.g., `esjednice-abc123`)
- **Project Number**: (shown in project settings)

### Step 3: Access Project Settings

1. Click **⚙️ (Settings icon)** in top-left next to project name
2. Select **"Project settings"**
3. Note the following information:
   - **Project ID** (used in multiple places)
   - **Project Number** (used in some configurations)

---

## Firebase Firestore Configuration

### Step 1: Create Firestore Database

1. In Firebase Console, left sidebar click **"Firestore Database"**
2. Click **"Create database"** or **"+ Start collection"**
3. Choose region:
   - **Recommended**: Select closest to your users
   - For Europe: `europe-west1` (Belgium)
   - For US: `us-central1`
4. Start in **"Production mode"** (we'll add security rules later)
5. Click **"Create"**

### Step 2: Create Collections and Structure

#### Collection 1: korisnici (Users)

1. In Firestore, click **"Start collection"**
2. Collection ID: `korisnici`
3. Click **"Next"**
4. Click **"Auto ID"** to create first document
5. Add fields (manually create structure):

```
Document ID (auto-generated example: abc123xyz)
├── email: "user@example.com" (string)
├── ime: "John" (string)
├── prezime: "Doe" (string)
├── uloga: "nastavnik" (string)
│   └── Options: "ravnatelj", "zapisnicar", "nastavnik", "roditelj", "ucenik"
├── grupe: [] (array - empty for now)
├── created: (server timestamp)
├── lastLogin: (server timestamp - nullable)
└── aktivan: true (boolean)
```

**Do NOT save this dummy document** - just use it to understand structure.
Click the **X** to cancel and don't save.

#### Collection 2: sjednice (Meetings)

1. Click **"+ Start collection"**
2. Collection ID: `sjednice`
3. Click **"Next"**
4. Auto ID, add structure:

```
Document ID (auto-generated)
├── naslov: "Plenary Meeting" (string)
├── opis: "Monthly meeting" (string)
├── grupa: "Grupa A" (string)
├── vrijeme: (timestamp)
├── lokacija: "Room 101" (string)
├── status: "planned" (string)
│   └── Options: "planned", "inProgress", "concluded", "canceled"
├── sazivac: "user-id" (string)
├── zapisnicar: "user-id" (string)
├── dnevniRed: [] (array - agenda items)
├── prisutnost: [] (array - attendance)
├── dokumenti: [] (array - uploaded files)
├── created: (server timestamp)
└── updated: (server timestamp - nullable)
```

**Do NOT save** - just reference.

#### Collection 3: glasanja (Votings)

1. Click **"+ Start collection"**
2. Collection ID: `glasanja`
3. Click **"Next"**
4. Structure reference:

```
Document ID (auto-generated)
├── sjednicaId: "sjednica-id" (string)
├── stavkaId: "agenda-item-id" (string)
├── naslov: "Proposal Vote" (string)
├── opis: "Description" (string)
├── grupa: "Grupa A" (string)
├── opcije: ["Da", "Ne", "Suzdržan"] (array)
├── status: "openForVoting" (string)
│   └── Options: "openForVoting", "closed"
├── glasovi: [] (array - vote records)
├── pocetneVrijeme: (timestamp)
├── krajnjeVrijeme: (timestamp)
├── created: (server timestamp)
└── updated: (server timestamp - nullable)
```

**Do NOT save** - just reference.

#### Collection 4: obavijesti (Announcements)

1. Click **"+ Start collection"**
2. Collection ID: `obavijesti`
3. Click **"Next"**
4. Structure reference:

```
Document ID (auto-generated)
├── naslov: "Important Announcement" (string)
├── sadrzaj: "Announcement content" (string)
├── autorizdId: "user-id" (string)
├── autoriziranoIme: "John Doe" (string)
├── tip: "opca" (string)
│   └── Options: "opca" (general), "grupa" (group), "uloga" (role)
├── grupe: ["Grupa A", "Grupa B"] (array - if tip="grupa")
├── uloge: ["nastavnik", "zapisnicar"] (array - if tip="uloga")
├── vrijeme: (timestamp)
├── aktivna: true (boolean)
├── created: (server timestamp)
└── updated: (server timestamp - nullable)
```

**Do NOT save** - just reference.

### Step 3: Create Firestore Indexes

1. In Firestore, go to **"Indexes"** tab
2. Click **"+ Create Index"** for each:

**Index 1: sjednice collection**
- Collection ID: `sjednice`
- Fields:
  - `grupa` (Ascending)
  - `status` (Ascending)
- Query scope: Collection
- Click **"Create Index"**

**Index 2: sjednice collection**
- Collection ID: `sjednice`
- Fields:
  - `vrijeme` (Descending)
- Query scope: Collection
- Click **"Create Index"**

**Index 3: glasanja collection**
- Collection ID: `glasanja`
- Fields:
  - `grupa` (Ascending)
  - `krajnjeVrijeme` (Descending)
- Query scope: Collection
- Click **"Create Index"**

**Index 4: glasanja collection**
- Collection ID: `glasanja`
- Fields:
  - `status` (Ascending)
- Query scope: Collection
- Click **"Create Index"**

**Index 5: obavijesti collection**
- Collection ID: `obavijesti`
- Fields:
  - `aktivna` (Ascending)
  - `vrijeme` (Descending)
- Query scope: Collection
- Click **"Create Index"**

**Index 6: obavijesti collection**
- Collection ID: `obavijesti`
- Fields:
  - `tip` (Ascending)
- Query scope: Collection
- Click **"Create Index"**

---

## Firebase Authentication Setup

### Step 1: Enable Authentication Methods

1. In Firebase Console, left sidebar click **"Authentication"**
2. Click **"Get started"** or **"Sign-in method"** tab
3. Click **"Email/Password"** provider
4. Toggle **"Enable"** to ON
5. Do NOT enable "Email link sign-in"
6. Click **"Save"**

### Step 2: Configure OAuth Consent Screen (Optional - For Google Sign-In)

**Skip this if you don't need Google Sign-In yet.**

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Select your project
3. Left sidebar: **APIs & Services** → **OAuth consent screen**
4. Select **"External"** user type
5. Fill in:
   - **App name**: `eSjednice`
   - **User support email**: your-email@example.com
   - **Developer contact**: your-email@example.com
6. Click **"Save and Continue"**
7. Add scopes:
   - `email`
   - `profile`
8. Click **"Save and Continue"**
9. Click **"Back to Dashboard"**

### Step 3: Create OAuth Credentials (Optional - For Google Sign-In)

**Skip this if you don't need Google Sign-In yet.**

1. **APIs & Services** → **Credentials**
2. Click **"+ Create Credentials"** → **OAuth 2.0 Client ID**
3. Application type: **Web application**
4. Name: `eSjednice Web`
5. Authorized JavaScript origins:
   - `http://localhost:3000` (development)
   - `http://localhost:5000` (Firebase emulator)
   - `https://your-domain.com` (production)
6. Authorized redirect URIs:
   - `http://localhost:3000/__/auth/handler`
   - `http://localhost:5000/__/auth/handler`
   - `https://your-domain.com/__/auth/handler`
7. Click **"Create"**
8. Copy Client ID (you'll need this later)

---

## Firebase Storage Setup

### Step 1: Create Storage Bucket

1. In Firebase Console, left sidebar click **"Storage"**
2. Click **"Get started"** or **"+ Start"**
3. Choose region:
   - **Recommended**: Same as Firestore (e.g., `europe-west1`)
4. Start in **"Production mode"**
5. Click **"Create"**

### Step 2: Create Storage Folder Structure

1. In Storage, click **"Create folder"**
2. Folder name: `sjednice`
3. Click **"Create"**

(Subfolders will be created automatically by the app when uploading files)

---

## Security Rules Deployment

### Step 1: Prepare Security Rules

The file `firestore.rules` is already created in the project root.

**Location**: `/home/engine/project/firestore.rules`

**Verify it contains the complete RBAC rules** with:
- Authentication checks
- Role-based access control
- Group filtering
- One-vote-per-user enforcement

### Step 2: Deploy Rules via Firebase CLI

**Prerequisites:**
- Node.js installed
- Firebase CLI installed

**Installation:**
```bash
# Install Firebase CLI globally
npm install -g firebase-tools

# Verify installation
firebase --version
```

**Deploy:**
```bash
# Navigate to project directory
cd /home/engine/project

# Login to Firebase
firebase login
# This opens a browser to authenticate

# List your projects to find project ID
firebase projects:list

# Select your project
firebase use YOUR_PROJECT_ID

# Validate rules before deploying
firebase deploy --only firestore:rules --dry-run

# Deploy rules
firebase deploy --only firestore:rules
```

**Expected output:**
```
✔  Deploy complete!

Project Console: https://console.firebase.google.com/project/YOUR_PROJECT_ID
```

### Step 3: Verify Rules Deployment

1. In Firebase Console → **Firestore** → **Rules** tab
2. Verify rules are updated (shows new rules)
3. Check that rules document contains RBAC logic

---

## App Configuration

### Step 1: Get Firebase Web SDK Credentials

1. In Firebase Console, click **⚙️ Settings** → **Project settings**
2. Scroll down to **"Your apps"** section
3. Click **"Web"** icon (if not already created)
4. Nickname: `esjednice-web`
5. Check **"Also set up Firebase Hosting"** (optional)
6. Click **"Register app"**
7. Copy the entire configuration object:

```javascript
const firebaseConfig = {
  apiKey: "AIzaSyC_...",
  authDomain: "esjednice-xxx.firebaseapp.com",
  projectId: "esjednice-xxx",
  storageBucket: "esjednice-xxx.appspot.com",
  messagingSenderId: "1234567890",
  appId: "1:1234567890:web:abc123xyz",
  databaseURL: "https://esjednice-xxx.firebaseio.com",
};
```

### Step 2: Update firebase_options.dart

1. Open file: `lib/firebase_options.dart`
2. Replace test values with your actual Firebase credentials:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_API_KEY',  // From firebaseConfig.apiKey
  appId: 'YOUR_APP_ID',  // From firebaseConfig.appId
  messagingSenderId: 'YOUR_MESSAGING_ID',  // From firebaseConfig.messagingSenderId
  projectId: 'YOUR_PROJECT_ID',  // From firebaseConfig.projectId
  authDomain: 'your-project.firebaseapp.com',  // From firebaseConfig.authDomain
  databaseURL: 'https://your-project.firebaseio.com',  // From firebaseConfig.databaseURL
  storageBucket: 'your-project.appspot.com',  // From firebaseConfig.storageBucket
);
```

**Example (Replace with YOUR values):**
```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyC_xYz1234567890_abcdefghijklmnop',
  appId: '1:123456789:web:abcd1234efgh5678',
  messagingSenderId: '123456789',
  projectId: 'esjednice-abc123',
  authDomain: 'esjednice-abc123.firebaseapp.com',
  databaseURL: 'https://esjednice-abc123.firebaseio.com',
  storageBucket: 'esjednice-abc123.appspot.com',
);
```

### Step 3: Add Google Sign-In Configuration (Optional)

**Only if you enabled Google Sign-In:**

1. File: `lib/provideri/auth.dart`
2. Uncomment Google Sign-In sections:
   - Import statement
   - `_googleSignIn` initialization
   - `signInWithGoogle()` method
   - `signOutGoogle()` method

3. In file: `lib/sucelja/prijava.dart`
4. Add Google sign-in button to UI (if desired)

---

## Initial Data Setup

### Step 1: Create Test Groups

These are group names you'll use throughout the app. Update them based on your institution's structure.

**Example groups:**
- `Grupa A` - Class A
- `Grupa B` - Class B
- `Nastavnički zbor` - Teachers council
- `Roditelji` - Parents group

**You will reference these when creating users and meetings.**

### Step 2: Create Test Users

You can create users two ways:

#### Method A: Through Firebase Console (Easiest)

1. Firebase Console → **Authentication** → **Users** tab
2. Click **"Add user"**
3. Fill in:
   - **Email**: `teacher1@school.edu`
   - **Password**: `test1234` (temporary)
4. Click **"Add user"**
5. Repeat for more test users

**Then** create Firestore documents:

1. Firestore → **korisnici** collection
2. Click **"+ Add document"**
3. Document ID: Paste the UID from Firebase user
4. Add fields:
   - `email`: `teacher1@school.edu`
   - `ime`: `John`
   - `prezime`: `Doe`
   - `uloga`: `nastavnik`
   - `grupe`: Add array value `Grupa A`
   - `created`: Server timestamp
   - `aktivan`: `true`
5. Click **"Save"**

#### Method B: Through App (After deployment)

1. Run the app
2. Click "Nemam račun" (No account)
3. Register users through the app
4. Then manually set roles and groups via Firestore (if needed)

### Step 3: Create Test Groups Structure

For each group, create optional metadata (optional but recommended):

1. Create new collection: `grupe` (optional)
2. Document ID: Group name (e.g., `Grupa A`)
3. Fields:
   - `naziv`: Group name
   - `opis`: Description
   - `kapacitet`: Number of members
   - `kreirana`: Server timestamp

---

## Testing the Setup

### Step 1: Verify Firestore Connection

1. Open terminal in project directory
2. Run:
   ```bash
   flutter pub get
   flutter clean
   flutter pub upgrade
   ```

### Step 2: Run the App

```bash
# For web
flutter run -d chrome

# For mobile (Android)
flutter run -d android

# For iOS
flutter run -d ios
```

### Step 3: Test Authentication

1. App should load and show login screen
2. Click **"Nemam račun"** (No account)
3. Register with:
   - Email: `test@example.com`
   - Password: `Test1234!`
   - First name: `Test`
   - Last name: `User`
4. Should create user in Firebase
5. Should redirect to Dashboard

### Step 4: Check Firestore

1. Firebase Console → **Firestore**
2. **korisnici** collection should have new user document
3. Verify fields are saved correctly

### Step 5: Test Login

1. Logout (Settings → Odjava)
2. Login with:
   - Email: `test@example.com`
   - Password: `Test1234!`
3. Should show Dashboard

### Step 6: Test Data Access

1. Create a meeting:
   - Go to Sjednice → Kreiraj sjednica
   - Fill in details
   - Select group: `Grupa A`
   - Click Spremi
2. Check Firestore:
   - **sjednice** collection should have new document
3. View meeting:
   - Go back to Sjednice
   - Click on meeting
   - Should show all details

### Step 7: Verify Security Rules

1. Firebase Console → **Firestore** → **Rules** tab
2. Rules should show RBAC logic
3. Test access with different users:
   - Create users with different roles
   - Try to access data they shouldn't see
   - Should be blocked by rules

---

## Environment Variables (Optional but Recommended)

For production, store sensitive data in environment files:

### Create .env file

File: `/home/engine/project/.env`

```
FIREBASE_API_KEY=AIzaSyC_...
FIREBASE_APP_ID=1:123456:web:abc...
FIREBASE_PROJECT_ID=esjednice-xxx
FIREBASE_AUTH_DOMAIN=esjednice-xxx.firebaseapp.com
FIREBASE_STORAGE_BUCKET=esjednice-xxx.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_DATABASE_URL=https://esjednice-xxx.firebaseio.com
```

### Use in Code (requires flutter_dotenv package)

```dart
// In pubspec.yaml
dependencies:
  flutter_dotenv: ^5.1.0

// In main.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  // ...
}

// In firebase_options.dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: String.fromEnvironment('FIREBASE_API_KEY'),
  // ...
);
```

---

## Post-Setup Configuration

### Step 1: Firestore Backup (Production)

1. Firebase Console → **Firestore** → **Backups**
2. Click **"+ Create Schedule"**
3. Set backup frequency:
   - Daily backups recommended
   - Retention: 7-90 days
4. Click **"Create"**

### Step 2: Enable Monitoring

1. Firebase Console → **Analytics** (auto-enabled)
2. Firebase Console → **Crashlytics** (auto-enabled)
3. Wait for first data collection (24 hours)

### Step 3: Set Up Alerts

1. Google Cloud Console → **Cloud Monitoring**
2. **Alerting** → **Policies**
3. Create alerts for:
   - High error rate
   - High quota usage
   - Database downtime

---

## Troubleshooting Setup Issues

### Issue: "Cannot create document - Permission denied"

**Cause**: Security rules are too restrictive

**Solution**:
1. Temporarily set rules to test mode (allows all):
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if true;
       }
     }
   }
   ```
2. Test app
3. Deploy proper rules once working

### Issue: "Collection not found"

**Cause**: Collections not created in Firestore

**Solution**:
1. Go to Firestore
2. Create collections manually:
   - `korisnici`
   - `sjednice`
   - `glasanja`
   - `obavijesti`

### Issue: "Invalid Firebase Credentials"

**Cause**: Wrong API key in `firebase_options.dart`

**Solution**:
1. Go to Firebase Console → Project settings
2. Copy credentials again
3. Verify exact copy (no extra spaces)
4. Update `firebase_options.dart`
5. Run `flutter clean` and rebuild

### Issue: "Authentication method not enabled"

**Cause**: Email/Password provider not enabled

**Solution**:
1. Firebase Console → **Authentication**
2. **Sign-in method** tab
3. Click **Email/Password**
4. Toggle **Enable** to ON
5. Click **Save**

### Issue: "CORS error" on web

**Cause**: Domain not allowed in Firebase

**Solution**:
1. Firebase Console → **Authentication**
2. **Settings** tab
3. Authorized domains:
   - Add `localhost` (for dev)
   - Add your production domain
4. Click **Save**

### Issue: "Storage bucket not found"

**Cause**: Storage not created in Firebase

**Solution**:
1. Firebase Console → **Storage**
2. Click **"Get started"**
3. Choose region (same as Firestore)
4. Start in Production mode
5. Click **"Create"**

---

## Quick Reference: What Goes Where

| Item | Location | Value |
|------|----------|-------|
| API Key | `lib/firebase_options.dart` | From Firebase console |
| Project ID | `lib/firebase_options.dart` | From Firebase console |
| Auth Domain | `lib/firebase_options.dart` | From Firebase console |
| Storage Bucket | `lib/firebase_options.dart` | From Firebase console |
| Messaging ID | `lib/firebase_options.dart` | From Firebase console |
| Security Rules | `firestore.rules` | Already provided |
| Google Client ID | `lib/provideri/auth.dart` | From Google Cloud Console |
| Group Names | Firestore `sjednice` | Your institution's groups |
| User Roles | Firestore `korisnici.uloga` | ravnatelj, zapisnicar, nastavnik, roditelj, ucenik |

---

## Verification Checklist

Before declaring setup complete, verify:

- [ ] Firebase project created
- [ ] Firestore database created in correct region
- [ ] Collections created: `korisnici`, `sjednice`, `glasanja`, `obavijesti`
- [ ] Firestore indexes created (6 total)
- [ ] Authentication enabled (Email/Password)
- [ ] Storage bucket created
- [ ] Security rules deployed via Firebase CLI
- [ ] `firebase_options.dart` updated with real credentials
- [ ] Test user created in Firebase Auth
- [ ] Test user document created in Firestore
- [ ] App runs without Firebase errors
- [ ] Login works with test user
- [ ] Firestore data can be read/written
- [ ] Security rules block unauthorized access

---

## Next Steps

After completing setup:

1. **Populate test data** - Create sample meetings, votings, announcements
2. **Test all features** - Verify each feature works with your data
3. **Configure production** - Set up production Firebase project
4. **Deploy** - Follow [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
5. **Monitor** - Set up alerts and monitoring

---

## Support Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [Firestore Setup Guide](https://firebase.google.com/docs/firestore/quickstart)
- [Firebase Auth Guide](https://firebase.google.com/docs/auth)
- [Firebase Storage Guide](https://firebase.google.com/docs/storage)

---

**Completion Date**: _______________
**Deployed By**: _______________
**Firebase Project ID**: _______________
