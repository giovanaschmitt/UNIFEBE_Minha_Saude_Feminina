import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cycle_record.dart';

/// Serviço responsável por todo o ciclo de vida dos registros de ciclo
/// menstrual: persistência local (SharedPreferences), cálculo de
/// estatísticas e previsão do próximo ciclo.
///
/// É um singleton simples com um [ValueNotifier] público, para que
/// qualquer tela possa "ouvir" mudanças nos registros sem precisar de
/// pacotes extras de gerenciamento de estado.
class CycleService {
  CycleService._internal();
  static final CycleService instance = CycleService._internal();

  static const String _storageKey = 'msf_cycle_records_v1';

  /// Duração média padrão (usada apenas enquanto não há dados suficientes
  /// no histórico da usuária para calcular uma média real).
  static const int defaultCycleLength = 28;
  static const int defaultPeriodLength = 5;

  final ValueNotifier<List<CycleRecord>> recordsNotifier = ValueNotifier<List<CycleRecord>>([]);

  bool _initialized = false;

  List<CycleRecord> get records => recordsNotifier.value;

  /// Carrega os registros salvos localmente. Deve ser chamado uma vez,
  /// idealmente antes do primeiro `runApp`.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await _load();
  }

  Future<void> _load() async {
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
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(records.map((r) => r.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  String _generateId() =>
      '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(99999)}';

  /// Registra o início (e, opcionalmente, o término) de um ciclo.
  Future<CycleRecord> addRecord({
    required DateTime startDate,
    DateTime? endDate,
    String? notes,
  }) async {
    final record = CycleRecord(
      id: _generateId(),
      startDate: _dateOnly(startDate),
      endDate: endDate != null ? _dateOnly(endDate) : null,
      notes: notes,
    );
    final updated = [...records, record]
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    recordsNotifier.value = updated;
    await _persist();
    return record;
  }

  Future<void> updateRecord(CycleRecord record) async {
    final updated = records.map((r) => r.id == record.id ? record : r).toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    recordsNotifier.value = updated;
    await _persist();
  }

  Future<void> deleteRecord(String id) async {
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
