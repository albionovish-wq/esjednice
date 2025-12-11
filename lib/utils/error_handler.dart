import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Custom exception class for application-specific errors
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;
  final StackTrace? stackTrace;

  AppException({
    required this.message,
    this.code,
    this.originalException,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

/// Error handler utility for consistent error management
class ErrorHandler {
  /// Handle Firebase Authentication errors
  static String handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Korisnik nije pronađen. Provjerite email adresu.';
      case 'wrong-password':
        return 'Pogrešna lozinka. Pokušajte ponovno.';
      case 'user-disabled':
        return 'Ovaj korisnik je onemogućen.';
      case 'too-many-requests':
        return 'Previše pokušaja. Pokušajte kasnije.';
      case 'operation-not-allowed':
        return 'Ova operacija nije dopuštena.';
      case 'email-already-in-use':
        return 'Email adresa je već registrirana.';
      case 'invalid-email':
        return 'Email adresa nije valjana.';
      case 'weak-password':
        return 'Lozinka je preslaba. Koristite najmanje 6 znakova.';
      case 'account-exists-with-different-credential':
        return 'Račun već postoji sa drugačitim pristupom.';
      case 'invalid-credential':
        return 'Nevalide kredencijale.';
      case 'operation-not-supported':
        return 'Ova operacija nije podržana.';
      case 'network-request-failed':
        return 'Mrežna greška. Provjerite vašu konekciju.';
      case 'internal-error':
        return 'Interna greška. Pokušajte ponovno.';
      default:
        return 'Greška pri autentifikaciji: ${e.message}';
    }
  }

  /// Handle Firestore errors
  static String handleFirestoreError(Exception e) {
    final message = e.toString();

    if (message.contains('PERMISSION_DENIED')) {
      return 'Nemate dozvolu za pristup ovom resurs.';
    }
    if (message.contains('NOT_FOUND')) {
      return 'Resurs nije pronađen.';
    }
    if (message.contains('ALREADY_EXISTS')) {
      return 'Resurs već postoji.';
    }
    if (message.contains('INVALID_ARGUMENT')) {
      return 'Nevalidan argument.';
    }
    if (message.contains('DEADLINE_EXCEEDED')) {
      return 'Zahtjev je trajao previše dugo.';
    }
    if (message.contains('UNAVAILABLE')) {
      return 'Servis je trenutno nedostupan. Pokušajte ponovno.';
    }
    if (message.contains('UNAUTHENTICATED')) {
      return 'Trebate se prijavljati.';
    }

    return 'Greška pri radu sa bazom: $message';
  }

  /// Handle generic exceptions
  static String handleGenericError(Exception e) {
    if (e is FirebaseAuthException) {
      return handleAuthError(e);
    }

    final message = e.toString();

    if (message.contains('Network')) {
      return 'Mrežna greška. Provjerite vašu konekciju.';
    }
    if (message.contains('Timeout')) {
      return 'Zahtjev je istekao. Pokušajte ponovno.';
    }
    if (message.contains('Permission')) {
      return 'Nemate dozvolu za ovu radnju.';
    }

    return 'Došlo je do greške: $message';
  }

  /// Log error for debugging
  static void logError({
    required String message,
    required Exception error,
    StackTrace? stackTrace,
  }) {
    print('❌ ERROR: $message');
    print('📍 Exception: ${error.toString()}');
    if (stackTrace != null) {
      print('📍 StackTrace:\n$stackTrace');
    }
  }

  /// Show error snackbar
  static void showErrorSnackbar({
    required BuildContext context,
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Zatvori',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackbar({
    required BuildContext context,
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show info snackbar
  static void showInfoSnackbar({
    required BuildContext context,
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue[700],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show error dialog
  static Future<void> showErrorDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('U redu'),
            ),
          ],
        );
      },
    );
  }
}
