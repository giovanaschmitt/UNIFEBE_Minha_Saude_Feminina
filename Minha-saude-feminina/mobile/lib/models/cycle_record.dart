/// Representa o registro de um ciclo menstrual: uma data de início
/// obrigatória e, opcionalmente, uma data de término (quando o ciclo
/// já foi concluído pela usuária).
class CycleRecord {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;

  CycleRecord({
    required this.id,
    required this.startDate,
    this.endDate,
    this.notes,
  });

  /// Ciclo em aberto = ainda não foi informada a data de término.
  bool get isOngoing => endDate == null;

  /// Duração do período em dias (inclusive). Enquanto o ciclo estiver
  /// em aberto, calcula a duração parcial até hoje.
  int get durationInDays {
    final end = endDate ?? DateTime.now();
    final normalizedStart = DateTime(startDate.year, startDate.month, startDate.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);
    return normalizedEnd.difference(normalizedStart).inDays + 1;
  }

  CycleRecord copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    bool clearEndDate = false,
    String? notes,
  }) {
    return CycleRecord(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'notes': notes,
      };

  /// Corpo enviado para POST/PUT /api/ciclos.
  Map<String, dynamic> toApi() => {
        'data_inicio': _apiDate(startDate),
        'data_fim': endDate == null ? null : _apiDate(endDate!),
        'observacao': notes,
      };

  /// Ciclo como vem da API (/api/ciclos).
  factory CycleRecord.fromApi(Map<String, dynamic> json) {
    return CycleRecord(
      id: json['id'].toString(),
      startDate: DateTime.parse(json['data_inicio'] as String),
      endDate: json['data_fim'] != null ? DateTime.parse(json['data_fim'] as String) : null,
      notes: json['observacao'] as String?,
    );
  }

  static String _apiDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  factory CycleRecord.fromJson(Map<String, dynamic> json) {
    return CycleRecord(
      id: json['id'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      notes: json['notes'] as String?,
    );
  }
}
