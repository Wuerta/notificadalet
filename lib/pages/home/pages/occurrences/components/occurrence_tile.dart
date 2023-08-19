import 'package:flutter/material.dart';
import 'package:notifica/entities/occurrence.dart';

class OccurrenceTile extends StatelessWidget {
  const OccurrenceTile({
    super.key,
    required this.occurrence,
    this.onTap,
    this.onDismiss,
  });

  final Occurrence occurrence;
  final Function(Occurrence)? onTap;
  final Function(Occurrence)? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(occurrence.id),
      onDismissed: (direction) => onDismiss?.call(occurrence),
      child: ListTile(
        onTap: onTap != null ? () => onTap?.call(occurrence) : null,
        trailing: Icon(occurrence.iconData, color: occurrence.iconColor),
        title: Text(occurrence.title),
        subtitle: Text('Ultima atualização: ${occurrence.date}'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
