import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/providers/cache_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../themes/app_theme.dart';

class CacheSection extends ConsumerWidget {
  const CacheSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cacheState = ref.watch(cacheProvider);

    return Column(
      children: [
        // Image cache size
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.spotifyGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.image, color: AppTheme.spotifyGreen, size: 24),
          ),
          title: Text(l10n.imageCacheSize),
          subtitle: Text(
            cacheState.isCalculating
                ? l10n.calculating
                : cacheState.formattedSize,
            style: TextStyle(color: AppTheme.spotifyLightGray),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: cacheState.isCalculating
                ? null
                : () => ref.read(cacheProvider.notifier).calculateCacheSize(),
            tooltip: 'Refresh',
          ),
        ),

        // Clear cache button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: cacheState.isClearing
                  ? null
                  : () => _clearCache(context, ref, l10n),
              icon: cacheState.isClearing
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.red,
                      ),
                    )
                  : const Icon(Icons.delete_outline, color: Colors.red),
              label: Text(
                l10n.clearCache,
                style: TextStyle(
                  color: cacheState.isClearing
                      ? AppTheme.spotifyLightGray
                      : Colors.red,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: cacheState.isClearing
                      ? AppTheme.spotifyLightGray
                      : Colors.red.withValues(alpha: 0.5),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),

        // Hint text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _getCacheHint(context),
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.spotifyLightGray.withValues(alpha: 0.7),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  String _getCacheHint(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'zh') {
      return '清除缓存仅删除图片缓存，不会影响您的账户信息、会话数据和设置。';
    }
    return 'Clearing cache only removes cached images. Your account, sessions, and settings will not be affected.';
  }

  Future<void> _clearCache(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearCache),
        content: Text(_getCacheHint(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.clearCache),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(cacheProvider.notifier).clearImageCache();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? l10n.cacheCleared : l10n.cacheClearFailed),
            backgroundColor: success ? AppTheme.spotifyGreen : Colors.red,
          ),
        );
      }
    }
  }
}
