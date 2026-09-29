import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ألوان التطبيق. القيم تتغير تلقائياً حسب [dark] (الوضع الليلي).
class AppColors {
  AppColors._();

  /// يُضبط من AppState عند تحميل الإعدادات أو تغيير الوضع الليلي.
  static bool dark = false;

  static Color _p(int light, int night) => Color(dark ? night : light);

  // ألوان ثابتة في الوضعين
  static const heroBg = Color(0xFF1F2F53); // البطاقة الزرقاء العلوية
  static const splash = Color(0xFF172038); // شاشة البداية وبطاقة المطور

  // الأساسيات
  static Color get bg => _p(0xFFF5F3EE, 0xFF11141B);
  static Color get surface => _p(0xFFFFFFFF, 0xFF1A1F2A);
  static Color get border => _p(0xFFE6E1D7, 0xFF2B3141);
  static Color get text => _p(0xFF1E1E22, 0xFFECEAE4);
  static Color get muted => _p(0xFF8D8272, 0xFFA39B8C);
  static Color get navy => _p(0xFF1F2F53, 0xFF5D7CC6);
  static Color get gold => _p(0xFFB27F30, 0xFFD9A54E);
  static Color get green => _p(0xFF3F6E50, 0xFF4F8F68);
  static Color get red => _p(0xFFB9412E, 0xFFE0705E);
  static Color get rose => _p(0xFFA64D65, 0xFFD98299);

  // الخلفيات الفرعية
  static Color get field => _p(0xFFF5F3EE, 0xFF222836);
  static Color get track => _p(0xFFE5E0D8, 0xFF343B4D);
  static Color get ringTrack => _p(0xFFDDDAD5, 0xFF343B4D);
  static Color get softBlue => _p(0xFFE6E9F0, 0xFF262F47);
  static Color get greenTint => _p(0xFFE3EDE6, 0xFF1E3428);
  static Color get redTint => _p(0xFFF5E6E3, 0xFF3A2321);
  static Color get goldTint => _p(0xFFF5EBDD, 0xFF3A2F1C);
  static Color get roseTint => _p(0xFFF3E3E8, 0xFF3A2530);
  static Color get chip => _p(0xFFE9E7E1, 0xFF2B3141);
  static Color get chipIdle => _p(0xFFF1EEE7, 0xFF262C3A);
  static Color get warmCard => _p(0xFFF7F3EC, 0xFF161B25);
  static Color get stepDone => _p(0xFFFBFAF7, 0xFF161A23);
  static Color get menuSelected => _p(0xFFE6E3DC, 0xFF2B3141);

  // الحدود والتفاصيل
  static Color get divider => _p(0xFFECE8DF, 0xFF2B3141);
  static Color get checkBorder => _p(0xFFDAD5CB, 0xFF3B4254);
  static Color get switchOff => _p(0xFFD8D3C8, 0xFF3B4254);
  static Color get emptyIcon => _p(0xFFCFC8BC, 0xFF485065);
  static Color get greenBorder => _p(0xFFB9CDBF, 0xFF2F5240);
  static Color get greenBorderSoft => _p(0xFFCBDCD1, 0xFF264536);
  static Color get avatarBorder => _p(0xFFB9BFD0, 0xFF3B4560);

  // نصوص
  static Color get hint => _p(0xFFB0A797, 0xFF6E7688);
  static Color get faint => _p(0xFFA79E8E, 0xFF7A8294);
  static Color get doneText => _p(0xFF55575C, 0xFF9AA0AD);
}

Color alpha(Color c, double opacity) => c.withAlpha((opacity * 255).round());

class AppText {
  AppText._();

  /// خط النصوص العادية.
  static TextStyle body({
    double size = 15,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double? height,
  }) =>
      GoogleFonts.ibmPlexSansArabic(
        fontSize: size,
        fontWeight: weight,
        color: color ?? AppColors.text,
        height: height,
      );

  /// خط العناوين (نسخ عربي كلاسيكي).
  static TextStyle heading({
    double size = 24,
    Color? color,
    FontWeight weight = FontWeight.w700,
  }) =>
      GoogleFonts.amiri(
        fontSize: size,
        fontWeight: weight,
        color: color ?? AppColors.text,
        height: 1.4,
      );
}

ThemeData buildTheme() {
  final brightness = AppColors.dark ? Brightness.dark : Brightness.light;
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.navy, brightness: brightness)
        .copyWith(primary: AppColors.navy, surface: AppColors.surface),
    scaffoldBackgroundColor: AppColors.bg,
  );
  return base.copyWith(
    textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(base.textTheme),
    textSelectionTheme: TextSelectionThemeData(cursorColor: AppColors.navy),
  );
}
