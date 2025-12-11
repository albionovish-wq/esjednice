# eSjednice - Digital Meeting Management System

A Flutter-based digital platform for managing meetings (sjednice), voting, and announcements within educational institutions.

## Overview

eSjednice (eSessions) is designed to digitize and efficiently manage meetings, voting, and announcements for schools and educational groups. The application enables transparent, fast, and organized communication among principals, secretaries, teachers, students, and parents.

## Features

### Completed
- ✅ **Authentication** - Secure login via Firebase (email/password)
- ✅ **Role-Based Authorization** - Different access levels for various user roles
- ✅ **Dashboard** - Overview with quick access cards
- ✅ **Meeting Details** - Comprehensive meeting information display

### Planned
- ⏳ **Meeting List** - Filtered view of all relevant meetings
- ⏳ **Meeting Management** - Create, edit, and delete meetings
- ⏳ **Voting System** - Integrated voting within agenda items
- ⏳ **Announcements** - Role and group-based announcements
- ⏳ **Groups** - Group management and membership

## Technology Stack

- **Frontend**: Flutter (Dart)
- **State Management**: Riverpod
- **Backend & Database**: Firebase (Firestore, Authentication)
- **Storage**: Firebase Storage (planned)
- **Design System**: Custom CARNET-inspired design

## Project Structure

```
lib/
├── dizajn_sistem/
│   └── dizajn_sistem.dart      # Design system (colors, typography, themes)
├── modeli/
│   ├── korisnik.dart            # User model
│   └── sjednica.dart            # Meeting model
├── provideri/
│   ├── auth.dart                # Authentication service
│   ├── global.dart              # Global providers
│   └── sjednice.dart            # Meeting providers
├── sucelja/
│   ├── prijava.dart             # Login screen
│   ├── dashboard.dart           # Dashboard screen
│   ├── sjednice.dart            # Meetings list screen
│   ├── detalji_sjednice.dart   # Meeting details screen
│   ├── grupe.dart               # Groups screen
│   ├── glasanja.dart            # Voting screen
│   ├── komunikacija.dart        # Communication screen
│   └── postavke.dart            # Settings screen
├── komponente/
│   └── komponente.dart          # Reusable UI components
└── main.dart                    # Application entry point
```

## User Roles

- **Ravnatelj (Principal)** - Full access to all meetings and system features
- **Zapisničar (Secretary)** - Meeting management and record keeping
- **Nastavnik (Teacher)** - Access to relevant meetings and voting
- **Roditelj (Parent)** - Access to assigned group meetings
- **Učenik (Student)** - Attendance and participation (planned)

## Getting Started

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart 3.0.0 or higher
- Firebase project setup

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd esjednice
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
- Create a Firebase project in the Firebase Console
- Update `lib/firebase_options.dart` with your credentials
- Enable Firestore Database and Authentication

4. Run the application
```bash
flutter run
```

## Design System

The application follows the CARNET visual identity with:

- **Primary Colors**:
  - Primary Blue: `#0066CC`
  - Dark Blue: `#003366`
  - Light Gray: `#F8F9FA`

- **Components**: Rounded corners (12px), subtle shadows, and clear typography

- **Layout**: Sidebar navigation with main content area

## State Management

The application uses **Riverpod** for:
- Dependency injection
- Global state management
- Asynchronous data fetching
- Provider composition

Key providers:
- `authStateProvider` - Current authentication state
- `korisnikPodaciProvider` - Logged-in user data
- `sjedniceProvider` - Filtered meetings list
- `pojedinacnaSjednicaProvider` - Individual meeting details

## Database Schema

### Collections

#### korisnici
- `uid` - User ID
- `email` - Email address
- `ime` - First name
- `prezime` - Last name
- `uloga` - User role
- `grupe` - List of group IDs
- `created` - Creation timestamp
- `lastLogin` - Last login timestamp
- `aktivan` - Active status

#### sjednice
- `id` - Meeting ID
- `naslov` - Meeting title
- `opis` - Description
- `grupa` - Associated group
- `vrijeme` - Date and time
- `lokacija` - Location
- `status` - Meeting status
- `sazivac` - Meeting convener
- `zapisnicar` - Secretary responsible
- `dnevniRed` - Agenda items array
- `prisutnost` - Attendance records array
- `zapisnik` - Minutes document reference
- `created` - Creation timestamp
- `updated` - Last update timestamp

## Contributing

Follow these guidelines when contributing:
- Use the existing code style and patterns
- Follow Flutter best practices
- Keep components modular and reusable
- Document complex logic
- Use meaningful commit messages

## License

This project is proprietary and intended for use in educational institutions.

## Support

For issues, feature requests, or questions, please contact the development team.
