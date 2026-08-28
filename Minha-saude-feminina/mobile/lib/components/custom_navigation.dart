import 'package:flutter/material.dart';
import 'package:frontend/screens/home_screen.dart'; // Importante para o botão Home
import 'package:frontend/screens/contents_screen.dart';
import 'package:frontend/screens/record_symptom.dart';
import 'package:frontend/screens/cycle_screen.dart';
import 'package:frontend/screens/profile_screen.dart';

class CustomNavigationWidgets {
  static const Color corPrimaria = Color(0xFFC43A4A);
  static const Color corRosaBotao = Color(0xFFD81B60);

  // LOGICA DO BOTÃO CENTRAL
  Widget buildFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const RecordSymptomScreen()));
      },
      backgroundColor: corRosaBotao,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: Colors.white, size: 35),
    );
  }

  // LOGICA DA BARRA INTEIRA
  // `activeTab` destaca visualmente a aba atual ('home', 'calendar', 'contents').
  // Parâmetro opcional para não quebrar telas que já chamam sem argumento.
  Widget buildBottomBar(BuildContext context, {String activeTab = ''}) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // HOME: Volta para o início e limpa tudo
          IconButton(
            icon: const Icon(Icons.home_outlined),
            color: activeTab == 'home' ? corPrimaria : Colors.grey,
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            ),
          ),
          // CALENDÁRIO / CICLO MENSTRUAL
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            color: activeTab == 'calendar' ? corPrimaria : Colors.grey,
            onPressed: () {
              if (activeTab == 'calendar') return;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CycleScreen()),
              );
            },
          ),

          const SizedBox(width: 48), // ESPAÇO DO "+"

          // CONTEÚDOS
          IconButton(
            icon: const Icon(Icons.menu_book),
            color: activeTab == 'contents' ? corPrimaria : Colors.grey,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ConteudosScreen()),
            ),
          ),
          // PERFIL
          IconButton(
            icon: const Icon(Icons.person_outline),
            color: activeTab == 'profile' ? corPrimaria : Colors.grey,
            onPressed: () {
              if (activeTab == 'profile') return;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
