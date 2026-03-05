import 'package:go_router/go_router.dart';

import 'screens/home_screen.dart';
import 'screens/question_bank_screen.dart';
import 'screens/question_detail_screen.dart';
import 'screens/add_edit_question_screen.dart';
import 'screens/play_quiz_screen.dart';
import 'screens/stats_screen.dart';

GoRouter buildRouter() {
  return GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/questions', builder: (_, __) => const QuestionBankScreen()),
      GoRoute(path: '/questions/new', builder: (_, __) => const AddEditQuestionScreen()),
      GoRoute(
        path: '/questions/:id',
        builder: (_, state) => QuestionDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/questions/:id/edit',
        builder: (_, state) => AddEditQuestionScreen(editId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/play', builder: (_, __) => const PlayQuizScreen()),
      GoRoute(path: '/stats', builder: (_, __) => const StatsScreen()),
    ],
  );
}