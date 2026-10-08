import 'package:flutter/material.dart';
import '../../models/quiz_model.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String disasterId;
  final String topicName;
  final List<QuizQuestion> questions;

  const QuizScreen({
    super.key,
    required this.disasterId,
    required this.topicName,
    required this.questions,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedOptionIndex;
  bool _hasAnswered = false;

  void _onOptionSelected(int index) {
    if (_hasAnswered) return; // Prevent changing answer
    setState(() {
      _selectedOptionIndex = index;
      _hasAnswered = true;
      if (index == widget.questions[_currentIndex].correctOptionIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
        _hasAnswered = false;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(
            result: QuizResult(
              disasterId: widget.disasterId,
              score: _score,
              totalQuestions: widget.questions.length,
              timestamp: DateTime.now(),
            ),
            topicName: widget.topicName,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentIndex];
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.topicName} Quiz'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (_currentIndex + 1) / widget.questions.length,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: theme.colorScheme.primary,
              minHeight: 6,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Question ${_currentIndex + 1} of ${widget.questions.length}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      question.question,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Options
                    ...List.generate(question.options.length, (index) {
                      final isSelected = _selectedOptionIndex == index;
                      final isCorrectOption = index == question.correctOptionIndex;
                      
                      Color cardColor = theme.colorScheme.surface;
                      Color borderColor = theme.colorScheme.outlineVariant;
                      IconData? statusIcon;
                      
                      if (_hasAnswered) {
                        if (isCorrectOption) {
                          cardColor = Colors.green.shade100;
                          borderColor = Colors.green;
                          statusIcon = Icons.check_circle;
                        } else if (isSelected && !isCorrectOption) {
                          cardColor = Colors.red.shade50;
                          borderColor = Colors.red;
                          statusIcon = Icons.cancel;
                        }
                      } else if (isSelected) {
                        borderColor = theme.colorScheme.primary;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: InkWell(
                          onTap: () => _onOptionSelected(index),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor, width: 2),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    question.options[index],
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: _hasAnswered && isCorrectOption ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (_hasAnswered && statusIcon != null)
                                  Icon(statusIcon, color: borderColor),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 24),
                    
                    // Explanation Card
                    if (_hasAnswered)
                      Card(
                        color: _selectedOptionIndex == question.correctOptionIndex 
                            ? Colors.green.shade50 
                            : theme.colorScheme.errorContainer,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _selectedOptionIndex == question.correctOptionIndex ? Icons.thumb_up : Icons.lightbulb,
                                    color: _selectedOptionIndex == question.correctOptionIndex ? Colors.green.shade700 : theme.colorScheme.onErrorContainer,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _selectedOptionIndex == question.correctOptionIndex ? 'Correct!' : 'Why?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _selectedOptionIndex == question.correctOptionIndex ? Colors.green.shade700 : theme.colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                question.explanation,
                                style: TextStyle(
                                  color: _selectedOptionIndex == question.correctOptionIndex ? Colors.green.shade900 : theme.colorScheme.onErrorContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Next Button Area
            if (_hasAnswered)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: FilledButton(
                  onPressed: _nextQuestion,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: Text(_currentIndex == widget.questions.length - 1 ? 'Finish Quiz' : 'Next Question'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
