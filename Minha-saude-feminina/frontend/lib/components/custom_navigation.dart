import 'package:flutter/material.dart';
import 'package:frontend/screens/home_screen.dart'; // Importante para o botão Home
import 'package:frontend/screens/contents_screen.dart';
import 'package:frontend/screens/record_symptom.dart';

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
  Widget buildBottomBar(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // HOME: Volta para o início e limpa tudo
          IconButton(
            icon: const Icon(Icons.home_outlined),
            color: corPrimaria,
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            ),
          ),
          // CALENDÁRIO
          IconButton(icon: const Icon(Icons.calendar_month_outlined), color: Colors.grey, onPressed: () {}),
          
          const SizedBox(width: 48), // ESPAÇO DO "+"
          
          // CONTEÚDOS
          IconButton(
            icon: const Icon(Icons.menu_book),
            color: Colors.grey,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ConteudosScreen()),
            ),
          ),
          // PERFIL
          IconButton(icon: const Icon(Icons.person_outline), color: Colors.grey, onPressed: () {}),
        ],
      ),
    );
  }
}