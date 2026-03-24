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
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthFetcher(),
      child: Scaffold(
        backgroundColor: AppColors.grey1,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Consumer<AuthFetcher>(
              builder: (context, auth, _) {
                final state = auth.state;

                if (state is AuthSuccess) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.go('/home');
                  });
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        isSignupMode ? 'Inscription' : 'Connexion',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: AppColors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            children: [
                              TextField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: AppColors.blue,
                                  ),
                                  hintText: 'Adresse email',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: AppColors.blue,
                                  ),
                                  hintText: 'Mot de passe',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (state is AuthError)
                                Column(
                                  children: [
                                    Text(
                                      state.message,
                                      style: const TextStyle(color: Colors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.yellow,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                onPressed: state is AuthLoading
                                    ? null
                                    : () {
                                        final email = emailController.text
                                            .trim();
                                        final password = passwordController.text
                                            .trim();

                                        if (isSignupMode) {
                                          auth.signup(
                                            email: email,
                                            password: password,
                                          );
                                        } else {
                                          auth.login(
                                            email: email,
                                            password: password,
                                          );
                                        }
                                      },
                                child: Text(
                                  isSignupMode ? 'S\'inscrire' : 'Se connecter',
                                  style: const TextStyle(
                                    color: AppColors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: state is AuthLoading
                                    ? null
                                    : () {
                                        setState(
                                          () => isSignupMode = !isSignupMode,
                                        );
                                      },
                                child: Text(
                                  isSignupMode
                                      ? 'Déjà un compte ? Se connecter'
                                      : 'Pas de compte ? Créer un compte',
                                  style: const TextStyle(
                                    color: AppColors.blueDark,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (state is AuthLoading)
                                const CircularProgressIndicator(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
