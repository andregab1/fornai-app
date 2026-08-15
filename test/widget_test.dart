import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fornai_app/app/fornai_app.dart';
import 'package:fornai_app/features/collection/data/progress_repository.dart';
import 'package:fornai_app/features/collection/domain/collection_controller.dart';
import 'test_catalog.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogProvider.overrideWithValue(testCatalog()),
          progressRepositoryProvider.overrideWithValue(
            MemoryProgressRepository(),
          ),
        ],
        child: const FornaiApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('mostra progresso, busca e marca variante em celular compacto', (
    tester,
  ) async {
    await pumpApp(tester, const Size(390, 844));
    expect(find.text('0 de 3 variantes'), findsOneWidget);
    await tester.tap(find.text('Normal').first);
    await tester.pumpAndSettle();
    expect(find.text('1 de 3 variantes'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Futuro');
    await tester.pumpAndSettle();
    expect(find.text('Futuro'), findsNWidgets(2));
    expect(find.text('Água'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('grade renderiza sem overflow em tela grande', (tester) async {
    await pumpApp(tester, const Size(900, 1200));
    expect(find.text('Água'), findsOneWidget);
    expect(find.text('Futuro'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
