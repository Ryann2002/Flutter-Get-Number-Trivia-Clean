import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia/core/errors/exceptions.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockDio extends Mock implements Dio {
  @override
  BaseOptions options;
  MockDio({
    required this.options,
  });
}

void main() {
  late NumberTriviaRemoteDataSourceImpl dataSourceImpl;
  late MockDio mockDio;
  late BaseOptions options;

  const tNumber = 1;
  final tNumberTriviaModel =
      NumberTriviaModel.fromJson(json.decode(fixture("trivia.json")));

  void setUpMockHttpClientSucess200({required String path}) {
    when(() => mockDio.get(any())).thenAnswer((invocation) async => Response(
        statusCode: 200,
        data: fixture("trivia.json"),
        requestOptions: RequestOptions(path: path)));
  }

  void setUpMockHttpClientFailure404({required String path}) {
    when(() => mockDio.get(any())).thenAnswer((invocation) async =>
        Response(statusCode: 404, requestOptions: RequestOptions(path: path)));
  }

  setUp(() {
    options = BaseOptions(headers: {'Accept': 'application/json'});
    mockDio = MockDio(options: options);
    dataSourceImpl = NumberTriviaRemoteDataSourceImpl(client: mockDio);
  });

  group('getConcreteNumberTrivia', () {
    test(
        'Should perform a GET request on a URL with number being the endpoint and with application/json header',
        () async {
      setUpMockHttpClientSucess200(path: "/$tNumber");
      dataSourceImpl.getConcreteNumberTrivia(tNumber);
      verify(() => mockDio.get('http://numbersapi.com/$tNumber?json'));
    });

    test("Should return a number trivia model whe response code is 200",
        () async {
      setUpMockHttpClientSucess200(path: "/$tNumber");

      final result = await dataSourceImpl.getConcreteNumberTrivia(tNumber);

      expect(
        result,
        equals(tNumberTriviaModel),
      );
    });

    test(
      "should throw a ServerException when status code is diferent from 200",
      () async {
        setUpMockHttpClientFailure404(path: "/$tNumber");

        final call = dataSourceImpl.getConcreteNumberTrivia;

        expect(
            () => call(tNumber),
            throwsA(
              const TypeMatcher<ServerException>(),
            ));
      },
    );
  });

  group('getRandomNumberTrivia', () {
    test(
        'Should perform a GET request on a URL with number being the endpoint and with application/json header',
        () async {
      setUpMockHttpClientSucess200(path: "/random");
      dataSourceImpl.getRandomNumberTrivia();
      verify(() => mockDio.get('http://numbersapi.com/random?json'));
    });

    test("Should return a number trivia model whe response code is 200",
        () async {
      setUpMockHttpClientSucess200(path: "/random");

      final result = await dataSourceImpl.getRandomNumberTrivia();

      expect(
        result,
        equals(tNumberTriviaModel),
      );
    });

    test(
      "should throw a ServerException when status code is diferent from 200",
      () async {
        setUpMockHttpClientFailure404(path: "random");

        final call = dataSourceImpl.getConcreteNumberTrivia;

        expect(
            () => call(tNumber),
            throwsA(
              const TypeMatcher<ServerException>(),
            ));
      },
    );
  });
}
