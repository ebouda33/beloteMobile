import 'package:flutter/material.dart';

import 'game/cards/belote_card.dart';
import 'game/game_state.dart';

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
  GameState? _gameState;

  void _startNewGame() {
    setState(() {
      _gameState = createInitialGameState();
    });
  }

  void _chooseTrump() {
    final gameState = _gameState;
    if (gameState == null) {
      return;
    }

    setState(() {
      _gameState = gameState.chooseTrump();
    });
  }

  void _passTrump() {
    final gameState = _gameState;
    if (gameState == null) {
      return;
    }

    setState(() {
      _gameState = gameState.passTrump().passRemainingPlayers();
    });
  }

  void _playCard(BeloteCard card) {
    final gameState = _gameState;
    if (gameState == null) {
      return;
    }

    setState(() {
      _gameState = gameState.playCard(card).playAutomaticTurns();
    });
  }

  void _playAutomaticTurns() {
    final gameState = _gameState;
    if (gameState == null) {
      return;
    }

    setState(() {
      _gameState = gameState.playAutomaticTurns();
    });
  }

  void _startNextRound() {
    final gameState = _gameState;
    if (gameState == null) {
      return;
    }

    setState(() {
      _gameState = gameState.startNextRound();
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
        child: SingleChildScrollView(
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
              if (_gameState case final gameState?) ...[
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
                    for (final card in gameState.humanHand)
                      if (gameState
                          .playableCards(gameState.humanSeat)
                          .contains(card))
                        ActionChip(
                          label: Text(card.label),
                          onPressed: () => _playCard(card),
                        )
                      else
                        Chip(label: Text(card.label)),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  gameState.trumpSuit == null
                      ? 'Atout : a choisir'
                      : 'Atout : ${gameState.trumpSuit!.label}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Score partie - ${Team.humanTeam.label} : '
                  '${gameState.gameScore[Team.humanTeam] ?? 0}',
                ),
                Text(
                  'Score partie - ${Team.opponentTeam.label} : '
                  '${gameState.gameScore[Team.opponentTeam] ?? 0}',
                ),
                if (gameState.trumpTaker case final trumpTaker?) ...[
                  const SizedBox(height: 8),
                  Text('Preneur : ${trumpTaker.label}'),
                ],
                if (gameState.currentPlayer case final currentPlayer?) ...[
                  const SizedBox(height: 8),
                  Text('Joueur courant : ${currentPlayer.label}'),
                ],
                const SizedBox(height: 8),
                Text('Carte retournee : ${gameState.turnedCard.label}'),
                if (gameState.phase == GamePhase.playingTrick ||
                    gameState.phase == GamePhase.roundComplete) ...[
                  const SizedBox(height: 24),
                  Text('Plis joues : ${gameState.completedTrickCount}/8'),
                  const SizedBox(height: 8),
                  Text(
                    '${Team.humanTeam.label} : '
                    '${gameState.wonTricks[Team.humanTeam]?.length ?? 0}',
                  ),
                  Text(
                    '${Team.opponentTeam.label} : '
                    '${gameState.wonTricks[Team.opponentTeam]?.length ?? 0}',
                  ),
                ],
                if (gameState.currentTrick.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Pli en cours',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final playedCard in gameState.currentTrick)
                        Chip(
                          label: Text(
                            '${playedCard.player.label} : ${playedCard.card.label}',
                          ),
                        ),
                    ],
                  ),
                ],
                if (gameState.lastCompletedTrick.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Dernier pli',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  if (gameState.lastTrickWinner case final lastTrickWinner?)
                    Text('Gagnant : ${lastTrickWinner.label}'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final playedCard in gameState.lastCompletedTrick)
                        Chip(
                          label: Text(
                            '${playedCard.player.label} : ${playedCard.card.label}',
                          ),
                        ),
                    ],
                  ),
                ],
                if (gameState.phase == GamePhase.playingTrick &&
                    gameState.currentPlayer != gameState.humanSeat) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _playAutomaticTurns,
                    child: const Text('Continuer'),
                  ),
                ],
                if (gameState.phase == GamePhase.roundComplete) ...[
                  const SizedBox(height: 12),
                  const Text('Manche terminee. Points de cartes calcules.'),
                  const SizedBox(height: 8),
                  if (gameState.takerTeam case final takerTeam?)
                    Text('Equipe preneuse : ${takerTeam.label}'),
                  if (gameState.isContractFulfilled case final fulfilled?)
                    Text(fulfilled ? 'Contrat reussi' : 'Contrat chute'),
                  if (gameState.capotTeam case final capotTeam?)
                    Text('Capot : ${capotTeam.label}'),
                  Text(
                    'Points ${Team.humanTeam.label} : '
                    '${gameState.roundPoints[Team.humanTeam] ?? 0}',
                  ),
                  Text(
                    'Points ${Team.opponentTeam.label} : '
                    '${gameState.roundPoints[Team.opponentTeam] ?? 0}',
                  ),
                  Text(
                    'Score ${Team.humanTeam.label} : '
                    '${gameState.roundScore[Team.humanTeam] ?? 0}',
                  ),
                  Text(
                    'Score ${Team.opponentTeam.label} : '
                    '${gameState.roundScore[Team.opponentTeam] ?? 0}',
                  ),
                  if (gameState.isGameComplete) ...[
                    const SizedBox(height: 12),
                    const Text('Partie terminee.'),
                  ] else ...[
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _startNextRound,
                      child: const Text('Nouvelle manche'),
                    ),
                  ],
                ],
                if (gameState.phase == GamePhase.choosingTrump) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: _chooseTrump,
                        child: Text(
                          'Prendre ${gameState.turnedCard.suit.label}',
                        ),
                      ),
                      TextButton(
                        onPressed: _passTrump,
                        child: const Text('Passer'),
                      ),
                    ],
                  ),
                ],
                if (gameState.phase == GamePhase.waitingForTrumpTaker) ...[
                  const SizedBox(height: 12),
                  const Text('Vous avez passe. En attente des autres joueurs.'),
                ],
                if (gameState.phase == GamePhase.allPlayersPassed) ...[
                  const SizedBox(height: 12),
                  const Text('Tous les joueurs ont passe. Redistribuez.'),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _startNewGame,
                    child: const Text('Redistribuer'),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
