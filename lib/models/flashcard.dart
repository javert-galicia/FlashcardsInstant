class Flashcard {
  final String id;
  final String question;
  final String answer;
  final DateTime createdAt;
  int correctAttempts;
  int totalAttempts;

  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    required this.createdAt,
    this.correctAttempts = 0,
    this.totalAttempts = 0,
  });

  double get successRate => 
    totalAttempts > 0 ? correctAttempts / totalAttempts : 0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'answer': answer,
    'createdAt': createdAt.toIso8601String(),
    'correctAttempts': correctAttempts,
    'totalAttempts': totalAttempts,
  };

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
    id: json['id'],
    question: json['question'],
    answer: json['answer'],
    createdAt: DateTime.parse(json['createdAt']),
    correctAttempts: json['correctAttempts'],
    totalAttempts: json['totalAttempts'],
  );
}
