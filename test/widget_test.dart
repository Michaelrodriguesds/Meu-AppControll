import 'package:flutter_test/flutter_test.dart';
import 'package:meu_app_financas/main.dart';

void main() {
  testWidgets('Renderização inicial do app', (WidgetTester tester) async {
    // ✅ FinanceApp é o nome real da classe em main.dart
    await tester.pumpWidget(const FinanceApp());
    expect(find.byType(FinanceApp), findsOneWidget);
  });
}