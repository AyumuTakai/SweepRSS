import 'package:flutter_riverpod/legacy.dart';
import '../../core/models/selection.dart';

final selectionProvider = StateProvider<Selection>((ref) => const SelectionAll());

final currentArticleIdProvider = StateProvider<String?>((ref) => null);
