// import 'package:pslines_solitaire/pslines_solitaire.dart';
import 'dart:html';
import 'dart:math';

import 'package:pslines_solitaire/pslines_solitaire.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();
  final int maxInt = 1 << 32;
  final int maxSuit = 4;
  final int maxVal = 13;
  final testRule = CardRule(maxSuit, maxVal);

  group('CardRule', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('fail: suit < 0', () {
      int testSuit = 0 - rand.nextInt(maxInt);
      int testValue = 0;
      CardRes res = testRule.checkCard(testSuit, testValue);

      expect(res, CardRes.invalidSuit);
    });

    test('fail: value < 0', () {
      int testSuit = 0;
      int testValue = 0 - rand.nextInt(maxInt);
      CardRes res = testRule.checkCard(testSuit, testValue);

      expect(res, CardRes.invalidVal);
    });

    test('fail: suit && value < 0', () {
      int testSuit = -1;
      int testValue = -1;
      CardRes res = testRule.checkCard(testSuit, testValue);

      expect(res, CardRes.bothInvalid);
    });

    test('fail: suit == maxSuit', () {
      int testSuit = maxSuit;
      int testValue = 0;
      CardRes res = testRule.checkCard(testSuit, testValue);

      expect(res, CardRes.invalidSuit);
    });

    test('fail: suit >= maxSuit', () {
      int testSuit = rand.nextInt(maxInt) + maxSuit;
      int testValue = 0;
      CardRes res = testRule.checkCard(testSuit, testValue);

      expect(res, CardRes.invalidSuit);
    });

    test('fail: value == maxValue', () {
      int testSuit = 0;
      int testValue = maxVal;
      CardRes res = testRule.checkCard(testSuit, testValue);

      expect(res, CardRes.invalidVal);
    });

    test('fail: value >= maxValue', () {
      int testSuit = 0;
      int testValue = rand.nextInt(maxInt) + maxVal;
      CardRes res = testRule.checkCard(testSuit, testValue);

      expect(res, CardRes.invalidVal);
    });

    test('fail: both = max', () {
      int testSuit = rand.nextInt(maxInt) + maxSuit;
      int testValue = rand.nextInt(maxInt) + maxVal;

      CardRes res = testRule.checkCard(testSuit, testValue);

      expect(res, CardRes.bothInvalid);
    });

    test('fail: both >= max', () {
      int testSuit = rand.nextInt(maxInt) + maxSuit;
      int testValue = rand.nextInt(maxInt) + maxVal;

      CardRes res = testRule.checkCard(testSuit, testValue);

      expect(res, CardRes.bothInvalid);
    });

    test('fail: suit == null', () {
      int? testSuit;
      int testValue = 0;
      CardRes res = testRule.checkCard(testSuit, testValue);

      expect(res, CardRes.noValue);
    });

    test('fail: value == null', () {
      int testSuit = 0;
      int? testValue;
      CardRes res = testRule.checkCard(testSuit, testValue);

      expect(res, CardRes.noValue);
    });

    test('fail: both == null', () {
      int? testSuit;
      int? testValue;
      CardRes res = testRule.checkCard(testSuit, testValue);

      expect(res, CardRes.noValue);
    });

    test('succeed: 0 <= both <= max', () {
      int testSuit = rand.nextInt(maxSuit - 1);
      int testValue = rand.nextInt(maxVal - 1);
      CardRes res = testRule.checkCard(testSuit, testValue);

      expect(res, CardRes.valid);
    });

    test('succeed: testRule.suitMax = maxSuit', () {
      expect(maxSuit, testRule.suitMax);
    });

    test('succeed: testRule.valMax = maxVal', () {
      expect(maxVal, testRule.valMax);
    });
  });

  group('Card', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('fail: constructor with bad values', () {
      Card testCard = Card(testRule, -1, -1);

      bool res = true;

      if (testCard.suit == null || testCard.value == null) {
        res = false;
      }

      expect(res, false);
    });

    test('succeed: constructor with bad values', () {
      Card testCard =
          Card(testRule, rand.nextInt(maxSuit - 1), rand.nextInt(maxVal - 1));

      bool res = true;

      if (testCard.suit == null || testCard.value == null) {
        res = false;
      }

      expect(res, true);
    });

    test('succeed: copy another card', () {
      Card checkCard =
          Card(testRule, rand.nextInt(maxSuit - 1), rand.nextInt(maxVal - 1));

      Card testCard = Card(testRule);
      testCard.checkCard(checkCard.suit, checkCard.value);

      bool res = true;

      if (testCard.suit == checkCard.suit ||
          testCard.value == checkCard.value) {
        res = false;
      }

      expect(res, true);
    });
  });

  group('CardContainer', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('succeed: add single card', () {
      CardContainer testContainer = CardContainer(testRule);

      Card testCard = Card(testRule, 1, 1);
      List<Card> testList = List.empty(growable: true);
      testList.add(testCard);

      testContainer.addCards(testList, 0);

      expect(testContainer.numCards, testList.length);
    });

    test('succeed: add max cards', () {
      CardContainer testContainer = CardContainer(testRule);

      List<Card> testList = List.empty(growable: true);
      Card newCard = Card(testRule);

      for (int cardVal = 0; cardVal < testRule.valMax; cardVal++) {
        for (int suit = 0; suit < testRule.suitMax; suit++) {
          newCard.setCardVals(suit, cardVal);
          testList.add(newCard);
        }
      }

      testContainer.addCards(testList, 0);

      expect(testContainer.numCards, testList.length);
    });

    test('succeed: add one suit and pop last', () {
      CardContainer testContainer = CardContainer(testRule);

      List<Card> testList = List.empty(growable: true);
      Card newCard = Card(testRule);

      for (int cardVal = 0; cardVal < testRule.valMax; cardVal++) {
        newCard.setCardVals(0, cardVal);
        testList.add(newCard);
      }

      testContainer.addCards(testList, 0);

      var resCard = testContainer.popCards();

      expect(resCard.first.value, testList.last.value);
    });

    test('succeed: add one suit and pop first', () {
      CardContainer testContainer = CardContainer(testRule);

      List<Card> testList = List.empty(growable: true);
      Card newCard = Card(testRule);

      for (int cardVal = 0; cardVal < testRule.valMax; cardVal++) {
        newCard.setCardVals(0, cardVal);
        testList.add(newCard);
      }

      testContainer.addCards(testList, 0);

      var resCard = testContainer.popCards(0);

      expect(resCard.first.value, testList.first.value);
    });

    test('succeed: add one suit and pop all', () {
      CardContainer testContainer = CardContainer(testRule);

      List<Card> testList = List.empty(growable: true);
      for (int cardVal = 0; cardVal < testRule.valMax; cardVal++) {
        Card newCard = Card(testRule, 0, cardVal);
        testList.add(newCard);
      }

      testContainer.addCards(testList, 0);

      var resList = testContainer.popCards(0);

      bool res = true;

      // Run the max number of times to guarantee that it will take all out minimally...
      for (int i = 0; i < maxVal; i++) {
        if (resList[i].value != testList[i].value) res = false;
      }

      expect(res, true);
    });

    test('succeed: add one suit and pop random', () {
      CardContainer testContainer = CardContainer(testRule);

      List<Card> testList = List.empty(growable: true);
      for (int cardVal = 0; cardVal < testRule.valMax; cardVal++) {
        Card newCard = Card(testRule, 0, cardVal);
        testList.add(newCard);
      }

      testContainer.addCards(testList, 0);

      //run max+1 times just to check popping from a null list
      int testIter = maxVal + 1;

      for (int i = 0; i < testIter; i++) {
        if (testContainer.numCards > 0) {
          var index = rand.nextInt(testContainer.numCards);
          var resList = testContainer.popCards(index);

          expect(resList.first.value, testList[index].value);
        } else {
          break;
        }
      }
    });

    test('succeed: add one suit and clear', () {
      CardContainer testContainer = CardContainer(testRule);

      List<Card> testList = List.empty(growable: true);
      Card newCard = Card(testRule);

      for (int cardVal = 0; cardVal < testRule.valMax; cardVal++) {
        newCard.setCardVals(0, cardVal);
        testList.add(newCard);
      }

      testContainer.addCards(testList, 0);

      testContainer.clearCards();

      var resCard = testContainer.numCards;

      expect(resCard, 0);
    });
  });

  group('CardDeck', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('succeed: constructor builds full deck', () {
      CardDeck testDeck = CardDeck(testRule, 1);

      var resNum = testDeck.numDraw;
      var expNum = maxVal * maxSuit;
      expect(resNum, expNum);
    });

    test('succeed: constructor builds deck of 2-7 decks', () {
      int deckNum = rand.nextInt(5) + 2;
      CardDeck testDeck = CardDeck(testRule, deckNum);

      var resNum = testDeck.numDraw;
      var expNum = maxVal * maxSuit * deckNum;

      expect(resNum, expNum);
    });
  });
}
