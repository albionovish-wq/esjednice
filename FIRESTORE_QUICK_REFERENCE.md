# Firestore Database - Quick Reference Card

**Print and keep handy during setup!**

---

## Collections at a Glance

```
Database: eSjednice
│
├── Collection: korisnici (Users)
│   └── Document ID: [User UID from Firebase Auth]
│       ├── email: string
│       ├── ime: string
│       ├── prezime: string
│       ├── uloga: string (ravnatelj|zapisnicar|nastavnik|roditelj|ucenik)
│       ├── grupe: array
│       ├── created: timestamp
│       ├── lastLogin: timestamp (nullable)
│       └── aktivan: boolean
│
├── Collection: sjednice (Meetings)
│   └── Document ID: [Auto UUID]
│       ├── naslov: string
│       ├── opis: string (nullable)
│       ├── grupa: string
│       ├── vrijeme: timestamp
│       ├── lokacija: string
│       ├── status: string (planned|inProgress|concluded|canceled)
│       ├── sazivac: string (user UID)
│       ├── zapisnicar: string (user UID, nullable)
│       ├── dnevniRed: array[object]
│       ├── prisutnost: array[object]
│       ├── dokumenti: array[object]
│       ├── created: timestamp
│       └── updated: timestamp (nullable)
│
├── Collection: glasanja (Votings)
│   └── Document ID: [Auto UUID]
│       ├── sjednicaId: string
│       ├── stavkaId: string
│       ├── naslov: string
│       ├── opis: string (nullable)
│       ├── grupa: string
│       ├── opcije: array[string]
│       ├── status: string (openForVoting|closed)
│       ├── glasovi: array[object]
│       ├── pocetneVrijeme: timestamp
│       ├── krajnjeVrijeme: timestamp
│       ├── created: timestamp
│       └── updated: timestamp (nullable)
│
└── Collection: obavijesti (Announcements)
    └── Document ID: [Auto UUID]
        ├── naslov: string
        ├── sadrzaj: string
        ├── autorizdId: string
        ├── autoriziranoIme: string
        ├── tip: string (opca|grupa|uloga)
        ├── grupe: array[string] (if tip=grupa)
        ├── uloge: array[string] (if tip=uloga)
        ├── vrijeme: timestamp
        ├── aktivna: boolean
        ├── created: timestamp
        └── updated: timestamp (nullable)
```

---

## Data Types Quick Reference

| Type | Values | Example |
|------|--------|---------|
| **String** | Text | `"John Doe"` |
| **Number** | Integer/Decimal | `42`, `3.14` |
| **Boolean** | true/false | `true` |
| **Timestamp** | Date/Time | `2024-02-15T10:30:00Z` |
| **Array** | List | `["item1", "item2"]` |
| **Map** | Object | `{"key": "value"}` |

---

## Enum Values Reference

### uloga (User Role)
```
- "ravnatelj" = Principal
- "zapisnicar" = Secretary
- "nastavnik" = Teacher (default)
- "roditelj" = Parent
- "ucenik" = Student
```

### status (Meeting Status)
```
- "planned" = Not started
- "inProgress" = In progress
- "concluded" = Finished
- "canceled" = Cancelled
```

### status (Voting Status)
```
- "openForVoting" = Accepting votes
- "closed" = Voting ended
```

### tip (Announcement Type)
```
- "opca" = General (all users)
- "grupa" = Specific groups
- "uloga" = Specific roles
```

### vrsta (Agenda Item Type)
```
- "obavijest" = Notice
- "glasanje" = Voting
- "rasprava" = Discussion
```

### prezentacija (Attendance)
```
- "Planirana" = Planned to attend
- "Prisutan" = Present
- "Izostao" = Absent
```

---

## Indexes Required (6 Total)

| # | Collection | Fields | Type | Purpose |
|---|---|---|---|---|
| 1 | sjednice | grupa (Asc), status (Asc) | Composite | Filter meetings by group & status |
| 2 | sjednice | vrijeme (Desc) | Single | Order meetings by time |
| 3 | glasanja | grupa (Asc), krajnjeVrijeme (Desc) | Composite | Find votings by group & deadline |
| 4 | glasanja | status (Asc) | Single | Filter votings by status |
| 5 | obavijesti | aktivna (Asc), vrijeme (Desc) | Composite | Get active announcements |
| 6 | obavijesti | tip (Asc) | Single | Filter announcements by type |

---

## Creating an Index - Steps

```
1. Firebase Console → Select Project
2. Firestore Database → Indexes tab
3. Click "+ Create Index"
4. Fill in details:
   Collection ID: [Collection name]
   Field 1: [Field name] ([Asc|Desc])
   Field 2: [Field name] ([Asc|Desc]) - if composite
5. Click "Create Index"
6. Wait for "Enabled" status (1-5 min)
```

---

## Sample Field Values

### korisnici (User) Document
```json
{
  "email": "john.doe@school.edu",
  "ime": "John",
  "prezime": "Doe",
  "uloga": "nastavnik",
  "grupe": ["Grupa A", "Grupa B"],
  "created": "2024-01-15T10:30:00Z",
  "lastLogin": "2024-02-15T14:45:00Z",
  "aktivan": true
}
```

