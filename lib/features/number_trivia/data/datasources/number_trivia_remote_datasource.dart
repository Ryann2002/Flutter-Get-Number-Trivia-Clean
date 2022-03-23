import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:number_trivia/core/errors/exceptions.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';

abstract class NumberTriviaRemoteDataSource {
  /// Calls the http://numbersapi.com/{number} endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<NumberTriviaModel> getConcreteNumberTrivia(int? number);

  /// Calls the http://numbersapi.com/random endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<NumberTriviaModel> getRandomNumberTrivia();
}

class NumberTriviaRemoteDataSourceImpl implements NumberTriviaRemoteDataSource {
  final Dio client;

  NumberTriviaRemoteDataSourceImpl({required this.client});

  @override
  Future<NumberTriviaModel> getConcreteNumberTrivia(int? number) async {
    debugPrint(client.options.headers.toString());
    return getTriviaFromURl("http://numbersapi.com/$number?json");
  }

  @override
  Future<NumberTriviaModel> getRandomNumberTrivia() {
    return getTriviaFromURl("http://numbersapi.com/random?json");
  }

  Future<NumberTriviaModel> getTriviaFromURl(url) async {
    final response = await client.get(url);

    if (response.statusCode == 200) {
      return NumberTriviaModel.fromJson((response.data));
    } else {
      throw ServerException();
    }
  }
}
