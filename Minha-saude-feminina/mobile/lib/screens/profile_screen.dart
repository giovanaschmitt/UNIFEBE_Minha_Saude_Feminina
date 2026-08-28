import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/custom_navigation.dart';
import '../models/cycle_record.dart';
import '../services/cycle_service.dart';

/// Tela de Perfil: mostra os dados da conta autenticada (via Firebase
/// Auth, já existente no app), um resumo dos registros de ciclo salvos
/// localmente e a opção de sair da conta. Não cria nenhuma conexão
/// nova — só lê informações que o app já tinha disponíveis.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color corPrimaria = Color(0xFFC43A4A);
  static const Color corRoxo = Color(0xFF5B2A86);
  static const Color corFundo = Color(0xFFF6F1EE);

  String _iniciais(String nome) {
    final partes = nome.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (partes.isEmpty) return '?';
    if (partes.length == 1) return partes.first.substring(0, 1).toUpperCase();
    return (partes.first.substring(0, 1) + partes.last.substring(0, 1)).toUpperCase();
  }

  String _nomeExibicao(User user) {
    final name = (user.displayName ?? '').trim();
    if (name.isNotEmpty) return name;
    return user.email?.split('@').first ?? 'Usuária';
  }

  String _origemConta(User user) {
    final isGoogle = user.providerData.any((p) => p.providerId == 'google.com');
    return isGoogle ? 'Conectado via Google' : 'Conectado via e-mail';
  }

  String _membroDesde(User user) {
    final created = user.metadata.creationTime;
    if (created == null) return '';
    const meses = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez',
    ];
    return 'Membro desde ${meses[created.month - 1]}/${created.year}';
  }

  Future<void> _confirmarSaida(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Sair da conta'),
        content: const Text('Tem certeza que deseja sair? Seus registros de ciclo continuam salvos neste aparelho.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair', style: TextStyle(color: corPrimaria, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      // O StreamBuilder em main.dart já redireciona para a tela de
      // login automaticamente assim que o estado de autenticação muda.
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav = CustomNavigationWidgets();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: corFundo,
      bottomNavigationBar: nav.buildBottomBar(context, activeTab: 'profile'),
      floatingActionButton: nav.buildFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        child: user == null
            ? const Center(child: Text('Nenhuma usuária autenticada.'))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Perfil',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 18),
                    _buildHeaderCard(user),
                    const SizedBox(height: 22),
                    const Text('Seus dados de ciclo', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildCycleStats(),
                    const SizedBox(height: 22),
                    const Text('Conta', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildAccountSection(context, user),
                    const SizedBox(height: 22),
                    const Text('Sobre', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildAboutSection(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeaderCard(User user) {
    final nome = _nomeExibicao(user);
    final foto = user.photoURL;

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
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white.withOpacity(0.25),
            backgroundImage: (foto != null && foto.isNotEmpty) ? NetworkImage(foto) : null,
            child: (foto == null || foto.isEmpty)
                ? Text(
                    _iniciais(nome),
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                if ((user.email ?? '').isNotEmpty)
                  Text(
                    user.email!,
                    style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _origemConta(user),
                    style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleStats() {
    return ValueListenableBuilder<List<CycleRecord>>(
      valueListenable: CycleService.instance.recordsNotifier,
      builder: (context, records, _) {
        final service = CycleService.instance;
        return Row(
          children: [
            Expanded(child: _statCard('Registros', '${records.length}', Icons.event_note_outlined, corPrimaria)),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                'Ciclo médio',
                service.averageCycleLength != null ? '${service.averageCycleLength} dias' : '—',
                Icons.autorenew_rounded,
                corRoxo,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                'Duração média',
                service.averagePeriodLength != null ? '${service.averagePeriodLength} dias' : '—',
                Icons.water_drop_outlined,
                corPrimaria,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, User user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          _accountRow(
            icon: Icons.badge_outlined,
            iconColor: corRoxo,
            title: 'E-mail',
            subtitle: user.email ?? 'não informado',
          ),
          _divider(),
          _accountRow(
            icon: Icons.calendar_today_outlined,
            iconColor: corRoxo,
            title: 'Conta criada',
            subtitle: _membroDesde(user).replaceFirst('Membro desde ', '').isEmpty
                ? 'não disponível'
                : _membroDesde(user).replaceFirst('Membro desde ', ''),
          ),
          _divider(),
          InkWell(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
            onTap: () => _confirmarSaida(context),
            child: _accountRow(
              icon: Icons.logout_rounded,
              iconColor: corPrimaria,
              title: 'Sair da conta',
              subtitle: 'Encerrar sessão neste dispositivo',
              titleColor: corPrimaria,
              showChevron: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, indent: 60, color: Colors.grey.shade100);

  Widget _accountRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Color? titleColor,
    bool showChevron = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: titleColor ?? Colors.black87),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          if (showChevron) const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: corRoxo.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.favorite_outline, color: corRoxo, size: 18),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Minha Saúde Feminina — projeto UNIFEBE',
              style: TextStyle(fontSize: 12.5, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
