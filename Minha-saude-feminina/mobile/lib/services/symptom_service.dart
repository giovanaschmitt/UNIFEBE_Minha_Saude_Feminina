import 'api_client.dart';

/// Sintoma registrado pela usuária, como vem de /api/sintomas.
class RegistroSintoma {
  final int id;
  final String sintoma;
  final String intensidade;
  final String? observacao;
  final DateTime dataRegistro;

  const RegistroSintoma({
    required this.id,
    required this.sintoma,
    required this.intensidade,
    required this.observacao,
    required this.dataRegistro,
  });

  factory RegistroSintoma.fromJson(Map<String, dynamic> json) => RegistroSintoma(
        id: (json['id'] as num).toInt(),
        sintoma: json['sintoma'] as String,
        intensidade: json['intensidade'] as String,
        observacao: json['observacao'] as String?,
        dataRegistro: DateTime.parse(json['data_registro'] as String),
      );
}

/// Registro de sintomas no back-end, vinculado à conta autenticada.
class SymptomService {
  SymptomService._internal();
  static final SymptomService instance = SymptomService._internal();

  final ApiClient _api = ApiClient.instance;

  Future<List<RegistroSintoma>> listar() async {
    final dados = await _api.get('/sintomas') as List<dynamic>;
    return dados.map((item) => RegistroSintoma.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// [intensidade] deve ser "Leve", "Moderada" ou "Forte". Registrar o mesmo
  /// sintoma de novo no mesmo dia atualiza o registro do dia.
  Future<RegistroSintoma> registrar({
    required String sintoma,
    required String intensidade,
    String? observacao,
  }) async {
    final hoje = DateTime.now().toIso8601String().substring(0, 10);
    final dados = await _api.post('/sintomas', {
      'sintoma': sintoma,
      'intensidade': intensidade,
      'observacao': ?observacao,
      'data_registro': hoje,
    }) as Map<String, dynamic>;
    return RegistroSintoma.fromJson(dados);
  }

  Future<void> excluir(int id) => _api.delete('/sintomas/$id');
}
