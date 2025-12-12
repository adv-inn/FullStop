import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../themes/app_theme.dart';

class TrackLimitDialog extends StatefulWidget {
  final TextEditingController controller;
  final int initialValue;
  final AppLocalizations l10n;

  const TrackLimitDialog({
    super.key,
    required this.controller,
    required this.initialValue,
    required this.l10n,
  });

  @override
  State<TrackLimitDialog> createState() => _TrackLimitDialogState();
}

class _TrackLimitDialogState extends State<TrackLimitDialog> {
  late int _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final value = int.tryParse(widget.controller.text);
    if (value != null && value > 0) {
      setState(() {
        _selectedValue = value;
      });
    }
  }

  void _selectValue(int value) {
    setState(() {
      _selectedValue = value;
      widget.controller.text = value.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.spotifyDarkGray,
      title: Text(
        widget.l10n.trackLimit,
        style: const TextStyle(color: AppTheme.spotifyWhite),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: const TextStyle(color: AppTheme.spotifyWhite),
            decoration: InputDecoration(
              hintText: '50',
              hintStyle: TextStyle(color: AppTheme.spotifyLightGray),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.spotifyLightGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.spotifyGreen),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Quick select buttons (max 100)
          Wrap(
            spacing: 8,
            children: [20, 50, 80, 100].map((value) {
              final isSelected = _selectedValue == value;
              return ActionChip(
                label: Text('$value'),
                backgroundColor: isSelected
                    ? AppTheme.spotifyGreen.withValues(alpha: 0.3)
                    : AppTheme.spotifyBlack,
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppTheme.spotifyGreen
                      : AppTheme.spotifyWhite,
                  fontSize: 12,
                ),
                onPressed: () => _selectValue(value),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            widget.l10n.cancel,
            style: const TextStyle(color: AppTheme.spotifyLightGray),
          ),
        ),
        TextButton(
          onPressed: () {
            final value = int.tryParse(widget.controller.text);
            if (value != null && value > 0) {
              // Clamp to max 100 tracks
              final clampedValue = value > 100 ? 100 : value;
              Navigator.pop(context, clampedValue);
            }
          },
          child: Text(
            widget.l10n.save,
            style: const TextStyle(color: AppTheme.spotifyGreen),
          ),
        ),
      ],
    );
  }
}
