# eSjednice - Providers Reference Guide

Complete reference for all Riverpod providers and their usage.

---

## Table of Contents
1. [Providers Overview](#providers-overview)
2. [Authentication Providers](#authentication-providers)
3. [User Providers](#user-providers)
4. [Meeting Providers](#meeting-providers)
5. [Voting Providers](#voting-providers)
6. [Announcement Providers](#announcement-providers)
7. [File Upload Providers](#file-upload-providers)
8. [Usage Examples](#usage-examples)

---

## Providers Overview

**Total Providers**: 20+ across 8 files

| File | Type | Purpose |
|------|------|---------|
| `auth.dart` | Service | Firebase authentication logic |
| `global.dart` | Providers | Global state (auth, user data) |
| `sjednice.dart` | Providers | Meeting queries and stats |
| `sjednice_notifier.dart` | Notifier | Meeting CRUD operations |
| `glasanja.dart` | Providers | Voting queries and stats |
| `glasanja_notifier.dart` | Notifier | Voting CRUD operations |
| `obavijesti.dart` | Providers | Announcement queries and stats |
| `obavijesti_notifier.dart` | Notifier | Announcement CRUD operations |
| `dokumenti_notifier.dart` | Notifier | File upload operations |

---

## Authentication Providers

### Location
`lib/provideri/auth.dart`

### AuthService Class

```dart
class AuthService {
  // Authentication methods
  Stream<User?> get authStateChanges
  Future<User?> signUpWithEmailPassword(...)
  Future<User?> signInWithEmailPassword(...)
  Future<void> signOut()
  Future<void> resetPassword(...)
  User? get currentUser
}
```

### Available Methods

#### signUpWithEmailPassword
```dart
Future<User?> signUpWithEmailPassword({
  required String email,
  required String password,
  required String ime,
  required String prezime,
})
```
**Purpose**: Register new user account
**Returns**: Firebase User or null
**Creates**: User document in korisnici collection

#### signInWithEmailPassword
```dart
Future<User?> signInWithEmailPassword({
  required String email,
  required String password,
})
```
**Purpose**: Login with credentials
**Returns**: Firebase User or null
**Updates**: lastLogin timestamp

#### signOut
```dart
Future<void> signOut()
```
**Purpose**: Logout current user
**Side effects**: Clears auth session

#### resetPassword
```dart
Future<void> resetPassword({
  required String email,
})
```
**Purpose**: Send password reset email
**Throws**: Exception if email not found

---

## User Providers

### Location
`lib/provideri/global.dart`

### authServiceProvider
```dart
final authServiceProvider = Provider<AuthService>
```
**Type**: Provider
**Returns**: AuthService instance
**Usage**: Access authentication methods

**Example**:
```dart
final authService = ref.read(authServiceProvider);
await authService.signOut();
```

### authStateProvider
```dart
final authStateProvider = StreamProvider<User?>
```
**Type**: StreamProvider
**Returns**: Firebase User or null
**Updates**: When auth state changes
**Usage**: Monitor login/logout

**Example**:
```dart
final authState = ref.watch(authStateProvider);
authState.when(
  data: (user) => user != null ? Dashboard() : Login(),
  error: (e, st) => ErrorWidget(),
  loading: () => LoadingWidget(),
);
```

### korisnikPodaciProvider
```dart
final korisnikPodaciProvider = StreamProvider<Korisnik?>
```
**Type**: StreamProvider
**Returns**: Current user data or null
**Fetches from**: korisnici collection
**Updates**: Real-time changes to user document
**Usage**: Access user info (role, groups, etc.)

**Example**:
```dart
final korisnikData = ref.watch(korisnikPodaciProvider);
korisnikData.whenData((user) {
  print('User role: ${user?.uloga.displayName}');
  print('User groups: ${user?.grupe}');
});
```

### korisnikUlogaProvider
```dart
final korisnikUlogaProvider = FutureProvider<KorisnikUloga?>
```
**Type**: FutureProvider
**Returns**: Current user's role (async)
**Values**: ravnatelj, zapisnicar, nastavnik, roditelj, ucenik
**Usage**: Check user role for access control

**Example**:
```dart
final uloga = ref.watch(korisnikUlogaProvider);
if (uloga.value == KorisnikUloga.ravnatelj) {
  // Show admin features
}
```

### korisnikGrupeProvider
```dart
final korisnikGrupeProvider = FutureProvider<List<String>>
```
**Type**: FutureProvider
**Returns**: List of group IDs user belongs to
**Usage**: Filter content by user's groups

**Example**:
```dart
final grupe = ref.watch(korisnikGrupeProvider);
grupe.whenData((userGroups) {
  // Filter meetings by userGroups
});
```

### trenutniKorisnikProvider
```dart
final trenutniKorisnikProvider = StreamProvider<Korisnik?>
```
**Type**: StreamProvider
**Returns**: Current user with real-time updates
**Usage**: Alternative to korisnikPodaciProvider with different error handling

---

## Meeting Providers

### Location
`lib/provideri/sjednice.dart` and `lib/provideri/sjednice_notifier.dart`

### sjedniceProvider
```dart
final sjedniceProvider = StreamProvider<List<Sjednica>>
```
**Type**: StreamProvider
**Returns**: List of meetings (filtered by user role/group)
**Updates**: Real-time from sjednice collection
**Filtering**:
- Ravnatelj: See all meetings
- Others: See only their group's meetings
**Ordering**: By vrijeme (descending)

**Example**:
```dart
final sjednice = ref.watch(sjedniceProvider);
sjednice.whenData((meetings) {
  meetings.forEach((meeting) {
    print('${meeting.naslov} - ${meeting.status}');
  });
});
```

### pojedinacnaSjednicaProvider
```dart
final pojedinacnaSjednicaProvider = 
    StreamProvider.family<Sjednica?, String>
```
**Type**: Family StreamProvider
**Parameter**: sjednicaId (meeting ID)
**Returns**: Single meeting with real-time updates
**Usage**: Get specific meeting details

**Example**:
```dart
final meeting = ref.watch(
  pojedinacnaSjednicaProvider('meeting-id-123')
);
```

### sjedniceStatsProvider
```dart
final sjedniceStatsProvider = FutureProvider<Map<String, int>>
```
**Type**: FutureProvider
**Returns**: Statistics map:
```dart
{
  'planned': int,      // Meetings in planned status
  'inProgress': int,   // Meetings in progress
  'concluded': int,    // Finished meetings
  'canceled': int,     // Cancelled meetings
  'total': int         // Total meetings
}
```
**Usage**: Dashboard statistics

**Example**:
```dart
final stats = ref.watch(sjedniceStatsProvider);
stats.whenData((data) {
  print('Planned: ${data['planned']}');
});
```

### sjedniceNotifierProvider
```dart
final sjedniceNotifierProvider = 
    StateNotifierProvider<SjedniceNotifier, AsyncValue<void>>
```
**Type**: StateNotifierProvider
**Methods Available**:

#### createSjednica
```dart
Future<String> createSjednica({
  required String naslov,
  required String opis,
  required String grupa,
  required DateTime vrijeme,
  required String lokacija,
  required String sazivac,
  String? zapisnicar,
  List<DnevniRedItem>? dnevniRed,
})
```
**Returns**: Meeting ID
**Creates**: New sjednice document

#### updateSjednica
```dart
Future<void> updateSjednica({
  required String sjednicaId,
  required String naslov,
  required String opis,
  required String grupa,
  required DateTime vrijeme,
  required String lokacija,
  String? zapisnicar,
  List<DnevniRedItem>? dnevniRed,
})
```
**Updates**: Meeting details

#### updateStatus
```dart
Future<void> updateStatus({
  required String sjednicaId,
  required SjednicaStatus status,
})
```
**Values**: planned, inProgress, concluded, canceled

#### updateAttendance
```dart
Future<void> updateAttendance({
  required String sjednicaId,
  required String korisnikId,
  required String prezentacija,
})
```
**Values**: "Planirana", "Prisutan", "Izostao"
**Updates**: Attendance record

#### addAgendaItem
```dart
Future<void> addAgendaItem({
  required String sjednicaId,
  required String naslov,
  required String opis,
  required String vrsta,
  String? glasanjeId,
})
```
**Vrsta**: "obavijest", "glasanje", "rasprava"

#### removeAgendaItem
```dart
Future<void> removeAgendaItem({
  required String sjednicaId,
  required String itemId,
})
```
**Removes**: Agenda item and re-orders

#### deleteSjednica
```dart
Future<void> deleteSjednica({
  required String sjednicaId,
})
```
**Deletes**: Entire meeting

#### addDocumentReference
```dart
Future<void> addDocumentReference({
  required String sjednicaId,
  required String dokumentId,
  required String naziv,
  required String tip,
  required int veličina,
  required String putanja,
  required String urlPreuzimanja,
  required String kreatoriId,
})
```
**Adds**: Document metadata to meeting

#### removeDocumentReference
```dart
Future<void> removeDocumentReference({
  required String sjednicaId,
  required String dokumentId,
})
```
**Removes**: Document from meeting

**Usage Example**:
```dart
final notifier = ref.read(sjedniceNotifierProvider.notifier);
await notifier.createSjednica(
  naslov: 'Board Meeting',
  opis: 'Monthly board meeting',
  grupa: 'Grupa A',
  vrijeme: DateTime(2024, 2, 15, 14, 0),
  lokacija: 'Room 101',
  sazivac: currentUserUID,
);
```

---

## Voting Providers

### Location
`lib/provideri/glasanja.dart` and `lib/provideri/glasanja_notifier.dart`

### glasanjaProvider
```dart
final glasanjaProvider = StreamProvider<List<Glasanje>>
```
**Type**: StreamProvider
**Returns**: List of votings (filtered by user role/group)
**Updates**: Real-time from glasanja collection
**Ordering**: By krajnjeVrijeme (descending)

### pojedinacnoGlasanjeProvider
```dart
final pojedinacnoGlasanjeProvider = 
    StreamProvider.family<Glasanje?, String>
```
**Type**: Family StreamProvider
**Parameter**: glasanjeId (voting ID)
**Returns**: Single voting with real-time updates

### glasanjaStatsProvider
```dart
final glasanjaStatsProvider = FutureProvider<Map<String, int>>
```
**Type**: FutureProvider
**Returns**: Statistics map:
```dart
{
  'open': int,     // Open votings
  'closed': int,   // Closed votings
  'total': int     // Total votings
}
```

### userVotedProvider
```dart
final userVotedProvider = 
    FutureProvider.family<bool, String>
```
**Type**: Family FutureProvider
**Parameter**: glasanjeId
**Returns**: true if user has voted, false otherwise
**Usage**: Prevent duplicate voting

### glasanjaNotifierProvider
```dart
final glasanjaNotifierProvider = 
    StateNotifierProvider<GlasanjaNotifier, AsyncValue<void>>
```
**Type**: StateNotifierProvider
**Methods**:

#### createGlasanje
```dart
Future<void> createGlasanje({
  required String sjednicaId,
  required String stavkaId,
  required String naslov,
  required String? opis,
  required String grupa,
  required List<String> opcije,
  required DateTime pocetneVrijeme,
  required DateTime krajnjeVrijeme,
})
```

#### castVote
```dart
Future<void> castVote({
  required String glasanjeId,
  required String korisnikId,
  required String izbor,
})
```
**izbor**: Must be one of opcije values

#### closeVoting
```dart
Future<void> closeVoting({
  required String glasanjeId,
})
```

#### deleteGlasanje
```dart
Future<void> deleteGlasanje({
  required String glasanjeId,
})
```

---

## Announcement Providers

### Location
`lib/provideri/obavijesti.dart` and `lib/provideri/obavijesti_notifier.dart`

### obavijrestiProvider
```dart
final obavijrestiProvider = StreamProvider<List<Obavijest>>
```
**Type**: StreamProvider
**Returns**: List of announcements (filtered by user)
**Filtering**:
- By tip (opca, grupa, uloga)
- By aktivna status (only active)
- Real-time updates
**Ordering**: By vrijeme (descending)

### pojedinacnaObavijestProvider
```dart
final pojedinacnaObavijestProvider = 
    StreamProvider.family<Obavijest?, String>
```
**Type**: Family StreamProvider
**Parameter**: obavijestId
**Returns**: Single announcement

### obavijestStatsProvider
```dart
final obavijestStatsProvider = FutureProvider<Map<String, int>>
```
**Type**: FutureProvider
**Returns**: Statistics map:
```dart
{
  'active': int,   // Active announcements
  'total': int     // Total announcements
}
```

### obavijrestiNotifierProvider
```dart
final obavijrestiNotifierProvider = 
    StateNotifierProvider<ObavijrestiNotifier, AsyncValue<void>>
```
**Type**: StateNotifierProvider
**Methods**:

#### createObavijest
```dart
Future<void> createObavijest({
  required String naslov,
  required String sadrzaj,
  required String autorizdId,
  required String autoriziranoIme,
  required ObavijestTip tip,
  required List<String>? grupe,
  required List<String>? uloge,
  required DateTime vrijeme,
})
```
**tip**: obca, grupa, or uloga

#### updateObavijest
```dart
Future<void> updateObavijest({
  required String obavijestId,
  required String naslov,
  required String sadrzaj,
  required ObavijestTip tip,
  required List<String>? grupe,
  required List<String>? uloge,
  required DateTime vrijeme,
})
```

#### deactivateObavijest
```dart
Future<void> deactivateObavijest({
  required String obavijestId,
})
```
**Sets**: aktivna to false

#### deleteObavijest
```dart
Future<void> deleteObavijest({
  required String obavijestId,
})
```

---

## File Upload Providers

### Location
`lib/provideri/dokumenti_notifier.dart`

### dokumentiNotifierProvider
```dart
final dokumentiNotifierProvider = 
    StateNotifierProvider<DokumentiNotifier, AsyncValue<void>>
```
**Type**: StateNotifierProvider
**Methods**:

#### uploadMinutes
```dart
Future<String> uploadMinutes({
  required String sjednicaId,
  required File file,
  required String fileName,
  required String korisnikId,
})
```
**Returns**: Download URL
**Uploads to**: Firebase Storage
**Stores metadata**: In Firestore
**Validations**:
- File type: PDF, DOCX, DOC, TXT
- Max size: 50 MB

#### deleteDocument
```dart
Future<void> deleteDocument({
  required String sjednicaId,
  required String dokumentId,
  required String storagePath,
})
```
**Removes**: From Storage and Firestore

#### getDownloadUrl
```dart
Future<String> getDownloadUrl({
  required String storagePath,
})
```
**Returns**: Download URL for document

---

## Usage Examples

### Example 1: Watching Meeting List
```dart
class MeetingList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sjednice = ref.watch(sjedniceProvider);
    
    return sjednice.when(
      data: (meetings) => ListView(
        children: meetings.map((m) => 
          ListTile(title: Text(m.naslov))
        ).toList(),
      ),
      error: (e, st) => Text('Error: $e'),
      loading: () => CircularProgressIndicator(),
    );
  }
}
```

### Example 2: Creating a Meeting
```dart
class CreateMeetingForm extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final notifier = ref.read(sjedniceNotifierProvider.notifier);
        final meetingId = await notifier.createSjednica(
          naslov: 'Team Meeting',
          opis: 'Weekly sync',
          grupa: 'Grupa A',
          vrijeme: DateTime.now().add(Duration(days: 1)),
          lokacija: 'Room 101',
          sazivac: ref.read(authStateProvider).value?.uid ?? '',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Meeting created: $meetingId')),
        );
      },
      child: Text('Create Meeting'),
    );
  }
}
```

### Example 3: Checking User Role
```dart
class RoleBasedWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uloga = ref.watch(korisnikUlogaProvider);
    
    return uloga.when(
      data: (role) {
        if (role == KorisnikUloga.ravnatelj) {
          return AdminPanel();
        }
        return UserDashboard();
      },
      error: (e, st) => Text('Error loading role'),
      loading: () => CircularProgressIndicator(),
    );
  }
}
```

### Example 4: Updating Meeting Attendance
```dart
class AttendanceForm extends ConsumerWidget {
  final String sjednicaId;
  final String korisnikId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () async {
            final notifier = ref.read(sjedniceNotifierProvider.notifier);
            await notifier.updateAttendance(
              sjednicaId: sjednicaId,
              korisnikId: korisnikId,
              prezentacija: 'Prisutan',
            );
          },
          child: Text('Mark Present'),
        ),
        ElevatedButton(
          onPressed: () async {
            final notifier = ref.read(sjedniceNotifierProvider.notifier);
            await notifier.updateAttendance(
              sjednicaId: sjednicaId,
              korisnikId: korisnikId,
              prezentacija: 'Izostao',
            );
          },
          child: Text('Mark Absent'),
        ),
      ],
    );
  }
}
```

### Example 5: Casting a Vote
```dart
class VotingButton extends ConsumerWidget {
  final String glasanjeId;
  final String opcija;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final notifier = ref.read(glasanjaNotifierProvider.notifier);
        final user = ref.read(authStateProvider).value;
        
        if (user != null) {
          await notifier.castVote(
            glasanjeId: glasanjeId,
            korisnikId: user.uid,
            izbor: opcija,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Vote cast: $opcija')),
          );
        }
      },
      child: Text(opcija),
    );
  }
}
```

---

## Provider Dependency Graph

```
authStateProvider
├── korisnikPodaciProvider
│   ├── korisnikUlogaProvider
│   ├── korisnikGrupeProvider
│   └── trenutniKorisnikProvider
│
├── sjedniceProvider (filters by role/group)
│   └── sjedniceStatsProvider
│
├── glasanjaProvider (filters by role/group)
│   └── glasanjaStatsProvider
│
└── obavijrestiProvider (filters by role/group)
    └── obavijestStatsProvider
```

---

## Best Practices

1. **Use StreamProvider for real-time data** (sjednice, glasanja, obavijesti)
2. **Use FutureProvider for computed data** (stats, boolean checks)
3. **Use StateNotifierProvider for mutations** (CRUD operations)
4. **Watch vs Read**:
   - Use `watch()` for reactive UI updates
   - Use `read()` for one-time operations
5. **Error Handling**: Always handle `.error` state in `.when()`
6. **Loading States**: Show loading indicator on `.loading()` state
7. **Dependencies**: Properly declare dependencies between providers

---

**Last Updated**: 2024
**Version**: 1.0.0
**Status**: Complete Reference