### sjednice (Meeting) Document - Minimal
```json
{
  "naslov": "Monthly Meeting",
  "opis": "Regular staff meeting",
  "grupa": "Grupa A",
  "vrijeme": "2024-02-15T14:00:00Z",
  "lokacija": "Room 101",
  "status": "planned",
  "sazivac": "[user-uid-here]",
  "zapisnicar": null,
  "dnevniRed": [],
  "prisutnost": [],
  "dokumenti": [],
  "created": "2024-02-01T09:00:00Z",
  "updated": null
}
```

### glasanja (Voting) Document - Minimal
```json
{
  "sjednicaId": "[meeting-uuid]",
  "stavkaId": "item-001",
  "naslov": "Approve Budget",
  "opis": "2024 budget proposal",
  "grupa": "Grupa A",
  "opcije": ["Da", "Ne", "Suzdržan"],
  "status": "openForVoting",
  "glasovi": [],
  "pocetneVrijeme": "2024-02-15T14:00:00Z",
  "krajnjeVrijeme": "2024-02-15T14:30:00Z",
  "created": "2024-02-15T14:00:00Z",
  "updated": null
}
```

### obavijesti (Announcement) Document - Minimal
```json
{
  "naslov": "Important Notice",
  "sadrzaj": "School closed due to weather",
  "autorizdId": "[user-uid-here]",
  "autoriziranoIme": "Principal John",
  "tip": "opca",
  "grupe": null,
  "uloge": null,
  "vrijeme": "2024-02-15T08:00:00Z",
  "aktivna": true,
  "created": "2024-02-15T07:45:00Z",
  "updated": null
}
```

---

## Field Length Limits

| Field | Min Chars | Max Chars |
|---|---|---|
| email | - | 254 |
| ime | 1 | 50 |
| prezime | 1 | 50 |
| naslov (meeting/voting) | 5 | 200 |
| naslov (announcement) | 5 | 200 |
| opis | 0 | 1000 |
| sadrzaj (announcement) | 10 | 5000 |
| lokacija | 1 | 200 |
| grupa | 1 | 100 |
| Path (storage) | - | 1024 |

---

## Verification Checklist

### Before Setup
- [ ] Firebase project created
- [ ] Firestore database created
- [ ] Selected correct region

### Creating Collections
- [ ] korisnici created ✓
- [ ] sjednice created ✓
- [ ] glasanja created ✓
- [ ] obavijesti created ✓

### Creating Indexes
- [ ] Index 1: sjednice (grupa+status) - Status: Enabled
- [ ] Index 2: sjednice (vrijeme) - Status: Enabled
- [ ] Index 3: glasanja (grupa+krajnjeVrijeme) - Status: Enabled
- [ ] Index 4: glasanja (status) - Status: Enabled
- [ ] Index 5: obavijesti (aktivna+vrijeme) - Status: Enabled
- [ ] Index 6: obavijesti (tip) - Status: Enabled

### Post-Setup
- [ ] All collections have 0 documents (clean start)
- [ ] All indexes show "Enabled" in Indexes tab
- [ ] No error messages in console
- [ ] Ready for test data

---

## Common Operations

### Add User Document
```
Collection: korisnici
Document ID: [paste Firebase Auth UID]
Fields: email, ime, prezime, uloga, grupe[], created, aktivan
```

### Add Meeting Document
```
Collection: sjednice
Document ID: [auto-generate]
Fields: naslov, grupa, vrijeme, status, sazivac, dnevniRed[], prisutnost[]
```

### Add Voting Document
```
Collection: glasanja
Document ID: [auto-generate]
Fields: sjednicaId, naslov, grupa, opcije[], status, glasovi[]
```

### Add Announcement Document
```
Collection: obavijesti
Document ID: [auto-generate]
Fields: naslov, sadrzaj, tip, grupe[], uloge[], vrijeme, aktivna
```

---

## Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| "Collection doesn't exist" | Create collection via Firestore console |
| "Index required for query" | Create index via Indexes tab |
| "Permission denied" | Deploy security rules via Firebase CLI |
| "Document not found" | Verify document ID exists exactly |
| "Can't add field" | Check field type matches specification |
| "Array exceeds size limit" | Maximum 20,000 elements per array |
| "Timestamp format error" | Use ISO 8601: YYYY-MM-DDTHH:MM:SSZ |

---

## Firebase Console Navigation

```
Firebase Console
└── Your Project
    └── Firestore Database
        ├── Data tab
        │   ├── Collections list
        │   └── Document viewer
        ├── Indexes tab
        │   ├── Single-field indexes (auto)
        │   └── Composite indexes (manual)
        ├── Rules tab
        │   └── Security rules editor
        ├── Backups tab
        │   ├── Automated backups
        │   └── Manual export/import
        └── Settings tab
            └── Database configuration
```

---

**Setup Status:**
- Database Created: [ ] Yes [ ] No
- Collections Created: [ ] Yes [ ] No
- Indexes Created: [ ] Yes [ ] No
- Ready for Data: [ ] Yes [ ] No

**Created By**: ________________
**Date**: ________________
