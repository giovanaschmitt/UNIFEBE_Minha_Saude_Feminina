import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/sign_up_screen.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    "Seja bem vinda!",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Faça o login com seu email e senha \nou continue com o Google",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  const SignInForm(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),

                  const GoogleSignInButton(),

                  const SizedBox(height: 20),
                  const NoAccountText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


const authOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFF757575)),
  borderRadius: BorderRadius.all(Radius.circular(100)),
);

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_mapAuthError(e))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Email inválido.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou senha incorretos.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      default:
        return e.message ?? 'Erro ao fazer login.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            validator: (v) {
              final value = (v ?? '').trim();
              if (value.isEmpty) return 'Informe seu email';
              if (!value.contains('@') || !value.contains('.')) {
                return 'Email inválido';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: "Insira seu email",
              labelText: "Email",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintStyle: const TextStyle(color: Color(0xFF757575)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: SvgPicture.string(mailIcon),
              ),
              border: authOutlineInputBorder,
              enabledBorder: authOutlineInputBorder,
              focusedBorder: authOutlineInputBorder.copyWith(
                borderSide: const BorderSide(color: Color(0xFFC43A4A)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          //senha
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onFieldSubmitted: (_) => _signIn(),
            validator: (v) {
              if ((v ?? '').isEmpty) return 'Informe sua senha';
              if ((v ?? '').length < 6) {
                return 'A senha deve ter pelo menos 6 caracteres';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: "Insira sua senha",
              labelText: "Senha",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintStyle: const TextStyle(color: Color(0xFF757575)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF757575),
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: authOutlineInputBorder,
              enabledBorder: authOutlineInputBorder,
              focusedBorder: authOutlineInputBorder.copyWith(
                borderSide: const BorderSide(color: Color(0xFFC43A4A)),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _loading ? null : () => _forgotPassword(context),
              child: const Text(
                'Esqueceu a senha?',
                style: TextStyle(color: Color(0xFFC43A4A)),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // botão entrar
          ElevatedButton(
            onPressed: _loading ? null : _signIn,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFFC43A4A),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(100)),
              ),
            ),
            child: _loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.4,
                    ),
                  )
                : const Text("Entrar", style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Future<void> _forgotPassword(BuildContext context) async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite seu email no campo acima primeiro.'),
        ),
      );
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email de redefinição enviado para $email.')),
      );
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_mapAuthError(e))),
      );
    }
  }
}

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _loading = false;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize();
    _initialized = true;
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      await _ensureInitialized();
      final googleUser = await GoogleSignIn.instance.authenticate();
      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'missing-id-token',
          message: 'Não foi possível obter o token do Google.',
        );
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on GoogleSignInException catch (e) {
      if (!mounted) return;
      if (e.code == GoogleSignInExceptionCode.canceled) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro no login Google: ${e.description ?? e.code.name}')),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Erro ao autenticar.')),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Google sign-in error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro inesperado ao entrar com Google.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SocalCard(
          icon: _loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : SvgPicture.string(googleIcon),
          press: _loading ? () {} : _signInWithGoogle,
        ),
      ],
    );
  }
}

class SocalCard extends StatelessWidget {
  const SocalCard({super.key, required this.icon, required this.press});

  final Widget icon;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        padding: const EdgeInsets.all(12),
        height: 56,
        width: 56,
        decoration: const BoxDecoration(
          color: Color(0xFFF5F6F9),
          shape: BoxShape.circle,
        ),
        child: icon,
      ),
    );
  }
}

