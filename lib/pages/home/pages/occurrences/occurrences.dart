import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notifica/constants/images.dart';
import 'package:notifica/entities/occurrence.dart';
import 'package:notifica/pages/home/pages/occurrences/components/occurrence_dialog.dart';
import 'package:notifica/pages/home/pages/occurrences/components/occurrence_tile.dart';

class OccurrencesPage extends StatefulWidget {
  const OccurrencesPage({super.key});

  @override
  State<OccurrencesPage> createState() => _OccurrencesPageState();
}

class _OccurrencesPageState extends State<OccurrencesPage> {
  final fireAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  late final currentUser = fireAuth.currentUser;
  late final occurrencesReference =
      firestore.collection('users/${currentUser?.uid}/occurrences');

  void showOccurrenceDialog(Occurrence occurrence) async {
    final result = await showDialog<OccurrenceStatus>(
      context: context,
      builder: (context) => OccurrenceDialog(occurrence: occurrence),
    );

    if (result != null) {
      int? updatedAt;
      int? closedAt;
      final now = DateTime.now().millisecondsSinceEpoch;

      switch(result) {
        case OccurrenceStatus.opened:
        case OccurrenceStatus.assignned:
          updatedAt = now;
        break;
        case OccurrenceStatus.closedWithError:
        case OccurrenceStatus.closedWithSuccess:
          closedAt = now;
        break;
      }

      await occurrencesReference.doc(occurrence.id).update({
        'status': result.name,
        if (updatedAt != null) 'updatedAt': updatedAt,
        if (closedAt != null) 'closedAt': closedAt,
      });
    }
  }

  Future<void> deleteOccurrence(Occurrence occurrence) async {
    await occurrencesReference.doc(occurrence.id).delete();
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
              child: StreamBuilder(
                stream: occurrencesReference
                    .orderBy('createdAt', descending: true)
                    .withConverter(
                      fromFirestore: Occurrence.fromFirestore,
                      toFirestore: (Occurrence occurrence, _) =>
                          occurrence.toFirestore(),
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.connectionState == ConnectionState.none) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.error != null) {
                    return const Center(
                      child: Text('Occorreu um erro desconhecido!'),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.size <= 0) {
                    return const Center(
                      child: Text('Ainda não temos ocorrências!'),
                    );
                  }

                  final occurrences = snapshot.data!.docs
                      .map(
                        (doc) => doc.data(),
                      )
                      .toList();

                  return ListView.builder(
                    itemCount: occurrences.length,
                    itemBuilder: (context, index) => OccurrenceTile(
                      occurrence: occurrences[index],
                      onTap: showOccurrenceDialog,
                      onDismiss: deleteOccurrence,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
