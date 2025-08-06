import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:meu_app_financas/main.dart'; // Importa o app principal

void main() {
  testWidgets('Teste básico de renderização da tela de login', (WidgetTester tester) async {
    // Inicializa o app real
    await tester.pumpWidget(const MeuAppFinancas());

    // Verifica se o texto "Login" (ou algo similar) aparece na tela
    expect(find.text('Login'), findsOneWidget);

    // Aqui você pode expandir esse teste para interagir com campos de login,
    // botão, etc., se desejar no futuro.
  });
}
