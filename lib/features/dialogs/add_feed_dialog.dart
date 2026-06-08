import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../shared/providers/active_space_provider.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/widgets/toast_overlay.dart';

class AddFeedDialog extends ConsumerStatefulWidget {
  const AddFeedDialog({super.key});

  @override
  ConsumerState<AddFeedDialog> createState() => _AddFeedDialogState();
}

class _AddFeedDialogState extends ConsumerState<AddFeedDialog> {
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() { _loading = true; _error = null; });

    try {
      final activeSpace = ref.read(resolvedActiveSpaceProvider);
      await ref.read(rsServiceProvider).addFeed(
        url,
        title: _titleController.text.trim().isEmpty
            ? null
            : _titleController.text.trim(),
        spaceId: activeSpace?.id,
      );
      if (mounted) {
        ref
            .read(toastProvider.notifier)
            .show(AppLocalizations.of(context).toastFeedAdded);
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.addFeedDialogTitle),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: l10n.addFeedUrlLabel,
                hintText: 'https://example.com/feed.xml',
              ),
              autofocus: true,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.addFeedTitleLabel,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.dialogCancel),
        ),
        FilledButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.dialogAdd),
        ),
      ],
    );
  }
}
