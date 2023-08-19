import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notifica/entities/occurrence.dart';

class OccurrenceDialog extends StatefulWidget {
  const OccurrenceDialog({super.key, required this.occurrence});

  final Occurrence occurrence;

  @override
  State<OccurrenceDialog> createState() => _OccurrenceDialogState();
}

class _OccurrenceDialogState extends State<OccurrenceDialog> {
  late Set<OccurrenceStatus> selectedStatus = {widget.occurrence.status};

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.occurrence.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(widget.occurrence.description),
            const SizedBox(height: 16),
            SegmentedButton<OccurrenceStatus>(
              selected: selectedStatus,
              multiSelectionEnabled: false,
              showSelectedIcon: false,
              emptySelectionAllowed: false,
              onSelectionChanged: (selection) => setState(
                () => selectedStatus = selection,
              ),
              segments: const [
                ButtonSegment(
                  value: OccurrenceStatus.opened,
                  label: Icon(
                    Icons.pending_actions,
                    color: Colors.orange,
                  ),
                ),
                ButtonSegment(
                  value: OccurrenceStatus.assignned,
                  label: Icon(
                    Icons.pending,
                    color: Colors.blue,
                  ),
                ),
                ButtonSegment(
                  value: OccurrenceStatus.closedWithError,
                  label: Icon(
                    Icons.error,
                    color: Colors.red,
                  ),
                ),
                ButtonSegment(
                  value: OccurrenceStatus.closedWithSuccess,
                  label: Icon(
                    Icons.done,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => context.pop(selectedStatus.first),
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
