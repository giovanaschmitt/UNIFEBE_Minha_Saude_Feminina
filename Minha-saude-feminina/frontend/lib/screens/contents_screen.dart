import 'package:flutter/material.dart';
import 'package:frontend/screens/content_detail_screen.dart';
// 1. Importe o arquivo onde está a classe CustomNavigationWidgets
import 'package:frontend/components/custom_navigation.dart'; 

class ConteudosScreen extends StatefulWidget {
  const ConteudosScreen({super.key});

  @override
  State<ConteudosScreen> createState() => _ConteudosScreenState();
}

class _ConteudosScreenState extends State<ConteudosScreen> {
  static const Color corPrimariaVinho = Color(0xFFC43A4A);
  static const Color corFundoRosa = Color(0xFFFBD9E5);
  static const Color corBegeFundo = Color(0xFFFBF4EB);

  String _filtroSelecionado = "Todos";
  String _termoBusca = "";

  final List<Map<String, String>> _todosConteudos = [
    {
      "emoji": "🩸",
      "titulo": "Cólicas menstruais: quando se preocupar",
      "descricao": "Saiba diferenciar cólicas normais de sinais médicos.",
      "categoria": "Menstruação",
      "tempo": "6 min",
    },
    {
      "emoji": "✨",
      "titulo": "Fase Folicular e Libido",
      "descricao": "Entenda como seus hormônios afetam seu desejo.",
      "categoria": "Menstruação",
      "tempo": "4 min",
    },
    {
      "emoji": "💊",
      "titulo": "Tipos de Anticoncepcional",
      "descricao": "Conheça as opções e como cada uma age no corpo.",
      "categoria": "Contracepção",
      "tempo": "8 min",
    },
    {
      "emoji": "🤰",
      "titulo": "Primeiros sinais de Gravidez",
      "descricao": "O que o seu corpo sente nas primeiras semanas.",
      "categoria": "Gravidez",
      "tempo": "5 min",
    },
  ];

  List<Map<String, String>> _conteudosExibidos = [];

  @override
  void initState() {
    super.initState();
    _conteudosExibidos = _todosConteudos;
  }

  void _aplicarFiltros() {
    setState(() {
      _conteudosExibidos = _todosConteudos.where((item) {
        final combinaBusca = item['titulo']!.toLowerCase().contains(_termoBusca.toLowerCase()) ||
                             item['categoria']!.toLowerCase().contains(_termoBusca.toLowerCase());
        final combinaCategoria = _filtroSelecionado == "Todos" || item['categoria'] == _filtroSelecionado;
        return combinaBusca && combinaCategoria;
      }).toList();
    });
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
      bottomNavigationBar: nav.buildBottomBar(context),

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFiltros(),
            Expanded(
              child: _conteudosExibidos.isEmpty
                  ? const Center(child: Text("Nenhum resultado encontrado 🔍"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _conteudosExibidos.length,
                      itemBuilder: (context, index) {
                        final item = _conteudosExibidos[index];
                        return _buildCardConteudo(
                          context: context,
                          emoji: item['emoji']!,
                          titulo: item['titulo']!,
                          descricao: item['descricao']!,
                          categoria: item['categoria']!,
                          tempoLeitura: item['tempo']!,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MÉTODOS DE UI (MANTIDOS) ---

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: corFundoRosa,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Conteúdos 💜",
            style: TextStyle(color: corPrimariaVinho, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            onChanged: (valor) {
              _termoBusca = valor;
              _aplicarFiltros();
            },
            decoration: InputDecoration(
              hintText: "Buscar conteúdos...",
              prefixIcon: const Icon(Icons.search, color: corPrimariaVinho),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide.none,
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
      {"label": "Menstruação", "emoji": "🩸"},
      {"label": "Contracepção", "emoji": "💊"},
      {"label": "Gravidez", "emoji": "🤰"},
    ];

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: filtros.length,
        itemBuilder: (context, index) {
          final filtro = filtros[index]['label']!;
          final isSelected = _filtroSelecionado == filtro;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text("${filtros[index]['emoji']} $filtro"),
              selected: isSelected,
              selectedColor: corPrimariaVinho,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : corPrimariaVinho,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _filtroSelecionado = filtro;
                    _aplicarFiltros();
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardConteudo({
    required BuildContext context,
    required String emoji,
    required String titulo,
    required String descricao,
    required String tempoLeitura,
    required String categoria,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalhesConteudoScreen(titulo: titulo, categoria: categoria),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(categoria.toUpperCase(), style: const TextStyle(color: corPrimariaVinho, fontWeight: FontWeight.bold, fontSize: 10)),
                  Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(descricao, style: const TextStyle(color: Colors.black54, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}