import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/providers/create_session_provider.dart';
import '../../../l10n/app_localizations.dart';

class SelectedArtistsSection extends ConsumerWidget {
  const SelectedArtistsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final createState = ref.watch(createSessionProvider);

    if (createState.selectedArtists.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l10n.selectedArtists} (${createState.selectedArtists.length})',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: createState.selectedArtists.map((artist) {
              return ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 180),
                child: Chip(
                  avatar: artist.thumbnailUrl != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(artist.thumbnailUrl!),
                        )
                      : null,
                  label: Text(
                    artist.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () {
                    ref
                        .read(createSessionProvider.notifier)
                        .removeArtist(artist.id);
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
