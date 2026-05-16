import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/contents_screen.dart';
import 'package:frontend/screens/record_symptom.dart';
import 'package:frontend/components/custom_navigation.dart'; // Importe o novo componente

String _displayName() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return 'Usuária';
  final isGoogle =
      user.providerData.any((p) => p.providerId == 'google.com');
  final name = (user.displayName ?? '').trim();
  if (name.isEmpty) {
    return user.email?.split('@').first ?? 'Usuária';
  }
  return isGoogle ? name.split(' ').first : name;
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Paleta de Cores (Mantidas para os cards do body)
  static const Color corPrimaria = Color(0xFFC43A4A);
  static const Color corRoxo = Color(0xFF5B2A86);
  static const Color corFundo = Color(0xFFF6F1EE);
  static const Color corCard = Color(0xFFE8E8E8);

  // Dados mockados
  static const int diasParaProximoCiclo = 8;
  static const int sintomasHoje = 0;

  @override
  Widget build(BuildContext context) {
    // 1. Instanciamos o helper de navegação que contém toda a lógica
    final nav = CustomNavigationWidgets();

    return Scaffold(
      backgroundColor: corFundo,

      // 2. CHAMA A BARRA MODULAR (Lógica centralizada no componente)
      bottomNavigationBar: nav.buildBottomBar(context),

      // 3. CHAMA O BOTÃO CENTRAL MODULAR
      floatingActionButton: nav.buildFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // TÍTULO
              const Center(
                child: Text(
                  "Minha Saúde Feminina",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),

              const SizedBox(height: 24),

              // HEADER ROSA
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD98DA5), Color(0xFFE3A4B6)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Bem vinda",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _displayName(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // CARD: PRÓXIMO CICLO
              _buildProximoCicloCard(),

              const SizedBox(height: 12),

              // CARD: REGISTRAR SINTOMA
              _buildRegistrarSintomaCard(context),

              const SizedBox(height: 18),

              // CARD CONSULTA
              _buildAgendaCard(
                icon: Icons.calendar_today_outlined,
                titulo: "Consulta",
                subtitulo: "Hoje - 15:00",
              ),

              const SizedBox(height: 10),

              // CARD PREVENTIVO
              _buildAgendaCard(
                icon: Icons.shield_outlined,
                titulo: "Preventivo",
                subtitulo: "Sexta - 09:00",
              ),

              const SizedBox(height: 28),

              const Text(
                "Navegue",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 14),

              // CARDS NAVEGAÇÃO (Atalhos rápidos no meio da tela)
              Row(
                children: [
                  Expanded(
                    child: _buildBottomCard(
                      titulo: "Calendário Menstrual",
                      subtitulo: "Acompanhe seus sintomas",
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ConteudosScreen()),
                        );
                      },
                      child: _buildBottomCard(
                        titulo: "Conteúdos",
                        subtitulo: "Aprenda sobre",
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 100), // Espaço para não cobrir o conteúdo com a barra
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES DA HOME ---

  Widget _buildProximoCicloCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: corPrimaria.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: corPrimaria.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.water_drop_outlined, color: corPrimaria, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Próximo ciclo", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(text: "Faltam  ", style: TextStyle(fontSize: 15, color: Colors.black87)),
                      TextSpan(
                        text: "$diasParaProximoCiclo",
                        style: const TextStyle(fontSize: 32, color: corPrimaria, fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: "  dias", style: TextStyle(fontSize: 15, color: Colors.black87)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 22),
        ],
      ),
    );
  }

  Widget _buildRegistrarSintomaCard(BuildContext context) {
    final bool temSintomas = sintomasHoje > 0;
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const RecordSymptomScreen()));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: corRoxo.withOpacity(0.12),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: corRoxo.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.sentiment_satisfied_alt_outlined, color: corRoxo, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Registrar sintoma", style: TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    sintomasHoje == 0 ? "Nenhum sintoma registrado hoje" : "$sintomasHoje sintoma(s) registrado(s) hoje",
                    style: TextStyle(fontSize: 12, color: temSintomas ? corRoxo : Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendaCard({required IconData icon, required String titulo, required String subtitulo}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: corCard, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.brown.shade700, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(subtitulo, style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCard({required String titulo, required String subtitulo}) {
    return Container(
      height: 86,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(colors: [Color(0xFFC43A4A), Color(0xFFB04D9B)]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          Text(subtitulo, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}