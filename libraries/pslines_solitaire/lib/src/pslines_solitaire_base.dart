import 'dart:math';

/// Enumeration for Card Rule Responses
enum CardRes { valid, noValue, bothInvalid, invalidSuit, invalidVal }

/// Super class for card encapsulating max values since they should be const, and it is simpler to just put into its own class.
class CardRule {
  /// The max value the suit may be (for 4 suits this would be 4 making suits 0-3).
  final int _suitMax;

  /// The max card face value possible (for french this would be 13 making cards 0 (ace) - 12 (king)).
  final int _valMax;

  /// Initialize with the max values (non inclusive) for suit and value.
  CardRule(int inSuitMax, int inValMax)
      : _suitMax = inSuitMax,
        _valMax = inValMax;

  /// Get copy of card's max suit value.
  int get suitMax => _suitMax;

  /// Get copy of card's max value.
  int get valMax => _valMax;

  /// Checks that the inputted suit and value are valid under the card-set rules.
  ///
  /// Inputs: suit and value of a card.
  /// Outputs: outputs a response of type CardRes
  CardRes checkCard(int? inSuit, int? inVal) {
    //first check values are not null, then suit, both, or just value
    if (null == inSuit || null == inVal) {
      return CardRes.noValue;
    } else if (_suitMax <= inSuit || inSuit < 0) {
      if (_valMax <= inVal || inVal < 0) {
        return CardRes.bothInvalid;
      }
      return CardRes.invalidSuit;
    } else if (_valMax <= inVal || inVal < 0) {
      return CardRes.invalidVal;
    } else {
      return CardRes.valid;
    }
  }
}

/// Class for a single card, mainly built as const with get, but also contains set and copy functions.
class Card extends CardRule {
  /// Current Suit of this card.
  int? _cardSuit;

  /// Current value of this card.
  int? _cardVal;

  /// Initialize Card using previous rule, and this card's values.
  ///
  /// Input:
  ///   inRule = The rule for this card's max suit and value.
  ///   inSuit = This cards current suit.
  ///   inVal = This card's current value.
  Card(CardRule inRule, [int? inSuit, int? inVal])
      : super(inRule.suitMax, inRule.valMax) {
    setCardVals(inSuit, inVal);
  }

  /// Get the card's current suit.
  int? get suit => _cardSuit;

  /// Get the card's current value.
  int? get value => _cardVal;

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

  /// Copy suit and value from another card, and checks if it is valid.
  ///
  /// Inputs: suit and value of a card.
  /// Outputs: outputs a response of type CardRes
  CardRes copyCard(Card inCard) {
    return setCardVals(inCard.suit, inCard.value);
  }
}

/// Enumeration of different Card region types based off standard solitaire categories.
enum RegionType { drawDeck, graveyard, tableau, foundation }

/// Super class for CardDeck and CardPlayRegion as both store cards but in different contexts.
///
/// i.e CardPlayRegion shouldn't contain a deck in and of itself but does require similar functionality.
class CardContainer {
  final List<Card> _cards = List<Card>.empty(growable: true);
  final CardRule _cardRule;
  final RegionType _regionType;

  CardContainer(CardRule inRule, RegionType inRType)
      : _cardRule = inRule,
        _regionType = inRType;

  /// Get the number of cards in the container.
  int get numCards => _cards.length;

  /// Get a copy of index cards from the list.
  List<Card> get peekCards => _cards.toList();

  Card get peekLast => _cards.last;

  /// Get the type of region that this container represents.
  RegionType get regionType => _regionType;

  /// Clear all cards in container
  void clearCards() {
    _cards.clear();
  }

  /// Get the cards from the index to the end of the pile, and remove them from the container.
  ///
  /// Inputs: index of position from the top (with the last card being the face up one), -1 for last value.
  /// Outputs: List of cards, or list containing one card for that region if default index is given.
  List<Card> popCards([int index = -1]) {
    List<Card> outCards = List.empty(growable: true);

    if (-1 == index || _cards.length <= index) {
      outCards.add(_cards.removeLast());
    } else {
      outCards.addAll(_cards.getRange(index, _cards.length));
      _cards.removeRange(index, _cards.length);
    }

    return outCards;
  }

