import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/perfil.dart';
import '../services/api_client.dart';
import '../services/user_service.dart';
import '../utils/date_format_utils.dart';

/// Formulário para completar ou editar o perfil (nome, nascimento e fase da vida).
/// Devolve o [Perfil] salvo ao fechar.
class EditProfileScreen extends StatefulWidget {
  final Perfil? perfil;

  const EditProfileScreen({super.key, this.perfil});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color corPrimaria = Color(0xFFC43A4A);
  static const Color corFundo = Color(0xFFF6F1EE);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  DateTime? _dataNascimento;
  String? _faseVida;
  bool _salvando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    final perfil = widget.perfil;
    _nomeController = TextEditingController(
      text: perfil?.nome ?? FirebaseAuth.instance.currentUser?.displayName ?? '',
    );
    _dataNascimento = perfil?.dataNascimento;
    _faseVida = perfil?.faseVida;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final hoje = DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _dataNascimento ?? DateTime(hoje.year - 25),
      firstDate: DateTime(1920),
      lastDate: hoje.subtract(const Duration(days: 1)),
      locale: const Locale('pt', 'BR'),
      helpText: 'Data de nascimento',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );
    if (escolhida != null) setState(() => _dataNascimento = escolhida);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _salvando = true;
      _erro = null;
    });
    try {
      final nome = _nomeController.text.trim();
      final perfil = await UserService.instance.completarPerfil(
        nome: nome,
        dataNascimento: _dataNascimento,
        faseVida: _faseVida,
      );
      await FirebaseAuth.instance.currentUser?.updateDisplayName(nome);
      if (mounted) Navigator.pop(context, perfil);
    } catch (e) {
      if (mounted) {
        setState(() => _erro = e is ApiException ? e.mensagem : 'Não foi possível salvar o perfil.');
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  InputDecoration _decoracao(String rotulo, IconData icone) => InputDecoration(
        labelText: rotulo,
        prefixIcon: Icon(icone, color: corPrimaria),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      appBar: AppBar(
        backgroundColor: corFundo,
        elevation: 0,
        title: const Text('Meu perfil', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
            children: [
              Text(
                'Esses dados ajudam a mostrar conteúdos e orientações certos para você.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nomeController,
                textCapitalization: TextCapitalization.words,
                maxLength: 100,
                decoration: _decoracao('Nome', Icons.person_outline),
                validator: (valor) => (valor == null || valor.trim().isEmpty) ? 'Informe seu nome.' : null,
              ),
              const SizedBox(height: 6),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _escolherData,
                child: InputDecorator(
                  decoration: _decoracao('Data de nascimento', Icons.cake_outlined),
                  child: Text(
                    _dataNascimento == null ? 'Toque para escolher' : DateFormatUtils.long(_dataNascimento!),
                    style: TextStyle(color: _dataNascimento == null ? Colors.grey.shade500 : Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                initialValue: _faseVida,
                decoration: _decoracao('Fase da vida', Icons.spa_outlined),
                items: [
                  for (final fase in fasesDaVida.entries)
                    DropdownMenuItem(value: fase.key, child: Text(fase.value)),
                ],
                onChanged: (valor) => setState(() => _faseVida = valor),
              ),
              if (_erro != null) ...[
                const SizedBox(height: 14),
                Text(_erro!, style: const TextStyle(color: corPrimaria, fontSize: 13)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _salvando ? null : _salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corPrimaria,
                    disabledBackgroundColor: corPrimaria.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _salvando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
                        )
                      : const Text(
                          'Salvar',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
