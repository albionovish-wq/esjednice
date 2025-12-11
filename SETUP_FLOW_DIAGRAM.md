# eSjednice - Setup Flow Diagram

## Complete Setup Flow (Visual Guide)

```
┌─────────────────────────────────────────────────────────────┐
│         START: eSjednice Setup Process                      │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────┐
        │ 1. Create Firebase Project │
        │  ✓ Go to firebase.google.com
        │  ✓ Create new project       │
        │  ✓ Enable Google Analytics  │
        │  ✓ Note Project ID          │
        └────────────────┬────────────┘
                         │
                         ▼
        ┌────────────────────────────┐
        │ 2. Setup Firestore Database│
        │  ✓ Create database         │
        │  ✓ Select region           │
        │  ✓ Create 4 collections:   │
        │    - korisnici             │
        │    - sjednice              │
        │    - glasanja              │
        │    - obavijesti            │
        └────────────────┬────────────┘
                         │
                         ▼
        ┌────────────────────────────┐
        │ 3. Create Firestore Indexes│
        │  ✓ 6 indexes total         │
        │  ✓ One per query pattern   │
        │  ✓ Follow SETUP_MANUAL.md  │
        └────────────────┬────────────┘
                         │
                         ▼
        ┌────────────────────────────┐
        │ 4. Enable Authentication   │
        │  ✓ Email/Password method   │
        │  ✓ Toggle Enable: ON       │
        │  ✓ Save settings           │
        └────────────────┬────────────┘
                         │
                         ▼
        ┌────────────────────────────┐
        │ 5. Create Storage Bucket   │
        │  ✓ Select same region      │
        │  ✓ Production mode         │
        │  ✓ Create /sjednice folder │
        └────────────────┬────────────┘
                         │
                         ▼
        ┌────────────────────────────┐
        │ 6. Deploy Security Rules   │
        │  ✓ Install Firebase CLI    │
        │  ✓ firebase login          │
        │  ✓ firebase use PROJECT_ID │
        │  ✓ firebase deploy         │
        └────────────────┬────────────┘
                         │
                         ▼
        ┌────────────────────────────┐
        │ 7. Update App Config       │
        │  ✓ Get Web SDK credentials │
        │  ✓ Update firebase_options │
        │  ✓ Verify all fields       │
        └────────────────┬────────────┘
                         │
                         ▼
        ┌────────────────────────────┐
        │ 8. Create Test Data        │
        │  ✓ Create test user in Auth
        │  ✓ Create user doc in DB   │
        │  ✓ Set role and groups     │
        └────────────────┬────────────┘
                         │
                         ▼
        ┌────────────────────────────┐
        │ 9. Run & Test App          │
        │  ✓ flutter pub get         │
        │  ✓ flutter run             │
        │  ✓ Test login              │
        │  ✓ Test features           │
        └────────────────┬────────────┘
                         │
                         ▼
        ┌────────────────────────────┐
        │ ✓ SETUP COMPLETE           │
        │   Ready for Production     │
        └────────────────────────────┘
```

---

## Firebase Configuration Dependencies

```
Firebase Project
│
├─ Firestore Database
│  ├─ Collections
│  │  ├─ korisnici (users)
│  │  ├─ sjednice (meetings)
│  │  ├─ glasanja (votings)
│  │  └─ obavijesti (announcements)
│  ├─ Indexes (6 total)
│  └─ Security Rules
│
├─ Authentication
│  ├─ Email/Password
│  ├─ Test Users
│  └─ OAuth Consent Screen (optional)
│
├─ Storage
│  ├─ Bucket
│  └─ /sjednice folder
│
└─ Web SDK Credentials
   └─ → firebase_options.dart
```

---

## Data Flow Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                     Flutter Application                      │
│  ┌────────────────────────────────────────────────────────┐  │
│  │              UI Screens (lib/sucelja/)                │  │
│  │  ┌──────────┬──────────┬──────────┬──────────────────┐ │  │
│  │  │ Prijava  │Dashboard │Sjednice  │Glasanja/Obavijesti
│  │  └──────────┴──────────┴──────────┴──────────────────┘ │  │
│  └────────┬───────────────────────────────────────────────┘  │
│           │                                                   │
│           ▼                                                   │
│  ┌────────────────────────────────────────────────────────┐  │
│  │         Riverpod Providers (lib/provideri/)            │  │
│  │  ┌──────────┬──────────┬──────────┬──────────────────┐ │  │
│  │  │ auth     │ global   │sjednice  │glasanja/obavijesti
│  │  │ service  │ providers│ notifier │notifier          │  │
│  │  └──────────┴──────────┴──────────┴──────────────────┘ │  │
│  └────────┬───────────────────────────────────────────────┘  │
│           │                                                   │
└───────────┼───────────────────────────────────────────────────┘
            │
            ▼
