import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notifica/constants/images.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fireAuth = FirebaseAuth.instance;

  bool showPassword = false;
  bool loadingLogin = false;

  Future<void> login() async {
    if (loadingLogin) return;
    setState(() => loadingLogin = true);

    final email = emailController.text.trim();
    final password = passwordController.text;
    const genericErrorMessage = 'Ocorreu um erro ao realizar login';

    try {
      await fireAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;
      context.go('/home/occurrences');
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message ?? genericErrorMessage,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          duration: const Duration(milliseconds: 4000),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            genericErrorMessage,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          duration: const Duration(milliseconds: 4000),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }

    if (!mounted) return;
    setState(() => loadingLogin = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.maxFinite,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      Theme.of(context).brightness == Brightness.light
                          ? loginImageLight
                          : loginImageDark,
                    ),
                    const SizedBox(height: 8),
                    const Text('Registre e gerencie as ocorrências do seu IF.'),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        filled: true,
                        labelText: 'Email',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo obrigatório';
                        }

                        if (!EmailValidator.validate(value)) {
                          return 'Email inválido';
                        }

                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        filled: true,
                        labelText: 'Senha',
                        suffixIcon: IconButton(
                          onPressed: () => setState(() {
                            showPassword = !showPassword;
                          }),
                          icon: Icon(
                            showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo obrigatório';
                        }

                        return null;
                      },
                      onFieldSubmitted: (value) {
                        if (formKey.currentState!.validate()) {
                          login();
                        }
                      },
                      textInputAction: TextInputAction.send,
                      obscureText: !showPassword,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.maxFinite,
                      child: ElevatedButton(
                        onPressed: !loadingLogin
                            ? () {
                                if (formKey.currentState!.validate()) {
                                  login();
                                }
                              }
                            : null,
                        child: const Text('Entrar'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Não possui conta?'),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            context.push('/createAccount');
                          },
                          child: Text(
                            'Clique aqui!',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
