import 'package:flutter/material.dart';

import 'game/cards/belote_card.dart';
import 'game/cards/deck.dart';

void main() {
  runApp(const BeloteApp());
}

class BeloteApp extends StatelessWidget {
  const BeloteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Belote Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF116149)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<BeloteCard> _playerHand = const [];

  void _startNewGame() {
    final hands = dealFourHands(createDeck());

    setState(() {
      _playerHand = hands.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Belote Mobile'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Belote',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              const Text('Version locale : Web, puis iOS, puis Android.'),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _startNewGame,
                child: const Text('Nouvelle partie'),
              ),
              if (_playerHand.isNotEmpty) ...[
                const SizedBox(height: 32),
                const Text(
                  'Votre main',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final card in _playerHand)
                      Chip(label: Text(card.label)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