┌──────────────────────────────────────────────────────────────┐
│              Firebase Backend (Cloud)                         │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ ┌─────────────┐  ┌──────────────┐  ┌──────────────┐   │  │
│  │ │Authentication  │Firestore DB  │ │Cloud Storage │   │  │
│  │ │             │  │              │  │              │   │  │
│  │ │ Email/Pass  │  │ korisnici    │  │ sjednice/    │   │  │
│  │ │ User Auth   │  │ sjednice     │  │ dokumenti/   │   │  │
│  │ │             │  │ glasanja     │  │ files        │   │  │
│  │ │             │  │ obavijesti   │  │              │   │  │
│  │ └─────────────┘  └──────────────┘  └──────────────┘   │  │
│  │                                                        │  │
│  │         Security Rules (firestore.rules)              │  │
│  │         - Role-based access control                   │  │
│  │         - Group filtering                             │  │
│  │         - One-vote enforcement                        │  │
│  └────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

---

## User Authentication & Authorization Flow

```
┌─────────────────────────────────────────────────────────────┐
│              User Lifecycle                                 │
└─────────────────────────────────────────────────────────────┘

REGISTRATION:
┌──────────────┐    ┌───────────────┐    ┌─────────────────┐
│   User       │───▶│   Firebase    │───▶│   Firestore     │
│   Registers  │    │   Auth        │    │   korisnici     │
└──────────────┘    └───────────────┘    └─────────────────┘
                        │ Creates UID
                        │
                    ┌───▼──────────────┐
                    │ Email verified   │
                    └────────────────┘

LOGIN:
┌──────────────┐    ┌───────────────┐    ┌─────────────────┐
│   User       │───▶│   Firebase    │───▶│   Check User    │
│   Submits    │    │   Auth        │    │   Permissions   │
│   Credentials│    │   Validates   │    │   & Groups      │
└──────────────┘    └───────────────┘    └─────────────────┘
                          │
                          ▼ (on success)
                    ┌─────────────┐
                    │ Issue Token │
                    └──────┬──────┘
                           │
                           ▼
                    ┌──────────────┐
                    │ App Loads    │
                    │ Dashboard    │
                    └──────────────┘

ACCESS CONTROL:
┌──────────────┐    ┌─────────────────────┐    ┌──────────────┐
│  User Views  │───▶│  Security Rules     │───▶│  Return Data │
│  Resource    │    │  Check:             │    │  (if allowed)│
└──────────────┘    │ 1. Authentication   │    └──────────────┘
                    │ 2. User Role        │
                    │ 3. Group Membership │
                    └─────────────────────┘
```

---

## Firestore Collections Relationship

```
                    ┌─────────────────┐
                    │   korisnici     │
                    │   (Users)       │
                    │                 │
                    │ uid (PK)        │
                    │ email           │
                    │ nama            │
                    │ uloga           │
                    │ grupe[] ◄──────┐│
                    └─────────────────┘
                           ▲           │
                           │           │
                ┌──────────┘           └──────────┐
                │                                  │
                │                                  │
         ┌──────────────┐                  ┌──────────────┐
         │  sjednice    │◄─────┐           │  glasanja    │
         │ (Meetings)   │      │      ┌────│ (Votings)    │
         │              │      │      │    │              │
         │ id (PK)      │      │      │    │ id (PK)      │
         │ naslov       │      │      │    │ naslov       │
         │ grupa ◄──────┼──────┴──────┼────│ grupa ◄─────┐
         │ vrijeme      │             │    │ status       │
         │ sazivac ─────┼──┐          │    │ glasovi[]    │
         │ zapisnicar ──┼──┼──┐       │    └──────────────┘
         │ status       │  │  │       │
         │ dnevniRed[]  │  │  │  ┌────────────────┐
         │ prisutnost[] │  │  │  │  obavijesti   │
         │ dokumenti[]  │  │  │  │ (Announcements)
         └──────────────┘  │  │  │                │
                           │  │  │ id (PK)       │
                           │  │  │ naslov        │
                           │  │  │ tip           │
                           │  │  │ grupe[]       │
                           │  │  │ uloge[]       │
                           └──┴──┴─ vrijeme      │
                                  │ aktivan      │
                                  └────────────┘
```

