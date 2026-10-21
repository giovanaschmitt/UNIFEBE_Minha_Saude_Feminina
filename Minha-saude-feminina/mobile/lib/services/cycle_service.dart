import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cycle_record.dart';
import 'api_client.dart';

/// Serviço responsável por todo o ciclo de vida dos registros de ciclo
/// menstrual: sincronização com a API (/api/ciclos), cópia local por
/// usuária (SharedPreferences, para abrir sem internet), cálculo de
/// estatísticas e previsão do próximo ciclo.
///
/// É um singleton simples com um [ValueNotifier] público, para que
/// qualquer tela possa "ouvir" mudanças nos registros sem precisar de
/// pacotes extras de gerenciamento de estado.
class CycleService {
  CycleService._internal();
  static final CycleService instance = CycleService._internal();

  /// Chave antiga, de quando os ciclos ficavam só no aparelho. Os registros
  /// encontrados nela são enviados para a conta no primeiro login.
  static const String _legacyStorageKey = 'msf_cycle_records_v1';

  /// Duração média padrão (usada apenas enquanto não há dados suficientes
  /// no histórico da usuária para calcular uma média real).
  static const int defaultCycleLength = 28;
  static const int defaultPeriodLength = 5;

  final ValueNotifier<List<CycleRecord>> recordsNotifier = ValueNotifier<List<CycleRecord>>([]);

  final ApiClient _api = ApiClient.instance;

  /// UID da usuária logada; os dados locais ficam separados por conta.
  String? _uid;

  List<CycleRecord> get records => recordsNotifier.value;

  String get _storageKey => 'msf_cycle_records_v2_$_uid';

  /// Chamado quando a usuária entra: mostra na hora a cópia local e, em
  /// seguida, busca a versão atual na API.
  Future<void> entrar(String uid) async {
    if (_uid == uid) return;
    _uid = uid;
    await _loadCache();
    try {
      await sincronizar();
    } catch (_) {
      // Sem conexão: segue com a cópia local até a próxima sincronização.
    }
  }

  /// Chamado ao sair da conta: limpa os dados da memória.
  void sair() {
    _uid = null;
    recordsNotifier.value = [];
  }

  /// Envia registros antigos que só existiam no aparelho e baixa todos os
  /// ciclos da conta.
  Future<void> sincronizar() async {
    if (_uid == null) return;
    await _enviarRegistrosAntigos();
    final dados = await _api.get('/ciclos') as List<dynamic>;
    final list = dados.map((item) => CycleRecord.fromApi(item as Map<String, dynamic>)).toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    recordsNotifier.value = list;
    await _persist();
  }

