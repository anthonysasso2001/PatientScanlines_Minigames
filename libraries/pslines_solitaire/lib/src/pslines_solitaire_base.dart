// TODO: Put public facing types in this file.

import 'dart:math';

/// Enummeration for Card Rule Responses
enum CardRes { valid, noValue, bothInvalid, invalidSuit, invalidVal }

/// Super class for card encapsulating max values since they should be const.
class CardRule {
  final int _suitMax;
  final int _valMax;

  /// Initalize with the max values (non inclusive) for suit and value.
  CardRule(int inSuitMax, int inValMax)
      : _suitMax = inSuitMax,
        _valMax = inValMax;

  /// Checks that the inputed suit and value.
  ///
  /// Inputs: suit and value of a card.
  /// Outputs: outputs a response of type CardRes
  CardRes checkCard(int? inSuit, int? inVal) {
    //first check values are not null, then suit, both, or just value
    if (null == inSuit || null == inVal) {
      return CardRes.noValue;
    } else if (_suitMax < inSuit) {
      if (_valMax < inVal) {
        return CardRes.bothInvalid;
      }
      return CardRes.invalidSuit;
    } else if (_valMax < inVal) {
      return CardRes.invalidVal;
    } else {
      return CardRes.valid;
    }
  }

  /// Get copy of card's max suit value.
  int get suitMax => _suitMax;

  /// Get copy of card's max value.
  int get valMax => _valMax;
}

/// Class for a single card, mainly built as const with get, but also contains set and copy functions.
class Card extends CardRule {
  //private vars & funcs

  int? _cardSuit;
  int? _cardVal;

  //public vars & funcs

  /// Set card's values and checks if it is valid, otherwise returns error from checkCard.
  ///
  /// Inputs: suit and value of a card.
  /// Outputs: outputs a response of type CardRes
  CardRes setCardVals(int? inSuit, int? inVal) {
    var checkCard = super.checkCard(inSuit, inVal);

    //check that the card is valid, otherwise throw exception for first, second, or both vars
    if (CardRes.valid == checkCard) {
      _cardSuit = inSuit;
      _cardVal = inVal;
    }
    return checkCard;
  }

  /// Initalize Card using previous rule, and this card's values.
  ///
  /// Input:
  ///   inRule = The rule for this card's max suit and value.
  ///   inSuit = This cards current suit.
  ///   inVal = This card's current value.
  Card(CardRule inRule, {int? inSuit, int? inVal})
      : super(inRule.suitMax, inRule.valMax) {
    setCardVals(inSuit, inVal);
  }

  /// Copy suit and value from another card, and checks if it is valid.
  ///
  /// Inputs: suit and value of a card.
  /// Outputs: outputs a response of type CardRes
  CardRes copyCard(Card inCard) {
    return setCardVals(inCard.suit, inCard.value);
  }

  /// Get the current card's suit.
  int? get suit => _cardSuit;

  /// Get the current card's value.
  int? get value => _cardVal;
}

/// abstract class for CardContainer
class CardContainer {
  List<Card> _cards = List<Card>.empty();
  final CardRule _cardRule;

  CardContainer(CardRule inRule) : _cardRule = inRule;

  /// Get the cards from the index to the end of the pile, and remove them from the container.
  ///
  /// Inputs: index of position FROM the bottom (ex 5 in 6 card foundation is second from the bottom), -1 for last value.
  ///
  /// Outputs:
  ///   - List of cards, or list containing one card for that region if default / invalid index is given.
  ///   - Null list for empty region.
  List<Card> _popCards(int index) {
    List<Card> outCards = List.empty(growable: true);

    if (-1 == index || _cards.length <= index) {
      outCards.add(_cards.removeLast());
    } else {
      outCards.addAll(_cards.getRange(index, _cards.length));
      _cards.removeRange(index, _cards.length);
    }

    return outCards;
  }

  /// Add new cards to the end of the list
  _addCardsEnd(List<Card> nCards) {
    _cards.followedBy(nCards);
  }

  /// Add new cards to the beginning of the list
  _addCardsStart(List<Card> nCards) {
    _cards.insertAll(0, nCards);
  }
}

/// Class for the draw deck of cards, can contain multiple decks
class CardDeck extends CardContainer {
  final int _maxSize;

  CardDeck(CardRule inRule, int numDecks)
      : _maxSize = (inRule.suitMax * inRule.valMax * numDecks),
        super(inRule) {
    Card newCard = Card(inRule);

    _cards = List.filled(_maxSize, Card(_cardRule));

    // Add 0-max card values to the deck, one for each suit, and add once for each of the decks (ex 2 decks of french cards would be adding 13 card values,of 4 suits, 2 times)
    for (int cardVal = 0; cardVal < inRule.valMax; cardVal++) {
      for (int suit = 0; suit < inRule._suitMax; suit++) {
        for (int deck = 0; deck < numDecks; deck++) {
          newCard.setCardVals(suit, cardVal);
          _cards[cardVal + suit * cardVal] = newCard;
        }
      }
    }
  }

  /// Shuffle the deck with the current cards, randomizing the order.
  void shuffle() {
    _cards.shuffle(Random.secure());
  }

  /// Wrapper for accessing parents popCard function but limited to only get one at a time.
  Card get popCard => super._popCards(-1).first;
}

/// Enummeration of different Card region types based off standard solitaire categories.
enum RegionType { DrawDeck, Graveyard, Tableau, Foundation }

/// Interface of Card order rule which will be overloaded/implemented for different games, one for each of the four categories of the game. Assumes it is the target.
abstract class RegionRule {
  final RegionType _regionType;

  RegionRule(RegionType inRType) : _regionType = inRType;

  /// Overloaded check function for deciding if move is valid.
  ///
  /// Inputs:
  ///   - nCards: The list of cards in the previous region being moved to the current region.
  ///   - pRType: The Region type the card is coming from.
  ///   - cEnd: the card at the end of the current region.
  ///   - eFounds: (optional rule for how many empty foundations exist, defaults to 0).
  ///   - eTabs: (optional rule for how many empty tableau exist, defualts to 0)
  ///
  /// Outputs: Boolean value of if that move can (true) or cannot (false) occur.
  bool checkPlacement(List<Card> nCards, RegionType pRType, Card cEnd,
      {int eFounds = 0, int eTabs = 0});
}

/// Class for the Play Region, Contains its own rule, and the storage for itself.
class CardPlayRegion extends CardContainer {
  final RegionRule _regionRule;

  CardPlayRegion(RegionRule inRegionRule, CardRule inCardRule)
      : _regionRule = inRegionRule,
        super(inCardRule);

  /// One or more cards being placed at the end of this region, from another region
  ///
  /// Inputs:
  ///   - cRType: current region's type.
  ///   - nCards: new cards being added from previous region.
  ///   - pRType: previous region's type.
  bool placeCards(RegionType cRType, List<Card> nCards, RegionType pRType) {
    bool outRes = _regionRule.checkPlacement(nCards, pRType, super._cards.last);

    if (outRes) {
      super._cards.followedBy(nCards);
    }

    return outRes;
  }

  /// Wrapper for accessing parents popCard function, but not locked to a single card.
  List<Card> popCards(index) => super._popCards(index);
}

class CardBoard {}