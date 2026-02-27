import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized App Theme.
///
/// All colors, text styles, and theme data controlled from here.
/// Uses Google Fonts (Inter) — no need to download font files.
class AppTheme {
  // ══════════════════════════════════════
  // COLORS
  // ══════════════════════════════════════

  // ── Primary ──
  static const Color primary = Color(0xFF667EEA);
  static const Color primaryDark = Color(0xFF764BA2);
  static const Color accent = Color(0xFF06B6D4);

  // ── Background ──
  static const Color scaffoldBg = Color(0xFFF4F2EE);
  static const Color cardBg = Colors.white;
  static const Color searchBg = Color(0xFFF3F4F6);

  // ── Text ──
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // ── Functional ──
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFD97706);
  static const Color warningText = Color(0xFF92400E);

  // ── Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFFFF7ED), Color(0xFFFEF3C7)],
  );

  // ── Rating ──
  static const Color ratingBg = Color(0xFFFFF3E0);
  static const Color ratingIcon = Color(0xFFFF9800);
  static const Color ratingText = Color(0xFFE65100);

  // ── Tags ──
  static Color productTagBg = primary.withValues(alpha: 0.08);
  static const Color productTagText = primary;
  static Color postTagBg = accent.withValues(alpha: 0.08);
  static const Color postTagText = Color(0xFF0891B2);

  // ── Reactions ──
  static const Color reactionBlue = Color(0xFF3B82F6);
  static const Color reactionRed = Color(0xFFEF4444);
  static const Color reactionGreen = Color(0xFF22C55E);

  // ══════════════════════════════════════
  // DIMENSIONS
  // ══════════════════════════════════════

  static const double cardRadius = 12.0;
  static const double iconRadius = 10.0;
  static const double tagRadius = 20.0;
  static const double buttonRadius = 12.0;
  static const double avatarSize = 44.0;
  static const double smallAvatarSize = 36.0;
  static const double logoSize = 36.0;
  static const double productImageHeight = 200.0;

  // ══════════════════════════════════════
  // TEXT STYLES (Google Fonts - Inter)
  // ══════════════════════════════════════

  // ── Headings ──
  static TextStyle heading1 = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static TextStyle heading2 = GoogleFonts.inter(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  // ── Card Title ──
  static TextStyle cardTitle = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.3,
  );

  // ── Body Text ──
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.6,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textTertiary,
  );

  // ── Labels ──
  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textTertiary,
  );

  // ── Price ──
  static TextStyle priceMain = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: success,
  );

  static TextStyle priceStrike = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textTertiary,
    decoration: TextDecoration.lineThrough,
  );

  // ── Action Buttons ──
  static TextStyle actionLabel = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  // ── Tag ──
  static TextStyle tagText = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  // ── Search ──
  static TextStyle searchInput = GoogleFonts.inter(
    fontSize: 14,
    color: textPrimary,
    fontWeight: FontWeight.w400,
  );

  static TextStyle searchHint = GoogleFonts.inter(
    fontSize: 14,
    color: textTertiary,
    fontWeight: FontWeight.w400,
  );

  // ── Banner ──
  static TextStyle bannerText = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: warningText,
  );

  // ── Discount Badge ──
  static TextStyle discountText = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: error,
  );

  // ── Rating ──
  static TextStyle ratingStyle = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: ratingText,
  );

  // ── Loader ──
  static TextStyle loaderText = GoogleFonts.inter(
    fontSize: 13,
    color: textTertiary,
    fontWeight: FontWeight.w500,
  );

  // ── Error ──
  static TextStyle errorTitleStyle = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle errorMessageStyle = GoogleFonts.inter(
    fontSize: 14,
    color: textTertiary,
    height: 1.5,
  );

  static TextStyle retryButtonStyle = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  // ── Logo ──
  static TextStyle logoText = GoogleFonts.inter(
    color: Colors.white,
    fontWeight: FontWeight.w700,
    fontSize: 14,
  );

  // ══════════════════════════════════════
  // CARD SHADOW
  // ══════════════════════════════════════

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];

  // ══════════════════════════════════════
  // THEME DATA
  // ══════════════════════════════════════

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: cardBg,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: heading1,
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
        ),
      ),
    );
  }
}
