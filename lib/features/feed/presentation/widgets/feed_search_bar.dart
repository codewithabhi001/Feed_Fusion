import 'package:flutter/material.dart';
import '../../../../core/constants/app_text.dart';
import '../../../../core/theme/app_theme.dart';

/// Premium search bar widget styled like LinkedIn's search.
///
/// Features debounced input callback and clear button.
/// All styling from AppTheme, all text from AppText.
class FeedSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool isSearchActive;

  const FeedSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.isSearchActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.searchBg,
        borderRadius: BorderRadius.circular(AppTheme.iconRadius),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTheme.searchInput,
        decoration: InputDecoration(
          hintText: AppText.searchHint,
          hintStyle: AppTheme.searchHint,
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isSearchActive ? AppTheme.primary : AppTheme.textTertiary,
            size: 22,
          ),
          suffixIcon: isSearchActive
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
