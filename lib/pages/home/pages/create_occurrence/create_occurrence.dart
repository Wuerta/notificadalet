import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notifica/constants/images.dart';
import 'package:notifica/entities/occurrence.dart';

class CreateOccurrencePage extends StatefulWidget {
  const CreateOccurrencePage({super.key});

  @override
  State<CreateOccurrencePage> createState() => _CreateOccurrencePageState();
}

class _CreateOccurrencePageState extends State<CreateOccurrencePage> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final fireAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  bool loadingOccurrence = false;

  Future<void> addOccurrence() async {
    if (loadingOccurrence) return;
    setState(() => loadingOccurrence = true);

    final currentUser = fireAuth.currentUser;
    final occurrencesReference = firestore
        .collection('users/${currentUser?.uid}/occurrences')
        .withConverter(
          fromFirestore: Occurrence.fromFirestore,
          toFirestore: (Occurrence occurrence, _) => occurrence.toFirestore(),
        );

    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final createdAt = DateTime.now().millisecondsSinceEpoch;
    final occurrence = Occurrence(
      id: '',
      title: title,
      description: description,
      status: OccurrenceStatus.opened,
      createdAt: createdAt,
    );

    try {
      await occurrencesReference.add(occurrence);

      if (!mounted) return;
      context.go('/home/occurrences');
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Occorrência adicionada com sucesso!',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          duration: const Duration(milliseconds: 2000),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Occorreu um erro desconhecido!',
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
    setState(() => loadingOccurrence = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: SizedBox(
        width: double.maxFinite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              Theme.of(context).brightness == Brightness.light
                  ? logoLight
                  : logoDark,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            filled: true,
                            labelText: 'Título',
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
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            filled: true,
                            labelText: 'Descrição',
                          ),
                          maxLines: 6,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Campo obrigatório';
                            }

                            return null;
                          },
                          onFieldSubmitted: (value) {
                            if (formKey.currentState!.validate()) {
                              addOccurrence();
                            }
                          },
                          textInputAction: TextInputAction.send,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.maxFinite,
                          child: ElevatedButton(
                            onPressed: !loadingOccurrence
                                ? () {
                                    if (formKey.currentState!.validate()) {
                                      addOccurrence();
                                    }
                                  }
                                : null,
                            child: const Text('Adicionar Ocorrência'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
