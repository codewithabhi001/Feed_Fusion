import 'package:flutter/material.dart';
import '../../../../core/constants/app_text.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/post_entity.dart';

/// LinkedIn-style Post Card.
///
/// Displays post title, body, tags, reactions (likes/dislikes),
/// and views in a social media card layout.
/// All styling from AppTheme, all text from AppText.
class PostCard extends StatelessWidget {
  final PostEntity post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 14),
            Text(
              post.title,
              style: AppTheme.cardTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Text(
              post.body,
              style: AppTheme.bodyLarge,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),
            if (post.tags.isNotEmpty) ...[
              _buildTags(),
              const SizedBox(height: 14),
            ],
            _buildStats(),
            const Divider(height: 24),
            _buildActionRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: AppTheme.avatarSize,
          height: AppTheme.avatarSize,
          decoration: BoxDecoration(
            gradient: AppTheme.accentGradient,
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          ),
          child: Center(
            child: Text('U${post.userId}', style: AppTheme.logoText),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('User ${post.userId}', style: AppTheme.labelMedium),
              const SizedBox(height: 2),
              Text(AppText.sharedAPost, style: AppTheme.bodySmall),
            ],
          ),
        ),
        Icon(Icons.more_horiz, color: AppTheme.textTertiary, size: 20),
      ],
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: post.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.postTagBg,
            borderRadius: BorderRadius.circular(AppTheme.tagRadius),
          ),
          child: Text(
            '#$tag',
            style: AppTheme.tagText.copyWith(color: AppTheme.postTagText),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        _buildReactionGroup(),
        const SizedBox(width: 8),
        Text(
          '${post.reactions} ${AppText.reactions}',
          style: AppTheme.bodySmall,
        ),
        const Spacer(),
        Text(
          '${_formatCount(post.views)} ${AppText.views}',
          style: AppTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildReactionGroup() {
    return SizedBox(
      width: 52,
      height: 22,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: _ReactionBubble(
              color: AppTheme.reactionBlue,
              icon: Icons.thumb_up_rounded,
            ),
          ),
          Positioned(
            left: 14,
            child: _ReactionBubble(
              color: AppTheme.reactionRed,
              icon: Icons.favorite_rounded,
            ),
          ),
          Positioned(
            left: 28,
            child: _ReactionBubble(
              color: AppTheme.reactionGreen,
              icon: Icons.celebration_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow() {
    return Row(
      children: [
        _buildAction(
          Icons.thumb_up_outlined,
          AppText.likeAction,
          '${post.likes}',
        ),
        _buildAction(Icons.comment_outlined, AppText.commentAction, ''),
        _buildAction(Icons.repeat_rounded, AppText.repostAction, ''),
        _buildAction(Icons.send_outlined, AppText.sendAction, ''),
      ],
    );
  }

  Widget _buildAction(IconData icon, String label, String count) {
    return Expanded(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  count.isNotEmpty ? '$label ($count)' : label,
                  style: AppTheme.actionLabel,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

class _ReactionBubble extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _ReactionBubble({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(icon, color: Colors.white, size: 10),
    );
  }
}
