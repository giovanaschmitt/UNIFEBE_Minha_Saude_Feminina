import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import '../models/artigo.dart';
import '../services/api_client.dart';
import '../services/content_service.dart';

class DetalhesConteudoScreen extends StatefulWidget {
  /// Artigo vindo da listagem (sem o HTML); o conteúdo completo é buscado aqui.
  final Artigo artigo;
  final Color corCategoria;

  const DetalhesConteudoScreen({
    super.key,
    required this.artigo,
    required this.corCategoria,
  });

  @override
  State<DetalhesConteudoScreen> createState() => _DetalhesConteudoScreenState();
}

class _DetalhesConteudoScreenState extends State<DetalhesConteudoScreen> {
  static const Color corPrimariaVinho = Color(0xFFC43A4A);
  static const Color corRoxo = Color(0xFF5B2A86);
  static const Color corFundoRosa = Color(0xFFE3A4B6);
  static const Color corFundoBege = Color(0xFFF6F1EE);

  Artigo? _completo;
  String? _erro;

  String get titulo => widget.artigo.titulo;
  String get categoria => widget.artigo.categoria;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _erro = null);
    try {
      final artigo = await ContentService.instance.buscarArtigo(widget.artigo.id);
      if (mounted) setState(() => _completo = artigo);
    } catch (e) {
      if (!mounted) return;
      setState(() => _erro = e is ApiException ? e.mensagem : 'Não foi possível abrir este conteúdo.');
    }
  }

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
                          "${widget.artigo.categoriaEmoji ?? '🌸'} $categoria",
                          style: TextStyle(
                            color: widget.corCategoria,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.schedule_rounded, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        "${widget.artigo.tempoLeitura} min de leitura",
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  _buildConteudo(),

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

  Widget _buildConteudo() {
    final Widget filho;
    if (_erro != null) {
      filho = Column(
        children: [
          Text(_erro!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _carregar,
            child: const Text(
              'Tentar novamente',
              style: TextStyle(color: corPrimariaVinho, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    } else if (_completo == null) {
      filho = const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(color: corPrimariaVinho)),
      );
    } else {
      final artigo = _completo!;
      filho = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (artigo.capaUrl != null && artigo.capaUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                artigo.capaUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, erro, pilha) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 14),
          ],
          HtmlWidget(
            artigo.conteudoHtml ?? '',
            textStyle: TextStyle(color: Colors.grey.shade800, height: 1.55, fontSize: 14),
          ),
          if (artigo.autora.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'Por ${artigo.autora}',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: filho,
    );
  }
}
