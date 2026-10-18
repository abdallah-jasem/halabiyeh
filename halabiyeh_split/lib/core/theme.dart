import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Arabic uses the bundled Noto Sans Arabic (Rubik has no Arabic glyphs, so
/// the system fallback looked lighter and sat off-baseline).
ThemeData buildAppTheme(Color accent, {bool arabic = false}) {
  final rubik = GoogleFonts.rubikTextTheme();
  final textTheme = arabic
      ? rubik.apply(fontFamily: 'NotoSansArabic', fontFamilyFallback: [GoogleFonts.rubik().fontFamily!])
      : rubik.apply(fontFamilyFallback: const ['NotoSansArabic']);
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: kPaper,
    textTheme: textTheme,
    colorScheme: ColorScheme.fromSeed(seedColor: accent, brightness: Brightness.light),
    appBarTheme: const AppBarTheme(
      backgroundColor: kPaper,
      foregroundColor: Color(0xFF17211D),
      elevation: 0,
      // Same inset as the ListView padding so titles line up with cards.
      titleSpacing: 20,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: accent,
        selectedForegroundColor: Colors.white,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF17211D),
        // No invisible 48px tap padding: it left extra space under the buttons.
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    ),
  );
}

const Color kPaper = Color(0xFFF3F1EC);
const Color kInk = Color(0xFF17211D);
const Color kMuted = Color(0xFF5C665F);
