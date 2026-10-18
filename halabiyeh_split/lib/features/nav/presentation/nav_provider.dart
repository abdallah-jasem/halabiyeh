import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which bottom-nav tab is showing. Pure UI state, separate from outing data.
class NavNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void goTo(int i) => state = i;
}

final navProvider = NotifierProvider<NavNotifier, int>(NavNotifier.new);
