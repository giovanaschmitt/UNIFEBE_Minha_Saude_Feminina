import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/symptom_service.dart';
import '../utils/date_format_utils.dart';

/// Lista os sintomas registrados (GET /api/sintomas), agrupados por dia,
/// com opção de excluir cada registro.
class SymptomHistoryScreen extends StatefulWidget {
  const SymptomHistoryScreen({super.key});

  @override
  State<SymptomHistoryScreen> createState() => _SymptomHistoryScreenState();
}

class _SymptomHistoryScreenState extends State<SymptomHistoryScreen> {
  static const Color corPrimaria = Color(0xFFC43A4A);
  static const Color corFundo = Color(0xFFF6F1EE);

  static const Map<String, Color> _corIntensidade = {
    'Leve': Color(0xFFDDA6B0),
    'Moderada': Color(0xFFC43A4A),
    'Forte': Color(0xFF7A1F2B),
  };

  List<RegistroSintoma> _registros = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final registros = await SymptomService.instance.listar();
      if (!mounted) return;
      setState(() {
        _registros = registros;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _carregando = false;
        _erro = e is ApiException ? e.mensagem : 'Não foi possível carregar o histórico.';
      });
    }
  }

  Future<void> _excluir(RegistroSintoma registro) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir registro'),
        content: Text('Excluir "${registro.sintoma}" de ${DateFormatUtils.long(registro.dataRegistro)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: corPrimaria)),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    try {
      await SymptomService.instance.excluir(registro.id);
      if (!mounted) return;
      setState(() => _registros.removeWhere((r) => r.id == registro.id));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e is ApiException ? e.mensagem : 'Não foi possível excluir o registro.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      appBar: AppBar(
        backgroundColor: corFundo,
        elevation: 0,
        title: const Text('Histórico de sintomas', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(child: _conteudo()),
    );
  }

  Widget _conteudo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator(color: corPrimaria));
    }
    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_erro!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700)),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _carregar,
                child: const Text('Tentar novamente',
                    style: TextStyle(color: corPrimaria, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    // Agrupa por dia, mantendo a ordem da API (mais recentes primeiro).
    final grupos = <DateTime, List<RegistroSintoma>>{};
    for (final registro in _registros) {
      grupos.putIfAbsent(registro.dataRegistro, () => []).add(registro);
    }

    return RefreshIndicator(
      color: corPrimaria,
      onRefresh: _carregar,
      child: _registros.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(32),
              children: [
                const SizedBox(height: 60),
                Icon(Icons.healing_outlined, size: 48, color: corPrimaria.withValues(alpha: 0.5)),
                const SizedBox(height: 14),
                const Text(
                  'Nenhum sintoma registrado ainda',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Use o botão + para registrar como você está se sentindo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                ),
              ],
            )
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
              children: [
                for (final grupo in grupos.entries) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 14, bottom: 8),
                    child: Text(
                      DateFormatUtils.long(grupo.key),
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                    ),
                  ),
                  for (final registro in grupo.value) _cartao(registro),
                ],
              ],
            ),
    );
  }

  Widget _cartao(RegistroSintoma registro) {
    final cor = _corIntensidade[registro.intensidade] ?? corPrimaria;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 12, 6, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(registro.sintoma, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('Intensidade ${registro.intensidade.toLowerCase()}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                if ((registro.observacao ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(registro.observacao!, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Excluir',
            icon: Icon(Icons.delete_outline_rounded, color: Colors.grey.shade500),
            onPressed: () => _excluir(registro),
          ),
        ],
      ),
    );
  }
}
