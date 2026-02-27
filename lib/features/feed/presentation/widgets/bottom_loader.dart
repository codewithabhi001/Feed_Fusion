import 'package:flutter/material.dart';
import '../../../../core/constants/app_text.dart';
import '../../../../core/theme/app_theme.dart';

/// Bottom loader shown during pagination.
///
/// Displays a circular progress indicator with a subtle message.
/// All styling from AppTheme, all text from AppText.
class BottomLoader extends StatelessWidget {
  const BottomLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primary.withValues(alpha: 0.7),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(AppText.loadingMore, style: AppTheme.loaderText),
          ],
        ),
      ),
    );
  }
}
