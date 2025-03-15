import 'package:go_router/go_router.dart';
import 'package:academia_unifor/screens.dart';

class NoTransitionPage extends CustomTransitionPage {
  NoTransitionPage({required super.child})
    : super(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
      );
}

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder:
          (context, state) => NoTransitionPage(child: const LoginScreen()),
    ),
    GoRoute(
      path: '/home',
      pageBuilder:
          (context, state) => NoTransitionPage(child: const HomeScreen()),
    ),
    GoRoute(
      path: '/workouts',
      pageBuilder:
          (context, state) => NoTransitionPage(child: const WorkoutsScreen()),
    ),
    GoRoute(
      path: '/profile',
      pageBuilder:
          (context, state) => NoTransitionPage(child: const ProfileScreen()),
    ),
    GoRoute(path: '/admin', builder: (context, state) => const AdminScreen()),
  ],
);
