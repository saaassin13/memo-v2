import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// 用户头像和昵称展示组件
class UserHeader extends StatelessWidget {
  const UserHeader({
    super.key,
    this.avatarUrl,
    this.nickname = '用户',
    this.onTap,
  });

  /// 头像 URL，为空时显示默认图标
  final String? avatarUrl;

  /// 用户昵称
  final String nickname;

  /// 点击回调
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // 头像
          CircleAvatar(
            radius: 40,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Icon(
                    LucideIcons.user,
                    size: 40,
                    color: theme.colorScheme.primary,
                  )
                : null,
          ),
          const SizedBox(height: 12),
          // 昵称
          Text(
            nickname,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
