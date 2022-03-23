import 'package:dartz/dartz.dart';
import 'package:number_trivia/core/errors/failures.dart';

class InputConverter {
  Either<Failure, int> stringToUnsignedIntenger(String str) {
    try {
      final intenger = int.parse(str);

      if (intenger < 0) {
        throw const FormatException();
      }

      return Right(intenger);
    } on FormatException {
      return Left(InvalidInputFailure());
    }
  }
}

class InvalidInputFailure extends Failure {}
