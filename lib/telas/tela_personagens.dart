import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/personagem.dart';
import 'tela_detalhe_personagem.dart';

class TelaPersonagens extends StatefulWidget {
  const TelaPersonagens({super.key});

  @override
  State<TelaPersonagens> createState() => _TelaPersonagensState();
}

class _TelaPersonagensState extends State<TelaPersonagens> {
  // chave = valor do filtro na URL ('' = sem filtro); valor = texto na tela
  static const filtros = {'': 'Todos', 'alive': 'Vivos', 'dead': 'Mortos'};

  late Future<List<Personagem>> _futuro;
  String filtro = '';
  int pagina = 1;
  int totalPaginas = 1;
  int? favoritoId;

  @override
  void initState() {
    super.initState();
    _futuro = buscarPersonagens(); // pede os dados UMA vez, ao abrir a tela
    _carregarFavorito();
  }

  Future<List<Personagem>> buscarPersonagens() async {
    final status = filtro.isEmpty ? '' : '&status=$filtro';
    final resposta = await http.get(Uri.parse(
      'https://rickandmortyapi.com/api/character?page=$pagina$status'));
    if (resposta.statusCode != 200) {
      throw Exception('Falha na consulta: ${resposta.statusCode}');
    }
    final dados = jsonDecode(resposta.body) as Map<String, dynamic>;
    totalPaginas = dados['info']['pages'];
    final lista = dados['results'] as List<dynamic>;
    return lista
        .map((item) => Personagem.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _carregarFavorito() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() { favoritoId = prefs.getInt(chaveFavorito); });
  }

  void _recarregar() {
    setState(() { _futuro = buscarPersonagens(); });
  }

  void _trocarFiltro(String novo) {
    filtro = novo;
    pagina = 1; // cada filtro tem sua própria quantidade de páginas
    _recarregar();
  }

  void _irParaPagina(int nova) {
    pagina = nova;
    _recarregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personagens')),
      body: FutureBuilder<List<Personagem>>(
        future: _futuro,
        builder: (context, snapshot) {
          final esperando =
              snapshot.connectionState == ConnectionState.waiting;
          return Column(children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Wrap(spacing: 8, children: [
                for (final item in filtros.entries)
                  ChoiceChip(
                    label: Text(item.value),
                    selected: filtro == item.key,
                    onSelected: esperando
                        ? null
                        : (_) => _trocarFiltro(item.key),
                  ),
              ]),
            ),
            Expanded(child: _conteudo(snapshot, esperando)),
          ]);
        },
      ),
    );
  }

  Widget _conteudo(AsyncSnapshot<List<Personagem>> snapshot, bool esperando) {
    if (esperando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Não foi possível carregar os personagens.'),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _recarregar,
            child: const Text('Tentar de novo')),
        ]),
      );
    }
    final personagens = snapshot.data!;
    return Column(children: [
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: personagens.length,
        itemBuilder: (context, i) {
          final p = personagens[i];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(p.imagem)),
              title: Text(p.nome),
              subtitle: Text('${p.especie} · ${p.status}'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                if (p.id == favoritoId)
                  const Icon(Icons.star, color: Colors.amber),
                const Icon(Icons.chevron_right),
              ]),
              onTap: () async {
                await Navigator.push(context,
                  MaterialPageRoute(builder: (_) =>
                    TelaDetalhePersonagem(personagem: p)));
                _carregarFavorito();
              },
            ),
          );
        },
      )),
      Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            ElevatedButton(
              onPressed: pagina > 1 ? () => _irParaPagina(pagina - 1) : null,
              child: const Text('Anterior')),
            Expanded(child: Text('Página $pagina de $totalPaginas',
              textAlign: TextAlign.center)),
            ElevatedButton(
              onPressed: pagina < totalPaginas
                  ? () => _irParaPagina(pagina + 1)
                  : null,
              child: const Text('Próxima')),
          ],
        ),
      ),
    ]);
  }
}