  /// Add new cards to the list, before the index's location (indexed value would become after).
  ///
  /// Inputs: index of the position from the top (with the last card being the face up one), -1 for adding at the end.
  bool addCards(List<Card> nCards, [int index = -1]) {
    if (nCards.any((element) =>
        CardRes.valid != _cardRule.checkCard(element.suit, element.value))) {
      return false;
    }

    if (-1 == index || _cards.length <= index) {
      _cards.addAll(nCards);
    } else {
      _cards.insertAll(index, nCards);
    }

    return true;
  }
}

/// Class for the draw deck of cards, can contain multiple decks
class CardDeck {
  final int _cycleMax;
  int _cycleCount = 0;
  final CardContainer _drawDeck;
  final CardContainer _graveyard;

  CardDeck(CardRule inRule, int inNDecks, [int inCyMax = 0])
      : _cycleMax = inCyMax,
        _graveyard = CardContainer(inRule, RegionType.graveyard),
        _drawDeck = CardContainer(inRule, RegionType.drawDeck) {
    // Add 0-max card values to the deck, one for each suit, and add once for each of the decks (ex 2 decks of french cards would be adding 13 card values,of 4 suits, 2 times)
    for (int cardVal = 0; cardVal < inRule.valMax; cardVal++) {
      for (int suit = 0; suit < inRule.suitMax; suit++) {
        for (int deck = 0; deck < inNDecks; deck++) {
          Card newCard = Card(inRule, suit, cardVal);
          _drawDeck.addCards(List<Card>.filled(1, newCard));
        }
      }
    }
  }

  /// Get current cycle count for the deck
  int get cycleCount => _cycleCount;

  /// Get all cards in the draw deck, without removing them.
  List<Card> get peekDraw => _drawDeck.peekCards;

  /// Get the last card (top) of the draw deck.
  Card get peekLastDraw => _drawDeck.peekLast;

  /// Get the number of cards in the draw deck
  int get numDraw => _drawDeck.numCards;

  /// Get all cards in the graveyard without removing them.
  List<Card> get peekGrave => _graveyard.peekCards;

  /// Get last card (top) of the graveyard.
  Card get peekLastGrave => _graveyard.peekLast;

  /// Get the number of cards in the graveyard
  int get numGrave => _graveyard.numCards;

  /// Shuffle the deck, graveyard, & other cards back into drawDeck (resets deck to full)
  void shuffle(List<Card> otherCards) {
    List<Card> cards = List.empty(growable: true);
    cards.addAll(otherCards);
    cards.addAll(_drawDeck.popCards(0));
    cards.addAll(_graveyard.popCards(0));
    cards.shuffle(Random.secure());
    _drawDeck.addCards(cards);
  }

  /// Draw numDraw cards from the top to front (topmost is end of array)
  List<Card> drawCards([int numDraw = 1]) {
    //goes from back to front, -1 since 0 is first index
    return _drawDeck.popCards(_drawDeck.numCards - numDraw);
  }

  // Add numDispose cards from the deck onto graveyard, in reverse order so top of deck becomes first card added to grave.
  void addToGraveyard([int numDispose = 1]) {
    var dCards = drawCards(numDispose);

    _graveyard.addCards(dCards.reversed.toList());
  }

  /// Cycle the deck and graveyard so start(bottom) of graveyard becomes end(top) for draw deck.
  bool cycleDeck() {
    // Cannot cycle if max is reached (assuming there is a max # of times), graveyard is empty, or deck is not empty
    if ((_cycleMax != 0 && _cycleCount >= _cycleMax) ||
        _graveyard.numCards == 0 ||
        _drawDeck.numCards != 0) {
      return false;
    }

    // ex draw = null, grave = 1,2,3,4(top) _> draw = 4,3,2,1(top) grave=null
    _drawDeck.addCards(_graveyard.popCards(0).reversed.toList());
    _cycleCount++;
    return true;
  }
}

/// Enumeration of possible region card orders.
enum OrderDirection { ascending, descending, both }

/// Structure for combinations of card orders, and loop (t/f).
class CardOrder {
  OrderDirection order;
  bool loop;

  CardOrder(OrderDirection inOrder, inLoop)
      : order = inOrder,
        loop = inLoop;
}

/// Interface of Card order rule which will be overloaded/implemented for different games, one for each of the four categories of the game. Assumes it is the target.
class RegionRule {
  final CardOrder _regionOrder;

