import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia/injection_container.dart';
import 'package:number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:number_trivia/presentation/widgets/loading_widget.dart';
import 'package:number_trivia/presentation/widgets/message_display.dart';
import 'package:number_trivia/presentation/widgets/trivia_control.dart';
import 'package:number_trivia/presentation/widgets/trivia_display.dart';

class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Number Trivia"),
      ),
      body: buildBody(context),
    );
  }

  BlocProvider<NumberTriviaBloc> buildBody(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NumberTriviaBloc>(),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(height: 10.0),
            BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
              builder: (context, state) {
                if (state is Empty) {
                  return const MessageDisplay(message: "Start Searching");
                } else if (state is Loading) {
                  return const LoadingWidget();
                } else if (state is Error) {
                  return MessageDisplay(message: state.message);
                }
                final numberTrivia = (state as Loaded).trivia;
                return TriviaDisplay(numberTrivia: numberTrivia);
              },
            ),
            const SizedBox(height: 10.0),
            const TriviaControl()
          ],
        ),
      ),
    );
  }
}
