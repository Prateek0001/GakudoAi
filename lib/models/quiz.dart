class Quiz {
  final String id;
  final String title;
  final List<Question> questions;
  final bool isCompleted;

  Quiz({
    required this.id,
    required this.title,
    required this.questions,
    this.isCompleted = false,
  });
}

class Question {
  final String id;
  final String text;
  final List<Option> options;
  final String correctOptionId;

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctOptionId,
  });
}

class Option {
  final String id;
  final String text;

  Option({
    required this.id,
    required this.text,
  });
} 