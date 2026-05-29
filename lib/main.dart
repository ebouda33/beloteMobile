import 'package:flutter/material.dart';
import 'dart:math';

import 'game/cards/belote_card.dart';
import 'game/game_state.dart';
import 'game/ui/game_board_view.dart';

export 'game/ui/game_board_view.dart';

void main() {
  runApp(const BeloteApp());
}

class BeloteApp extends StatelessWidget {
  const BeloteApp({super.key, this.random});

  final Random? random;

  @override
  Widget build(BuildContext context) {
    const forest = Color(0xFF243C32);
    const forestDeep = Color(0xFF182A23);
    const cream = Color(0xFFF4E8D6);
    const paper = Color(0xFFFCF8F1);
    const brass = Color(0xFFC4A15A);
    const burgundy = Color(0xFF7A3636);
    const ink = Color(0xFF2B251F);

    return MaterialApp(
      title: 'Belote Mobile',
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: forest,
          onPrimary: paper,
          primaryContainer: Color(0xFFD6E3D9),
          onPrimaryContainer: forestDeep,
          secondary: burgundy,
          onSecondary: paper,
          secondaryContainer: Color(0xFFE7D1D1),
          onSecondaryContainer: Color(0xFF4A1C1C),
          tertiary: brass,
          onTertiary: forestDeep,
          tertiaryContainer: Color(0xFFF3E2BD),
          onTertiaryContainer: forestDeep,
          error: Color(0xFF9D3C3C),
          onError: paper,
          errorContainer: Color(0xFFF8D9D9),
          onErrorContainer: Color(0xFF6F2424),
          surface: paper,
          onSurface: ink,
          surfaceContainerHighest: Color(0xFFF1E4D2),
          onSurfaceVariant: Color(0xFF5F5347),
          outline: Color(0xFFC9B092),
          outlineVariant: Color(0xFFE1D1BD),
          shadow: Color(0x4D2B251F),
          scrim: Color(0x802B251F),
          inverseSurface: forestDeep,
          onInverseSurface: paper,
          inversePrimary: brass,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: cream,
        fontFamily: 'Georgia',
        appBarTheme: const AppBarTheme(
          backgroundColor: forestDeep,
          foregroundColor: paper,
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: paper,
          ),
        ),
        textTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'Georgia',
          bodyColor: ink,
          displayColor: ink,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: forest,
            foregroundColor: paper,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            textStyle: const TextStyle(
              fontFamily: 'Georgia',
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: forestDeep,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            textStyle: const TextStyle(
              fontFamily: 'Georgia',
              fontWeight: FontWeight.w700,
            ),
            side: const BorderSide(color: brass),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: burgundy,
            textStyle: const TextStyle(
              fontFamily: 'Georgia',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: paper,
          selectedColor: const Color(0xFFF0E3CE),
          disabledColor: const Color(0xFFF7F0E4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color(0xFFD1B88A)),
          ),
          labelStyle: const TextStyle(fontFamily: 'Georgia', color: ink),
          side: const BorderSide(color: Color(0xFFD1B88A)),
        ),
      ),
      home: HomeScreen(random: random),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.random});

  final Random? random;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GameState? _gameState;
  bool _showOpponentCards = false;

  void _startNewGame() {
    setState(() {
      _gameState = createInitialGameState(
        random: widget.random,
      ).resolveAutomaticTrumpTurns().playAutomaticTurns();
      _showOpponentCards = false;
    });
  }

  void _chooseTrump({Suit? trumpSuit}) {
    final gameState = _gameState;
    if (gameState == null) {
      return;
    }

    setState(() {
      _gameState = gameState
          .chooseTrump(trumpSuit: trumpSuit)
          .playAutomaticTurns();
    });
  }

  void _passTrump() {
    final gameState = _gameState;
    if (gameState == null) {
      return;
    }

    setState(() {
      _gameState = gameState
          .passTrump()
          .resolveAutomaticTrumpTurns()
          .playAutomaticTurns();
    });
  }

  Future<void> _showTrumpChoiceDialog() async {
    final gameState = _gameState;
    if (gameState == null) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Votre choix'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gameState.biddingRound == 1
                    ? 'Prendre ${gameState.turnedCard.suit.label} ?'
                    : 'Choisissez une autre couleur que '
                          '${gameState.turnedCard.suit.label}.',
              ),
              const SizedBox(height: 14),
              Center(child: PlayingCardView(card: gameState.turnedCard)),
              if (gameState.biddingRound == 2) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final suit in gameState.availableTrumpSuits)
                      FilledButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          _chooseTrump(trumpSuit: suit);
                        },
                        child: Text('Prendre ${suit.label}'),
                      ),
                  ],
                ),
              ],
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _passTrump();
              },
              child: const Text('Passer'),
            ),
            if (gameState.biddingRound == 1)
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _chooseTrump();
                },
                child: const Text('Prendre'),
              ),
          ],
        );
      },
    );
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
      _gameState = gameState
          .startNextRound(random: widget.random)
          .resolveAutomaticTrumpTurns()
          .playAutomaticTurns();
    });
  }

  Widget _surfacePanel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFCF8F1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFC4A15A).withValues(alpha: 0.45),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A2B251F),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
    );
  }

  @override
  Widget build(BuildContext context) {
    const forestDeep = Color(0xFF182A23);
    const cream = Color(0xFFF4E8D6);
    const paper = Color(0xFFFCF8F1);
    const brass = Color(0xFFC4A15A);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: forestDeep,
        title: const Text('Belote Mobile'),
        actions: [
          IconButton(
            tooltip: _showOpponentCards
                ? 'Masquer les cartes des joueurs'
                : 'Voir les cartes des joueurs',
            onPressed: _gameState == null
                ? null
                : () {
                    setState(() {
                      _showOpponentCards = !_showOpponentCards;
                    });
                  },
            icon: Icon(
              _showOpponentCards
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            color: paper,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: brass.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: brass.withValues(alpha: 0.5)),
                ),
                child: const Text(
                  'Bistrot chic',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: paper,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [cream, Color(0xFFE7D7BF)],
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _surfacePanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Belote',
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Version locale : Web, puis iOS, puis Android.',
                                    ),
                                  ],
                                ),
                              ),
                              FilledButton.icon(
                                onPressed: _startNewGame,
                                icon: const Icon(Icons.local_play_outlined),
                                label: const Text('Nouvelle partie'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (_gameState case final gameState?) ...[
                      const SizedBox(height: 20),
                      GameBoardView(
                        gameState: gameState,
                        onCardTap: _playCard,
                        onTurnedCardTap: _showTrumpChoiceDialog,
                        showOpponentCards: _showOpponentCards,
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _statusPill(
                            gameState.trumpSuit == null
                                ? (gameState.biddingRound == 1
                                      ? 'Atout : a choisir'
                                      : 'Atout : 2e tour')
                                : 'Atout : ${gameState.trumpSuit!.label}',
                          ),
                          _statusPill(
                            'Score ${Team.humanTeam.label} : '
                            '${gameState.gameScore[Team.humanTeam] ?? 0}',
                          ),
                          _statusPill(
                            'Score ${Team.opponentTeam.label} : '
                            '${gameState.gameScore[Team.opponentTeam] ?? 0}',
                          ),
                          if (gameState.trumpTaker case final trumpTaker?)
                            _statusPill('Preneur : ${trumpTaker.label}'),
                          if (gameState.currentPlayer case final currentPlayer?)
                            _statusPill(
                              'Joueur courant : ${currentPlayer.label}',
                            ),
                          _statusPill(
                            'Carte retournee : ${gameState.turnedCard.label}',
                          ),
                          _statusPill(
                            'Plis joues : ${gameState.completedTrickCount}/8',
                          ),
                        ],
                      ),
                      if (gameState.phase == GamePhase.playingTrick ||
                          gameState.phase == GamePhase.roundComplete) ...[
                        const SizedBox(height: 20),
                        _surfacePanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionTitle('Dernier pli'),
                              const SizedBox(height: 12),
                              if (gameState.lastCompletedTrick.isEmpty)
                                const Text('Aucun pli termine pour le moment.')
                              else ...[
                                if (gameState.lastTrickWinner
                                    case final lastTrickWinner?)
                                  Text('Gagnant : ${lastTrickWinner.label}'),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    for (final playedCard
                                        in gameState.lastCompletedTrick)
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          PlayingCardView(
                                            card: playedCard.card,
                                            compact: true,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(playedCard.player.label),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      if (gameState.phase == GamePhase.playingTrick &&
                          gameState.currentPlayer != gameState.humanSeat) ...[
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                            onPressed: _playAutomaticTurns,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Continuer'),
                          ),
                        ),
                      ],
                      if (gameState.phase == GamePhase.roundComplete) ...[
                        const SizedBox(height: 20),
                        _surfacePanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionTitle('Fin de manche'),
                              const SizedBox(height: 12),
                              const Text(
                                'Manche terminee. Points de cartes calcules.',
                              ),
                              const SizedBox(height: 8),
                              if (gameState.takerTeam case final takerTeam?)
                                Text('Equipe preneuse : ${takerTeam.label}'),
                              if (gameState.isContractFulfilled
                                  case final fulfilled?)
                                Text(
                                  fulfilled
                                      ? 'Contrat reussi'
                                      : 'Contrat chute',
                                ),
                              if (gameState.capotTeam case final capotTeam?)
                                Text('Capot : ${capotTeam.label}'),
                              if (gameState.beloteBonusTeam
                                  case final beloteBonusTeam?)
                                Text(
                                  'Belote / rebelote : ${beloteBonusTeam.label} (+20)',
                                ),
                              const SizedBox(height: 12),
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
                                const SizedBox(height: 14),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7ECD8),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: brass),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        gameState.winningTeam == null
                                            ? 'Partie terminee. Egalite.'
                                            : 'Partie terminee. Vainqueur : '
                                                  '${gameState.winningTeam!.label}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Score final - ${Team.humanTeam.label} : '
                                        '${gameState.gameScore[Team.humanTeam] ?? 0}',
                                      ),
                                      Text(
                                        'Score final - ${Team.opponentTeam.label} : '
                                        '${gameState.gameScore[Team.opponentTeam] ?? 0}',
                                      ),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                const SizedBox(height: 14),
                                OutlinedButton.icon(
                                  onPressed: _startNextRound,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Nouvelle manche'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      if (gameState.phase == GamePhase.choosingTrump) ...[
                        const SizedBox(height: 20),
                        _surfacePanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gameState.biddingRound == 1
                                    ? 'Cliquez la carte retournee pour choisir votre atout.'
                                    : 'Premier tour passe. Choisissez une autre couleur.',
                              ),
                              if (_showOpponentCards) ...[
                                const SizedBox(height: 8),
                                const Text('Cartes des joueurs visibles.'),
                              ],
                            ],
                          ),
                        ),
                      ],
                      if (gameState.phase ==
                          GamePhase.waitingForTrumpTaker) ...[
                        const SizedBox(height: 20),
                        _surfacePanel(
                          child: const Text(
                            'Vous avez passe. En attente des autres joueurs.',
                          ),
                        ),
                      ],
                      if (gameState.phase == GamePhase.allPlayersPassed) ...[
                        const SizedBox(height: 20),
                        _surfacePanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tous les joueurs ont passe. Redistribuez.',
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: _startNewGame,
                                icon: const Icon(Icons.shuffle),
                                label: const Text('Redistribuer'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _statusPill(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFF7EFE0),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(
        color: const Color(0xFFC4A15A).withValues(alpha: 0.45),
      ),
    ),
    child: Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
  );
}
