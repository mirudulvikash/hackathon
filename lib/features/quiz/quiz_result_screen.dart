import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/quiz_model.dart';
import '../../providers/learning_progress_provider.dart';

class QuizResultScreen extends StatefulWidget {
  final QuizResult result;
  final String topicName;

  const QuizResultScreen({
    super.key,
    required this.result,
    required this.topicName,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LearningProgressProvider>().saveQuizResult(widget.result);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (widget.result.score / widget.result.totalQuestions) * 100;
    
    String feedbackLine = 'Good Job!';
    String feedbackDesc = 'You are learning well.';
    IconData icon = Icons.thumb_up_alt_outlined;
    Color color = Colors.orange;

    if (percentage == 100) {
      feedbackLine = 'Perfect Score!';
      feedbackDesc = 'You are an absolute expert on this topic!';
      icon = Icons.emoji_events;
      color = Colors.amber.shade600;
    } else if (percentage >= 75) {
      feedbackLine = 'Great Work!';
      feedbackDesc = 'You understand this disaster well.';
      icon = Icons.star;
      color = Colors.green;
    } else if (percentage < 50) {
      feedbackLine = 'Keep Practicing!';
      feedbackDesc = 'Review the material and try again to stay safe.';
      icon = Icons.menu_book;
      color = Colors.redAccent;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Result'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Force them to use the buttons
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(icon, size: 100, color: color),
              const SizedBox(height: 24),
              Text(
                feedbackLine,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                feedbackDesc,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16),
                  child: Column(
                    children: [
                      Text(
                        '${widget.result.score} / ${widget.result.totalQuestions}',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${percentage.toStringAsFixed(0)}% Accuracy - ${widget.topicName}',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Goes back to disaster detail
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Back to Topic / Retry'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  side: BorderSide(color: theme.colorScheme.primary),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home),
                label: const Text('Save & Check Dashboard'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
