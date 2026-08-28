import 'package:flutter/material.dart';

class RecordSymptomScreen extends StatefulWidget {
  const RecordSymptomScreen({super.key});

  @override
  State<RecordSymptomScreen> createState() => _RecordSymptomScreenState();
}

class _RecordSymptomScreenState extends State<RecordSymptomScreen> {
  static const Color corPrimaria = Color(0xFFC43A4A);
  static const Color corRoxo = Color(0xFF5B2A86);
  static const Color corFundo = Color(0xFFF6F1EE);

  // Cores da escala de intensidade (do mais leve ao mais forte).
  static const Color corLeve = Color(0xFFDDA6B0);
  static const Color corModerada = Color(0xFFC43A4A);
  static const Color corForte = Color(0xFF7A1F2B);

  // Controladores de estado
  int? _indiceSelecionado;
  String? _intensidadeSelecionada;

  // Sintomas com ícones do Material Design (sem emojis) e uma cor por
  // categoria: tons de vinho para sintomas físicos, tons de roxo para
  // sintomas emocionais/comportamentais.
  final List<Map<String, dynamic>> _sintomas = const [
    {"icon": Icons.bolt_rounded, "label": "Cólica", "cor": corPrimaria},
    {"icon": Icons.gps_fixed_rounded, "label": "Dor pélvica", "cor": corPrimaria},
    {"icon": Icons.water_drop_outlined, "label": "Corrimento", "cor": corPrimaria},
    {"icon": Icons.bloodtype_outlined, "label": "Sangramento fora do período", "cor": corPrimaria},
    {"icon": Icons.local_fire_department_outlined, "label": "Ardor ao urinar", "cor": corPrimaria},
    {"icon": Icons.favorite_border_rounded, "label": "Dor nas mamas", "cor": corPrimaria},
    {"icon": Icons.blur_on_rounded, "label": "Inchaço", "cor": corPrimaria},
    {"icon": Icons.mood_outlined, "label": "Humor alterado", "cor": corRoxo},
    {"icon": Icons.psychology_outlined, "label": "Ansiedade", "cor": corRoxo},
    {"icon": Icons.sentiment_dissatisfied_outlined, "label": "Irritabilidade", "cor": corRoxo},
    {"icon": Icons.bedtime_outlined, "label": "Alteração no sono", "cor": corRoxo},
  ];

  Color _corIntensidade(String label) {
    switch (label) {
      case "Leve":
        return corLeve;
      case "Moderada":
        return corModerada;
      case "Forte":
        return corForte;
      default:
        return corPrimaria;
    }
  }

  void _salvarSintoma() {
    final sintoma = _sintomas[_indiceSelecionado!];

    // Lógica de salvamento (mock, mantida como estava).
    _mostrarConfirmacao(
      label: sintoma['label'] as String,
      intensidade: _intensidadeSelecionada!,
      icone: sintoma['icon'] as IconData,
      cor: sintoma['cor'] as Color,
    );
    Navigator.pop(context);
  }

  void _mostrarConfirmacao({
    required String label,
    required String intensidade,
    required IconData icone,
    required Color cor,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 24),
        padding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF2E2A32),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 18, offset: const Offset(0, 8)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Sintoma registrado",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "$label · Intensidade $intensidade",
                      style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildHeader(context),
              const SizedBox(height: 22),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _sintomas.length,
                  itemBuilder: (context, index) {
                    final estaSelecionado = _indiceSelecionado == index;

                    return Column(
                      children: [
                        _buildSymptomTile(index, estaSelecionado),
                        if (estaSelecionado) ...[
                          const SizedBox(height: 10),
                          _buildSelectionArea(),
                        ],
                        const SizedBox(height: 12),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: const Icon(Icons.arrow_back_rounded, color: Colors.black87, size: 20),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Registrar sintoma",
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Colors.grey.shade900),
              ),
              const SizedBox(height: 2),
              Text(
                "Toque no sintoma e escolha a intensidade",
                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomTile(int index, bool estaSelecionado) {
    final sintoma = _sintomas[index];
    final Color cor = sintoma['cor'] as Color;

    return GestureDetector(
      onTap: () {
        setState(() {
          _indiceSelecionado = index;
          _intensidadeSelecionada = null; // Reseta intensidade ao trocar sintoma
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: estaSelecionado ? cor : Colors.transparent,
            width: 1.6,
          ),
          boxShadow: [
            BoxShadow(
              color: estaSelecionado ? cor.withOpacity(0.18) : Colors.black.withOpacity(0.04),
              blurRadius: estaSelecionado ? 14 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: cor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(sintoma['icon'] as IconData, color: cor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                sintoma['label'] as String,
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: estaSelecionado
                  ? Icon(Icons.check_circle_rounded, color: cor, key: const ValueKey('check'))
                  : Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300, key: const ValueKey('chevron')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Qual a intensidade?",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: Colors.grey.shade800),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _intensidadeBotao("Leve"),
              const SizedBox(width: 8),
              _intensidadeBotao("Moderada"),
              const SizedBox(width: 8),
              _intensidadeBotao("Forte"),
            ],
          ),
          if (_intensidadeSelecionada != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _salvarSintoma,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _corIntensidade(_intensidadeSelecionada!),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  "Salvar sintoma",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _intensidadeBotao(String label) {
    final bool selecionado = _intensidadeSelecionada == label;
    final Color cor = _corIntensidade(label);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _intensidadeSelecionada = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selecionado ? cor : cor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selecionado ? Colors.white : cor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
