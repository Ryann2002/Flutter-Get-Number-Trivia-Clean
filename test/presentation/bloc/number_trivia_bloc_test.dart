import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia/core/errors/failures.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:number_trivia/util/input_converter.dart';

class MockGetConcrete extends Mock implements GetConcreteNumberTrivia {}

class MockGetRandom extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

const SERVER_FAILURE_MESSAGE = "Server failure";
const CACHE_FAILURE_MESSAGE = "Cache faillure";
const INVALID_INPUT_MESSAGE = "Invalid input";

void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcrete mockGetConcrete;
  late MockGetRandom mockGetRandom;
  late MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcrete = MockGetConcrete();
    mockGetRandom = MockGetRandom();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
      concrete: mockGetConcrete,
      random: mockGetRandom,
      inputConverter: mockInputConverter,
    );
  });

  group("getTriviaForConcreteNumber", () {
    const tNumberString = "1";
    const tNumberParsed = 1;
    const tNumberTrivia = NumberTrivia(text: "test trivia", number: 1);

    void setUpMockInputConverterSucess() => {
          when(() => mockInputConverter.stringToUnsignedIntenger(any()))
              .thenReturn(const Right(tNumberParsed))
        };

    setUp(() {
      registerFallbackValue(const Params(tNumberParsed));
    });
    test("shoudl call the InputConverter to parse string into intenger",
        () async {
      setUpMockInputConverterSucess();
      when(() => mockGetConcrete(any()))
          .thenAnswer((_) async => const Right(tNumberTrivia));

      bloc.add(const GetTriviaForConcreteNumber(numberString: tNumberString));

      await untilCalled(
          () => mockInputConverter.stringToUnsignedIntenger(any()));
      verify(() => mockInputConverter.stringToUnsignedIntenger(tNumberString));
    });

    blocTest("the bloc should emit [ERROR] when input is invalid",
        setUp: () {
          when(() => mockInputConverter.stringToUnsignedIntenger(any()))
              .thenReturn(Left(InvalidInputFailure()));
        },
        build: () => bloc,
        act: (NumberTriviaBloc bloc) => bloc
          ..add(const GetTriviaForConcreteNumber(numberString: tNumberString)),
        expect: () => [const Error(message: INVALID_INPUT_MESSAGE)]);

    test("should get data from the concrete usecase", () async {
      setUpMockInputConverterSucess();
      when(() => mockGetConcrete(any()))
          .thenAnswer((_) async => const Right(tNumberTrivia));

      bloc.add(const GetTriviaForConcreteNumber(numberString: tNumberString));
      await untilCalled(() => mockGetConcrete(any()));

      verify(() => mockGetConcrete(const Params(tNumberParsed)));
    });

    blocTest(
        "the bloc should emit [LOADING, LOADED] when data is gotten sucessfully",
        setUp: () {
          setUpMockInputConverterSucess();
          when(() => mockGetConcrete(any()))
              .thenAnswer((_) async => const Right(tNumberTrivia));
        },
        build: () => bloc,
        act: (NumberTriviaBloc bloc) => bloc
          ..add(const GetTriviaForConcreteNumber(numberString: tNumberString)),
        expect: () => [Loading(), const Loaded(trivia: tNumberTrivia)]);

    blocTest("the bloc should emit [LOADING, ERROR] when getting data fails",
        setUp: () {
          setUpMockInputConverterSucess();
          when(() => mockGetConcrete(any()))
              .thenAnswer((_) async => Left(ServerFailure()));
        },
        build: () => bloc,
        act: (NumberTriviaBloc bloc) => bloc
          ..add(const GetTriviaForConcreteNumber(numberString: tNumberString)),
        expect: () =>
            [Loading(), const Error(message: SERVER_FAILURE_MESSAGE)]);

    blocTest(
        "the bloc should emit [LOADING, ERROR] with a proper message for the error when getting data fails",
        setUp: () {
          setUpMockInputConverterSucess();
          when(() => mockGetConcrete(any()))
              .thenAnswer((_) async => Left(CacheFailure()));
        },
        build: () => bloc,
        act: (NumberTriviaBloc bloc) => bloc
          ..add(const GetTriviaForConcreteNumber(numberString: tNumberString)),
        expect: () => [Loading(), const Error(message: CACHE_FAILURE_MESSAGE)]);
  });

  group("getTriviaForRandomNumber", () {
    const tNumberTrivia = NumberTrivia(text: "test trivia", number: 1);

    setUp(() {
      registerFallbackValue(NoParams());
    });
    test("should get data from the concrete usecase", () async {
      when(() => mockGetRandom(NoParams()))
          .thenAnswer((_) async => const Right(tNumberTrivia));

      bloc.add(GetTriviaForRandomNumber());
      await untilCalled(() => mockGetRandom(any()));

      verify(() => mockGetRandom(NoParams()));
    });

    blocTest(
        "the bloc should emit [LOADING, LOADED] when data is gotten sucessfully",
        setUp: () {
          when(() => mockGetRandom(NoParams()))
              .thenAnswer((_) async => const Right(tNumberTrivia));
        },
        build: () => bloc,
        act: (NumberTriviaBloc bloc) => bloc..add(GetTriviaForRandomNumber()),
        expect: () => [Loading(), const Loaded(trivia: tNumberTrivia)]);

    blocTest("the bloc should emit [LOADING, ERROR] when getting data fails",
        setUp: () {
          when(() => mockGetRandom(NoParams()))
              .thenAnswer((_) async => Left(ServerFailure()));
        },
        build: () => bloc,
        act: (NumberTriviaBloc bloc) => bloc..add(GetTriviaForRandomNumber()),
        expect: () =>
            [Loading(), const Error(message: SERVER_FAILURE_MESSAGE)]);

    blocTest(
        "the bloc should emit [LOADING, ERROR] with a proper message for the error when getting data fails",
        setUp: () {
          when(() => mockGetRandom(NoParams()))
              .thenAnswer((_) async => Left(CacheFailure()));
        },
        build: () => bloc,
        act: (NumberTriviaBloc bloc) => bloc..add(GetTriviaForRandomNumber()),
        expect: () => [Loading(), const Error(message: CACHE_FAILURE_MESSAGE)]);
  });
}
