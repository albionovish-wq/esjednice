# eSjednice - Firestore Database Complete Setup Guide

This guide provides detailed specifications for every Firestore collection, field, data type, index, and configuration needed for full deployment.

---

## Table of Contents
1. [Collections Overview](#collections-overview)
2. [Collection: korisnici (Users)](#collection-korisnici-users)
3. [Collection: sjednice (Meetings)](#collection-sjednice-meetings)
4. [Collection: glasanja (Votings)](#collection-glasanja-votings)
5. [Collection: obavijesti (Announcements)](#collection-obavijesti-announcements)
6. [Firestore Indexes](#firestore-indexes)
7. [Data Types Reference](#data-types-reference)
8. [Field Validation Rules](#field-validation-rules)
9. [Step-by-Step Setup](#step-by-step-setup)
10. [Backup and Recovery](#backup-and-recovery)

---

## Collections Overview

**Total Collections**: 4 main collections + optional subcollections

| Collection | Purpose | Document Count (est.) | Parent Collection |
|---|---|---|---|
| `korisnici` | User accounts and profiles | Grows with users | Root |
| `sjednice` | Meeting records | Grows monthly | Root |
| `glasanja` | Voting sessions | Grows per meeting | Root |
| `obavijesti` | Announcements | Grows weekly | Root |

---

## Collection: korisnici (Users)

**Purpose**: Store user account information, roles, and group memberships

### Document ID Structure
```
Document ID = Firebase Auth UID
Example: "abc123def456ghi789jkl012"
```

### Field Specifications

| Field Name | Data Type | Required | Nullable | Default | Description |
|---|---|---|---|---|---|
| `email` | String | ✓ | ✗ | - | User's email address |
| `ime` | String | ✓ | ✓ | - | First name |
| `prezime` | String | ✓ | ✓ | - | Last name |
| `uloga` | String | ✓ | ✗ | "nastavnik" | User role (enum) |
| `grupe` | Array | ✓ | ✗ | [] | List of group IDs user belongs to |
| `created` | Timestamp | ✓ | ✗ | Server time | Account creation date |
| `lastLogin` | Timestamp | ✗ | ✓ | null | Last login timestamp |
| `aktivan` | Boolean | ✓ | ✗ | true | Account active status |

### Field Descriptions & Validation

#### email (String)
```
Format: Valid email address
Example: "john.doe@school.edu"
Validation: 
  - Must match email format (RFC 5322)
  - Must be unique across korisnici collection
  - Case-insensitive comparison
```

#### ime (String)
```
Format: First name
Example: "John"
Validation:
  - 1-50 characters
  - Letters and hyphens allowed
  - Cannot be empty
```

#### prezime (String)
```
Format: Last name
Example: "Doe"
Validation:
  - 1-50 characters
  - Letters and hyphens allowed
  - Cannot be empty
```

#### uloga (String)
```
Format: Enum value (one of):
  - "ravnatelj" = Principal
  - "zapisnicar" = Secretary
  - "nastavnik" = Teacher (default)
  - "roditelj" = Parent
  - "ucenik" = Student

Example: "nastavnik"
Validation:
  - Must be one of the above values
  - Controls access permissions via security rules
```

#### grupe (Array of Strings)
```
Format: Array of group identifiers
Example: ["Grupa A", "Grupa B", "Nastavnicki zbor"]
Items:
  - Type: String
  - Each item: 1-100 characters
  - No duplicates allowed
Validation:
  - Maximum 20 groups per user
  - Must reference existing group names
```

#### created (Timestamp)
```
Format: Firestore Timestamp
Set by: Server timestamp (automatic)
Example: 2024-01-15T10:30:00Z
Validation:
  - Auto-generated at user creation
  - Cannot be manually modified
  - Used for account age calculation
```

#### lastLogin (Timestamp)
```
Format: Firestore Timestamp (nullable)
Set by: Server timestamp (on login)
Example: 2024-01-20T14:45:30Z
Validation:
  - Can be null for never-logged-in users
  - Updated on each login
  - Used for user activity tracking
```

#### aktivan (Boolean)
```
Format: true | false
Example: true
Validation:
  - true = Active user (can login)
  - false = Deactivated user (cannot login)
  - Default: true at creation
  - Set to false for disabled accounts
```

### Sample Document
```json
{
  "uid": "abc123def456ghi789jkl012",
  "email": "john.doe@school.edu",
  "ime": "John",
  "prezime": "Doe",
  "uloga": "nastavnik",
  "grupe": ["Grupa A", "Grupa B"],
  "created": Timestamp(2024-01-15T10:30:00Z),
  "lastLogin": Timestamp(2024-01-20T14:45:30Z),
  "aktivan": true
}
```

---

## Collection: sjednice (Meetings)

**Purpose**: Store meeting information, agendas, and attendance records

### Document ID Structure
```
Document ID = Auto-generated UUID
Example: "550e8400-e29b-41d4-a716-446655440000"
```

### Field Specifications

| Field Name | Data Type | Required | Nullable | Default | Description |
|---|---|---|---|---|---|
| `naslov` | String | ✓ | ✗ | - | Meeting title |
| `opis` | String | ✗ | ✓ | null | Meeting description |
| `grupa` | String | ✓ | ✗ | - | Target group ID |
| `vrijeme` | Timestamp | ✓ | ✗ | - | Meeting scheduled date/time |
| `lokacija` | String | ✓ | ✗ | - | Meeting location |
| `status` | String | ✓ | ✗ | "planned" | Meeting status (enum) |
| `sazivac` | String | ✓ | ✗ | - | Organizer user UID |
| `zapisnicar` | String | ✗ | ✓ | null | Secretary user UID |
| `dnevniRed` | Array | ✓ | ✗ | [] | Agenda items (array of objects) |
| `prisutnost` | Array | ✓ | ✗ | [] | Attendance records (array of objects) |
| `dokumenti` | Array | ✓ | ✗ | [] | Uploaded documents (array of objects) |
| `created` | Timestamp | ✓ | ✗ | Server time | Meeting creation date |
| `updated` | Timestamp | ✗ | ✓ | null | Last modification date |

### Field Descriptions & Validation

#### naslov (String)
```
Format: Meeting title/name
Example: "Monthly Plenary Meeting"
Validation:
  - 5-200 characters
  - Required field
  - Cannot be empty
```

#### opis (String)
```
Format: Meeting description (optional)
Example: "Regular monthly meeting for all staff"
Validation:
  - 0-1000 characters
  - Can be null/empty
  - Plain text or basic formatting
```

#### grupa (String)
```
Format: Group identifier
Example: "Grupa A"
Validation:
  - Must reference valid group
  - Case-sensitive match
  - Cannot be empty
  - Controls who sees this meeting
```

#### vrijeme (Timestamp)
```
Format: Firestore Timestamp
Example: 2024-02-15T14:00:00Z
Validation:
  - Must be future date at creation
  - Format: ISO 8601
  - Used for meeting ordering
```

#### lokacija (String)
```
Format: Location description
Example: "Room 101, Building A"
Validation:
  - 1-200 characters
  - Physical or virtual location
  - Cannot be empty
```

#### status (String)
```
Format: Enum value (one of):
  - "planned" = Scheduled, not yet started
  - "inProgress" = Currently happening
  - "concluded" = Finished, documented
  - "canceled" = Cancelled/Not held

Example: "planned"
Validation:
  - Must be one of above values
  - Workflow: planned → inProgress → (concluded OR canceled)
  - Controls available actions
```

#### sazivac (String)
```
Format: User UID
Example: "abc123def456ghi789jkl012"
Validation:
  - Must be valid korisnici document UID
  - Organizer of meeting
  - Can edit meeting details
  - Must have appropriate role
```

#### zapisnicar (String)
```
Format: User UID (nullable)
Example: "xyz789abc123def456ghi012"
Validation:
  - Optional field
  - Must be valid korisnici document UID if provided
  - Responsible for attendance and minutes
  - Typically has zapisnicar role
```

#### dnevniRed (Array of Objects)
```
Format: Array of agenda items
Each item structure:
{
  "id": String (UUID),
  "redni_broj": Number (1, 2, 3...),
  "naslov": String,
  "opis": String,
  "vrsta": String ("obavijest", "glasanje", "rasprava"),
  "glasanjeId": String (if vrsta="glasanje")
}

Example:
[
  {
    "id": "item-001",
    "redni_broj": 1,
    "naslov": "Otvaranje sjednice",
    "opis": "Opening remarks",
    "vrsta": "obavijest"
  },
  {
    "id": "item-002",
    "redni_broj": 2,
    "naslov": "Budžet 2024",
    "opis": "Budget proposal voting",
    "vrsta": "glasanje",
    "glasanjeId": "voting-001"
  }
]

Validation:
  - Maximum 50 items
  - IDs must be unique within this meeting
  - Redni broj must be sequential (1, 2, 3...)
```

#### prisutnost (Array of Objects)
```
Format: Array of attendance records
Each record structure:
{
  "korisnikId": String (UID),
  "prezentacija": String ("Planirana", "Prisutan", "Izostao"),
  "vrijeme_odgovora": Timestamp
}

Example:
[
  {
    "korisnikId": "user-001",
    "prezentacija": "Prisutan",
    "vrijeme_odgovora": Timestamp(2024-02-15T13:30:00Z)
  },
  {
    "korisnikId": "user-002",
    "prezentacija": "Izostao",
    "vrijeme_odgovora": Timestamp(2024-02-15T13:35:00Z)
  }
]

Validation:
  - One record per user
  - prezentacija options: "Planirana", "Prisutan", "Izostao"
  - User must belong to meeting group
  - Cannot have duplicates per user
```

#### dokumenti (Array of Objects)
```
Format: Array of uploaded documents
Each document structure:
{
  "id": String (timestamp-based),
  "naziv": String (filename),
  "tip": String ("pdf", "docx", "txt"),
  "veličina": Number (bytes),
  "putanja": String (storage path),
  "urlPreuzimanja": String (download URL),
  "kreatoriId": String (uploader UID),
  "vrijeme": Timestamp
}

Example:
[
  {
    "id": "doc-1705311600000",
    "naziv": "zapisnik_2024_02_15.pdf",
    "tip": "pdf",
    "veličina": 2048576,
    "putanja": "sjednice/meeting-001/dokumenti/zapisnik_2024_02_15.pdf",
    "urlPreuzimanja": "https://storage.googleapis.com/...",
    "kreatoriId": "user-secretary",
    "vrijeme": Timestamp(2024-02-16T10:00:00Z)
  }
]

Validation:
  - Maximum 10 documents per meeting
  - Filename: 5-255 characters
  - Supported types: pdf, docx, doc, txt
  - Size: max 50 MB per file
  - Storage path must start with "sjednice/"
```

#### created (Timestamp)
```
Format: Firestore Timestamp
Set by: Server timestamp (automatic)
Validation:
  - Auto-generated at meeting creation
  - Cannot be manually modified
```

#### updated (Timestamp)
```
Format: Firestore Timestamp (nullable)
Set by: Server timestamp (on update)
Validation:
  - Can be null for new meetings
  - Updated on each document modification
```

### Sample Document
```json
{
  "naslov": "Monthly Plenary Meeting",
  "opis": "Regular monthly meeting for all staff",
  "grupa": "Grupa A",
  "vrijeme": Timestamp(2024-02-15T14:00:00Z),
  "lokacija": "Room 101",
  "status": "planned",
  "sazivac": "abc123def456ghi789jkl012",
  "zapisnicar": "xyz789abc123def456ghi012",
  "dnevniRed": [
    {
      "id": "item-001",
      "redni_broj": 1,
      "naslov": "Opening",
      "opis": "Meeting opening",
      "vrsta": "obavijest"
    }
  ],
  "prisutnost": [],
  "dokumenti": [],
  "created": Timestamp(2024-02-01T09:00:00Z),
  "updated": null
}
```

---

## Collection: glasanja (Votings)

**Purpose**: Store voting sessions and vote records

### Document ID Structure
```
Document ID = Auto-generated UUID
Example: "voting-550e8400-e29b-41d4-a716"
```

### Field Specifications

| Field Name | Data Type | Required | Nullable | Default | Description |
|---|---|---|---|---|---|
| `sjednicaId` | String | ✓ | ✗ | - | Reference to meeting |
| `stavkaId` | String | ✓ | ✗ | - | Reference to agenda item |
| `naslov` | String | ✓ | ✗ | - | Voting title |
| `opis` | String | ✗ | ✓ | null | Voting description |
| `grupa` | String | ✓ | ✗ | - | Target group |
| `opcije` | Array | ✓ | ✗ | - | Voting options |
| `status` | String | ✓ | ✗ | "openForVoting" | Voting status (enum) |
| `glasovi` | Array | ✓ | ✗ | [] | Vote records |
| `pocetneVrijeme` | Timestamp | ✓ | ✗ | - | Voting start time |
| `krajnjeVrijeme` | Timestamp | ✓ | ✗ | - | Voting end time |
| `created` | Timestamp | ✓ | ✗ | Server time | Creation date |
| `updated` | Timestamp | ✗ | ✓ | null | Last modification |

### Field Descriptions & Validation

#### sjednicaId (String)
```
Format: Meeting UUID
Example: "550e8400-e29b-41d4-a716-446655440000"
Validation:
  - Must reference valid sjednice document
  - Links voting to specific meeting
  - Cannot be changed after creation
```

#### stavkaId (String)
```
Format: Agenda item ID
Example: "item-001"
Validation:
  - Must reference valid dnevniRed item
  - Links voting to specific agenda point
  - Cannot be changed after creation
```

#### naslov (String)
```
Format: Voting title
Example: "Approve 2024 Budget"
Validation:
  - 5-200 characters
  - Clear and descriptive
  - Required field
```

#### opis (String)
```
Format: Voting description (optional)
Example: "Vote to approve the annual budget proposal"
Validation:
  - 0-500 characters
  - Provides context for voters
```

#### grupa (String)
```
Format: Group identifier
Example: "Grupa A"
Validation:
  - Must match meeting's grupa
  - Controls who can vote
  - Must be valid group
```

#### opcije (Array of Strings)
```
Format: Voting options
Example: ["Da", "Ne", "Suzdržan"]
Options:
  - Standard: ["Da", "Ne", "Suzdržan"]
  - Yes/No only: ["Da", "Ne"]
  - Custom: ["Option A", "Option B", "Option C"]

Validation:
  - Minimum 2 options
  - Maximum 10 options
  - Each option: 1-50 characters
  - No duplicates
  - Required field
```

#### status (String)
```
Format: Enum value (one of):
  - "openForVoting" = Currently accepting votes
  - "closed" = Voting period ended, results visible

Example: "openForVoting"
Validation:
  - Must be one of above
  - Workflow: openForVoting → closed
  - Determines if new votes accepted
```

#### glasovi (Array of Objects)
```
Format: Array of vote records
Each vote structure:
{
  "korisnikId": String (UID),
  "izbor": String (one of opcije values),
  "vrijeme": Timestamp
}

Example:
[
  {
    "korisnikId": "user-001",
    "izbor": "Da",
    "vrijeme": Timestamp(2024-02-15T14:05:00Z)
  },
  {
    "korisnikId": "user-002",
    "izbor": "Ne",
    "vrijeme": Timestamp(2024-02-15T14:08:00Z)
  }
]

Validation:
  - One vote per user (enforced by security rules)
  - izbor must be from opcije array
  - User must belong to target group
  - Cannot add votes if status="closed"
  - Maximum votes = group member count
```

#### pocetneVrijeme (Timestamp)
```
Format: Firestore Timestamp
Example: 2024-02-15T14:00:00Z
Validation:
  - Should be meeting start time
  - Cannot be in the past
```

#### krajnjeVrijeme (Timestamp)
```
Format: Firestore Timestamp
Example: 2024-02-15T14:30:00Z
Validation:
  - Must be after pocetneVrijeme
  - Determines when voting closes
  - Can be in future or past
```

#### created (Timestamp)
```
Format: Firestore Timestamp
Set by: Server timestamp (automatic)
Validation:
  - Auto-generated at creation
```

#### updated (Timestamp)
```
Format: Firestore Timestamp (nullable)
Set by: Server timestamp (on vote added/status changed)
Validation:
  - Can be null for new votings
```

### Sample Document
```json
{
  "sjednicaId": "550e8400-e29b-41d4-a716",
  "stavkaId": "item-002",
  "naslov": "Approve 2024 Budget",
  "opis": "Vote to approve the annual budget proposal",
  "grupa": "Grupa A",
  "opcije": ["Da", "Ne", "Suzdržan"],
  "status": "openForVoting",
  "glasovi": [
    {
      "korisnikId": "user-001",
      "izbor": "Da",
      "vrijeme": Timestamp(2024-02-15T14:05:00Z)
    }
  ],
  "pocetneVrijeme": Timestamp(2024-02-15T14:00:00Z),
  "krajnjeVrijeme": Timestamp(2024-02-15T14:30:00Z),
  "created": Timestamp(2024-02-15T14:00:00Z),
  "updated": null
}
```

---

## Collection: obavijesti (Announcements)

**Purpose**: Store announcements for communication with groups and roles

### Document ID Structure
```
Document ID = Auto-generated UUID
Example: "announce-550e8400-e29b-41d4-a716"
```

### Field Specifications

| Field Name | Data Type | Required | Nullable | Default | Description |
|---|---|---|---|---|---|
| `naslov` | String | ✓ | ✗ | - | Announcement title |
| `sadrzaj` | String | ✓ | ✗ | - | Announcement content |
| `autorizdId` | String | ✓ | ✗ | - | Author user UID |
| `autoriziranoIme` | String | ✓ | ✗ | - | Author full name |
| `tip` | String | ✓ | ✗ | - | Announcement type (enum) |
| `grupe` | Array | ✗ | ✓ | null | Target groups (if tip="grupa") |
| `uloge` | Array | ✗ | ✓ | null | Target roles (if tip="uloga") |
| `vrijeme` | Timestamp | ✓ | ✗ | - | Publication date/time |
| `aktivna` | Boolean | ✓ | ✗ | true | Active/published status |
| `created` | Timestamp | ✓ | ✗ | Server time | Creation date |
| `updated` | Timestamp | ✗ | ✓ | null | Last modification |

### Field Descriptions & Validation

#### naslov (String)
```
Format: Announcement title
Example: "Important: School Closure - Weather"
Validation:
  - 5-200 characters
  - Clear and informative
  - Required field
```

#### sadrzaj (String)
```
Format: Announcement content
Example: "Due to severe weather, school is closed today..."
Validation:
  - 10-5000 characters
  - Can include line breaks
  - Plain text format
  - Required field
```

#### autorizdId (String)
```
Format: User UID
Example: "abc123def456ghi789jkl012"
Validation:
  - Must be valid korisnici document UID
  - Author of announcement
  - Must have appropriate role (ravnatelj or zapisnicar)
```

#### autoriziranoIme (String)
```
Format: Author's full name
Example: "John Doe"
Validation:
  - 5-100 characters
  - Should match korisnici fullName
  - Display purposes only
```

#### tip (String)
```
Format: Enum value (one of):
  - "opca" = General (visible to all users)
  - "grupa" = Group-specific (requires grupe field)
  - "uloga" = Role-specific (requires uloge field)

Example: "grupa"
Validation:
  - Must be one of above values
  - Determines visibility
  - Controls which field is required:
    - opca: no additional field needed
    - grupa: must have grupe array
    - uloga: must have uloge array
```

#### grupe (Array of Strings)
```
Format: Array of target group identifiers (if tip="grupa")
Example: ["Grupa A", "Grupa B"]
Items:
  - Type: String
  - Each item: Group identifier
  - No duplicates

Validation:
  - Required if tip="grupa"
  - Must be null if tip != "grupa"
  - Maximum 50 groups
  - Must reference valid groups
```

#### uloge (Array of Strings)
```
Format: Array of target roles (if tip="uloga")
Example: ["nastavnik", "zapisnicar"]
Valid roles:
  - "ravnatelj"
  - "zapisnicar"
  - "nastavnik"
  - "roditelj"
  - "ucenik"

Validation:
  - Required if tip="uloga"
  - Must be null if tip != "uloga"
  - Only valid role values allowed
  - No duplicates
```

#### vrijeme (Timestamp)
```
Format: Firestore Timestamp
Example: 2024-02-15T10:00:00Z
Validation:
  - Set to immediate or future time
  - Used for scheduling announcements
  - Determines visibility timeline
```

#### aktivna (Boolean)
```
Format: true | false
Example: true
Validation:
  - true = Visible to target audience
  - false = Hidden from view
  - Default: true
  - Set to false to "delete" announcement
```

#### created (Timestamp)
```
Format: Firestore Timestamp
Set by: Server timestamp (automatic)
Validation:
  - Auto-generated at creation
```

#### updated (Timestamp)
```
Format: Firestore Timestamp (nullable)
Set by: Server timestamp (on update)
Validation:
  - Can be null for new announcements
  - Updated on content changes
```

### Sample Document
```json
{
  "naslov": "School Closure Notice",
  "sadrzaj": "Due to severe weather, school is closed today. All activities postponed to tomorrow.",
  "autorizdId": "abc123def456ghi789jkl012",
  "autoriziranoIme": "Principal John Doe",
  "tip": "opca",
  "grupe": null,
  "uloge": null,
  "vrijeme": Timestamp(2024-02-15T08:00:00Z),
  "aktivna": true,
  "created": Timestamp(2024-02-15T07:45:00Z),
  "updated": null
}
```

---

## Firestore Indexes

Indexes are critical for query performance. Firestore automatically manages some, but composite indexes must be manually created.

### Index 1: sjednice - Group + Status Filtering

**Purpose**: Efficient filtering of meetings by group and status

**How to Create**:
1. Firebase Console → Firestore Database → Indexes tab
2. Click "+ Create Index"
3. Fill in:
   - Collection ID: `sjednice`
   - First field: `grupa` (Ascending)
   - Second field: `status` (Ascending)
4. Click "Create Index"
5. Wait for "Enabled" status

**Query this improves**:
```
where('grupa', '==', 'Grupa A')
  .where('status', '==', 'planned')
  .orderBy('vrijeme', 'desc')
```

---

### Index 2: sjednice - Time Ordering

**Purpose**: Fast retrieval of meetings ordered by time

**How to Create**:
1. Firebase Console → Firestore → Indexes tab
2. Click "+ Create Index"
3. Fill in:
   - Collection ID: `sjednice`
   - Field: `vrijeme` (Descending)
4. Click "Create Index"
5. Wait for "Enabled" status

**Query this improves**:
```
.orderBy('vrijeme', 'descending')
.limit(10)
```

---

### Index 3: glasanja - Group + Deadline

**Purpose**: Find votings by group and deadline

**How to Create**:
1. Firebase Console → Firestore → Indexes tab
2. Click "+ Create Index"
3. Fill in:
   - Collection ID: `glasanja`
   - First field: `grupa` (Ascending)
   - Second field: `krajnjeVrijeme` (Descending)
4. Click "Create Index"
5. Wait for "Enabled" status

**Query this improves**:
```
where('grupa', 'in', ['Grupa A', 'Grupa B'])
  .orderBy('krajnjeVrijeme', 'descending')
```

---

### Index 4: glasanja - Status Filtering

**Purpose**: Find open or closed votings

**How to Create**:
1. Firebase Console → Firestore → Indexes tab
2. Click "+ Create Index"
3. Fill in:
   - Collection ID: `glasanja`
   - Field: `status` (Ascending)
4. Click "Create Index"
5. Wait for "Enabled" status

**Query this improves**:
```
where('status', '==', 'openForVoting')
.orderBy('krajnjeVrijeme', 'descending')
```

---

### Index 5: obavijesti - Active + Time

**Purpose**: Retrieve active announcements ordered by time

**How to Create**:
1. Firebase Console → Firestore → Indexes tab
2. Click "+ Create Index"
3. Fill in:
   - Collection ID: `obavijesti`
   - First field: `aktivna` (Ascending)
   - Second field: `vrijeme` (Descending)
4. Click "Create Index"
5. Wait for "Enabled" status

**Query this improves**:
```
where('aktivna', '==', true)
  .orderBy('vrijeme', 'descending')
```

---

### Index 6: obavijesti - Type Filtering

**Purpose**: Filter announcements by type

**How to Create**:
1. Firebase Console → Firestore → Indexes tab
2. Click "+ Create Index"
3. Fill in:
   - Collection ID: `obavijesti`
   - Field: `tip` (Ascending)
4. Click "Create Index"
5. Wait for "Enabled" status

**Query this improves**:
```
where('tip', '==', 'grupa')
  .where('aktivna', '==', true)
  .orderBy('vrijeme', 'descending')
```

---

## Data Types Reference

### Firestore Data Types Used

| Type | Description | Dart Type | Example |
|---|---|---|---|
| String | Text data | `String` | `"John Doe"` |
| Number | Integer or decimal | `int` or `double` | `42`, `3.14` |
| Boolean | True/false value | `bool` | `true`, `false` |
| Timestamp | Date and time | `Timestamp` | `2024-02-15T10:30:00Z` |
| Array | List of values | `List` | `["item1", "item2"]` |
| Map/Object | Dictionary/object | `Map` | `{"key": "value"}` |
| Reference | Link to document | `DocumentReference` | (auto-generated) |
| Null | Empty value | `null` | `null` |

### Timestamp Format
```
ISO 8601 format: YYYY-MM-DDTHH:MM:SSZ
Example: 2024-02-15T14:30:45Z

In Dart/Flutter:
DateTime.parse('2024-02-15T14:30:45Z')
Timestamp.fromDate(DateTime.now())
```

---

## Field Validation Rules

### Global Validation Rules

**String fields**:
```
- Non-empty (unless nullable)
- Max length enforced by Firestore rules
- No leading/trailing whitespace
- UTF-8 encoding
```

**Timestamp fields**:
```
- Must be valid ISO 8601 format
- Seconds precision minimum
- Server timestamp for creation/update
```

**Array fields**:
```
- Each element must match declared type
- No null elements (unless specified)
- Maximum 20,000 elements per array
- No automatic de-duplication
```

**Boolean fields**:
```
- Must be true or false
- Default values specified in collections
```

---

## Step-by-Step Setup

### Step 1: Access Firestore

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Click "Firestore Database" in left menu
4. Click "Create Database" if not already created
5. Select region (same as your app region)
6. Start in Production mode

### Step 2: Create Collections

**Create collection: korisnici**
1. Click "+ Start collection" or "+ Create collection"
2. Collection ID: `korisnici`
3. Click Next
4. Document ID: `Auto ID` (let Firestore generate)
5. Add sample fields (then delete - structure only):
   - `email` (String)
   - `ime` (String)
   - `uloga` (String)
6. Click Save

**Repeat for other collections**:
- `sjednice`
- `glasanja`
- `obavijesti`

### Step 3: Create Indexes

For each index below:
1. Go to Firestore → Indexes tab
2. Click "+ Create Index"
3. Follow index specifications above
4. Click Create Index
5. Wait for "Enabled" status (1-5 minutes each)

**Index List** (6 total):
```
1. sjednice: grupa (Asc) + status (Asc)
2. sjednice: vrijeme (Desc)
3. glasanja: grupa (Asc) + krajnjeVrijeme (Desc)
4. glasanja: status (Asc)
5. obavijesti: aktivna (Asc) + vrijeme (Desc)
6. obavijesti: tip (Asc)
```

### Step 4: Verify Setup

1. In Firestore Console, verify:
   - ✓ 4 collections exist (korisnici, sjednice, glasanja, obavijesti)
   - ✓ 6 indexes created and "Enabled"
   - ✓ No sample documents (should be empty)

---

## Backup and Recovery

### Automatic Backups

**Enable backup schedule**:
1. Firestore → Backups tab
2. Click "+ Create Schedule"
3. Recurrence: Daily
4. Retention: 7-90 days (recommended: 30 days)
5. Click Create

### Manual Backup

**Export collection**:
1. Firestore → Start Collection
2. Right-click collection name
3. Export collection
4. Choose destination (Cloud Storage bucket)
5. Click Export

### Recovery Process

**Restore from backup**:
1. If scheduled backup:
   - Backup tab → Choose backup
   - Click "Restore"
   - Confirm deletion of current data

2. If exported backup:
   - Firestore → Import collections
   - Select exported file from Storage
   - Click Import

---

## Troubleshooting Database Setup

### Issue: "Index already exists"

**Cause**: Index was already created automatically

**Solution**:
- Ignore message, continue
- Index is ready to use

### Issue: "Composite query requires index"

**Cause**: Index not created yet

**Solution**:
1. Go to Firestore → Indexes
2. Click link provided in error
3. Create index following specifications

### Issue: "Collection is empty"

**Normal**:
- New collections start empty
- First documents created via app or manual entry

**To add test data**:
1. Firestore Console
2. Collection → Add Document
3. Manually fill fields
4. Save

### Issue: "Document reference not found"

**Cause**: Document ID doesn't exist in referenced collection

**Solution**:
1. Ensure source document exists
2. Use exact document IDs
3. Check typos in references

---

## Complete Database Checklist

Before going to production, verify:

### Collections Created
- [ ] korisnici (Users)
- [ ] sjednice (Meetings)
- [ ] glasanja (Votings)
- [ ] obavijesti (Announcements)

### Indexes Created (6 total)
- [ ] sjednice: grupa + status
- [ ] sjednice: vrijeme
- [ ] glasanja: grupa + krajnjeVrijeme
- [ ] glasanja: status
- [ ] obavijesti: aktivna + vrijeme
- [ ] obavijesti: tip

### Backup Configured
- [ ] Automatic backup schedule enabled
- [ ] Retention period set (30 days recommended)
- [ ] Manual export tested

### Security Rules
- [ ] Deployed via Firebase CLI
- [ ] Verified in console
- [ ] Tested with test users

### Sample Data (Optional)
- [ ] Test user in korisnici
- [ ] Test meeting in sjednice
- [ ] Test voting in glasanja
- [ ] Test announcement in obavijesti

---

## Production Deployment Checklist

**Before deploying to production**:

✓ All 4 collections created
✓ All 6 indexes created and enabled
✓ All fields match specifications
✓ Data types verified
✓ Sample data (if any) removed
✓ Security rules deployed
✓ Backup schedule configured
✓ Test users successfully created
✓ Test operations successful

---

**Last Updated**: 2024
**Version**: 1.0.0
**Status**: Complete - Ready for Deployment
