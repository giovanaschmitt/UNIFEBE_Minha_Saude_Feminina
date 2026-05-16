import 'package:flutter/material.dart';

class RecordSymptomScreen extends StatefulWidget {
  const RecordSymptomScreen({super.key});

  @override
  State<RecordSymptomScreen> createState() => _RecordSymptomScreenState();
}

class _RecordSymptomScreenState extends State<RecordSymptomScreen> {
  static const Color corPrimaria = Color(0xFFC43A4A);
  static const Color corFundo = Color(0xFFF6F1EE);

  // Controladores de estado
  int? _indiceSelecionado;
  String? _intensidadeSelecionada;

  final List<Map<String, dynamic>> _sintomas = const [
    {"icon": "🔥", "label": "Cólica"},
    {"icon": "🌀", "label": "Dor pélvica"},
    {"icon": "💧", "label": "Corrimento"},
    {"icon": "🩸", "label": "Sangramento fora do período"},
    {"icon": "⚡", "label": "Ardor ao urinar"},
    {"icon": "😫", "label": "Dor nas mamas"},
    {"icon": "😢", "label": "Humor alterado"},
    {"icon": "😰", "label": "Ansiedade"},
    {"icon": "😠", "label": "Irritabilidade"},
    {"icon": "😴", "label": "Alteração no sono"},
    {"icon": "📱", "label": "Inchaço"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Voltar", style: TextStyle(color: Colors.black, fontSize: 16)),
        titleSpacing: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Registrar Sintomas",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            const Text(
              "Selecione o sintoma e a intensidade",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _sintomas.length,
                itemBuilder: (context, index) {
                  bool estaSelecionado = _indiceSelecionado == index;

                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _indiceSelecionado = index;
                            _intensidadeSelecionada = null; // Reseta intensidade ao trocar sintoma
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: estaSelecionado ? corPrimaria : Colors.black.withOpacity(0.05),
                              width: estaSelecionado ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(_sintomas[index]["icon"], style: const TextStyle(fontSize: 24)),
                              const SizedBox(width: 16),
                              Text(
                                _sintomas[index]["label"],
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              const Spacer(),
                              if (estaSelecionado)
                                const Icon(Icons.check_circle, color: corPrimaria),
                            ],
                          ),
                        ),
                      ),
                      
                      // EXIBIR INTENSIDADE E BOTÃO SE SELECIONADO
                      if (estaSelecionado) _buildSelectionArea(),
                      const SizedBox(height: 12),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text("Qual a intensidade?", style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _intensidadeBotao("Leve"),
              _intensidadeBotao("Moderada"),
              _intensidadeBotao("Forte"),
            ],
          ),
          if (_intensidadeSelecionada != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Lógica para salvar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Salvo: ${_sintomas[_indiceSelecionado!]['label']} ($_intensidadeSelecionada)")),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: corPrimaria,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("Salvar Sintoma", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _intensidadeBotao(String label) {
    bool selecionado = _intensidadeSelecionada == label;
    return GestureDetector(
      onTap: () => setState(() => _intensidadeSelecionada = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selecionado ? corPrimaria : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: corPrimaria),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selecionado ? Colors.white : corPrimaria,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}