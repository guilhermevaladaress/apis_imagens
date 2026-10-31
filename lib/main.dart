import 'package:flutter/material.dart';
import 'telas/tela_caes.dart';
import 'telas/tela_pokemon.dart';
import 'telas/tela_personagens.dart';

void main() => runApp(const MeuApp());

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'APIs Divertidas',
    home: Scaffold(
      appBar: AppBar(title: const Text('APIs Divertidas')),
      body: Builder(builder: (context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, spacing: 12, children: [
          ElevatedButton(
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const TelaCaes())),
            child: const Text('Galeria de cães')),
          ElevatedButton(
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const TelaPokemon())),
            child: const Text('Pokédex')),
          ElevatedButton(
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const TelaPersonagens())),
            child: const Text('Personagens')),
        ]),
      )),
    ),
  );
}
