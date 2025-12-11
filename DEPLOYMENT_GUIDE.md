# eSjednice - Comprehensive Deployment Guide

## Table of Contents
1. [Pre-Deployment Setup](#pre-deployment-setup)
2. [Firebase Configuration](#firebase-configuration)
3. [Security Rules Deployment](#security-rules-deployment)
4. [Web Deployment](#web-deployment)
5. [Mobile Deployment](#mobile-deployment)
6. [Post-Deployment Verification](#post-deployment-verification)
7. [Monitoring & Maintenance](#monitoring--maintenance)
8. [Troubleshooting](#troubleshooting)

---

## Pre-Deployment Setup

### 1. Environment Requirements

```bash
# Check Flutter version (3.0+)
flutter --version

# Check Dart version (3.0+)
dart --version

# Install Firebase CLI
npm install -g firebase-tools

# Verify Firebase CLI
firebase --version
```

### 2. Project Configuration

#### 2.1 Update Firebase Credentials
```bash
# File: lib/firebase_options.dart
# Replace test credentials with production credentials:

static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_API_KEY',
  appId: 'YOUR_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_ID',
  projectId: 'YOUR_PROJECT_ID',
  authDomain: 'your-project.firebaseapp.com',
  databaseURL: 'https://your-project.firebaseio.com',
  storageBucket: 'your-project.appspot.com',
);
```

#### 2.2 Get Firebase Credentials
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create new project or select existing
3. Go to Project Settings
4. Under "Your apps", click on web icon
5. Copy the firebaseConfig object
6. Update `firebase_options.dart`

### 3. Dependencies Check

```bash
cd /home/engine/project

# Update dependencies
flutter pub get

# Check for any issues
flutter pub outdated

# Run analyzer
flutter analyze
```

### 4. Testing Before Deployment

```bash
# Run unit tests
flutter test

# Run widget tests (if available)
flutter test --verbose

# Build without signing (web)
flutter build web

# Check build size
flutter build web --release --analyze-size
```

---

## Firebase Configuration

### 1. Firestore Setup

#### 1.1 Create Collections
```bash
# Using Firebase CLI
firebase firestore:indexes --project YOUR_PROJECT_ID

# Or through Firebase Console:
# - Create collection: korisnici
# - Create collection: sjednice
# - Create collection: glasanja
# - Create collection: obavijesti
```

#### 1.2 Set Up Indexes

For optimal performance, create these indexes:

**Collection: sjednice**
- Fields: `grupa` (Ascending), `status` (Ascending)
- Fields: `vrijeme` (Descending)

**Collection: glasanja**
- Fields: `grupa` (Ascending), `krajnjeVrijeme` (Descending)
- Fields: `status` (Ascending)

**Collection: obavijesti**
- Fields: `aktivna` (Ascending), `vrijeme` (Descending)
- Fields: `tip` (Ascending)

### 2. Firebase Authentication Setup

#### 2.1 Enable Authentication Methods

1. Go to Firebase Console → Authentication
2. Enable providers:
   - ✅ Email/Password
   - ✅ Google Sign-In (optional)
3. Configure OAuth consent screen:
   - App name: "eSjednice"
   - User support email: your-email@domain.com
   - Developer contact: your-email@domain.com

#### 2.2 Configure Google Sign-In (Optional)

```bash
# Create OAuth 2.0 credentials
# 1. Go to Google Cloud Console
# 2. Create OAuth 2.0 Client ID (Web)
# 3. Add authorized URLs:
#    - http://localhost:3000 (dev)
#    - https://your-domain.com (production)
```

### 3. Firebase Storage Setup

```bash
# Enable Storage through Firebase Console
# Set default location: Choose closest to your users
# Create storage bucket: your-project.appspot.com
```

#### 3.1 Create Storage Rules

```bash
# Update firebase_storage_rules file:
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /sjednice/{sjednicaId}/dokumenti/{dokument=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                      request.resource.size < 50 * 1024 * 1024;
    }
  }
}
```

---

## Security Rules Deployment

### 1. Deploy Firestore Rules

```bash
# Login to Firebase
firebase login

# Select project
firebase use YOUR_PROJECT_ID

# Validate rules
firebase deploy --only firestore:rules --dry-run

# Deploy rules (production)
firebase deploy --only firestore:rules
```

### 2. Validate Rules

```bash
# Test rules locally
firebase emulator:start

# In another terminal, run tests
flutter test --verbose
```

### 3. Monitor Rules

```bash
# Check rules in Firebase Console
# Firestore → Rules tab

# Monitor rule violations
# Firestore → Usage tab
```

---

## Web Deployment

### 1. Firebase Hosting Setup

```bash
# Initialize Firebase hosting
firebase init hosting --project YOUR_PROJECT_ID

# When prompted:
# - What do you want to use as your public directory? → build/web
# - Configure as single-page app? → Yes
```

### 2. Build Web App

```bash
# Build release version
flutter build web --release

# Optimize build
flutter build web --release --web-renderer html

# Check build output
ls -lah build/web
```

### 3. Deploy to Firebase Hosting

```bash
# Deploy to Firebase
firebase deploy --only hosting:esjednice

# Monitor deployment
# Firebase Console → Hosting tab

# Check deployment logs
firebase hosting:channel:list
```

### 4. Custom Domain Setup

```bash
# Add custom domain
firebase hosting:domain:create your-domain.com

# Or through Firebase Console:
# Hosting → Connected domains → Add custom domain

# Update DNS records (provided by Firebase)
```

### 5. SSL/HTTPS Configuration

- Firebase Hosting automatically provisions SSL certificate
- Takes up to 24 hours
- Certificate auto-renews

---

## Mobile Deployment

### Android Deployment

#### 1. Generate Signing Key

```bash
# Generate Android keystore
keytool -genkey -v -keystore ~/release_keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias release

# Store password securely
```

#### 2. Configure Signing

```bash
# File: android/key.properties
storePassword=<password>
keyPassword=<password>
keyAlias=release
storeFile=<path-to-keystore>
```

#### 3. Build APK/AAB

```bash
# Build signed APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

#### 4. Release to Google Play

```bash
# Create app on Google Play Console
# Upload AAB or APK
# Configure store listing
# Submit for review
```

### iOS Deployment

#### 1. Configure Signing

```bash
# Open iOS project in Xcode
open ios/Runner.xcworkspace

# Select Runner project
# Go to Signing & Capabilities
# Team: Select your team
# Bundle Identifier: com.yourcompany.esjednice
```

#### 2. Build IPA

```bash
# Build release IPA
flutter build ios --release

# Archive for TestFlight
flutter build ios --release --no-bitcode
```

#### 3. Upload to App Store

```bash
# Use Xcode or Transporter app
# Upload build
# Configure metadata
# Submit for review
```

---

## Post-Deployment Verification

### 1. Functionality Testing

- [ ] Login/Signup works
- [ ] User roles functioning correctly
- [ ] Meeting CRUD operations
- [ ] Voting system working
- [ ] Announcements displaying
- [ ] File upload/download
- [ ] Real-time data sync
- [ ] Error handling working

### 2. Security Verification

```bash
# Test security rules
firebase emulator:start

# Verify:
# - Users can only access own data
# - Group filtering works
# - Role-based access enforced
# - One-vote-per-user enforced
```

### 3. Performance Testing

```bash
# Lighthouse testing (web)
lighthouse https://your-domain.com

# Monitor metrics:
# - First Contentful Paint (FCP)
# - Largest Contentful Paint (LCP)
# - Cumulative Layout Shift (CLS)
```

### 4. Monitor User Activity

```bash
# Firebase Console → Analytics
# Monitor:
# - Daily active users
# - Session duration
# - Crash rates
# - Error rates
```

---

## Monitoring & Maintenance

### 1. Set Up Error Tracking

```bash
# Firebase Crashlytics is automatically enabled
# Monitor crashes in Firebase Console → Crashlytics

# Enable performance monitoring:
firebase.performance().start();
```

### 2. Set Up Logging

```bash
# Firebase has built-in logging
# Monitor logs in Firebase Console → Firestore → Usage
# Check database reads/writes
```

### 3. Regular Backups

```bash
# Export Firestore data
gcloud firestore export gs://your-bucket/backups/$(date +%s)

# Schedule regular backups in Cloud Scheduler
```

### 4. Update Management

```bash
# Push updates to web (auto-deployed)
# For mobile, release new version with play store/app store

# Version management in pubspec.yaml:
version: 1.1.0+2  # major.minor.patch+build
```

---

## Troubleshooting

### Common Issues

#### 1. Authentication Failures

**Problem**: Users can't login
```bash
# Check:
# - Firebase Auth is enabled
# - Credentials are correct
# - User exists in Firebase Console
# - No IP/region restrictions
```

**Solution**:
```dart
try {
  await authService.signInWithEmailPassword(email, password);
} on FirebaseAuthException catch (e) {
  // Handle specific errors with ErrorHandler
  ErrorHandler.handleAuthError(e);
}
```

#### 2. Firestore Access Denied

**Problem**: "Permission denied" errors
```bash
# Check:
# - Security rules are deployed
# - User has proper role
# - User is in correct group
```

**Solution**:
```bash
# Test rules locally
firebase emulator:start

# Check rule logs in Firebase Console
```

#### 3. File Upload Issues

**Problem**: Can't upload files
```bash
# Check:
# - Storage bucket exists
# - Storage rules allow writes
# - File size < 50 MB
# - File format is allowed
```

**Solution**:
```dart
// Validate file before upload
bool isValidDocument(File file) {
  final extension = file.path.split('.').last.toLowerCase();
  return ['pdf', 'docx', 'doc', 'txt'].contains(extension);
}
```

#### 4. Real-Time Data Not Updating

**Problem**: Changes not appearing in real-time
```bash
# Check:
# - Firestore listeners are active
# - Network connection is stable
# - Riverpod providers not dispose too early
```

**Solution**:
```dart
// Use autoDispose carefully
final provider = StreamProvider.autoDispose<Data>((ref) {
  // Listener will dispose when not watching
  // Keep reference to prevent disposal
});
```

### Performance Issues

#### 1. Slow Loading

- [ ] Enable Firestore indexes
- [ ] Optimize queries with WHERE clauses
- [ ] Use pagination for large lists
- [ ] Cache data with Riverpod

#### 2. High Database Costs

- [ ] Review Firestore read/write operations
- [ ] Implement proper filtering (where clauses)
- [ ] Use batch writes for bulk operations
- [ ] Archive old data

---

## Production Checklist

### Before Going Live

- [ ] All tests passing
- [ ] Security rules deployed and tested
- [ ] Firebase configuration updated
- [ ] Environment variables set
- [ ] Error logging configured
- [ ] Analytics enabled
- [ ] Backups scheduled
- [ ] SSL/HTTPS configured
- [ ] Custom domain set up
- [ ] Performance optimized
- [ ] Documentation updated
- [ ] Support plan in place

### Launch Day

- [ ] Monitor error rates
- [ ] Check user feedback
- [ ] Monitor database usage
- [ ] Monitor server performance
- [ ] Have rollback plan ready

### Post-Launch

- [ ] Weekly performance review
- [ ] Monthly security audit
- [ ] Quarterly feature releases
- [ ] Continuous user feedback collection

---

## Support & Resources

### Documentation
- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev)

### Monitoring Tools
- [Firebase Console](https://console.firebase.google.com)
- [Google Cloud Console](https://console.cloud.google.com)
- [Firebase CLI](https://firebase.google.com/docs/cli)

### Community Support
- [Flutter Community](https://flutter.dev/community)
- [Firebase Community](https://firebase.google.com/community)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)

---

## Rollback Procedure

If critical issues occur after deployment:

```bash
# Web Rollback
firebase hosting:rollback

# Or redeploy previous version
firebase deploy --only hosting

# Firestore Rollback
# No direct rollback - check Firebase backups
gcloud firestore restore BACKUP_ID --collection-ids korisnici,sjednice

# Contact Firebase Support for critical issues
```

---

**Last Updated**: 2024
**Version**: 1.0.0
**Status**: Ready for Production Deployment
