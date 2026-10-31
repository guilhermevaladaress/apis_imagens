import 'package:flutter_test/flutter_test.dart';
import 'package:apis_imagens/main.dart';
import 'package:apis_imagens/modelos/personagem.dart';

void main() {
  testWidgets('Home mostra os três botões', (tester) async {
    await tester.pumpWidget(const MeuApp());

    expect(find.text('Galeria de cães'), findsOneWidget);
    expect(find.text('Pokédex'), findsOneWidget);
    expect(find.text('Personagens'), findsOneWidget);
  });

  test('Personagem.fromMap lê os campos do JSON', () {
    final p = Personagem.fromMap({
      'id': 1,
      'name': 'Rick Sanchez',
      'status': 'Alive',
      'species': 'Human',
      'gender': 'Male',
      'origin': {'name': 'Earth (C-137)'},
      'location': {'name': 'Citadel of Ricks'},
      'image': 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
    });

    expect(p.nome, 'Rick Sanchez');
    expect(p.genero, 'Male');
    expect(p.origem, 'Earth (C-137)');
    expect(p.localizacao, 'Citadel of Ricks');
  });
}
