import 'package:app_aula14/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('exibe a tela de geolocalização ao iniciar', (tester) async {
    await tester.pumpWidget(const MeuApp());
    await tester.pumpAndSettle();

    expect(find.text('Check-in & GPS'), findsOneWidget);
    expect(find.text('Capturar Localização Atual'), findsOneWidget);
    expect(find.text('Iniciar Rastreamento Contínuo'), findsOneWidget);
  });
}
