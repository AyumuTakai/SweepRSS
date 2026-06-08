import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ToastMessage {
  final String text;
  final bool isError;
  final DateTime createdAt;

  ToastMessage({required this.text, this.isError = false})
      : createdAt = DateTime.now();
}

class ToastNotifier extends Notifier<List<ToastMessage>> {
  @override
  List<ToastMessage> build() => [];

  void show(String text, {bool isError = false}) {
    final msg = ToastMessage(text: text, isError: isError);
    state = [...state, msg];
    Future.delayed(const Duration(seconds: 3), () {
      state = state.where((m) => m != msg).toList();
    });
  }

  void showError(String text) => show(text, isError: true);
}

final toastProvider = NotifierProvider<ToastNotifier, List<ToastMessage>>(
  ToastNotifier.new,
);

class ToastOverlay extends ConsumerWidget {
  final Widget child;
  const ToastOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toasts = ref.watch(toastProvider);
    return Stack(
      children: [
        child,
        Positioned(
          bottom: 24,
          right: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: toasts
                .map((t) => _ToastCard(message: t))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _ToastCard extends StatelessWidget {
  final ToastMessage message;
  const _ToastCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: message.isError ? Colors.red.shade800 : Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: Text(
        message.text,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }
}
