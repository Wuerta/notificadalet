import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmationController = TextEditingController();
  final fireAuth = FirebaseAuth.instance;

  bool showPassword = false;
  bool showPasswordConfirmation = false;
  bool loadingCreateAccount = false;

  Future<void> createAccount() async {
    if (loadingCreateAccount) return;
    setState(() => loadingCreateAccount = true);

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    const genericErrorMessage = 'Ocorreu um erro ao criar conta';

    try {
      final credentials = await fireAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credentials.user?.updateDisplayName(name);
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Conta criada com sucesso!',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          duration: const Duration(milliseconds: 2000),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
      );
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
    setState(() => loadingCreateAccount = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
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
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        filled: true,
                        labelText: 'Nome',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo obrigatório';
                        }

                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
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
                      textInputAction: TextInputAction.next,
                      obscureText: !showPassword,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordConfirmationController,
                      decoration: InputDecoration(
                        filled: true,
                        labelText: 'Confirmar senha',
                        suffixIcon: IconButton(
                          onPressed: () => setState(() {
                            showPasswordConfirmation =
                                !showPasswordConfirmation;
                          }),
                          icon: Icon(
                            showPasswordConfirmation
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo obrigatório';
                        }

                        if (value != passwordController.text) {
                          return 'A senha não corresponde';
                        }

                        return null;
                      },
                      onFieldSubmitted: (value) {
                        if (formKey.currentState!.validate()) {
                          createAccount();
                        }
                      },
                      textInputAction: TextInputAction.send,
                      obscureText: !showPasswordConfirmation,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.maxFinite,
                      child: ElevatedButton(
                        onPressed: !loadingCreateAccount
                            ? () {
                                if (formKey.currentState!.validate()) {
                                  createAccount();
                                }
                              }
                            : null,
                        child: const Text('Criar conta'),
                      ),
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
