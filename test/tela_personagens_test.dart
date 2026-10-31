import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apis_imagens/telas/tela_personagens.dart';

final _corpo = jsonEncode({
  'info': {'pages': 2},
  'results': [
    {
      'id': 1,
      'name': 'Rick Sanchez',
      'status': 'Alive',
      'species': 'Human',
      'gender': 'Male',
      'origin': {'name': 'Earth (C-137)'},
      'location': {'name': 'Citadel of Ricks'},
      'image': 'https://exemplo.com/1.jpeg',
    },
  ],
});

// Abre a tela usando uma API falsa e avança os segundos pedidos
Future<void> abrir(WidgetTester tester, MockClient api, int segundos) =>
    http.runWithClient(() async {
      await tester.pumpWidget(const MaterialApp(home: TelaPersonagens()));
      for (var i = 0; i < segundos * 2; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }
      tester.takeException(); // imagem do avatar não existe na API falsa
    }, () => api);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('429 passageiro: repete e mostra a lista', (tester) async {
    var pedidos = 0;
    final api = MockClient((_) async {
      pedidos++;
      return pedidos <= 2 ? http.Response('', 429) : http.Response(_corpo, 200);
    });

    await abrir(tester, api, 4);

    expect(pedidos, 3);
    expect(find.text('Rick Sanchez'), findsOneWidget);
    expect(find.text('Tentar de novo'), findsNothing);
  });

  testWidgets('429 respeita o Retry-After da API', (tester) async {
    var pedidos = 0;
    final api = MockClient((_) async {
      pedidos++;
      return pedidos == 1
          ? http.Response('', 429, headers: {'retry-after': '5'})
          : http.Response(_corpo, 200);
    });

    await abrir(tester, api, 3);
    expect(pedidos, 1);

    await http.runWithClient(() async {
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      tester.takeException();
    }, () => api);
    expect(pedidos, 2);
    expect(find.text('Rick Sanchez'), findsOneWidget);
  });

  testWidgets('429 persistente: desiste e oferece Tentar de novo',
      (tester) async {
    var pedidos = 0;
    final api = MockClient((_) async {
      pedidos++;
      return http.Response('', 429);
    });

    await abrir(tester, api, 8);

    expect(pedidos, 4);
    expect(find.text('Tentar de novo'), findsOneWidget);
  });

  testWidgets('página já vista não é pedida de novo', (tester) async {
    var pedidos = 0;
    final api = MockClient((_) async {
      pedidos++;
      return http.Response(_corpo, 200);
    });

    await abrir(tester, api, 1);
    expect(pedidos, 1);

    await http.runWithClient(() async {
      for (final botao in ['Próxima', 'Anterior', 'Próxima']) {
        await tester.tap(find.text(botao));
        await tester.pump();
        await tester.pump();
        tester.takeException();
      }
    }, () => api);

    expect(pedidos, 2); // páginas 1 e 2, uma vez cada
  });
}
