import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TelaCaes extends StatefulWidget {
  const TelaCaes({super.key});

  @override
  State<TelaCaes> createState() => _TelaCaesState();
}

class _TelaCaesState extends State<TelaCaes> {
  // chave = nome usado na URL da API; valor = texto mostrado no ChoiceChip
  static const racas = {
    'husky': 'Husky',
    'pug': 'Pug',
    'beagle': 'Beagle',
    'labrador': 'Labrador',
  };

  String raca = 'husky';
  String? imagem;
  String? erro;
  bool carregando = false;
  int sorteadas = 0;

  Future<void> buscarCao() async {
    setState(() { carregando = true; erro = null; });
    try {
      final resposta = await http.get(
        Uri.parse('https://dog.ceo/api/breed/$raca/images/random'));
      if (resposta.statusCode != 200) throw Exception('Falha na consulta');
      final dados = jsonDecode(resposta.body);
      if (!mounted) return;
      setState(() {
        imagem = dados['message'];
        sorteadas++;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { erro = 'Não foi possível carregar a foto.'; });
    } finally {
      if (mounted) setState(() { carregando = false; });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.amber.shade50,
    appBar: AppBar(title: const Text('Meus cães favoritos')),
    body: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Escolha uma raça e conheça um novo amigo!'),
        const SizedBox(height: 12),
        Wrap(spacing: 8, alignment: WrapAlignment.center, children: [
          for (final item in racas.entries)
            ChoiceChip(
              label: Text(item.value),
              selected: raca == item.key,
              onSelected: (_) => setState(() { raca = item.key; }),
            ),
        ]),
        const SizedBox(height: 16),
        if (carregando) const CircularProgressIndicator(),
        if (erro != null) Text(erro!),
        if (imagem != null) ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(imagem!, height: 260, fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const Text('Imagem indisponível'))),
        const SizedBox(height: 16),
        Text('Fotos sorteadas: $sorteadas'),
        const SizedBox(height: 8),
        ElevatedButton(onPressed: carregando ? null : buscarCao,
          child: const Text('Quero ver um cachorro')),
      ]),
    )),
  );
}
