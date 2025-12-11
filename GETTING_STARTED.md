# Getting Started with eSjednice

## Quick Start Guide

### Prerequisites
- Flutter 3.0+ ([Install Flutter](https://flutter.dev/docs/get-started/install))
- Dart 3.0+
- Firebase Account ([Create Account](https://firebase.google.com))
- Git

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/esjednice.git
cd esjednice
```

### 2. Install Dependencies

```bash
# Get Flutter packages
flutter pub get

# Analyze code
flutter analyze

# Check for issues
flutter doctor
```

### 3. Configure Firebase

#### Option A: Use Existing Firebase Project

```bash
# Login to Firebase
firebase login

# Select your project
firebase use YOUR_PROJECT_ID

# Download Firebase config
firebase setup:web

# Update lib/firebase_options.dart with credentials
```

#### Option B: Create New Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create new project "eSjednice"
3. Enable Firestore Database
4. Enable Firebase Authentication (Email/Password)
5. Enable Firebase Storage
6. Copy Web SDK credentials
7. Update `lib/firebase_options.dart`

### 4. Run the Application

#### Web
```bash
# Run in development
flutter run -d chrome

# Or build for production
flutter build web --release
```

#### Android
```bash
# Run on device/emulator
flutter run -d android

# Build APK
flutter build apk --release
```

#### iOS
```bash
# Run on device/simulator
flutter run -d ios

# Build IPA
flutter build ios --release
```

---

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── firebase_options.dart              # Firebase config
├── dizajn_sistem/
│   └── dizajn_sistem.dart            # Design system & theme
├── modeli/                            # Data models
│   ├── korisnik.dart                 # User model
│   ├── sjednica.dart                 # Meeting model
│   ├── glasanje.dart                 # Voting model
│   └── obavijest.dart                # Announcement model
├── provideri/                         # State management (Riverpod)
│   ├── auth.dart                     # Authentication
│   ├── global.dart                   # Global providers
│   ├── sjednice.dart                 # Meeting providers
│   ├── sjednice_notifier.dart        # Meeting CRUD
│   ├── glasanja.dart                 # Voting providers
│   ├── glasanja_notifier.dart        # Voting CRUD
│   ├── obavijesti.dart               # Announcement providers
│   ├── obavijesti_notifier.dart      # Announcement CRUD
│   └── dokumenti_notifier.dart       # File upload
├── sucelja/                           # Screens
│   ├── prijava.dart                  # Login screen
│   ├── dashboard.dart                # Home screen
│   ├── sjednice.dart                 # Meetings list
│   ├── detalji_sjednice.dart         # Meeting details
│   ├── kreiraj_sjednica.dart         # Create meeting
│   ├── uredi_sjednica.dart           # Edit meeting
│   ├── glasanja.dart                 # Votings list
│   ├── detalji_glasanja.dart         # Voting participation
│   ├── komunikacija.dart             # Announcements
│   ├── grupe.dart                    # Groups
│   └── postavke.dart                 # Settings
├── komponente/                        # Reusable components
│   ├── komponente.dart               # Main components
│   └── upload_dokument.dart          # File upload widget
└── utils/
    └── error_handler.dart            # Error handling

test/
├── modeli/                           # Model tests
│   ├── glasanje_test.dart
│   └── obavijest_test.dart
└── integration/                      # Integration tests
    └── auth_flow_test.dart
```

---

## Authentication

### Login

1. Navigate to login screen (automatic on first launch)
2. Enter email and password
3. Click "Prijava" (Sign In)
4. On success, redirected to Dashboard

### Register

1. On login screen, click "Nemam račun" (No account)
2. Enter email, password, first name, last name
3. Click "Kreiraj račun" (Create Account)
4. Account created with default role "Nastavnik" (Teacher)

### Reset Password

1. On login screen, click "Zaboravljena lozinka" (Forgot Password)
2. Enter email address
3. Check email for reset link
4. Follow link to reset password

---

## Key Features

### Meetings Management
- Create meetings with agenda items
- Set date, time, and location
- Invite specific groups
- Track attendance
- Manage meeting status
- Upload minutes documents

### Voting System
- Create voting on agenda items
- Multiple voting options
- Real-time vote counting
- View results
- One-vote-per-user enforcement

### Announcements
- Broadcast to all users
- Target specific groups
- Target specific roles
- Activate/deactivate announcements

### User Management
- Role-based access control
- Group memberships
- Profile management
- Last login tracking

---

## Development Workflow

### Creating a New Feature

1. **Create Model** (if needed)
```dart
// lib/modeli/nova_funkcionalnost.dart
class NovaFunkcionalnost {
  final String id;
  // ... properties
}
```

2. **Create Providers**
```dart
// lib/provideri/nova_funkcionalnost.dart
final novaFunkcionalnostProvider = StreamProvider<List<NovaFunkcionalnost>>((ref) {
  // Logic here
});

// lib/provideri/nova_funkcionalnost_notifier.dart
class NovaFunkcionalnostNotifier extends StateNotifier<AsyncValue<void>> {
  // CRUD operations
}
```

3. **Create Screen**
```dart
// lib/sucelja/nova_funkcionalnost.dart
class NovaFunkcionalnostEkran extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // UI here
  }
}
```

4. **Add Route** (in main.dart)
```dart
case '/nova-funkcionalnost':
  return MaterialPageRoute(builder: (_) => const NovaFunkcionalnostEkran());
```

### Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/modeli/glasanje_test.dart

# Run with coverage
flutter test --coverage
```

### Code Analysis

```bash
# Analyze code
flutter analyze

# Format code
flutter format lib/

# Check if code is properly formatted
flutter format --set-exit-if-changed lib/
```

---

## Firebase Setup Details

### Firestore Collections Structure

#### korisnici
- `uid` (string) - User ID
- `email` (string)
- `ime` (string) - First name
- `prezime` (string) - Last name
- `uloga` (string) - User role
- `grupe` (array) - Group IDs
- `created` (timestamp)
- `lastLogin` (timestamp)
- `aktivan` (boolean)

#### sjednice
- `id` (string)
- `naslov` (string)
- `grupa` (string)
- `vrijeme` (timestamp)
- `status` (string) - planned, inProgress, concluded, canceled
- `dnevniRed` (array) - Agenda items
- `prisutnost` (array) - Attendance records
- `dokumenti` (array) - Uploaded files

#### glasanja
- `id` (string)
- `sjednicaId` (string)
- `naslov` (string)
- `grupa` (string)
- `opcije` (array) - Voting options
- `status` (string) - openForVoting, closed
- `glasovi` (array) - Vote records
- `krajnjeVrijeme` (timestamp)

#### obavijesti
- `id` (string)
- `naslov` (string)
- `sadrzaj` (string)
- `tip` (string) - opca, grupa, uloga
- `grupe` (array) - Target groups (if grupa type)
- `uloge` (array) - Target roles (if uloga type)
- `vrijeme` (timestamp)
- `aktivna` (boolean)

---

## Common Tasks

### Add New Role

1. Update `KorisnikUloga` enum in `lib/modeli/korisnik.dart`
2. Add display name in extension
3. Update security rules in `firestore.rules`
4. Update filtering logic in providers

### Create Custom Component

```dart
// lib/komponente/moja_komponenta.dart
class MojaKomponenta extends StatelessWidget {
  const MojaKomponenta({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppDesign.white,
        borderRadius: BorderRadius.circular(AppDesign.cardRadius),
        border: Border.all(color: AppDesign.borderGray),
      ),
      child: // Your widget
    );
  }
}
```

### Handle Errors

```dart
try {
  // Your async operation
  await someAsyncOperation();
} on FirebaseAuthException catch (e) {
  final message = ErrorHandler.handleAuthError(e);
  ErrorHandler.showErrorSnackbar(context: context, message: message);
} catch (e) {
  final message = ErrorHandler.handleGenericError(e as Exception);
  ErrorHandler.showErrorSnackbar(context: context, message: message);
}
```

---

## Deployment

### Web Deployment

```bash
# Build for web
flutter build web --release

# Deploy to Firebase
firebase deploy --only hosting:esjednice
```

### Mobile Deployment

See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for detailed instructions.

---

## Troubleshooting

### Compilation Errors

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub upgrade
flutter analyze
```

### Firebase Connection Issues

- Check Firebase credentials in `lib/firebase_options.dart`
- Verify Firestore rules are deployed
- Check internet connection
- Restart emulator/device

### State Management Issues

- Check provider syntax
- Ensure proper disposal of listeners
- Use `.autoDispose` for temporary data
- Verify Riverpod dependency versions

---

## Documentation

- [PROJECT_STATUS.md](PROJECT_STATUS.md) - Complete project overview
- [PHASE_4_DETAILED.md](PHASE_4_DETAILED.md) - Security and features
- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - Deployment instructions
- [PRODUCTION_CHECKLIST.md](PRODUCTION_CHECKLIST.md) - Launch checklist

---

## Support

### Getting Help

1. Check existing documentation
2. Review test files for examples
3. Check Firebase Console for errors
4. Consult Flutter documentation
5. Contact development team

### Reporting Issues

Include:
- Description of issue
- Steps to reproduce
- Expected vs actual behavior
- Screenshots/logs
- Device/browser info

---

## Next Steps

1. **Set up Firebase Project** - Follow Firebase setup section
2. **Run locally** - Test with `flutter run`
3. **Review code** - Understand project structure
4. **Make changes** - Create features following workflow
5. **Test thoroughly** - Run tests and manual testing
6. **Deploy** - Follow deployment guide

---

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [Material Design](https://material.io/design)

---

**Happy coding! 🚀**
