import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia/core/errors/exceptions.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late NumberTriviaLocalDataSourceImpl dataSourceImpl;
  late MockSharedPreferences mockSharedPreferences;
  const CACHED_NUMBER_TRIVIA = "CACHED_NUMBER_TRIVIA";
  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSourceImpl = NumberTriviaLocalDataSourceImpl(mockSharedPreferences);
  });

  group("getLastNumberTrivia", () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia_cached.json')));

    test("should return NumberTrivia from sharedPrefrences when available",
        () async {
      const keyString = "CACHED_NUMBER_TRIVIA";
      when(() => mockSharedPreferences.getString("CACHED_NUMBER_TRIVIA"))
          .thenReturn(fixture("trivia_cached.json"));

      final result = await dataSourceImpl.getLastNumberTrivia();
      verify(() => mockSharedPreferences.getString(keyString));
      expect(result, equals(tNumberTriviaModel));
    });

    test(
        "should throws a CacheExpection from sharedPrefrences when there isn't data",
        () async {
      when(() => mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA))
          .thenReturn(null);

      final call = dataSourceImpl.getLastNumberTrivia;
      expect(() => call(), throwsA(const TypeMatcher<CacheException>()));
    });
  });

  group("cachedNumberTrivia", () {
    const tNumberTriviaModel =
        NumberTriviaModel(number: 1, text: "Text trivia");
    test("should call LocalDataSource to cache the data", () {
      when(() => mockSharedPreferences.setString(CACHED_NUMBER_TRIVIA, any()))
          .thenAnswer((value) async => true);

      dataSourceImpl.cacheNumberTrivia(tNumberTriviaModel);
      final expectedJsonString = json.encode(tNumberTriviaModel.toJson());
      verify(() => mockSharedPreferences.setString(
          CACHED_NUMBER_TRIVIA, expectedJsonString));
    });
  });
}
