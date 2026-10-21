import '../models/artigo.dart';
import 'api_client.dart';

/// Leitura dos conteúdos educativos publicados pelo painel administrativo.
class ContentService {
  ContentService._internal();
  static final ContentService instance = ContentService._internal();

  final ApiClient _api = ApiClient.instance;

  Future<List<Categoria>> listarCategorias() async {
    final dados = await _api.get('/categorias') as List<dynamic>;
    return dados.map((item) => Categoria.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<Artigo>> listarArtigos() async {
    final dados = await _api.get('/artigos') as Map<String, dynamic>;
    final artigos = dados['artigos'] as List<dynamic>? ?? const [];
    return artigos.map((item) => Artigo.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Artigo> buscarArtigo(int id) async {
    final dados = await _api.get('/artigos/$id') as Map<String, dynamic>;
    return Artigo.fromJson(dados);
  }
}
