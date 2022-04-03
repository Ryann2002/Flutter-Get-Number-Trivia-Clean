// ignore_for_file: constant_identifier_names

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:number_trivia/core/errors/failures.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia/util/input_converter.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const SERVER_FAILURE_MESSAGE = "Server failure";
const CACHE_FAILURE_MESSAGE = "Cache faillure";
const INVALID_INPUT = "Invalid input";

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required GetConcreteNumberTrivia concrete,
    required GetRandomNumberTrivia random,
    required this.inputConverter,
  })  : getConcreteNumberTrivia = concrete,
        getRandomNumberTrivia = random,
        super(Empty()) {
    on<GetTriviaForConcreteNumber>((event, emit) async {
      await _onEventGetTriviaForConcreteNumber(event, emit);
    });

    on<GetTriviaForRandomNumber>((event, emit) async {
      await _onEventGetTriviaForRandomNumber(event, emit);
    });
  }

  _onEventGetTriviaForConcreteNumber(
      GetTriviaForConcreteNumber event, Emitter<NumberTriviaState> emit) async {
    Either<Failure, int> inputEither =
        inputConverter.stringToUnsignedIntenger(event.numberString);

    await inputEither.fold(
      (failure) async => emit(Error(message: INVALID_INPUT)),
      (intenger) async {
        emit(Loading());
        final triviaOrfailure = await getConcreteNumberTrivia(Params(intenger));

        return triviaOrfailure.fold(
          (failure) => emit(Error(message: _mapFailureToMessage(failure))),
          (trivia) => emit(Loaded(trivia: trivia)),
        );
      },
    );
  }

  _onEventGetTriviaForRandomNumber(
      GetTriviaForRandomNumber event, Emitter<NumberTriviaState> emit) async {
    emit(Loading());
    final triviaOrfailure = await getRandomNumberTrivia(NoParams());

    triviaOrfailure.fold(
      (failure) => emit(Error(message: _mapFailureToMessage(failure))),
      (trivia) => emit(Loaded(trivia: trivia)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return "Unexpected Error";
    }
  }
}
