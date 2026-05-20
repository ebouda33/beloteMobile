enum Suit { clubs, diamonds, hearts, spades }

enum Rank { seven, eight, nine, jack, queen, king, ten, ace }

extension SuitLabel on Suit {
  String get label {
    return switch (this) {
      Suit.clubs => 'Trefle',
      Suit.diamonds => 'Carreau',
      Suit.hearts => 'Coeur',
      Suit.spades => 'Pique',
    };
  }
}

extension RankLabel on Rank {
  String get label {
    return switch (this) {
      Rank.seven => '7',
      Rank.eight => '8',
      Rank.nine => '9',
      Rank.jack => 'Valet',
      Rank.queen => 'Dame',
      Rank.king => 'Roi',
      Rank.ten => '10',
      Rank.ace => 'As',
    };
  }
}

class BeloteCard {
  const BeloteCard({required this.suit, required this.rank});

  final Suit suit;
  final Rank rank;

  String get id => '${suit.name}-${rank.name}';

  String get label => '${rank.label} de ${suit.label}';

  bool isTrump(Suit trumpSuit) => suit == trumpSuit;

  int points({required Suit trumpSuit}) {
    if (isTrump(trumpSuit)) {
      return switch (rank) {
        Rank.jack => 20,
        Rank.nine => 14,
        Rank.ace => 11,
        Rank.ten => 10,
        Rank.king => 4,
        Rank.queen => 3,
        Rank.eight || Rank.seven => 0,
      };
    }

    return switch (rank) {
      Rank.ace => 11,
      Rank.ten => 10,
      Rank.king => 4,
      Rank.queen => 3,
      Rank.jack => 2,
      Rank.nine || Rank.eight || Rank.seven => 0,
    };
  }

  int strength({required Suit trumpSuit}) {
    if (isTrump(trumpSuit)) {
      return switch (rank) {
        Rank.jack => 8,
        Rank.nine => 7,
        Rank.ace => 6,
        Rank.ten => 5,
        Rank.king => 4,
        Rank.queen => 3,
        Rank.eight => 2,
        Rank.seven => 1,
      };
    }

    return switch (rank) {
      Rank.ace => 8,
      Rank.ten => 7,
      Rank.king => 6,
      Rank.queen => 5,
      Rank.jack => 4,
      Rank.nine => 3,
      Rank.eight => 2,
      Rank.seven => 1,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is BeloteCard && other.suit == suit && other.rank == rank;
  }

  @override
  int get hashCode => Object.hash(suit, rank);

  @override
  String toString() => label;
}
