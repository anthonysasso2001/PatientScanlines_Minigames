// import 'package:pslines_solitaire/pslines_solitaire.dart';
import 'dart:math';

import 'package:pslines_solitaire/pslines_solitaire.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();
  final int maxInt = 1 << 32;

  group('CardRule', () {
    final int maxSuit = 4;
    final int maxVal = 13;
    final testRule = CardRule(maxSuit, maxVal);

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
      ;
      CardRes res = testRule.checkCard(testSuit, testValue);

      expect(res, CardRes.bothInvalid);
    });

    test('fail: both >= max', () {
      int testSuit = rand.nextInt(maxInt) + maxSuit;
      int testValue = rand.nextInt(maxInt) + maxVal;
      ;
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
    final rand = Random();

    setUp(() {
      // Additional setup goes here.
    });

    test('fail: ', () {
      expect(true, true);
    });
  });
}
