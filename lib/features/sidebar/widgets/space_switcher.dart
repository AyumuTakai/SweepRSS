import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/providers/active_space_provider.dart';
import '../../dialogs/space_manager_dialog.dart';

/// サイドバー最上部に表示するスペース切り替えウィジェット。
/// スペースが存在しない場合は非表示。
class SpaceSwitcher extends ConsumerWidget {
  const SpaceSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spaces = ref.watch(spacesStreamProvider).valueOrNull ?? [];
    final activeSpace = ref.watch(resolvedActiveSpaceProvider);

    if (spaces.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTapDown: (details) => _showSpaceMenu(
        context,
        ref,
        details.globalPosition,
        spaces,
        activeSpace,
      ),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Row(
          children: [
            const Icon(Icons.layers_outlined, size: 13),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                activeSpace?.name ??
                    AppLocalizations.of(context).spaceSwitcherSelect,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.unfold_more, size: 14),
          ],
        ),
      ),
    );
  }

  void _showSpaceMenu(
    BuildContext context,
    WidgetRef ref,
    Offset position,
    List spaces,
    activeSpace,
  ) {
    showMenu<String?>(
      context: context,
      position: RelativeRect.fromLTRB(
          position.dx, position.dy, position.dx + 1, position.dy + 1),
      items: [
        for (final s in spaces)
          PopupMenuItem<String?>(
            value: s.id,
            child: Row(
              children: [
                Icon(
                  Icons.check,
                  size: 14,
                  color: activeSpace?.id == s.id
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                ),
                const SizedBox(width: 8),
                Text(s.name),
              ],
            ),
          ),
        const PopupMenuDivider(),
        PopupMenuItem<String?>(
          value: '__manage__',
          child: Row(
            children: [
              const SizedBox(width: 22),
              Icon(Icons.settings_outlined,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context).spaceSwitcherManage),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (!context.mounted) return;
      if (value == '__manage__') {
        showDialog(
          context: context,
          builder: (_) => const SpaceManagerDialog(),
        );
      } else if (value != null) {
        ref.read(activeSpaceProvider.notifier).setSpace(value);
      }
    });
  }
}
