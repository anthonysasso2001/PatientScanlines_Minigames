import 'dart:math';

import 'package:pslines_solitaire/pslines_solitaire.dart';

/// Preset rules for the three main categories of solitaire game, plus italian solitaire to demonstrate alternate decks.

final frenchDeckRule = CardRule(4, 13);

final scopaDeckRule = CardRule(4, 10);

/// Generic rule for draw deck, blocks anything from placing onto it... essentially read only
class GenericDrawDeckRule extends RegionRule {
  GenericDrawDeckRule(RegionType inRType, CardOrder inOrder)
      : super(inRType, inOrder);

  @override
  bool checkPlacement(List<Card> nCards, RegionType pRType, Card? cEnd,
      [int? moveLim]) {
    return false;
  }
}

/// Generic rule for draw deck that cycles, only lets you cycle when cycle limit <= max and cend is null (nothing left in draw), and the cards being cycles are from a "draw deck" as well.
class GenericCycleDeckRule extends RegionRule {
  final int _cycleLim;
  int cycleCount = 0;
  GenericCycleDeckRule(RegionType inRType, CardOrder inOrder, int inCycleLim)
      : _cycleLim = inCycleLim,
        super(inRType, inOrder);

  @override
  bool checkPlacement(List<Card> nCards, RegionType pRType, Card? cEnd,
      [int? moveLim]) {
    // First check if any values in new cards are null.
    if (!initCheck(nCards, pRType, cEnd)) {
      return false;
    } else if (cEnd != null ||
        cycleCount >= _cycleLim ||
        pRType != RegionType.drawDeck) {
      // if new cards are ok check that draw deck is empty, cycle limit has not been reached, and the cards are also of type draw deck.
      return false;
    }

    // Otherwise, cycle is valid
    return true;
  }
}

/// Generic rule for graveyard, essentially it will always allow cards to be placed.
class GenericGraveyardRule extends RegionRule {
  GenericGraveyardRule(RegionType inRType, CardOrder inOrder)
      : super(inRType, inOrder);

  @override
  bool checkPlacement(List<Card> nCards, RegionType pRType, Card? cEnd,
      [int? moveLim]) {
    return true;
  }
}

class GenericStripedRule extends RegionRule {
  GenericStripedRule(RegionType inRType, CardOrder inOrder)
      : super(inRType, inOrder);

  @override
  bool checkPlacement(List<Card> nCards, RegionType pRType, Card? cEnd,
      [int? moveLim]) {
    // First check that new cards are not null, then check that the suit color is different
    if (nCards
        .any((element) => (element.suit == null || element.value == null))) {
      return false;
    }
    // check that there is a move limit (ignore for games like klondike, and that there are less cards being moved)
    if (moveLim != null && nCards.length >= moveLim) {
      return false;
    }

    // Now get the difference between the suits, if the difference is odd, then they are different colours.
    // ex: french suit (spade [black]=0, heart [red]=1, clubs [black]=2, diamonds [red]=3)
    //  if largest suit is a  diamond:
    //    3 - 3 = 0, d + d = invalid
    //    3 - 2 = 1, d + c = valid
    //    3 - 1 = 2, d + h = invalid
    //    3 - 0 = 3, d + s = valid
    // if largest suit is a club:
    //    2 - 2 = 0, c + c = invalid
    //    2 - 1 = 1, c + h = valid
    //    2 - 0 = 2, c + s = invalid
    // if largest suit is a heart:
    //    1 - 1 = 0, h + h = invalid
    //    1 - 0 = 1, h + s = valid
    var diff = max<int>(cEnd!.suit!, nCards.first.suit!) -
        min<int>(cEnd.suit!, nCards.first.suit!);
    if (diff.isOdd) {
      return true;
    }

    return false;
  }
}

class GenericSuitedRule extends RegionRule {
  GenericSuitedRule(RegionType inRType, CardOrder inOrder)
      : super(inRType, inOrder);

  @override
  bool checkPlacement(List<Card> nCards, RegionType pRType, Card? cEnd,
      [int? moveLim]) {
    // First check that new cards are not null, then if cEnd is not empty check moveLimit is <= number of new cards
    if (nCards
        .any((element) => (element.suit == null || element.value == null))) {
      return false;
    } else if (nCards.any((element) => element.suit != cEnd!.suit)) {
      return false;
    }

    // check that there is a move limit (ignore for games like klondike, and that there are less cards being moved)
    if (moveLim != null && nCards.length >= moveLim) {
      return false;
    }

    return true;
  }
}

class SpiderSuitedRule extends RegionRule {
  SpiderSuitedRule(RegionType inRType, CardOrder inOrder)
      : super(inRType, inOrder);

  @override
  bool checkPlacement(List<Card> nCards, RegionType pRType, Card? cEnd,
      [int? moveLim]) {
    // First check that new cards are not null, then if cEnd is not empty check moveLimit is <= number of new cards
    if (nCards
        .any((element) => (element.suit == null || element.value == null))) {
      return false;
    }

    // Since in spider the new cards must be a complete suit to move more than one, otherwise only let one move
    // Also lets you use spider rules with move limits assumig moveLin != null...
    //ex: h,h,h,c,h => moveLimit=1 (can only move one, or fail) | h,h,h,h => moveLimit=0 (can move all, ret true) | [any] => moveLimit=0 (since all suits of only one card would match).
    if (null == moveLim &&
        0 !=
            nCards.indexWhere((element) => element.suit != nCards.first.suit)) {
      moveLim = 1;
    } else {
      moveLim = 0;
    }

    // check that there is a move limit (ignore for games like klondike, and that there are less cards being moved)
    if (moveLim != 0 && nCards.length >= moveLim) {
      return false;
    }

    return true;
  }
}