class NoAccountText extends StatelessWidget {
  const NoAccountText({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Não tem uma conta? ",
          style: TextStyle(color: Color(0xFF757575)),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SignUpScreen()),
            );
          },
          child: const Text(
            "Cadastre-se",
            style: TextStyle(
              color: Color(0xFFC43A4A),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}


const mailIcon =
    '''<svg width="18" height="13" viewBox="0 0 18 13" fill="none" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" clip-rule="evenodd" d="M15.3576 3.39368C15.5215 3.62375 15.4697 3.94447 15.2404 4.10954L9.80876 8.03862C9.57272 8.21053 9.29421 8.29605 9.01656 8.29605C8.7406 8.29605 8.4638 8.21138 8.22775 8.04204L2.76041 4.11039C2.53201 3.94618 2.47851 3.62546 2.64154 3.39454C2.80542 3.16362 3.12383 3.10974 3.35223 3.27566L8.81872 7.20645C8.93674 7.29112 9.09552 7.29197 9.2144 7.20559L14.6469 3.27651C14.8753 3.10974 15.1937 3.16447 15.3576 3.39368ZM16.9819 10.7763C16.9819 11.4366 16.4479 11.9745 15.7932 11.9745H2.20765C1.55215 11.9745 1.01892 11.4366 1.01892 10.7763V2.22368C1.01892 1.56342 1.55215 1.02632 2.20765 1.02632H15.7932C16.4479 1.02632 16.9819 1.56342 16.9819 2.22368V10.7763ZM15.7932 0H2.20765C0.990047 0 0 0.998092 0 2.22368V10.7763C0 12.0028 0.990047 13 2.20765 13H15.7932C17.01 13 18 12.0028 18 10.7763V2.22368C18 0.998092 17.01 0 15.7932 0Z" fill="#757575"/></svg>''';
const lockIcon =
    '''<svg width="15" height="18" viewBox="0 0 15 18" fill="none" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" clip-rule="evenodd" d="M9.24419 11.5472C9.24419 12.4845 8.46279 13.2453 7.5 13.2453C6.53721 13.2453 5.75581 12.4845 5.75581 11.5472C5.75581 10.6098 6.53721 9.84906 7.5 9.84906C8.46279 9.84906 9.24419 10.6098 9.24419 11.5472ZM13.9535 14.0943C13.9535 15.6863 12.6235 16.9811 10.9884 16.9811H4.01163C2.37645 16.9811 1.04651 15.6863 1.04651 14.0943V9C1.04651 7.40802 2.37645 6.11321 4.01163 6.11321H10.9884C12.6235 6.11321 13.9535 7.40802 13.9535 9V14.0943ZM4.53488 3.90566C4.53488 2.31368 5.86483 1.01887 7.5 1.01887C8.28488 1.01887 9.03139 1.31943 9.59477 1.86028C10.1564 2.41387 10.4651 3.14066 10.4651 3.90566V5.09434H4.53488V3.90566ZM11.5116 5.12745V3.90566C11.5116 2.87151 11.0956 1.89085 10.3352 1.14028C9.5686 0.405 8.56221 0 7.5 0C5.2875 0 3.48837 1.7516 3.48837 3.90566V5.12745C1.52267 5.37792 0 7.01915 0 9V14.0943C0 16.2484 1.79913 18 4.01163 18H10.9884C13.2 18 15 16.2484 15 14.0943V9C15 7.01915 13.4773 5.37792 11.5116 5.12745Z" fill="#757575"/></svg>''';
const googleIcon =
    '''<svg width="16" height="17" viewBox="0 0 16 17" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M15.9988 8.3441C15.9988 7.67295 15.9443 7.18319 15.8265 6.67529H8.1626V9.70453H12.6611C12.5705 10.4573 12.0807 11.5911 10.9923 12.3529L10.9771 12.4543L13.4002 14.3315L13.5681 14.3482C15.1099 12.9243 15.9988 10.8292 15.9988 8.3441Z" fill="#4285F4"/><path d="M8.16265 16.3254C10.3666 16.3254 12.2168 15.5998 13.5682 14.3482L10.9924 12.3528C10.3031 12.8335 9.37796 13.1691 8.16265 13.1691C6.00408 13.1691 4.17202 11.7452 3.51894 9.7771L3.42321 9.78523L0.903556 11.7352L0.870605 11.8268C2.2129 14.4933 4.9701 16.3254 8.16265 16.3254Z" fill="#34A853"/><path d="M3.519 9.77716C3.34668 9.26927 3.24695 8.72505 3.24695 8.16275C3.24695 7.6004 3.34668 7.05624 3.50994 6.54834L3.50537 6.44017L0.954141 4.45886L0.870669 4.49857C0.317442 5.60508 0 6.84765 0 8.16275C0 9.47785 0.317442 10.7204 0.870669 11.8269L3.519 9.77716Z" fill="#FBBC05"/><path d="M8.16265 3.15623C9.69541 3.15623 10.7293 3.81831 11.3189 4.3716L13.6226 2.12231C12.2077 0.807206 10.3666 0 8.16265 0C4.9701 0 2.2129 1.83206 0.870605 4.49853L3.50987 6.54831C4.17202 4.58019 6.00408 3.15623 8.16265 3.15623Z" fill="#EB4335"/></svg>''';
