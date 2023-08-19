import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Objetivo do App:',
            ),
            SizedBox(height: 16),
            Text(
              'Aplicativo desenvolvido em Flutter no curso do IFB, com intuito de permitir que as ocorrências sejam registradas e acompanhadas.',
            ),
            SizedBox(height: 16),
            Text(
              'Desenvolvedores:',
            ),
            SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(),
                SizedBox(width: 8),
                Text('Letícia Baldin Galvani')
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(),
                SizedBox(width: 8),
                Text('Gabriel Felix Huerta Duas Balas Araujo')
              ],
            ),
          ],
        ),
      ),
    );
  }
}