  RegionRule(CardOrder inOrder) : _regionOrder = inOrder;

  bool initCheck(List<Card> nCards, Card? cEnd) {
    if (nCards
        .any((element) => (element.suit == null || element.value == null))) {
      return false;
    }

    List<Card> checkList = List<Card>.empty();
    // Check the type or direction, then run check for end of current column and first value in new cards.
    if (_regionOrder.order == OrderDirection.ascending &&
        (cEnd == null || nCards.first.value == cEnd.value! + 1)) {
      checkList.addAll(nCards);
    } else if (_regionOrder.order == OrderDirection.descending &&
        (cEnd == null || nCards.first.value == cEnd.value! - 1)) {
      // Reverse the deck for descending to check the same as ascending now that we know cEnd is correct.
      checkList.addAll(nCards.reversed);
    } else if (_regionOrder.order == OrderDirection.both &&
        (cEnd == null ||
            (nCards.first.value == cEnd.value! + 1 ||
                nCards.first.value == cEnd.value! - 1))) {
      checkList.addAll(nCards);
    } else {
      return false;
    }

    // Set first check to null since cEnd is already checked.
    Card? tempCard;

    // Check that the order is correct, one directional are sorted in same dir, so we can treat the same, otherwise check for both case + always for loop case.
    for (var i in checkList) {
      // Should never be null first, but may be if where it's being placed is empty. In that case just skip first check.
      if (tempCard != null) {
        // Check if its bidirectional or not.
        if (_regionOrder.order == OrderDirection.both) {
          // Can it loop?
          if (_regionOrder.loop) {
            // Check that its not looped above
            if ((tempCard.value == tempCard.valMax - 1 &&
                    (i.value != 0 || i.value != tempCard.value! - 1)) ||
                // Check that its not looped below
                (tempCard.value == 0 &&
                    (i.value != tempCard.valMax - 1 ||
                        i.value != tempCard.value! + 1))) {
              return false;
            }
            // Just check that the value is +/- 1 from previous value, since we already checked loop cases
            else if ((i.value != tempCard.value! + 1) ||
                (i.value != tempCard.value! - 1)) {
              return false;
            }
          }
          // Check that the value is +/- 1 from previous value, since it cannot loop.
          else if ((i.value != tempCard.value! + 1) ||
              (i.value != tempCard.value! - 1)) {
            return false;
          }
        } else {
          // unidirectional only has to check king -> Ace loop since descending was flipped to ace like ascending
          if (_regionOrder.loop &&
              (tempCard.value == tempCard.valMax && i.value != 0)) {
            return false;
          }
          // If it cannot loop just check i value is one above temp card
          else if (i.value != tempCard.value! + 1) {
            return false;
          }
        }
      }
      tempCard = i;
    }
    return true;
  }

  /// Check function for deciding if move is valid, if not overridden it will always return true.
  ///
  /// Inputs:
  ///   - nCards: The list of cards in the previous region being moved to the current region.
  ///   - pRType: The region type the card is coming from.
  ///   - cEnd: the card at the end of the current region.
  ///   - cRType: The region type of the current region.
  ///   - {optional} moveLim: limit for how many cards may move at a time.
  /// Outputs: Boolean value of if that move can (true) or cannot (false) occur.
  bool checkPlacement(
      List<Card> nCards, RegionType pRType, Card? cEnd, RegionType cRType,
      [int? moveLim]) {
    return true;
  }
}

/// Class for the Play Region, Contains its own rule, and the storage for itself.
class CardPlayRegion extends CardContainer {
  final RegionRule _regionRule;

  CardPlayRegion(
      RegionRule inRegionRule, RegionType inRType, CardRule inCardRule)
      : _regionRule = inRegionRule,
        super(inCardRule, inRType);

  /// One or more cards being placed at the end of this region, from another region
  ///
  /// Inputs:
  ///   - cRType: current region's type.
  ///   - nCards: new cards being added from previous region.
  ///   - pRType: previous region's type.
  bool placeCards(List<Card> nCards, RegionType pRType) {
    bool outRes = _regionRule.checkPlacement(
        nCards, pRType, super.peekLast, super.regionType);

    if (outRes) {
      super.addCards(nCards, -1);
    }

    return outRes;
  }
}

class CardBoard {}
