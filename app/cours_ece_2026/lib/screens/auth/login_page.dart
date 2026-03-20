import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthFetcher(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Connexion')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Consumer<AuthFetcher>(
            builder: (context, auth, _) {
              final state = auth.state;

              if (state is AuthSuccess) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.go('/home');
                });
              }

              return Column(
                children: [
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Mot de passe',
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      auth.login(
                        email: emailController.text,
                        password: passwordController.text,
                      );
                    },
                    child: const Text('Se connecter'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      auth.signup(
                        email: emailController.text,
                        password: passwordController.text,
                      );
                    },
                    child: const Text('Créer un compte'),
                  ),
                  const SizedBox(height: 24),
                  if (state is AuthLoading)
                    const CircularProgressIndicator(),
                  if (state is AuthError)
                    Text(state.message),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}