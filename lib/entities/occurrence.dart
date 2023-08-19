import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum OccurrenceStatus { opened, assignned, closedWithError, closedWithSuccess }

class Occurrence {
  const Occurrence({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.closedAt,
  });

  final String title;
  final String description;
  final String id;
  final OccurrenceStatus status;
  final int createdAt;
  final int? updatedAt;
  final int? closedAt;

  IconData get iconData {
    switch (status) {
      case OccurrenceStatus.opened:
        return Icons.pending_actions;
      case OccurrenceStatus.assignned:
        return Icons.pending;
      case OccurrenceStatus.closedWithSuccess:
        return Icons.done;
      case OccurrenceStatus.closedWithError:
        return Icons.error;
    }
  }

  Color get iconColor {
    switch (status) {
      case OccurrenceStatus.opened:
        return Colors.orange;
      case OccurrenceStatus.assignned:
        return Colors.blue;
      case OccurrenceStatus.closedWithSuccess:
        return Colors.green;
      case OccurrenceStatus.closedWithError:
        return Colors.red;
    }
  }

  String get date {
    final formatter = DateFormat("dd/MM/yyyy 'às' HH:mm");

    switch (status) {
      case OccurrenceStatus.opened:
        final date = DateTime.fromMillisecondsSinceEpoch(createdAt);
        return formatter.format(date);
      case OccurrenceStatus.assignned:
        final date = DateTime.fromMillisecondsSinceEpoch(updatedAt!);
        return formatter.format(date);
      case OccurrenceStatus.closedWithSuccess:
      case OccurrenceStatus.closedWithError:
        final date = DateTime.fromMillisecondsSinceEpoch(closedAt!);
        return formatter.format(date);
    }
  }

  factory Occurrence.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Occurrence(
        id: snapshot.id,
        title: data?['title'] ?? 'Sem título',
        description: data?['description'] ?? 'Sem descrição',
        status: OccurrenceStatus.values.firstWhere(
          (status) => status.name == (data?['status'] ?? 'opened'),
        ),
        createdAt: data?['createdAt'] ?? 0,
        updatedAt: data?['updatedAt'],
        closedAt: data?['closedAt']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'status': status.name,
      'createdAt': createdAt,
    };
  }
}
