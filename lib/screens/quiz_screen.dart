import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/quiz_bloc.dart';
import '../bloc/quiz_event.dart';
import '../bloc/quiz_state.dart';

class QuizScreen extends StatelessWidget {
  final String quizId;

  const QuizScreen({super.key, required this.quizId});

  @override
  Widget build(BuildContext context) {
    context.read<QuizBloc>().add(LoadQuizEvent(quizId));
    return _QuizView(quizId: quizId);
  }
}

class _QuizView extends StatefulWidget {
  final String quizId;

  const _QuizView({required this.quizId});

  @override
  State<_QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<_QuizView> {
  int currentQuestionIndex = 0;
  final Map<String, String> answers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Test'),
        elevation: 0,
      ),
      body: BlocConsumer<QuizBloc, QuizState>(
        listener: (context, state) {
          if (state is QuizErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is QuizSubmittedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Quiz submitted successfully')),
            );
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is QuizLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is QuizLoadedState) {
            final question = state.quiz.questions[currentQuestionIndex];

            return Column(
              children: [
                LinearProgressIndicator(
                  value:
                      (currentQuestionIndex + 1) / state.quiz.questions.length,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Question ${currentQuestionIndex + 1}/${state.quiz.questions.length}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          question.question,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ...question.options.map((option) {
                          final isSelected = answers[question.id] == option;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Card(
                              elevation: isSelected ? 4 : 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    answers[question.id] = option;
                                  });
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Colors.grey,
                                            width: 2,
                                          ),
                                        ),
                                        child: isSelected
                                            ? Center(
                                                child: Container(
                                                  width: 12,
                                                  height: 12,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                                ),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          option,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      if (currentQuestionIndex > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                currentQuestionIndex--;
                              });
                            },
                            child: const Text('Previous'),
                          ),
                        ),
                      if (currentQuestionIndex > 0) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: answers[question.id] != null
                              ? () {
                                  if (currentQuestionIndex ==
                                      state.quiz.questions.length - 1) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Submit Quiz'),
                                        content: const Text(
                                          'Are you sure you want to submit your answers?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('CANCEL'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(
                                                  context); // Close dialog
                                              context.read<QuizBloc>().add(
                                                    SubmitQuizEvent(
                                                      quizId: widget.quizId,
                                                      answers: answers,
                                                    ),
                                                  );
                                              Navigator.pop(
                                                  context); // Return to quiz list
                                            },
                                            child: const Text('SUBMIT'),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    setState(() {
                                      currentQuestionIndex++;
                                    });
                                  }
                                }
                              : null,
                          child: Text(
                            currentQuestionIndex ==
                                    state.quiz.questions.length - 1
                                ? 'Submit Quiz'
                                : 'Next',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('Failed to load quiz'));
        },
      ),
    );
  }
}
