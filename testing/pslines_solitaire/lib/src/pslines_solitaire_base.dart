// TODO: Put public facing types in this file.

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

/// Class for the draw deck of cards, can contain multiple decks
class CardDeck {
  final int _maxSize;
  final CardRule _cardRule;

  int currentSize = 0;
  List<Card> cards = List<Card>.empty();

  CardDeck(CardRule inRule, int numDecks)
      : _maxSize = (inRule.suitMax * inRule.valMax * numDecks),
        _cardRule = inRule {
    Card newCard = Card(inRule);

    cards = List.filled(_maxSize, Card(_cardRule), growable: false);

    // Add 0-max card values to the deck, one for each suit, and add once for each of the decks (ex 2 decks of french cards would be adding 13 card values,of 4 suits, 2 times)
    for (int cardVal = 0; cardVal < inRule.valMax; cardVal++) {
      for (int suit = 0; suit < inRule._suitMax; suit++) {
        for (int deck = 0; deck < numDecks; deck++) {
          newCard.setCardVals(suit, cardVal);
          cards[cardVal + suit * cardVal] = newCard;
        }
      }
    }
  }
}

abstract class CardOrderRule {
  bool checkPlacement(Card prevCard, Card nextCard);
}

class CardPlayRegion {
  final int _numRules;
  final List<CardOrderRule> _suitRules =
      List<CardOrderRule>.empty(growable: true);

  CardPlayRegion(int inNumRules, List<CardOrderRule> inRules)
      : _numRules = inNumRules {
    _suitRules.addAll(inRules);
  }

  int get numRules => _numRules;
  List<CardOrderRule>? get rules => _suitRules;
}

class CardBoard {}
