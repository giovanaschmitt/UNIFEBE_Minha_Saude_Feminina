import 'package:flutter/material.dart';

import '../models/cycle_record.dart';
import '../services/cycle_service.dart';
import '../utils/date_format_utils.dart';
import '../widgets/cycle_form_sheet.dart';

/// Consulta dos registros de ciclo já realizados: lista completa,
/// ordenada da mais recente para a mais antiga, com estatísticas
/// rápidas e acesso à edição/exclusão de cada registro.
class CycleHistoryScreen extends StatelessWidget {
  const CycleHistoryScreen({super.key});

  static const Color corPrimaria = Color(0xFFC43A4A);
  static const Color corRoxo = Color(0xFF5B2A86);
  static const Color corFundo = Color(0xFFF6F1EE);

  @override
  Widget build(BuildContext context) {
    final service = CycleService.instance;

    return Scaffold(
      backgroundColor: corFundo,
      appBar: AppBar(
        backgroundColor: corFundo,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Histórico de ciclos', style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600)),
      ),
      body: ValueListenableBuilder<List<CycleRecord>>(
        valueListenable: service.recordsNotifier,
        builder: (context, records, _) {
          final sorted = service.sortedRecords;

          if (sorted.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
            itemCount: sorted.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildSummaryRow(service),
                );
              }
              final record = sorted[index - 1];
              final previous = index < sorted.length ? sorted[index] : null;
              final cycleLength = previous != null
                  ? record.startDate.difference(previous.startDate).inDays
                  : null;
              return _buildRecordCard(context, record, cycleLength);
            },
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(CycleService service) {
    return Row(
      children: [
        Expanded(child: _summaryCard('Total de registros', '${service.records.length}', Icons.event_note_outlined, corPrimaria)),
        const SizedBox(width: 10),
        Expanded(child: _summaryCard('Ciclo médio', service.averageCycleLength != null ? '${service.averageCycleLength} dias' : '—', Icons.autorenew, corRoxo)),
      ],
    );
  }

  Widget _summaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, CycleRecord record, int? cycleLength) {
    final rangeLabel = record.isOngoing
        ? '${DateFormatUtils.short(record.startDate)} — em andamento'
        : '${DateFormatUtils.short(record.startDate)} — ${DateFormatUtils.short(record.endDate!)}';

    return GestureDetector(
      onTap: () => showCycleFormSheet(context, existing: record),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: (record.isOngoing ? corRoxo : corPrimaria).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                record.isOngoing ? Icons.hourglass_top_rounded : Icons.water_drop_outlined,
                color: record.isOngoing ? corRoxo : corPrimaria,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rangeLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [
                      Text('${record.durationInDays} dias de duração', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      if (cycleLength != null)
                        Text('· ciclo de $cycleLength dias', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                  if (record.notes != null && record.notes!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      record.notes!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(color: corPrimaria.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.calendar_month_outlined, color: corPrimaria, size: 38),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nenhum registro ainda',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Registre o início do seu ciclo para começar a acompanhar seu histórico e receber previsões.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: () => showCycleFormSheet(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: corPrimaria,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Registrar ciclo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
