import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halabiyeh_split/core/providers.dart';
import 'package:halabiyeh_split/features/bill/domain/entities/outing.dart';
import 'package:halabiyeh_split/features/bill/presentation/screens/split_screen.dart';
import 'package:halabiyeh_split/features/groups/domain/group_repository.dart';
import 'package:halabiyeh_split/features/history/domain/outing_repository.dart';
import 'package:halabiyeh_split/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeOutings implements OutingRepository {
  final saved = <Outing>[];
  @override
  Future<List<Outing>> getHistory() async => saved;
  @override
  Future<void> save(Outing o) async => saved.add(o);
  @override
  Future<void> delete(String id) async {}
}

class FakeGroup implements GroupRepository {
  @override
  List<String> load() => ['Abood'];
  @override
  Future<void> save(List<String> names) async {}
}

void main() {
  testWidgets('add friend, item, payment -> results and settlement', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(800, 6000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          outingRepositoryProvider.overrideWithValue(FakeOutings()),
          groupRepositoryProvider.overrideWithValue(FakeGroup()),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: SplitScreen(),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(ActionChip, 'Add'));
    await tester.pumpAndSettle();
    await tester.enterText(find.descendant(of: find.byType(AlertDialog), matching: find.byType(TextField)), 'Ziad');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Add item'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Item name'), 'Food');
    await tester.enterText(find.widgetWithText(TextField, 'Price'), '60');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    // First "Who paid?" field is Abood's: "40 + 20" = 60.
    await tester.enterText(find.byType(TextField).at(0 + 3), '40 + 20');
    await tester.pumpAndSettle();

    expect(find.text('= 60'), findsOneWidget);
    expect(find.text('\u2068Ziad\u2069 gives \u2068Abood\u2069 30'), findsOneWidget);
  });
}
