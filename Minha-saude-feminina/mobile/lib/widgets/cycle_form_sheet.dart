import 'package:flutter/material.dart';

import '../models/cycle_record.dart';
import '../services/cycle_service.dart';
import '../utils/date_format_utils.dart';

/// Abre um modal (bottom sheet) para registrar um novo ciclo menstrual
/// ou editar/excluir um já existente.
Future<void> showCycleFormSheet(
  BuildContext context, {
  CycleRecord? existing,
  DateTime? initialStartDate,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => CycleFormSheet(existing: existing, initialStartDate: initialStartDate),
  );
}

class CycleFormSheet extends StatefulWidget {
  final CycleRecord? existing;
  final DateTime? initialStartDate;

  const CycleFormSheet({super.key, this.existing, this.initialStartDate});

  @override
  State<CycleFormSheet> createState() => _CycleFormSheetState();
}

class _CycleFormSheetState extends State<CycleFormSheet> {
  static const Color corPrimaria = Color(0xFFC43A4A);

  late DateTime _startDate;
  DateTime? _endDate;
  late bool _ongoing;
  late TextEditingController _notesController;
  String? _errorText;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _startDate = existing?.startDate ?? widget.initialStartDate ?? DateTime.now();
    _endDate = existing?.endDate;
    _ongoing = existing == null ? false : existing.isOngoing;
    _notesController = TextEditingController(text: existing?.notes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      locale: const Locale('pt', 'BR'),
      helpText: 'Início da menstruação',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = null;
        }
        _errorText = null;
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (_endDate != null && !_endDate!.isBefore(_startDate)) ? _endDate! : _startDate,
      firstDate: _startDate,
      lastDate: _startDate.add(const Duration(days: 20)),
      locale: const Locale('pt', 'BR'),
      helpText: 'Término da menstruação',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _errorText = null;
      });
    }
  }

  Future<void> _save() async {
    if (!_ongoing && _endDate == null) {
      setState(() => _errorText = 'Selecione a data de término ou marque como em andamento.');
      return;
    }
    setState(() {
      _saving = true;
      _errorText = null;
    });

    final notes = _notesController.text.trim();

    try {
      if (_isEditing) {
        final updated = widget.existing!.copyWith(
          startDate: _startDate,
          endDate: _ongoing ? null : _endDate,
          clearEndDate: _ongoing,
          notes: notes.isEmpty ? null : notes,
        );
        await CycleService.instance.updateRecord(updated);
      } else {
        await CycleService.instance.addRecord(
          startDate: _startDate,
          endDate: _ongoing ? null : _endDate,
          notes: notes.isEmpty ? null : notes,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir registro'),
        content: const Text('Tem certeza que deseja excluir este registro de ciclo? Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: corPrimaria)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await CycleService.instance.deleteRecord(widget.existing!.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text(
                _isEditing ? 'Editar ciclo' : 'Registrar ciclo menstrual',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Informe o início e, se souber, o término do período.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),

              _dateField(
                label: 'Início da menstruação',
                icon: Icons.water_drop_outlined,
                value: DateFormatUtils.long(_startDate),
                onTap: _pickStartDate,
              ),
              const SizedBox(height: 14),

              // Toggle "em andamento"
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F1EE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Ciclo ainda em andamento',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Switch(
                      value: _ongoing,
                      activeColor: corPrimaria,
                      onChanged: (v) => setState(() {
                        _ongoing = v;
                        _errorText = null;
                      }),
                    ),
                  ],
                ),
              ),

              if (!_ongoing) ...[
                const SizedBox(height: 14),
                _dateField(
                  label: 'Término da menstruação',
                  icon: Icons.event_available_outlined,
                  value: _endDate != null ? DateFormatUtils.long(_endDate!) : 'Selecionar data',
                  onTap: _pickEndDate,
                  isPlaceholder: _endDate == null,
                ),
              ],

              const SizedBox(height: 14),
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Observações (opcional)',
                  filled: true,
                  fillColor: const Color(0xFFF6F1EE),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              if (_errorText != null) ...[
                const SizedBox(height: 10),
                Text(_errorText!, style: const TextStyle(color: corPrimaria, fontSize: 13)),
              ],

              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corPrimaria,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
                        )
                      : Text(
                          _isEditing ? 'Salvar alterações' : 'Salvar registro',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                ),
              ),

              if (_isEditing) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton.icon(
                    onPressed: _saving ? null : _delete,
                    icon: const Icon(Icons.delete_outline, color: corPrimaria),
                    label: const Text('Excluir registro', style: TextStyle(color: corPrimaria, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateField({
    required String label,
    required IconData icon,
    required String value,
    required VoidCallback onTap,
    bool isPlaceholder = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F1EE),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: corPrimaria, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isPlaceholder ? Colors.grey.shade500 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
