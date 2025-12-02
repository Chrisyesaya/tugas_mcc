import 'package:flutter/material.dart';

class ReaderScreen extends StatelessWidget {
  final String title;
  final String content;

  const ReaderScreen({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          content,
          style: const TextStyle(fontSize: 18, height: 1.5),
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }
}