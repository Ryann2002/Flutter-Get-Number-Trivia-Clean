import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';

import '../../../../fixtures/fixture_reader.dart';

main() {
  const tNumberTriviaModel = NumberTriviaModel(number: 1, text: 'Test text');
  test("Number trivia model should be a subclass of Number trivia", () {
    expect(tNumberTriviaModel, isA<NumberTrivia>());
  });

  group("fromJson", () {
    test("should return a valid model when JSON number is a intenger", () {
      final Map<String, dynamic> jsonMap = json.decode(fixture("trivia.json"));
      final result = NumberTriviaModel.fromJson(jsonMap);
      expect(result, equals(tNumberTriviaModel));
    });

    test(
        "should return a valid model when JSON number is regarded as as double",
        () {
      final Map<String, dynamic> jsonMap =
          json.decode(fixture("trivia_double.json"));
      final result = NumberTriviaModel.fromJson(jsonMap);
      expect(result, equals(tNumberTriviaModel));
    });
  });

  group("toJson", () {
    test("should return a valid JSON when model number is a intenger ", () {
      final json = tNumberTriviaModel.toJson();
      final expectedMap = {
        "text": "Test text",
        "number": 1,
      };
      expect(json, expectedMap);
    });
  });
}
