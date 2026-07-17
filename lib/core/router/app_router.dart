import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/feed/screens/home_feed_screen.dart';
import '../../features/post/screens/create_post_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/saved/screens/saved_posts_screen.dart';

final routerRefreshProvider = Provider<GoRouterRefreshStream>((ref) {
  final notifier = GoRouterRefreshStream();
  ref.listen(authStateChangesProvider, (_, _) => notifier.ping());
  ref.onDispose(notifier.dispose);
  return notifier;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: ref.watch(routerRefreshProvider),
    redirect: (context, state) {
      final authState = ref.read(authStateChangesProvider);
      final isAuthLoading = authState.isLoading;
      final isLoggedIn = authState.valueOrNull?.session != null;

      final currentPath = state.matchedLocation;
      final isSplash = currentPath == '/splash';
      final isAuthRoute =
          currentPath == '/login' || currentPath == '/register';

      if (isAuthLoading) {
        return null;
      }

      if (!isLoggedIn) {
        return isAuthRoute ? null : '/login';
      }

      if (isAuthRoute || isSplash) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeFeedScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/create-post',
        builder: (context, state) => const CreatePostScreen(),
      ),
      GoRoute(
        path: '/saved',
        builder: (context, state) => const SavedPostsScreen(),
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  void ping() => notifyListeners();
}
