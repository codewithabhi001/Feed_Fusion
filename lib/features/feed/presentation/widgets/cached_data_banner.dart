import 'package:flutter/material.dart';
import '../../../../core/constants/app_text.dart';
import '../../../../core/theme/app_theme.dart';

/// Banner shown when displaying cached offline data.
///
/// Styled with warning amber color scheme.
/// All styling from AppTheme, all text from AppText.
class CachedDataBanner extends StatelessWidget {
  const CachedDataBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: AppTheme.warningGradient,
        border: Border(
          bottom: BorderSide(color: AppTheme.warning.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              color: AppTheme.warningDark,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(AppText.cachedDataMessage, style: AppTheme.bannerText),
          ),
        ],
      ),
    );
  }
}
