import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TelaPokemon extends StatefulWidget {
  const TelaPokemon({super.key});

  @override
  State<TelaPokemon> createState() => _TelaPokemonState();
}

class _TelaPokemonState extends State<TelaPokemon> {
  final controle = TextEditingController(text: 'pikachu');
  Map<String, dynamic>? pokemon;
  String? erro;
  bool carregando = false;

  Future<void> buscarPokemon() async {
    final busca = controle.text.trim().toLowerCase();
    if (busca.isEmpty) {
      setState(() { erro = 'Digite um nome ou número.'; });
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() { carregando = true; erro = null; pokemon = null; });
    try {
      final resposta = await http.get(Uri.parse(
        'https://pokeapi.co/api/v2/pokemon/${Uri.encodeComponent(busca)}'));
      if (resposta.statusCode != 200) throw Exception('Não encontrado');
      final dados = jsonDecode(resposta.body) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() { pokemon = dados; });
    } catch (e) {
      if (!mounted) return;
      setState(() { erro = 'Pokémon não encontrado ou sem conexão.'; });
    } finally {
      if (mounted) setState(() { carregando = false; });
    }
  }

  void buscarAleatorio() {
    controle.text = '${Random().nextInt(151) + 1}';
    buscarPokemon();
  }

  @override
  void dispose() { controle.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final sprite = pokemon?['sprites']?['front_default'];
    final tipos = pokemon?['types'] as List<dynamic>? ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('Pokédex')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: controle,
            decoration: const InputDecoration(
              labelText: 'Nome ou número do Pokémon')),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: [
            ElevatedButton(onPressed: carregando ? null : buscarPokemon,
              child: const Text('Buscar')),
            ElevatedButton(onPressed: carregando ? null : buscarAleatorio,
              child: const Text('Aleatório')),
          ]),
          if (carregando) const CircularProgressIndicator(),
          if (erro != null) Text(erro!),
          if (pokemon != null) ...[
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Text('#${pokemon!['id']}'),
                  Text('${pokemon!['name']}',
                    style: const TextStyle(fontSize: 25)),
                  if (sprite != null) Image.network(sprite,
                    width: 180, height: 180, fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Text('Sem imagem')),
                  Wrap(spacing: 8, children: [
                    for (final t in tipos)
                      Chip(label: Text('${t['type']['name']}')),
                  ]),
                  const SizedBox(height: 8),
                  Text('Altura: ${pokemon!['height']} décimos de metro'),
                  Text('Peso: ${pokemon!['weight']} décimos de kg'),
                ]),
              ),
            )),
          ],
        ]),
      ),
    );
  }
}
