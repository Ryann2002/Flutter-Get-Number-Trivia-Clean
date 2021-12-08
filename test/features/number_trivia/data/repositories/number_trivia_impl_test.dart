import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia/core/platform/network_info.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

main() {
  late NumberTriviaRepositoryImpl numberTriviaRepository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    numberTriviaRepository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );

    group("getConcreteNumberTrivia", () {
      const tNumber = 1;
      const tNumberTriviaModel = NumberTriviaModel(
        number: tNumber,
        text: 'Test trivia',
      );
      const NumberTrivia tNumberTrivia = tNumberTriviaModel;

      test("should check if device is online", () {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        numberTriviaRepository.getConcreteNumberTrivia(tNumber);

        verify(() => mockNetworkInfo.isConnected);
      });

      group("device is online", () {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        test(
            "should cache the data locally when the call to remote data source is sucessful",
            () async {
          when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
              .thenAnswer((_) async => tNumberTriviaModel);

          await numberTriviaRepository.getConcreteNumberTrivia(tNumber);
          verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          verify(
              () => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
        });
      });
      group("device is offline", () {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
    });
  });
}
