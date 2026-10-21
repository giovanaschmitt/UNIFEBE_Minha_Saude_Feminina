import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Erro devolvido pela API do back-end (ou falha de conexão, com status 0).
class ApiException implements Exception {
  final String mensagem;
  final int status;

  const ApiException(this.mensagem, this.status);

  @override
  String toString() => mensagem;
}

/// Cliente HTTP da API REST do Minha Saúde Feminina.
///
/// A URL base pode ser trocada sem mexer no código:
///   flutter run --dart-define=API_BASE_URL=http://192.168.0.10:8080/api
/// Sem isso, usa o localhost da máquina de desenvolvimento (no emulador
/// Android, o endereço 10.0.2.2 aponta para ela).
class ApiClient {
  ApiClient._internal();
  static final ApiClient instance = ApiClient._internal();

  static const String _baseConfigurada = String.fromEnvironment('API_BASE_URL');
  static const Duration _tempoLimite = Duration(seconds: 15);

  final http.Client _http = http.Client();

  String get baseUrl {
    if (_baseConfigurada.isNotEmpty) return _baseConfigurada;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api';
    }
    return 'http://localhost:8080/api';
  }

  Future<dynamic> get(String caminho, {Map<String, String>? parametros}) =>
      _enviar('GET', caminho, parametros: parametros);

  Future<dynamic> post(String caminho, Object corpo) => _enviar('POST', caminho, corpo: corpo);

  Future<dynamic> put(String caminho, Object corpo) => _enviar('PUT', caminho, corpo: corpo);

  Future<dynamic> delete(String caminho) => _enviar('DELETE', caminho);

  Future<dynamic> _enviar(
    String metodo,
    String caminho, {
    Map<String, String>? parametros,
    Object? corpo,
  }) async {
    final uri = Uri.parse('$baseUrl$caminho').replace(
      queryParameters: (parametros == null || parametros.isEmpty) ? null : parametros,
    );

    final cabecalhos = <String, String>{'Accept': 'application/json'};
    if (corpo != null) cabecalhos['Content-Type'] = 'application/json';
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token != null) cabecalhos['Authorization'] = 'Bearer $token';

    final requisicao = http.Request(metodo, uri)..headers.addAll(cabecalhos);
    if (corpo != null) requisicao.body = jsonEncode(corpo);

    http.Response resposta;
    try {
      resposta = await http.Response.fromStream(await _http.send(requisicao).timeout(_tempoLimite));
    } catch (_) {
      throw const ApiException('Sem conexão com o servidor. Verifique sua internet e tente novamente.', 0);
    }

    final texto = utf8.decode(resposta.bodyBytes);
    final dados = texto.isEmpty ? null : _lerJson(texto);

    if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
      final mensagem = dados is Map && dados['erro'] is String
          ? dados['erro'] as String
          : 'O servidor respondeu ${resposta.statusCode}.';
      throw ApiException(mensagem, resposta.statusCode);
    }
    return dados;
  }

  static dynamic _lerJson(String texto) {
    try {
      return jsonDecode(texto);
    } catch (_) {
      return {'erro': texto};
    }
  }
}