---

## Feature Implementation Stack

```
┌────────────────────────────────────────────────────────────┐
│                   Feature: Meetings                        │
├────────────────────────────────────────────────────────────┤
│ UI Layer          │ State Layer           │ Database Layer │
├───────────────────┼───────────────────────┼────────────────┤
│ sjednice.dart     │ sjednice.dart         │ korisnici      │
│ └─ List meetings  │ └─ StreamProvider     │ └─ User role   │
│                   │    (fetch & filter)   │    & groups    │
│                   │                       │                │
│ detalji_sjedni... │ sjednice_notifier.dart│ sjednice       │
│ └─ View details   │ └─ CRUD operations    │ └─ Meeting doc │
│                   │                       │    & subcoll   │
│ kreiraj_sjedni... │ dokumenti_notifier... │ Storage        │
│ └─ Create meeting │ └─ Upload files       │ └─ Minutes doc │
│                   │                       │                │
│ uredi_sjednica    │ Global providers      │ Indexes        │
│ └─ Edit meeting   │ └─ Auth state         │ └─ Queries     │
│                   │ └─ User data          │    optimized   │
└───────────────────┴───────────────────────┴────────────────┘
```

---

## Setup Timeline Estimate

```
Task                           Time      Total
─────────────────────────────────────────────────
Firebase Project Setup         10 min    10 min
Firestore Database             15 min    25 min
Firestore Indexes               5 min    30 min
Authentication Setup            5 min    35 min
Storage Bucket                  5 min    40 min
Security Rules Deployment      10 min    50 min
App Configuration               5 min    55 min
Test Data Creation             10 min    65 min
Testing & Verification         20 min    85 min
─────────────────────────────────────────────────
TOTAL SETUP TIME:              ~90 minutes (1.5 hours)

First-time setup may take longer (2-3 hours)
Subsequent setups faster (45-60 minutes)
```

---

## Troubleshooting Decision Tree

```
                    ┌─── App Won't Start ──┐
                    │                      │
                    ▼                      ▼
           ┌──────────────┐      ┌──────────────┐
           │ Firebase     │      │ Dart/Flutter │
           │ Credentials? │      │ Issue?       │
           └────┬─────────┘      └──────┬───────┘
                │                       │
           NO  ├─ Check firebase_options.dart
               │  Update with correct credentials
               │
           YES ├─ flutter pub get
                  └─ flutter clean

                    ┌─── Can't Login ──────┐
                    │                      │
                    ▼                      ▼
           ┌──────────────┐      ┌──────────────┐
           │ Auth         │      │ Firestore    │
           │ Enabled?     │      │ Rules OK?    │
           └────┬─────────┘      └──────┬───────┘
                │                       │
           NO  ├─ Enable Email/Password
               │
           YES ├─ Check user exists in
                  Firestore korisniki

                 ┌─── "Permission Denied" ──┐
                 │                          │
                 ▼                          ▼
         ┌──────────────┐          ┌──────────────┐
         │ Rules        │          │ User Role    │
         │ Deployed?    │          │ Correct?     │
         └────┬─────────┘          └──────┬───────┘
              │                           │
         NO  ├─ firebase deploy           │
             │  --only firestore:rules    │
             │                            │
         YES ├─ Check uloga field in
                korisniki collection
                └─ Should match one of:
                   ravnatelj, zapisnicar,
                   nastavnik, roditelj, ucenik
```

---

## Dependency Chain

Setup must follow this order:

```
1. Firebase Project
   ↓ (required for)
2. Firestore Database
   ↓ (required for)
3. Collections & Indexes
   ↓ (required for)
4. Security Rules
   ↓ (required for)
5. App Configuration
   ↓ (required for)
6. Authentication Setup
   ├─ (runs in parallel)
   └─ Storage Setup
   ↓ (all required for)
7. Test Data
   ↓ (required for)
8. App Testing
```

---

**Key Takeaway**: Follow the setup flow diagram step-by-step. Don't skip steps or change the order. Each step enables the next one.

For detailed instructions, see: [SETUP_MANUAL.md](SETUP_MANUAL.md)

For quick reference: [SETUP_QUICK_REFERENCE.md](SETUP_QUICK_REFERENCE.md)
