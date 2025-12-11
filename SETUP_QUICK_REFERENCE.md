# eSjednice - Setup Quick Reference Card

**Print this page for quick access during setup!**

---

## Firebase Project IDs & Credentials

**Record your values here:**

```
Project Name: _______________________
Project ID: _______________________
Project Number: _______________________
Region: _______________________
```

---

## Firebase Web SDK Configuration

**Copy from Firebase Console → Project Settings → Your Apps → Web:**

```
apiKey = _______________________
appId = _______________________
messagingSenderId = _______________________
projectId = _______________________
authDomain = _______________________
storageBucket = _______________________
databaseURL = _______________________
```

---

## Step Checklist

### Phase 1: Create Firebase Project
- [ ] Go to https://console.firebase.google.com
- [ ] Click "Create project"
- [ ] Name: `eSjednice`
- [ ] Accept terms
- [ ] Enable Google Analytics (optional)
- [ ] Wait for creation complete

### Phase 2: Firestore Database
- [ ] Left menu → "Firestore Database"
- [ ] Click "Create database"
- [ ] Select region: _______________________
- [ ] Production mode
- [ ] Click "Create"
- [ ] Create collections (no documents needed yet):
  - [ ] `korisnici`
  - [ ] `sjednice`
  - [ ] `glasanja`
  - [ ] `obavijesti`

### Phase 3: Firestore Indexes
- [ ] Go to "Indexes" tab
- [ ] Create 6 indexes (see SETUP_MANUAL.md for details)
  - [ ] Index 1: sjednice (grupa + status)
  - [ ] Index 2: sjednice (vrijeme)
  - [ ] Index 3: glasanja (grupa + krajnjeVrijeme)
  - [ ] Index 4: glasanja (status)
  - [ ] Index 5: obavijesti (aktivna + vrijeme)
  - [ ] Index 6: obavijesti (tip)

### Phase 4: Authentication
- [ ] Left menu → "Authentication"
- [ ] Click "Get started"
- [ ] Click "Email/Password"
- [ ] Toggle Enable: ON
- [ ] Click "Save"

### Phase 5: Storage
- [ ] Left menu → "Storage"
- [ ] Click "Get started"
- [ ] Select region: _______________________
- [ ] Production mode
- [ ] Click "Create"
- [ ] Create folder: `sjednice`

### Phase 6: Deploy Security Rules
- [ ] Install Firebase CLI: `npm install -g firebase-tools`
- [ ] In project directory: `firebase login`
- [ ] Get project ID: `firebase projects:list`
- [ ] Select project: `firebase use PROJECT_ID`
- [ ] Deploy: `firebase deploy --only firestore:rules`
- [ ] Verify: Check Firebase Console → Firestore → Rules

### Phase 7: App Configuration
- [ ] Get Web SDK credentials from Firebase Console
- [ ] Update `lib/firebase_options.dart`:
  ```dart
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_AUTH_DOMAIN',
    databaseURL: 'YOUR_DATABASE_URL',
    storageBucket: 'YOUR_STORAGE_BUCKET',
  );
  ```

### Phase 8: Test Data
- [ ] Create test user in Firebase Auth:
  - Email: `test@example.com`
  - Password: `Test1234!`
- [ ] Create user document in Firestore:
  - Collection: `korisniki`
  - Document ID: (user UID from Auth)
  - Fields:
    - email: test@example.com
    - ime: Test
    - prezime: User
    - uloga: nastavnik
    - grupe: ["Grupa A"]
    - created: (server timestamp)
    - aktivan: true

### Phase 9: Run & Test
- [ ] Run: `flutter pub get`
- [ ] Run: `flutter run -d chrome` (for web)
- [ ] Test login with test user
- [ ] Test creating meeting
- [ ] Verify Firestore data saved
- [ ] Test security rules

---

## Key Firestore Collections Reference

### korisnici (Users)
```
Document ID = user UID (from Firebase Auth)
├─ email: string
├─ ime: string
├─ prezime: string
├─ uloga: string (ravnatelj|zapisnicar|nastavnik|roditelj|ucenik)
├─ grupe: array (e.g., ["Grupa A", "Grupa B"])
├─ created: timestamp
├─ lastLogin: timestamp
└─ aktivan: boolean
```

### sjednice (Meetings)
```
Document ID = auto-generated
├─ naslov: string
├─ opis: string
├─ grupa: string
├─ vrijeme: timestamp
├─ lokacija: string
├─ status: string (planned|inProgress|concluded|canceled)
├─ sazivac: string (organizer UID)
├─ zapisnicar: string (secretary UID)
├─ dnevniRed: array
├─ prisutnost: array
├─ dokumenti: array
├─ created: timestamp
└─ updated: timestamp
```

