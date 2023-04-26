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

class Card extends CardRule {
  //private vars & funcs

  int? _cardSuit;
  int? _cardVal;

  /// Set card's values and checks if it is valid, otherwise returns error from checkCard.
  ///
  /// Inputs: suit and value of a card.
  /// Outputs: outputs a response of type CardRes
  CardRes _setCardVals(int? inSuit, int? inVal) {
    var checkCard = super.checkCard(inSuit, inVal);

    //check that the card is valid, otherwise throw exception for first, second, or both vars
    if (CardRes.valid == checkCard) {
      _cardSuit = inSuit;
      _cardVal = inVal;
    }
    return checkCard;
  }

  //public vars & funcs

  /// Initalize Card using previous rule, and this card's values.
  ///
  /// Input:
  ///   inRule = The rule for this card's max suit and value.
  ///   inSuit = This cards current suit.
  ///   inVal = This card's current value.
  Card(CardRule inRule, int? inSuit, int? inVal)
      : super(inRule.suitMax, inRule.valMax) {
    _setCardVals(inSuit, inVal);
  }

  /// Copy suit and value from another card, and checks if it is valid.
  ///
  /// Inputs: suit and value of a card.
  /// Outputs: outputs a response of type CardRes
  CardRes copyCard(Card inCard) {
    return _setCardVals(inCard.suit, inCard.value);
  }

  /// Get the current card's suit.
  int? get suit => _cardSuit;

  /// Get the current card's value.
  int? get value => _cardVal;
}

class CardBoard {}

class CardPlayRegion {}

abstract class CardOrderRule {}

class CardDeck {}
