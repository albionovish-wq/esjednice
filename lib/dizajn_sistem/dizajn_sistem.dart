import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppDesign {
  // Colors
  static const Color primaryBlue = Color(0xFF0066CC);
  static const Color darkBlue = Color(0xFF003366);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color errorRed = Color(0xFFDC3545);
  static const Color successGreen = Color(0xFF28A745);
  static const Color warningYellow = Color(0xFFFFC107);
  static const Color borderGray = Color(0xFFE9ECEF);

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXl = 32.0;

  // Border Radius
  static const double cardRadius = 12.0;
  static const double buttonRadius = 8.0;
  static const double iconRadius = 6.0;

  // Shadow
  static final BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 8.0,
    offset: const Offset(0, 2),
  );

  // Text Styles
  static TextStyle get pageTitle {
    return GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: darkBlue,
    );
  }

  static TextStyle get cardTitle {
    return GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: darkBlue,
    );
  }

  static TextStyle get bodyText {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: darkBlue,
    );
  }

  static TextStyle get bodyTextSmall {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: darkBlue,
    );
  }

  static TextStyle get buttonText {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: white,
    );
  }

  static TextStyle get labelText {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: darkBlue,
    );
  }

  // ThemeData
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: lightGray,
      appBarTheme: AppBarTheme(
        backgroundColor: white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        titleTextStyle: pageTitle,
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: primaryBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(buttonRadius)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingM,
            vertical: spacingS,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: buttonText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
          borderSide: const BorderSide(color: borderGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
          borderSide: const BorderSide(color: borderGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingM,
          vertical: spacingM,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: borderGray),
        ),
        color: white,
      ),
    );
  }
}
