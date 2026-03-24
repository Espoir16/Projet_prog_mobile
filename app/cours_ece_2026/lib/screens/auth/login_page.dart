import 'package:flutter/material.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/screens/auth/auth_fetcher.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isSignupMode = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthFetcher(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Consumer<AuthFetcher>(
            builder: (context, auth, _) {
              final state = auth.state;

              if (state is AuthSuccess) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.go('/home');
                });
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          children: [
                            SizedBox(
                              height: constraints.maxHeight * 0.37,
                              child: Center(
                                child: Text(
                                  isSignupMode ? 'Inscription' : 'Connexion',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.blue,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                            ),
                            _AuthTextField(
                              controller: emailController,
                              hintText: 'Adresse email',
                              icon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 12),
                            _AuthTextField(
                              controller: passwordController,
                              hintText: 'Mot de passe',
                              icon: Icons.lock,
                              obscureText: true,
                            ),
                            const SizedBox(height: 34),
                            if (state is AuthError)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            if (isSignupMode)
                              _AuthButton(
                                label: 'S\'inscrire',
                                onPressed: state is AuthLoading
                                    ? null
                                    : () => _submit(auth, signup: true),
                              )
                            else ...[
                              _AuthButton(
                                label: 'Créer un compte',
                                onPressed: state is AuthLoading
                                    ? null
                                    : () {
                                        setState(() => isSignupMode = true);
                                      },
                              ),
                              const SizedBox(height: 14),
                              _AuthButton(
                                label: 'Se connecter',
                                onPressed: state is AuthLoading
                                    ? null
                                    : () => _submit(auth, signup: false),
                              ),
                            ],
                            const SizedBox(height: 18),
                            if (isSignupMode)
                              TextButton(
                                onPressed: state is AuthLoading
                                    ? null
                                    : () {
                                        setState(() => isSignupMode = false);
                                      },
                                child: const Text(
                                  'Deja un compte ? Se connecter',
                                  style: TextStyle(color: AppColors.blueDark),
                                ),
                              ),
                            if (state is AuthLoading) ...[
                              const SizedBox(height: 12),
                              const CircularProgressIndicator(),
                            ],
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _submit(AuthFetcher auth, {required bool signup}) {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (signup) {
      auth.signup(email: email, password: password);
    } else {
      auth.login(email: email, password: password);
    }
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.blue),
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.grey2),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD9DCE6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.blue),
        ),
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  const _AuthButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 176,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.yellow,
          foregroundColor: AppColors.blue,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.visible,
                softWrap: false,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward, size: 22),
          ],
        ),
      ),
    );
  }
}
