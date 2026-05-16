import 'package:flutter/material.dart';

class DetalhesConteudoScreen extends StatelessWidget {
  final String titulo;
  final String categoria;

  const DetalhesConteudoScreen({
    super.key,
    required this.titulo,
    required this.categoria,
  });

  static const Color corPrimariaVinho = Color(0xFFC43A4A);
  static const Color corFundoRosa = Color(0xFFFBD9E5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF4EB), // Bege fundo [cite: 11]
      body: CustomScrollView(
        slivers: [
          // Header com botão voltar
          SliverAppBar(
            backgroundColor: corFundoRosa,
            expandedHeight: 120,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: corPrimariaVinho),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                titulo,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tag da Categoria [cite: 46]
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "🌸 $categoria",
                      style: const TextStyle(
                        color: corPrimariaVinho,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Seção: O que é normal [cite: 60]
                  _buildSectionCard(
                    emoji: "🌸",
                    tituloSecao: "O que é normal",
                    conteudo:
                        "O corrimento vaginal transparente ou esbranqueçado, sem cheiro forte, é completamente normal e faz parte da saúde íntima da mulher.",
                  ),

                  // Seção: Quando procurar a UBS [cite: 123]
                  _buildSectionCard(
                    emoji: "🏥",
                    tituloSecao: "Quando procurar a UBS",
                    conteudo:
                        "Procure a UBS se o corrimento tiver cor amarelada, esverdeada ou acinzentada, cheiro forte e desagradável.",
                    corBorda: Colors.red.withOpacity(0.2),
                  ),

                  // Alerta [cite: 61]
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E5F5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.purple),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Estas informações não substituem avaliação médica.",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.purple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String emoji,
    required String tituloSecao,
    required String conteudo,
    Color? corBorda,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: corBorda != null ? Border.all(color: corBorda) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                tituloSecao,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            conteudo,
            style: const TextStyle(color: Colors.black54, height: 1.5),
          ),
        ],
      ),
    );
  }
}
