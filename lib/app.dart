import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/opml/opml_import_provider.dart';
import 'l10n/generated/app_localizations.dart';
import 'shared/providers/active_space_provider.dart';
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
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ja'),
      ],
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

    final l10n = AppLocalizations.of(context);
    final isImporting = ref.watch(
      opmlImportProvider.select((s) => s.isRunning),
    );
    final activeSpace = ref.watch(resolvedActiveSpaceProvider);

    final scaffold = Scaffold(
      body: ToastOverlay(
        child: const AdaptiveLayout(),
      ),
    );

    if (Platform.isMacOS) {
      return PlatformMenuBar(
        menus: [
          PlatformMenu(
            label: 'SweepRSS',
            menus: [
              PlatformMenuItem(
                label: l10n.menuAbout,
                onSelected: () => showAboutDialog(
                  context: context,
                  applicationName: 'SweepRSS',
                  applicationVersion: '0.1.0',
                ),
              ),
              PlatformMenuItemGroup(members: [
                PlatformMenuItem(
                  label: l10n.menuQuit,
                  shortcut: const SingleActivator(LogicalKeyboardKey.keyQ,
                      meta: true),
                  onSelected: SystemNavigator.pop,
                ),
              ]),
            ],
          ),
          PlatformMenu(
            label: l10n.menuFile,
            menus: [
              PlatformMenuItem(
                label: l10n.menuImportOpml,
                shortcut: const SingleActivator(LogicalKeyboardKey.keyI,
                    meta: true),
                onSelected: isImporting
                    ? null
                    : () =>
                        ref.read(opmlImportProvider.notifier).startImport(),
              ),
              PlatformMenuItemGroup(members: [
                PlatformMenu(
                  label: l10n.menuExportOpml,
                  menus: [
                    PlatformMenuItem(
                      label: l10n.menuExportAllSpaces,
                      shortcut: const SingleActivator(
                          LogicalKeyboardKey.keyE,
                          meta: true,
                          shift: true),
                      onSelected: () => ref
                          .read(opmlImportProvider.notifier)
                          .exportAllSpaces(
                            dialogTitle: l10n.opmlExportAllDialogTitle,
                          ),
                    ),
                    PlatformMenuItem(
                      label: activeSpace != null
                          ? l10n.menuExportCurrentSpace(activeSpace.name)
                          : l10n.menuExportCurrentSpaceFallback,
                      shortcut: const SingleActivator(
                          LogicalKeyboardKey.keyE,
                          meta: true),
                      onSelected: activeSpace != null
                          ? () => ref
                              .read(opmlImportProvider.notifier)
                              .exportCurrentSpace(
                                activeSpace,
                                dialogTitle: l10n.opmlExportSpaceDialogTitle(
                                    activeSpace.name),
                              )
                          : null,
                    ),
                  ],
                ),
              ]),
            ],
          ),
          PlatformMenu(
            label: l10n.menuView,
            menus: [
              PlatformMenuItem(
                label: l10n.menuRefreshAll,
                shortcut: const SingleActivator(LogicalKeyboardKey.keyR,
                    meta: true),
                onSelected: () =>
                    ref.read(refreshProvider.notifier).refreshAll(),
              ),
            ],
          ),
        ],
        child: scaffold,
      );
    }

    // Windows / Linux: in-window menu bar
    return _WinLinuxMenuBar(
      isImporting: isImporting,
      activeSpace: activeSpace,
      child: scaffold,
    );
  }
}

// ── Windows / Linux インウィンドウ メニューバー ────────────────────────────────

class _WinLinuxMenuBar extends ConsumerWidget {
  const _WinLinuxMenuBar({
    required this.isImporting,
    required this.activeSpace,
    required this.child,
  });

  final bool isImporting;
  final dynamic activeSpace;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    void importOpml() {
      if (!isImporting) ref.read(opmlImportProvider.notifier).startImport();
    }

    void exportAll() => ref
        .read(opmlImportProvider.notifier)
        .exportAllSpaces(dialogTitle: l10n.opmlExportAllDialogTitle);

    void exportCurrent() {
      if (activeSpace != null) {
        ref.read(opmlImportProvider.notifier).exportCurrentSpace(
              activeSpace,
              dialogTitle:
                  l10n.opmlExportSpaceDialogTitle(activeSpace.name),
            );
      }
    }

    void refreshAll() => ref.read(refreshProvider.notifier).refreshAll();

    return CallbackShortcuts(
      bindings: {
        SingleActivator(LogicalKeyboardKey.keyI, control: true): importOpml,
        SingleActivator(LogicalKeyboardKey.keyE, control: true, shift: true):
            exportAll,
        SingleActivator(LogicalKeyboardKey.keyE, control: true): exportCurrent,
        SingleActivator(LogicalKeyboardKey.keyR, control: true): refreshAll,
        SingleActivator(LogicalKeyboardKey.keyQ, control: true):
            SystemNavigator.pop,
      },
      child: Focus(
        autofocus: true,
        child: Column(
          children: [
            MenuBar(
              children: [
                SubmenuButton(
                  menuChildren: [
                    MenuItemButton(
                      onPressed: () => showAboutDialog(
                        context: context,
                        applicationName: 'SweepRSS',
                        applicationVersion: '0.1.0',
                      ),
                      child: Text(l10n.menuAbout),
                    ),
                    const Divider(),
                    MenuItemButton(
                      onPressed: SystemNavigator.pop,
                      shortcut: const SingleActivator(
                          LogicalKeyboardKey.keyQ, control: true),
                      child: Text(l10n.menuQuit),
                    ),
                  ],
                  child: const Text('SweepRSS'),
                ),
                SubmenuButton(
                  menuChildren: [
                    MenuItemButton(
                      onPressed: isImporting ? null : importOpml,
                      shortcut: const SingleActivator(
                          LogicalKeyboardKey.keyI, control: true),
                      child: Text(l10n.menuImportOpml),
                    ),
                    SubmenuButton(
                      menuChildren: [
                        MenuItemButton(
                          onPressed: exportAll,
                          shortcut: const SingleActivator(
                              LogicalKeyboardKey.keyE,
                              control: true,
                              shift: true),
                          child: Text(l10n.menuExportAllSpaces),
                        ),
                        MenuItemButton(
                          onPressed: activeSpace != null ? exportCurrent : null,
                          shortcut: const SingleActivator(
                              LogicalKeyboardKey.keyE, control: true),
                          child: Text(
                            activeSpace != null
                                ? l10n.menuExportCurrentSpace(activeSpace.name)
                                : l10n.menuExportCurrentSpaceFallback,
                          ),
                        ),
                      ],
                      child: Text(l10n.menuExportOpml),
                    ),
                  ],
                  child: Text(l10n.menuFile),
                ),
                SubmenuButton(
                  menuChildren: [
                    MenuItemButton(
                      onPressed: refreshAll,
                      shortcut: const SingleActivator(
                          LogicalKeyboardKey.keyR, control: true),
                      child: Text(l10n.menuRefreshAll),
                    ),
                  ],
                  child: Text(l10n.menuView),
                ),
              ],
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
