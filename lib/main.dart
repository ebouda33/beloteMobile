import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';

import 'game/cards/belote_card.dart';
import 'game/game_state.dart';
import 'game/ui/game_board_view.dart';

export 'game/ui/game_board_view.dart';

void main() {
  runApp(const BeloteApp());
}

const gameTargetScoreOptions = <int>[501, 1000, 2000];
const _aiLevelPreferenceKey = 'home.ai_level';
const _targetScorePreferenceKey = 'home.target_score';

class BeloteApp extends StatelessWidget {
  const BeloteApp({
    super.key,
    this.random,
    this.randomizeDealerSeat = true,
    this.preferences,
  });

  final Random? random;
  final bool randomizeDealerSeat;
  final SharedPreferences? preferences;

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
      home: HomeScreen(
        random: random,
        randomizeDealerSeat: randomizeDealerSeat,
        preferences: preferences,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.random,
    this.randomizeDealerSeat = true,
    this.preferences,
  });

  final Random? random;
  final bool randomizeDealerSeat;
  final SharedPreferences? preferences;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GameState? _gameState;
  bool _showOpponentCards = false;
  bool _showLastTrick = false;
  AiLevel _aiLevel = AiLevel.debutant;
  int _targetScore = defaultTargetScore;
  int _biddingAnimationToken = 0;
  int _trickAnimationToken = 0;
  bool _trumpChoiceDialogOpen = false;
  GameState? _lastTrumpChoicePromptedState;
  SharedPreferences? _preferences;

  @override
  void initState() {
    super.initState();
    unawaited(_loadPreferences());
  }

  Future<void> _loadPreferences() async {
    final preferences =
        widget.preferences ?? await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }

    final savedAiLevelName = preferences.getString(_aiLevelPreferenceKey);
    final savedTargetScore = preferences.getInt(_targetScorePreferenceKey);
    AiLevel? savedAiLevel;
    for (final level in AiLevel.values) {
      if (level.name == savedAiLevelName) {
        savedAiLevel = level;
        break;
      }
    }

    setState(() {
      _preferences = preferences;
      _aiLevel = savedAiLevel ?? _aiLevel;
      _targetScore = gameTargetScoreOptions.contains(savedTargetScore)
          ? savedTargetScore!
          : _targetScore;
    });
  }

  Future<void> _persistSettings() async {
    final preferences =
        _preferences ??
        widget.preferences ??
        await SharedPreferences.getInstance();
    _preferences = preferences;
    await preferences.setString(_aiLevelPreferenceKey, _aiLevel.name);
    await preferences.setInt(_targetScorePreferenceKey, _targetScore);
  }

  Future<void> _startNewGame() async {
    setState(() {
      _gameState = createInitialGameState(
        random: widget.random,
        aiLevel: _aiLevel,
        randomizeDealerSeat: widget.randomizeDealerSeat,
        targetScore: _targetScore,
      );
      _showOpponentCards = false;
      _showLastTrick = false;
      _lastTrumpChoicePromptedState = null;
      _trumpChoiceDialogOpen = false;
    });

    _scheduleTrumpChoicePrompt();
    await _animateAutomaticTrumpBidding();
  }

  Future<void> _chooseTrump({Suit? trumpSuit}) async {
    final gameState = _gameState;
    if (gameState == null) {
      return;
    }

    setState(() {
      _gameState = gameState.chooseTrump(trumpSuit: trumpSuit);
      _lastTrumpChoicePromptedState = null;
    });

    _scheduleTrumpChoicePrompt();
    await _animateAutomaticTrumpBidding();
  }

  Future<void> _passTrump() async {
    final gameState = _gameState;
    if (gameState == null) {
      return;
    }

    setState(() {
      _gameState = gameState.passTrump();
      _lastTrumpChoicePromptedState = null;
    });

    _scheduleTrumpChoicePrompt();
    await _animateAutomaticTrumpBidding();
  }

  void _scheduleTrumpChoicePrompt() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final gameState = _gameState;
      if (gameState == null) {
        return;
      }

      if (gameState.phase == GamePhase.choosingTrump ||
          gameState.phase == GamePhase.waitingForTrumpTaker) {
        unawaited(_showTrumpChoiceDialogAutomatically());
      }
    });
  }

  Future<void> _animateAutomaticTrumpBidding() async {
    final token = ++_biddingAnimationToken;
    const delay = Duration(milliseconds: 420);

    while (mounted) {
      final gameState = _gameState;
      if (gameState == null) {
        return;
      }

      if (gameState.phase != GamePhase.choosingTrump &&
          gameState.phase != GamePhase.waitingForTrumpTaker) {
        break;
      }

      final currentPlayer = gameState.currentPlayer;
      if (currentPlayer == null || currentPlayer == gameState.humanSeat) {
        break;
      }

      await Future<void>.delayed(delay);
      if (!mounted || token != _biddingAnimationToken) {
        return;
      }

      setState(() {
        _gameState = gameState.resolveAutomaticTrumpTurn();
      });
    }

    final gameState = _gameState;
    if (gameState == null || !mounted || token != _biddingAnimationToken) {
      return;
    }

    if (gameState.phase == GamePhase.choosingTrump ||
        gameState.phase == GamePhase.waitingForTrumpTaker) {
      if (gameState.currentPlayer == gameState.humanSeat) {
        _scheduleTrumpChoicePrompt();
        await _showTrumpChoiceDialogAutomatically();
        return;
      }
    }

    await _scheduleAutomaticTrickTurns();
  }

  Future<void> _showTrumpChoiceDialogAutomatically() async {
    final gameState = _gameState;
    if (gameState == null ||
        gameState.currentPlayer != gameState.humanSeat ||
        (gameState.phase != GamePhase.choosingTrump &&
            gameState.phase != GamePhase.waitingForTrumpTaker) ||
        identical(_lastTrumpChoicePromptedState, gameState) ||
        _trumpChoiceDialogOpen) {
      return;
    }

    _lastTrumpChoicePromptedState = gameState;
    _trumpChoiceDialogOpen = true;
    try {
      await _showTrumpChoiceDialog();
    } finally {
      _trumpChoiceDialogOpen = false;
    }
  }

  Future<void> _scheduleAutomaticTrickTurns() async {
    final token = ++_trickAnimationToken;

    while (mounted) {
      final gameState = _gameState;
      if (gameState == null) {
        return;
      }

      if (gameState.phase != GamePhase.playingTrick ||
          gameState.currentPlayer == null ||
          gameState.currentPlayer == gameState.humanSeat) {
        break;
      }

      final delay =
          gameState.currentTrick.isEmpty &&
              gameState.lastTrickWinner != null &&
              gameState.lastTrickWinner != gameState.humanSeat
          ? const Duration(milliseconds: 1300)
          : const Duration(milliseconds: 650);

      await Future<void>.delayed(delay);
      if (!mounted || token != _trickAnimationToken) {
        return;
      }

      setState(() {
        _gameState = gameState.playAutomaticTurns();
      });
    }
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

    unawaited(_scheduleAutomaticTrickTurns());
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
      _showLastTrick = false;
      _lastTrumpChoicePromptedState = null;
    });

    _scheduleTrumpChoicePrompt();
    unawaited(_scheduleAutomaticTrickTurns());
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
                          const SizedBox(height: 16),
                          SegmentedButton<AiLevel>(
                            key: const ValueKey('ai-level-selector'),
                            segments: const [
                              ButtonSegment(
                                value: AiLevel.debutant,
                                label: Text('Debutant'),
                                icon: Icon(Icons.school_outlined),
                              ),
                              ButtonSegment(
                                value: AiLevel.expert,
                                label: Text('Expert'),
                                icon: Icon(Icons.psychology_outlined),
                              ),
                            ],
                            selected: {_aiLevel},
                            onSelectionChanged: (selection) {
                              setState(() {
                                _aiLevel = selection.first;
                              });
                              unawaited(_persistSettings());
                            },
                          ),
                          const SizedBox(height: 12),
                          SegmentedButton<int>(
                            key: const ValueKey('target-score-selector'),
                            segments: const [
                              ButtonSegment(
                                value: 501,
                                label: Text('501'),
                                icon: Icon(Icons.looks_one_outlined),
                              ),
                              ButtonSegment(
                                value: 1000,
                                label: Text('1000'),
                                icon: Icon(Icons.filter_1_outlined),
                              ),
                              ButtonSegment(
                                value: 2000,
                                label: Text('2000'),
                                icon: Icon(Icons.filter_2_outlined),
                              ),
                            ],
                            selected: {_targetScore},
                            onSelectionChanged: (selection) {
                              setState(() {
                                _targetScore = selection.first;
                              });
                              unawaited(_persistSettings());
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(switch (_targetScore) {
                            501 =>
                              'Format court, proche de ce qui se joue souvent en ligne.',
                            1000 =>
                              'Format classique de table, plus long et plus stable.',
                            2000 =>
                              'Format long pour une vraie session locale.',
                            _ => 'Score cible personnalise.',
                          }, style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    if (_gameState case final gameState?) ...[
                      const SizedBox(height: 20),
                      GameBoardView(
                        gameState: gameState,
                        onCardTap: _playCard,
                        showOpponentCards: _showOpponentCards,
                        showLastTrick: _showLastTrick,
                        onToggleLastTrick: () {
                          setState(() {
                            _showLastTrick = !_showLastTrick;
                          });
                        },
                        onStartNextRound: _startNextRound,
                        onToggleOpponentCards: () {
                          setState(() {
                            _showOpponentCards = !_showOpponentCards;
                          });
                        },
                        showOpponentCardsActionLabel: _showOpponentCards
                            ? 'Masquer les cartes des joueurs'
                            : 'Voir les cartes des joueurs',
                      ),
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
