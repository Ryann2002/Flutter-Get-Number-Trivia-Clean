import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia/util/input_converter.dart';

void main() {
  late InputConverter inputConverter;

  setUp(() {
    inputConverter = InputConverter();
  });

  group("stringToUnsignedInt", () {
    test(
      "should return an Intenger when the string represents an UnsignedIntenger",
      () {
        const tStr = "123";

        final result = inputConverter.stringToUnsignedIntenger(tStr);

        expect(result, const Right(123));
      },
    );

    test(
      "should return a Failure when the string is not an UnsignedIntenger",
      () {
        const tStr = "1BC";

        final result = inputConverter.stringToUnsignedIntenger(tStr);

        expect(result, Left(InvalidInputFailure()));
      },
    );

    test(
      "should return a Failure when the string is a negative an Intenger",
      () {
        const tStr = "-1";

        final result = inputConverter.stringToUnsignedIntenger(tStr);

        expect(result, Left(InvalidInputFailure()));
      },
    );
  });
}