  Future<void> _enviarRegistrosAntigos() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_legacyStorageKey);
    if (raw == null || raw.isEmpty) return;
    final antigos = (jsonDecode(raw) as List<dynamic>)
        .map((item) => CycleRecord.fromJson(item as Map<String, dynamic>));
    for (final registro in antigos) {
      try {
        await _api.post('/ciclos', registro.toApi());
      } on ApiException catch (e) {
        // 409: já existe um ciclo com essa data de início na conta.
        if (e.status != 409) rethrow;
      }
    }
    await prefs.remove(_legacyStorageKey);
  }

  Future<void> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) {
        recordsNotifier.value = [];
        return;
      }
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      final list = decoded
          .map((item) => CycleRecord.fromJson(item as Map<String, dynamic>))
          .toList();
      list.sort((a, b) => b.startDate.compareTo(a.startDate));
      recordsNotifier.value = list;
    } catch (_) {
      // Se os dados salvos estiverem corrompidos, evita quebrar o app.
      recordsNotifier.value = [];
    }
  }

  Future<void> _persist() async {
    if (_uid == null) return;
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(records.map((r) => r.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  /// Registra o início (e, opcionalmente, o término) de um ciclo.
  /// Lança [ApiException] se a API recusar ou estiver inacessível.
  Future<CycleRecord> addRecord({
    required DateTime startDate,
    DateTime? endDate,
    String? notes,
  }) async {
    final novo = CycleRecord(
      id: '',
      startDate: _dateOnly(startDate),
      endDate: endDate != null ? _dateOnly(endDate) : null,
      notes: notes,
    );
    final dados = await _api.post('/ciclos', novo.toApi()) as Map<String, dynamic>;
    final record = CycleRecord.fromApi(dados);
    final updated = [...records, record]
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    recordsNotifier.value = updated;
    await _persist();
    return record;
  }

  Future<void> updateRecord(CycleRecord record) async {
    final dados = await _api.put('/ciclos/${record.id}', record.toApi()) as Map<String, dynamic>;
    final salvo = CycleRecord.fromApi(dados);
    final updated = records.map((r) => r.id == salvo.id ? salvo : r).toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    recordsNotifier.value = updated;
    await _persist();
  }

  Future<void> deleteRecord(String id) async {
    await _api.delete('/ciclos/$id');
    final updated = records.where((r) => r.id != id).toList();
    recordsNotifier.value = updated;
    await _persist();
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Registros ordenados do mais recente para o mais antigo.
  List<CycleRecord> get sortedRecords {
    final list = [...records];
    list.sort((a, b) => b.startDate.compareTo(a.startDate));
    return list;
  }

  /// Registros ordenados do mais antigo para o mais recente (útil para
  /// cálculos de diferença entre ciclos consecutivos).
  List<CycleRecord> get _chronological {
    final list = [...records];
    list.sort((a, b) => a.startDate.compareTo(b.startDate));
    return list;
  }

  /// Ciclo em aberto (sem data de término), se houver.
  CycleRecord? get currentOpenCycle {
    for (final r in records) {
      if (r.isOngoing) return r;
    }
    return null;
  }

  /// Duração média do ciclo (do início de um período ao início do
  /// próximo), calculada com base no histórico. Retorna `null` se não
  /// houver histórico suficiente (menos de 2 registros).
  int? get averageCycleLength {
    final chrono = _chronological;
    if (chrono.length < 2) return null;
    final diffs = <int>[];
    for (var i = 1; i < chrono.length; i++) {
      final diff = chrono[i].startDate.difference(chrono[i - 1].startDate).inDays;
      if (diff > 0) diffs.add(diff);
    }
    if (diffs.isEmpty) return null;
    final avg = diffs.reduce((a, b) => a + b) / diffs.length;
    return avg.round();
  }

  /// Duração média do período menstrual (dias entre início e término),
  /// considerando apenas ciclos já concluídos.
  int? get averagePeriodLength {
    final finished = records.where((r) => !r.isOngoing).toList();
    if (finished.isEmpty) return null;
    final total = finished.fold<int>(0, (sum, r) => sum + r.durationInDays);
    return (total / finished.length).round();
  }

  int get effectiveCycleLength => averageCycleLength ?? defaultCycleLength;
  int get effectivePeriodLength => averagePeriodLength ?? defaultPeriodLength;

  /// Último registro (mais recente) por data de início.
  CycleRecord? get lastRecord => sortedRecords.isEmpty ? null : sortedRecords.first;

  /// Previsão de início do próximo ciclo, baseada na última menstruação
  /// registrada somada à duração média do ciclo.
  DateTime? get predictedNextStart {
    final last = lastRecord;
    if (last == null) return null;
    return _dateOnly(last.startDate.add(Duration(days: effectiveCycleLength)));
  }

  /// Previsão de término do próximo período.
  DateTime? get predictedNextEnd {
    final start = predictedNextStart;
    if (start == null) return null;
    return start.add(Duration(days: effectivePeriodLength - 1));
  }

  /// Quantos dias faltam até a próxima menstruação prevista. Pode ser
  /// negativo se a previsão já passou (ciclo atrasado). Retorna `null`
  /// quando ainda não há nenhum registro.
  int? get daysUntilNextCycle {
    final predicted = predictedNextStart;
    if (predicted == null) return null;
    final today = _dateOnly(DateTime.now());
    return predicted.difference(today).inDays;
  }

  /// Em que dia do ciclo atual a usuária está (dia 1 = início da última
  /// menstruação registrada). Retorna `null` sem histórico.
  int? get currentCycleDay {
    final last = lastRecord;
    if (last == null) return null;
    final today = _dateOnly(DateTime.now());
    return today.difference(last.startDate).inDays + 1;
  }

  /// Conjunto de todos os dias (normalizados, sem hora) que fazem parte
  /// de algum período efetivamente registrado — usado para pintar o
  /// calendário.
  Set<DateTime> get allPeriodDays {
    final days = <DateTime>{};
    for (final r in records) {
      final end = _dateOnly(r.endDate ?? DateTime.now());
      var cursor = _dateOnly(r.startDate);
      while (!cursor.isAfter(end)) {
        days.add(cursor);
        cursor = cursor.add(const Duration(days: 1));
      }
    }
    return days;
  }

  /// Dias (normalizados) que pertencem especificamente ao ciclo em
  /// aberto (sem data de término), do início até hoje — útil para
  /// destacar visualmente que aquele período ainda está em curso.
  Set<DateTime> get ongoingPeriodDays {
    final open = currentOpenCycle;
    if (open == null) return {};
    final days = <DateTime>{};
    final today = _dateOnly(DateTime.now());
    var cursor = _dateOnly(open.startDate);
    while (!cursor.isAfter(today)) {
      days.add(cursor);
      cursor = cursor.add(const Duration(days: 1));
    }
    return days;
  }

  /// Dias previstos para o próximo período (previsão, não registro).
  Set<DateTime> get predictedPeriodDays {
    final start = predictedNextStart;
    final end = predictedNextEnd;
    if (start == null || end == null) return {};
    final days = <DateTime>{};
    var cursor = start;
    while (!cursor.isAfter(end)) {
      days.add(cursor);
      cursor = cursor.add(const Duration(days: 1));
    }
    return days;
  }
}
