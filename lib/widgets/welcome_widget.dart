import 'package:flutter/material.dart';

class WelcomeWidget extends StatelessWidget {
  const WelcomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Olá, Narak Oliveira',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: () {
              debugPrint('Ver meu Plano clicado!');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
            child: const Text('Ver meu Plano'),
          ),
        ],
      ),
    );
  }
}
