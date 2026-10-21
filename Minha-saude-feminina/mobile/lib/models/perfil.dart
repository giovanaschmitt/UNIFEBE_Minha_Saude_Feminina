/// Perfil da usuária no back-end (GET/PUT /api/usuarios/me).
class Perfil {
  final String? nome;
  final String email;
  final DateTime? dataNascimento;
  final String? faseVida;

  const Perfil({
    required this.nome,
    required this.email,
    required this.dataNascimento,
    required this.faseVida,
  });

  bool get incompleto => (nome ?? '').isEmpty || dataNascimento == null || faseVida == null;

  /// Rótulo da fase da vida para exibição (ex.: "Idade fértil").
  String? get faseVidaRotulo => faseVida == null ? null : fasesDaVida[faseVida] ?? faseVida;

  int? get idade {
    final nascimento = dataNascimento;
    if (nascimento == null) return null;
    final hoje = DateTime.now();
    var anos = hoje.year - nascimento.year;
    if (hoje.month < nascimento.month || (hoje.month == nascimento.month && hoje.day < nascimento.day)) {
      anos--;
    }
    return anos;
  }

  factory Perfil.fromJson(Map<String, dynamic> json) => Perfil(
        nome: json['nome'] as String?,
        email: json['email'] as String? ?? '',
        dataNascimento:
            json['dataNascimento'] != null ? DateTime.parse(json['dataNascimento'] as String) : null,
        faseVida: json['faseVida'] as String?,
      );
}

/// Fases da vida aceitas pela API (código → rótulo).
const Map<String, String> fasesDaVida = {
  'adolescencia': 'Adolescência',
  'idade_fertil': 'Idade fértil',
  'gestante': 'Gestante',
  'pos_parto': 'Pós-parto',
  'climaterio': 'Climatério',
  'menopausa': 'Menopausa',
};
