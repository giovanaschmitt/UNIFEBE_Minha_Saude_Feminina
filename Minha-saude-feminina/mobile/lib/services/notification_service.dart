import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

/// Notificações push (Firebase Cloud Messaging).
///
/// Registra o token deste aparelho na API (/api/notificacoes/dispositivo);
/// o back-end envia os lembretes do ciclo. Com o app aberto, a notificação
/// aparece como um aviso na parte de baixo da tela ([mensageiro]).
class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  static const String _prefLembreteCiclo = 'msf_lembrete_ciclo';

  /// Usado para mostrar as notificações recebidas com o app aberto.
  final GlobalKey<ScaffoldMessengerState> mensageiro = GlobalKey<ScaffoldMessengerState>();

  /// Preferência "Lembretes do ciclo", exibida no Perfil.
  final ValueNotifier<bool> lembreteCiclo = ValueNotifier<bool>(true);

  final ApiClient _api = ApiClient.instance;
  String? _token;
  StreamSubscription<String>? _renovacao;
  StreamSubscription<RemoteMessage>? _primeiroPlano;

  bool get _suportado =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  /// Chamado quando a usuária entra: pede permissão e registra o aparelho.
  Future<void> entrar() async {
    if (!_suportado) return;
    final prefs = await SharedPreferences.getInstance();
    lembreteCiclo.value = prefs.getBool(_prefLembreteCiclo) ?? true;

    try {
      final messaging = FirebaseMessaging.instance;
      final permissao = await messaging.requestPermission();
      if (permissao.authorizationStatus == AuthorizationStatus.denied) return;

      _token = await messaging.getToken();
      await _registrar();

      _renovacao ??= messaging.onTokenRefresh.listen((novo) {
        _token = novo;
        _registrar();
      });
      _primeiroPlano ??= FirebaseMessaging.onMessage.listen(_mostrarEmPrimeiroPlano);
    } catch (e) {
      debugPrint('Notificações indisponíveis: $e');
    }
  }

  /// Chamado antes de sair da conta: o aparelho deixa de receber os avisos dela.
  Future<void> sair() async {
    final token = _token;
    _token = null;
    if (token == null) return;
    try {
      await _api.delete('/notificacoes/dispositivo?token=${Uri.encodeQueryComponent(token)}');
    } catch (_) {
      // Sem conexão: o token fica órfão e o back-end descarta quando o FCM recusar.
    }
  }

  /// Liga ou desliga os lembretes do ciclo neste aparelho.
  Future<void> definirLembreteCiclo(bool ativo) async {
    final anterior = lembreteCiclo.value;
    lembreteCiclo.value = ativo;
    try {
      await _registrar(obrigatorio: true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefLembreteCiclo, ativo);
    } catch (_) {
      lembreteCiclo.value = anterior;
      rethrow;
    }
  }

  /// Pede ao back-end uma notificação de teste para este aparelho.
  Future<void> enviarTeste() async {
    if (_token == null) {
      throw const ApiException('Ative as notificações do app nas configurações do celular.', 0);
    }
    await _api.post('/notificacoes/teste', const {});
  }

  Future<void> _registrar({bool obrigatorio = false}) async {
    final token = _token;
    if (token == null) {
      if (obrigatorio) {
        throw const ApiException('Ative as notificações do app nas configurações do celular.', 0);
      }
      return;
    }
    try {
      await _api.put('/notificacoes/dispositivo', {
        'token': token,
        'plataforma': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
        'lembrete_ciclo': lembreteCiclo.value,
      });
    } catch (e) {
      if (obrigatorio) rethrow;
      debugPrint('Falha ao registrar aparelho para notificações: $e');
    }
  }

  void _mostrarEmPrimeiroPlano(RemoteMessage mensagem) {
    final notificacao = mensagem.notification;
    if (notificacao == null) return;
    mensageiro.currentState?.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notificacao.title ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
            if (notificacao.body != null) Text(notificacao.body!),
          ],
        ),
      ),
    );
  }
}
