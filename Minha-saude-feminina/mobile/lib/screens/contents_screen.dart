import 'package:flutter/material.dart';
import 'package:frontend/screens/content_detail_screen.dart';
// 1. Importe o arquivo onde está a classe CustomNavigationWidgets
import 'package:frontend/components/custom_navigation.dart';
import 'package:frontend/models/artigo.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/services/content_service.dart';

class ConteudosScreen extends StatefulWidget {
  const ConteudosScreen({super.key});

  @override
  State<ConteudosScreen> createState() => _ConteudosScreenState();
}

class _ConteudosScreenState extends State<ConteudosScreen> {
  static const Color corPrimariaVinho = Color(0xFFC43A4A);
  static const Color corRoxo = Color(0xFF5B2A86);
  static const Color corFundoRosa = Color(0xFFFBD9E5);
  static const Color corBegeFundo = Color(0xFFF6F1EE);

  String _filtroSelecionado = "Todos";
  String _termoBusca = "";

  // --- DADOS (carregados da API: GET /api/artigos e /api/categorias) ---
  List<Artigo> _todosConteudos = [];
  List<Categoria> _categorias = [];
  bool _carregando = true;
  String? _erro;

  List<Artigo> _conteudosExibidos = [];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final resultados = await Future.wait([
        ContentService.instance.listarArtigos(),
        ContentService.instance.listarCategorias(),
      ]);
      if (!mounted) return;
      _todosConteudos = resultados[0] as List<Artigo>;
      _categorias = resultados[1] as List<Categoria>;
      if (_filtroSelecionado != "Todos" && !_categorias.any((c) => c.nome == _filtroSelecionado)) {
        _filtroSelecionado = "Todos";
      }
      _carregando = false;
      _aplicarFiltros();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _carregando = false;
        _erro = e is ApiException ? e.mensagem : 'Não foi possível carregar os conteúdos.';
      });
    }
  }

  // --- LÓGICA ---
  void _aplicarFiltros() {
    setState(() {
      final termo = _termoBusca.toLowerCase();
      _conteudosExibidos = _todosConteudos.where((item) {
        final combinaBusca = item.titulo.toLowerCase().contains(termo) ||
            item.resumo.toLowerCase().contains(termo) ||
            item.categoria.toLowerCase().contains(termo);
        final combinaCategoria = _filtroSelecionado == "Todos" || item.categoria == _filtroSelecionado;
        return combinaBusca && combinaCategoria;
      }).toList();
    });
  }

  Color _corDoArtigo(Artigo artigo) => artigo.categoriaCor ?? _corCategoria(artigo.categoria);

  Color _corCategoria(String categoria) {
    switch (categoria) {
      case 'Menstruação':
        return corPrimariaVinho;
      case 'Contracepção':
        return corRoxo;
      case 'Gravidez':
        return const Color(0xFFD98DA5);
      default:
        return corPrimariaVinho;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 2. Instancie a sua classe de navegação para acessar os métodos
    final nav = CustomNavigationWidgets();

    return Scaffold(
      backgroundColor: corBegeFundo,

      // 3. Chame o método do botão central (FAB)
      floatingActionButton: nav.buildFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 4. Chame o método da barra inferior
      bottomNavigationBar: nav.buildBottomBar(context, activeTab: 'contents'),

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFiltros(),
            const SizedBox(height: 4),
            Expanded(
              child: _carregando
                  ? const Center(child: CircularProgressIndicator(color: corPrimariaVinho))
                  : _erro != null
                      ? _buildErrorState()
                      : RefreshIndicator(
                          color: corPrimariaVinho,
                          onRefresh: _carregar,
                          child: _conteudosExibidos.isEmpty
                              ? ListView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  children: [_buildEmptyState()],
                                )
                              : ListView.builder(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                                  itemCount: _conteudosExibidos.length,
                                  itemBuilder: (context, index) {
                                    return _buildCardConteudo(
                                      context: context,
                                      artigo: _conteudosExibidos[index],
                                    );
                                  },
                                ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DE UI (VISUAL RENOVADO) ---

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE3A4B6), corFundoRosa],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(color: corPrimariaVinho.withOpacity(0.15), blurRadius: 18, offset: const Offset(0, 8)),
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
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.55), shape: BoxShape.circle),
                child: const Icon(Icons.auto_stories_outlined, color: corPrimariaVinho, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Conteúdos",
                  style: TextStyle(color: corPrimariaVinho, fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Informação confiável sobre saúde feminina",
            style: TextStyle(color: corPrimariaVinho.withOpacity(0.75), fontSize: 12.5, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: TextField(
              onChanged: (valor) {
                _termoBusca = valor;
                _aplicarFiltros();
              },
              decoration: InputDecoration(
                hintText: "Buscar conteúdos...",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, color: corPrimariaVinho),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    final filtros = [
      {"label": "Todos", "emoji": "✨"},
      for (final categoria in _categorias) {"label": categoria.nome, "emoji": categoria.emoji},
    ];

    return SizedBox(
      height: 66,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: filtros.length,
        itemBuilder: (context, index) {
          final filtro = filtros[index]['label']!;
          final isSelected = _filtroSelecionado == filtro;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _filtroSelecionado = filtro;
                  _aplicarFiltros();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? corPrimariaVinho : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [BoxShadow(color: corPrimariaVinho.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))]
                      : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Text(
                  "${filtros[index]['emoji']} $filtro",
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardConteudo({
    required BuildContext context,
    required Artigo artigo,
  }) {
    final corCategoria = _corDoArtigo(artigo);
    final emoji = artigo.emoji;
    final titulo = artigo.titulo;
    final descricao = artigo.resumo;
    final categoria = artigo.categoria;
    final tempoLeitura = "${artigo.tempoLeitura} min";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetalhesConteudoScreen(artigo: artigo, corCategoria: corCategoria),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: corCategoria.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: corCategoria.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          categoria.toUpperCase(),
                          style: TextStyle(color: corCategoria, fontWeight: FontWeight.bold, fontSize: 9.5, letterSpacing: 0.3),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        titulo,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, height: 1.25),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        descricao,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5, height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded, size: 13, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(tempoLeitura, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500)),
                          const Spacer(),
                          Icon(Icons.arrow_forward_rounded, size: 16, color: corCategoria),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: corPrimariaVinho.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.cloud_off_rounded, color: corPrimariaVinho, size: 34),
            ),
            const SizedBox(height: 18),
            const Text(
              "Não foi possível carregar",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              _erro ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _carregar,
              icon: const Icon(Icons.refresh_rounded, color: corPrimariaVinho),
              label: const Text(
                "Tentar novamente",
                style: TextStyle(color: corPrimariaVinho, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: corPrimariaVinho.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.search_off_rounded, color: corPrimariaVinho, size: 34),
            ),
            const SizedBox(height: 18),
            const Text(
              "Nenhum resultado encontrado",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "Tente buscar por outro termo ou escolha outra categoria.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
