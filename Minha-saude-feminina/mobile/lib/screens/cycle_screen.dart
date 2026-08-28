import 'package:flutter/material.dart';

import '../components/custom_navigation.dart';
import '../models/cycle_record.dart';
import '../services/cycle_service.dart';
import '../utils/date_format_utils.dart';
import '../widgets/cycle_form_sheet.dart';
import 'cycle_history_screen.dart';

/// Tela principal do ciclo menstrual: calendário mensal com os
/// períodos registrados e a previsão do próximo ciclo, além de acesso
/// rápido para registrar um novo ciclo ou consultar o histórico.
class CycleScreen extends StatefulWidget {
  const CycleScreen({super.key});

  @override
  State<CycleScreen> createState() => _CycleScreenState();
}

class _CycleScreenState extends State<CycleScreen> {
  static const Color corPrimaria = Color(0xFFC43A4A);
  static const Color corRoxo = Color(0xFF5B2A86);
  static const Color corFundo = Color(0xFFF6F1EE);
  static const Color corPrevisto = Color(0xFFE3A4B6);

  late DateTime _visibleMonth;
  DateTime _today = DateFormatUtils.dateOnly(DateTime.now());

  @override
  void initState() {
    super.initState();
    _visibleMonth = DateTime(_today.year, _today.month);
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  CycleRecord? _recordStartingOn(DateTime day, List<CycleRecord> records) {
    for (final r in records) {
      if (DateFormatUtils.isSameDay(r.startDate, day)) return r;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final nav = CustomNavigationWidgets();

    return Scaffold(
      backgroundColor: corFundo,
      bottomNavigationBar: nav.buildBottomBar(context, activeTab: 'calendar'),
      floatingActionButton: nav.buildFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        child: ValueListenableBuilder<List<CycleRecord>>(
          valueListenable: CycleService.instance.recordsNotifier,
          builder: (context, records, _) {
            final service = CycleService.instance;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _buildHeader(context),
                  const SizedBox(height: 18),
                  _buildStatsCard(service),
                  const SizedBox(height: 20),
                  _buildCalendarCard(records, service),
                  const SizedBox(height: 16),
                  _buildLegend(),
                  const SizedBox(height: 20),
                  _buildHistoryButton(context),
                  const SizedBox(height: 110),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ciclo Menstrual',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey.shade900),
              ),
              const SizedBox(height: 2),
              Text(
                'Acompanhe e preveja seu ciclo',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => showCycleFormSheet(context),
          child: Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(color: corPrimaria, shape: BoxShape.circle),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(CycleService service) {
    final daysUntil = service.daysUntilNextCycle;
    final currentDay = service.currentCycleDay;
    final isOnPeriod = service.allPeriodDays.contains(_today);
    final hasHistory = service.lastRecord != null;

    String mainLabel;
    String mainValue;
    IconData mainIcon = Icons.water_drop_outlined;

    if (!hasHistory) {
      mainLabel = 'Comece agora';
      mainValue = 'Registre seu primeiro ciclo';
    } else if (isOnPeriod) {
      mainLabel = 'Você está menstruada';
      mainValue = 'Dia $currentDay do ciclo';
    } else if (daysUntil != null && daysUntil >= 0) {
      mainLabel = 'Próxima menstruação prevista em';
      mainValue = daysUntil == 0 ? 'Hoje' : '$daysUntil dias';
    } else {
      final atraso = daysUntil != null ? daysUntil.abs() : 0;
      mainLabel = 'Ciclo pode estar atrasado';
      mainValue = '$atraso dias de atraso';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFC43A4A), Color(0xFFB04D9B)],
        ),
        boxShadow: [
          BoxShadow(color: corPrimaria.withOpacity(0.25), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(mainIcon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mainLabel, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(
                      mainValue,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasHistory) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                _statChip('Ciclo médio', '${service.effectiveCycleLength} dias'),
                const SizedBox(width: 10),
                _statChip('Duração média', '${service.effectivePeriodLength} dias'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _statChip(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard(List<CycleRecord> records, CycleService service) {
    final periodDays = service.allPeriodDays;
    final ongoingDays = service.ongoingPeriodDays;
    final predictedDays = service.predictedPeriodDays;

    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    // weekday: Monday=1..Sunday=7 in Dart; queremos grid iniciando no Domingo.
    final leadingEmpty = firstOfMonth.weekday % 7;

    final totalCells = leadingEmpty + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left_rounded, color: corPrimaria),
              ),
              Text(
                DateFormatUtils.monthYear(_visibleMonth),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right_rounded, color: corPrimaria),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: DateFormatUtils.weekdayLettersShort
                .map((l) => Expanded(
                      child: Center(
                        child: Text(l, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rows * 7,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              final dayNumber = index - leadingEmpty + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }
              final day = DateTime(_visibleMonth.year, _visibleMonth.month, dayNumber);
              final isToday = DateFormatUtils.isSameDay(day, _today);
              final isPeriod = periodDays.contains(day);
              final isPredicted = !isPeriod && predictedDays.contains(day);
              final isOngoingDay = ongoingDays.contains(day);

              return _buildDayCell(
                context: context,
                day: day,
                dayNumber: dayNumber,
                isToday: isToday,
                isPeriod: isPeriod,
                isPredicted: isPredicted,
                isOngoingStart: isOngoingDay,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell({
    required BuildContext context,
    required DateTime day,
    required int dayNumber,
    required bool isToday,
    required bool isPeriod,
    required bool isPredicted,
    required bool isOngoingStart,
  }) {
    Color? bgColor;
    Color textColor = Colors.black87;
    Border? border;

    if (isPeriod) {
      // Ciclo em aberto (ainda sem data de término) recebe um tom levemente
      // diferente para se distinguir de um período já concluído.
      bgColor = isOngoingStart ? corRoxo : corPrimaria;
      textColor = Colors.white;
    } else if (isPredicted) {
      bgColor = corPrevisto.withOpacity(0.35);
      textColor = corPrimaria;
    }

    if (isToday) {
      border = Border.all(color: Colors.grey.shade900, width: 2);
    }

    return GestureDetector(
      onTap: () {
        final existing = _recordStartingOn(day, CycleService.instance.records);
        showCycleFormSheet(context, existing: existing, initialStartDate: existing == null ? day : null);
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: border,
        ),
        child: Text(
          '$dayNumber',
          style: TextStyle(
            color: textColor,
            fontWeight: isToday || isPeriod ? FontWeight.bold : FontWeight.normal,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _legendItem(corPrimaria, 'Período registrado'),
        _legendItem(corRoxo, 'Ciclo em andamento'),
        _legendItem(corPrevisto.withOpacity(0.5), 'Previsão do próximo'),
        _legendDot(Colors.grey.shade900, 'Hoje'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
      ],
    );
  }

  Widget _buildHistoryButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CycleHistoryScreen())),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: corRoxo.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.history_rounded, color: corRoxo, size: 20),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text('Ver histórico de registros', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
