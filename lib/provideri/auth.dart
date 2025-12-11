import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Note: google_sign_in package should be added to pubspec.yaml
// import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<User?> signUpWithEmailPassword({
    required String email,
    required String password,
    required String ime,
    required String prezime,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user data to Firestore
      await _firestore.collection('korisnici').doc(userCredential.user!.uid).set({
        'email': email,
        'ime': ime,
        'prezime': prezime,
        'uloga': 'nastavnik',
        'grupe': [],
        'created': FieldValue.serverTimestamp(),
        'aktivan': true,
      });

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception('Sign up failed: ${e.message}');
    }
  }

  Future<User?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update lastLogin
      await _firestore
          .collection('korisnici')
          .doc(userCredential.user!.uid)
          .update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception('Sign in failed: ${e.message}');
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception('Reset password failed: ${e.message}');
    }
  }

  // Google Sign-In support (uncomment when google_sign_in is added to pubspec.yaml)
  /*
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      // Save or update user data in Firestore
      final userDoc =
          _firestore.collection('korisnici').doc(userCredential.user!.uid);
      
      final exists = await userDoc.get();
      if (!exists.exists) {
        // Create new user document
        await userDoc.set({
          'email': googleUser.email,
          'ime': googleUser.displayName?.split(' ').first ?? '',
          'prezime': googleUser.displayName?.split(' ').last ?? '',
          'uloga': 'nastavnik',
          'grupe': [],
          'created': FieldValue.serverTimestamp(),
          'aktivan': true,
        });
      } else {
        // Update last login
        await userDoc.update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }

      return userCredential.user;
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Google sign out failed: $e');
    }
  }
  */

  User? get currentUser => _firebaseAuth.currentUser;
}
