import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_text.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/feed_item_entity.dart';
import '../controller/feed_controller.dart';
import '../widgets/product_card.dart';
import '../widgets/post_card.dart';
import '../widgets/feed_search_bar.dart';
import '../widgets/cached_data_banner.dart';
import '../widgets/bottom_loader.dart';
import '../widgets/error_retry_widget.dart';
import '../widgets/feed_shimmer_loading.dart';
import '../widgets/log_viewer_sheet.dart';

/// Main Feed Page — LinkedIn-style unified feed.
class FeedPage extends GetView<FeedController> {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Obx(() {
              if (controller.showCachedBanner.value) {
                return const CachedDataBanner();
              }
              return const SizedBox.shrink();
            }),
            Expanded(child: Obx(() => _buildContent())),
          ],
        ),
      ),
      // Performance Log Viewer FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.bottomSheet(
          const LogViewerSheet(),
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: AppTheme.primary,
        elevation: 8,
        child: const Icon(Icons.analytics_outlined, color: Colors.white),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: AppTheme.logoSize,
            height: AppTheme.logoSize,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.iconRadius),
            ),
            child: Center(
              child: Text(AppText.appLogoText, style: AppTheme.logoText),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(
              () => FeedSearchBar(
                controller: controller.searchTextController,
                onChanged: controller.onSearchChanged,
                onClear: controller.clearSearch,
                isSearchActive: controller.isSearchMode.value,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: AppTheme.logoSize,
            height: AppTheme.logoSize,
            decoration: BoxDecoration(
              color: AppTheme.searchBg,
              borderRadius: BorderRadius.circular(AppTheme.iconRadius),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: AppTheme.textSecondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final state = controller.feedState.value;

    if (state is FeedLoading || state is FeedInitial) {
      return const FeedShimmerLoading();
    } else if (state is FeedLoaded) {
      return _buildFeedList(state.items);
    } else if (state is FeedCached) {
      return _buildFeedList(state.items);
    } else if (state is FeedError) {
      return ErrorRetryWidget(
        message: state.message,
        onRetry: controller.retry,
      );
    }

    return const FeedShimmerLoading();
  }

  Widget _buildFeedList(List<FeedItemEntity> items) {
    if (items.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: controller.onRefresh,
      color: AppTheme.primary,
      child: ListView.builder(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index == items.length) {
            return Obx(() {
              if (controller.isLoadingMore.value) {
                return const BottomLoader();
              }
              return const SizedBox(height: 20);
            });
          }

          final item = items[index];

          if (item is ProductFeedItem) {
            return ProductCard(product: item.product);
          } else if (item is PostFeedItem) {
            return PostCard(post: item.post);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.searchBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.search_off_rounded,
              color: AppTheme.textTertiary,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(AppText.noResultsTitle, style: AppTheme.heading2),
          const SizedBox(height: 8),
          Text(AppText.noResultsSubtitle, style: AppTheme.bodyLarge),
        ],
      ),
    );
  }
}
