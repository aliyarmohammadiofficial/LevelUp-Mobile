/// A single Quick Help FAQ entry shown on the Help & Support screen.
/// Static content for now — matches the reference screen's "How to..."
/// list under Quick Help.
class FaqEntry {
  const FaqEntry({required this.question, required this.answer});

  final String question;
  final String answer;
}

abstract class FaqContent {
  FaqContent._();

  static const entries = [
    FaqEntry(
      question: 'How to track workouts?',
      answer:
          'Open the Plan tab, pick a routine, and tap Start Workout. Mark '
          'each set as completed as you go — your streak and weekly stats '
          'update automatically once the workout is finished.',
    ),
    FaqEntry(
      question: 'How to log meals?',
      answer:
          'From the Nutrition tab, tap the "+" next to any meal slot '
          '(Breakfast, Lunch, Dinner, or Snack) and search for the food '
          'you ate. Your daily calorie and macro totals update instantly.',
    ),
    FaqEntry(
      question: 'How to reset password?',
      answer:
          'On the login screen, tap "Forgot Password?" and enter the email '
          'on your account. We\'ll send a reset link — it expires after '
          '30 minutes for security.',
    ),
    FaqEntry(
      question: 'How to change goals?',
      answer:
          'Go to Profile → Goals, tap the goal you want to update, and '
          'enter a new target. Your progress ring and weekly plan adjust '
          'to the new goal right away.',
    ),
  ];
}
