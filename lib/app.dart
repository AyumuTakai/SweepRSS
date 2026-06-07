import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/opml/opml_import_provider.dart';
import 'shared/providers/refresh_provider.dart';
import 'shared/widgets/adaptive_layout.dart';
import 'shared/widgets/toast_overlay.dart';

class RssReaderApp extends StatelessWidget {
  const RssReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SweepRSS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const _AppShell(),
    );
  }
}

class _AppShell extends ConsumerWidget {
  const _AppShell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(autoRefreshProvider);

    final isImporting = ref.watch(
      opmlImportProvider.select((s) => s.isRunning),
    );

    return PlatformMenuBar(
      menus: [
        PlatformMenu(
          label: 'SweepRSS',
          menus: [
            PlatformMenuItem(
              label: 'SweepRSS について',
              onSelected: () => showAboutDialog(
                context: context,
                applicationName: 'SweepRSS',
                applicationVersion: '0.1.0',
              ),
            ),
            PlatformMenuItemGroup(members: [
              PlatformMenuItem(
                label: 'SweepRSS を終了',
                shortcut: const SingleActivator(LogicalKeyboardKey.keyQ, meta: true),
                onSelected: SystemNavigator.pop,
              ),
            ]),
          ],
        ),
        PlatformMenu(
          label: 'ファイル',
          menus: [
            PlatformMenuItem(
              label: 'OPML をインポート...',
              shortcut: const SingleActivator(LogicalKeyboardKey.keyI, meta: true),
              onSelected: isImporting
                  ? null
                  : () => ref.read(opmlImportProvider.notifier).startImport(),
            ),
            PlatformMenuItemGroup(members: [
              PlatformMenuItem(
                label: 'OPML をエクスポート...',
                shortcut: const SingleActivator(LogicalKeyboardKey.keyE, meta: true),
                onSelected: () => ref.read(opmlImportProvider.notifier).exportOpml(),
              ),
            ]),
          ],
        ),
        PlatformMenu(
          label: '表示',
          menus: [
            PlatformMenuItem(
              label: '全フィードを更新',
              shortcut: const SingleActivator(LogicalKeyboardKey.keyR, meta: true),
              onSelected: () => ref.read(refreshProvider.notifier).refreshAll(),
            ),
          ],
        ),
      ],
      child: Scaffold(
        body: ToastOverlay(
          child: const AdaptiveLayout(),
        ),
      ),
    );
  }

}