### glasanja (Votings)
```
Document ID = auto-generated
├─ sjednicaId: string
├─ stavkaId: string
├─ naslov: string
├─ opis: string
├─ grupa: string
├─ opcije: array (e.g., ["Da", "Ne", "Suzdržan"])
├─ status: string (openForVoting|closed)
├─ glasovi: array
├─ pocetneVrijeme: timestamp
├─ krajnjeVrijeme: timestamp
├─ created: timestamp
└─ updated: timestamp
```

### obavijesti (Announcements)
```
Document ID = auto-generated
├─ naslov: string
├─ sadrzaj: string
├─ autorizdId: string
├─ autoriziranoIme: string
├─ tip: string (opca|grupa|uloga)
├─ grupe: array (if tip=grupa)
├─ uloge: array (if tip=uloga)
├─ vrijeme: timestamp
├─ aktivna: boolean
├─ created: timestamp
└─ updated: timestamp
```

---

## Troubleshooting Quick Fixes

| Problem | Quick Fix |
|---------|-----------|
| "Collection not found" | Create collections in Firestore (korisnici, sjednice, glasanja, obavijesti) |
| "Permission denied" | Deploy security rules: `firebase deploy --only firestore:rules` |
| "Invalid Firebase Credentials" | Check firebase_options.dart - verify exact copy from console |
| "Cannot authenticate" | Enable Email/Password in Firebase Auth |
| "Storage bucket not found" | Create storage bucket in Firebase Console |
| "Flutter can't find Firebase" | Run `flutter pub get` and `flutter clean` |
| "App won't build" | Run `flutter pub upgrade` |

---

## User Roles Quick Reference

| Role | Access | Can Create | Typical User |
|------|--------|-----------|---|
| **ravnatelj** | All data | Everything | School principal |
| **zapisnicar** | Assigned groups | Meetings, votings | Secretary/coordinator |
| **nastavnik** | Assigned groups | Participate | Teacher |
| **roditelj** | Assigned groups (read) | Vote | Parent |
| **ucenik** | Assigned groups (read) | None | Student |

---

## Common Test Groups

Create these in your Firestore for testing:

- `Grupa A` - Class/Group A
- `Grupa B` - Class/Group B
- `Nastavnički zbor` - Teachers council
- `Roditeljski odbor` - Parents board
- `Uprava` - Administration

---

## File Locations Reference

| File/Folder | Purpose |
|------------|---------|
| `lib/firebase_options.dart` | Firebase configuration (update with your credentials) |
| `lib/provideri/auth.dart` | Authentication logic |
| `lib/provideri/global.dart` | Global providers (auth state, user data) |
| `firestore.rules` | Firestore security rules (deploy via Firebase CLI) |
| `test/` | Test files |
| `lib/modeli/` | Data models |
| `lib/provideri/` | State management providers |
| `lib/sucelja/` | UI screens |
| `lib/komponente/` | Reusable components |
| `lib/dizajn_sistem/` | Design system & theme |

---

## Firebase CLI Commands Cheat Sheet

```bash
# Login
firebase login

# List projects
firebase projects:list

# Use specific project
firebase use PROJECT_ID

# Validate rules (dry-run)
firebase deploy --only firestore:rules --dry-run

# Deploy rules
firebase deploy --only firestore:rules

# Start emulator
firebase emulator:start

# Deploy web app
firebase deploy --only hosting

# Check deployment status
firebase apps:list
```

---

## Deployment Checklist

Before deploying to production:

- [ ] Firebase project created
- [ ] Firestore configured with all collections
- [ ] Indexes created (6 total)
- [ ] Authentication enabled
- [ ] Storage bucket created
- [ ] Security rules deployed
- [ ] firebase_options.dart updated
- [ ] Test user can login
- [ ] Test data can be saved/retrieved
- [ ] Security rules block unauthorized access
- [ ] Error handling tested
- [ ] Performance tested
- [ ] All features verified

---

## Contact & Support

- Firebase Docs: https://firebase.google.com/docs
- Flutter Docs: https://flutter.dev/docs
- Firestore Issues: https://firebase.google.com/support
- Stack Overflow: Tag with [firebase] [flutter]

---

**Setup Started**: _______________
**Setup Completed**: _______________
**Tested By**: _______________
**Ready for Production**: [ ] Yes [ ] No
