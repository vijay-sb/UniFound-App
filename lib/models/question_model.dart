class QuestionModel {
  final String question;
  final List<String> options;

  QuestionModel({required this.question, required this.options});

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      question: json['question'] as String,
      options: List<String>.from(json['options']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
    };
  }
}
