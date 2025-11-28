import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary colors
  static const Color primaryColor = Color(0xFF1976D2); // Sea blue
  static const Color primaryDark = Color(0xFF0D47A1); // Darker blue
  static const Color primaryLight = Color(0xFFBBDEFB); // Light blue

  // Secondary colors
  static const Color secondaryColor = Color(0xFF26A69A); // Teal
  static const Color secondaryLight = Color(0xFFB2DFDB); // Light teal

  // Accent colors
  static const Color accentColor = Color(0xFF64B5F6); // Light blue accent
  static const Color accentSecondary = Color(0xFF80CBC4); // Light teal accent

  // Neutral colors
  static const Color scaffoldBackground = Color(0xFFF5F9FC); // Very light blue-ish white
  static const Color cardBackground = Colors.white;
  static const Color dividerColor = Color(0xFFEEEEEE);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);
  static const Color textWhite = Colors.white;

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Feature colors (for cards)
  static const Color featureExamColor = Color(0xFF5C6BC0); // Indigo
  static const Color featureEducationColor = Color(0xFF66BB6A); // Green
  static const Color featureChatColor = Color(0xFFFF7043); // Deep Orange
  static const Color featureCommunityColor = Color(0xFF8E24AA); // Purple
}

class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primaryColor,
      Color(0xFF42A5F5), // Lighter blue
    ],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.secondaryColor,
      Color(0xFF4DB6AC), // Lighter teal
    ],
  );

  // Feature gradients
  static const LinearGradient examGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.featureExamColor, Color(0xFF7986CB)],
  );

  static const LinearGradient educationGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.featureEducationColor, Color(0xFF81C784)],
  );

  static const LinearGradient chatGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.featureChatColor, Color(0xFFFF9E80)],
  );

  static const LinearGradient communityGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.featureCommunityColor, Color(0xFFAB47BC)],
  );
}

class AppShadows {
  static BoxShadow get small => BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 4,
    offset: const Offset(0, 2),
  );

  static BoxShadow get medium => BoxShadow(
    color: Colors.black.withOpacity(0.07),
    blurRadius: 8,
    offset: const Offset(0, 4),
  );

  static BoxShadow get large => BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 16,
    offset: const Offset(0, 8),
  );
}

class AppBorderRadius {
  static BorderRadius get small => BorderRadius.circular(8);
  static BorderRadius get medium => BorderRadius.circular(16);
  static BorderRadius get large => BorderRadius.circular(24);
  static BorderRadius get circle => BorderRadius.circular(100);
}

class AppTheme {
  static ThemeData get lightTheme {
    final baseTheme = ThemeData.light();

    // Use Google Fonts for a more professional look
    final textTheme = GoogleFonts.nunitoSansTextTheme(baseTheme.textTheme);
    final headlineFont = GoogleFonts.montserrat();

    return ThemeData(
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryColor,
        secondary: AppColors.secondaryColor,
        error: AppColors.error,
        background: AppColors.scaffoldBackground,
        surface: AppColors.cardBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        color: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        titleTextStyle: headlineFont.copyWith(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: textTheme.copyWith(
        displayLarge: headlineFont.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displayMedium: headlineFont.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displaySmall: headlineFont.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: const TextStyle(
          color: AppColors.textLight,
          fontSize: 16,
        ),
        // Add shadow
        isDense: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerColor,
        space: 1,
        thickness: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}