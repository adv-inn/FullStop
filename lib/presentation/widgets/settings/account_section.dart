import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/providers/auth_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../themes/app_theme.dart';

class AccountSection extends ConsumerWidget {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);

    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundImage: authState.user?.imageUrl != null
                ? NetworkImage(authState.user!.imageUrl!)
                : null,
            child: authState.user?.imageUrl == null
                ? const Icon(Icons.person)
                : null,
          ),
          title: Text(authState.user?.displayName ?? 'Not logged in'),
          subtitle: Text(authState.user?.email ?? ''),
          trailing: Chip(
            label: Text(
              authState.user?.isPremium == true ? l10n.premium : l10n.free,
            ),
            backgroundColor: authState.user?.isPremium == true
                ? AppTheme.spotifyGreen.withValues(alpha: 0.2)
                : null,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: Text(l10n.logout),
          onTap: () => _showLogoutDialog(context, ref, l10n),
        ),
      ],
    );
  }

  void _showLogoutDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: const Text(
          'Are you sure you want to disconnect from Spotify?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
              Navigator.pop(context);
            },
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
}
