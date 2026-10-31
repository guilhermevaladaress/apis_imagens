class Personagem {
  final int id;
  final String nome;
  final String status;
  final String especie;
  final String genero;
  final String origem;
  final String localizacao;
  final String imagem;

  Personagem({
    required this.id,
    required this.nome,
    required this.status,
    required this.especie,
    required this.genero,
    required this.origem,
    required this.localizacao,
    required this.imagem,
  });

  // Converte um item do JSON (Map) em objeto Personagem
  factory Personagem.fromMap(Map<String, dynamic> m) => Personagem(
    id: m['id'],
    nome: m['name'],
    status: m['status'],
    especie: m['species'],
    genero: m['gender'],
    origem: m['origin']['name'],
    localizacao: m['location']['name'],
    imagem: m['image'],
  );
}
