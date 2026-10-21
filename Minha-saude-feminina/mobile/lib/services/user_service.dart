import '../models/perfil.dart';
import 'api_client.dart';

/// Perfil da usuária no back-end (tabela TB_USUARIA), ligado à conta Firebase.
class UserService {
  UserService._internal();
  static final UserService instance = UserService._internal();

  final ApiClient _api = ApiClient.instance;

  /// Busca o perfil; o back-end cria o registro no primeiro acesso.
  Future<Perfil> meuPerfil() async {
    return Perfil.fromJson(await _api.get('/usuarios/me') as Map<String, dynamic>);
  }

  /// Atualiza só os campos informados (os nulos ficam como estão).
  Future<Perfil> completarPerfil({
    String? nome,
    DateTime? dataNascimento,
    String? faseVida,
  }) async {
    final corpo = <String, dynamic>{
      'nome': ?nome,
      'dataNascimento': ?dataNascimento?.toIso8601String().substring(0, 10),
      'faseVida': ?faseVida,
    };
    return Perfil.fromJson(await _api.put('/usuarios/me', corpo) as Map<String, dynamic>);
  }
}
