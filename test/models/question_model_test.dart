import 'package:flutter_test/flutter_test.dart';
import 'package:lost_found_app/models/question_model.dart';

void main() {
  group('QuestionModel', () {
    test('fromJson parses correctly with 4 options', () {
      final json = {
        'question': 'What color is the item?',
        'options': ['Red', 'Blue', 'Black', 'Green'],
      };

      final model = QuestionModel.fromJson(json);

      expect(model.question, 'What color is the item?');
      expect(model.options.length, 4);
      expect(model.options[0], 'Red');
      expect(model.options[3], 'Green');
    });

    test('fromJson parses correctly with 3 options', () {
      final json = {
        'question': 'What brand is this?',
        'options': ['Nike', 'Adidas', 'Puma'],
      };

      final model = QuestionModel.fromJson(json);

      expect(model.question, 'What brand is this?');
      expect(model.options.length, 3);
    });

    test('fromJson parses correctly with 5 options', () {
      final json = {
        'question': 'Where was it found?',
        'options': ['Library', 'Canteen', 'AB1', 'AB3', 'Hostel'],
      };

      final model = QuestionModel.fromJson(json);

      expect(model.question, 'Where was it found?');
      expect(model.options.length, 5);
      expect(model.options[4], 'Hostel');
    });

    test('toJson produces correct map', () {
      final model = QuestionModel(
        question: 'What color is it?',
        options: ['A', 'B', 'C', 'D'],
      );

      final json = model.toJson();

      expect(json['question'], 'What color is it?');
      expect(json['options'], ['A', 'B', 'C', 'D']);
    });

    test('options list is independent from source', () {
      final sourceOptions = ['Red', 'Blue', 'Green'];
      final json = {
        'question': 'Test?',
        'options': sourceOptions,
      };

      final model = QuestionModel.fromJson(json);

      // Modifying source should not affect model
      sourceOptions.add('Yellow');
      expect(model.options.length, 3);
    });
  });
}
