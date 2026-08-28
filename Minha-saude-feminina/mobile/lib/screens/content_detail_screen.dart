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
  static const Color corRoxo = Color(0xFF5B2A86);
  static const Color corFundoRosa = Color(0xFFE3A4B6);
  static const Color corFundoBege = Color(0xFFF6F1EE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundoBege,
      body: CustomScrollView(
        slivers: [
          // Header com botão voltar
          SliverAppBar(
            backgroundColor: corFundoRosa,
            expandedHeight: 130,
            pinned: true,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.7),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: corPrimariaVinho, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 60, right: 20, bottom: 16),
              centerTitle: false,
              title: Text(
                titulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFE3A4B6), Color(0xFFFBD9E5)],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tag da Categoria + tempo de leitura
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
                        ),
                        child: Text(
                          "🌸 $categoria",
                          style: const TextStyle(
                            color: corPrimariaVinho,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Seção: O que é normal
                  _buildSectionCard(
                    emoji: "🌸",
                    corIcone: corPrimariaVinho,
                    tituloSecao: "O que é normal",
                    conteudo:
                        "O corrimento vaginal transparente ou esbranqueçado, sem cheiro forte, é completamente normal e faz parte da saúde íntima da mulher.",
                  ),

                  // Seção: Quando procurar a UBS
                  _buildSectionCard(
                    emoji: "🏥",
                    corIcone: const Color(0xFFD9534F),
                    tituloSecao: "Quando procurar a UBS",
                    conteudo:
                        "Procure a UBS se o corrimento tiver cor amarelada, esverdeada ou acinzentada, cheiro forte e desagradável.",
                    corBorda: Colors.red.withOpacity(0.15),
                  ),

                  // Alerta
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: corRoxo.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: corRoxo.withOpacity(0.15)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(color: corRoxo.withOpacity(0.12), shape: BoxShape.circle),
                          child: const Icon(Icons.warning_amber_rounded, color: corRoxo, size: 18),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Estas informações não substituem avaliação médica.",
                            style: TextStyle(
                              fontSize: 12.5,
                              color: corRoxo,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
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
    required Color corIcone,
    required String tituloSecao,
    required String conteudo,
    Color? corBorda,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: corBorda != null ? Border.all(color: corBorda) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: corIcone.withOpacity(0.1), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 17)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tituloSecao,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            conteudo,
            style: TextStyle(color: Colors.grey.shade700, height: 1.55, fontSize: 13.5),
          ),
        ],
      ),
    );
  }
}
