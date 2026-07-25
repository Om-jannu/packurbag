import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'models/nearby_traveler.dart';
import 'models/trip.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/sos_screen.dart';
import 'providers/auth_provider.dart';
import 'screens/bt_screen.dart';
import 'screens/currency_converter.dart';
import 'screens/gpt_screen.dart';
import 'screens/home_screen.dart';
import 'screens/main_screen.dart';
import 'screens/profile_page.dart';
import 'screens/splash_screen.dart';
import 'screens/translation_page.dart';
import 'screens/traveler_chat_screen.dart';
import 'screens/trip_detail_screen.dart';
import 'screens/trips_screen.dart';

const _publicRoutes = {'/splash', '/login', '/register'};

/// Notifies go_router to re-run its `redirect` whenever auth state changes —
/// without this, a session dying mid-use (e.g. a revoked refresh token)
/// would only be caught the next time the user manually navigates.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authProvider, (previous, next) => notifyListeners());
  }
}

/// Single route table replacing the ad hoc `Navigator.push` calls scattered
/// across the pre-revamp app.
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      if (auth.isLoading) return null;

      final isLoggedIn = auth.value != null;
      final isPublicRoute = _publicRoutes.contains(state.matchedLocation);

      if (!isLoggedIn && !isPublicRoute) return '/login';
      if (isLoggedIn && state.matchedLocation != '/splash' && isPublicRoute) {
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
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/trips', builder: (context, state) => const TripsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/translate',
                builder: (context, state) => const TranslationPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/nearby-chat',
                builder: (context, state) => const BtScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage()),
          ]),
        ],
      ),
      GoRoute(
        path: '/trips/detail',
        builder: (context, state) =>
            TripDetailScreen(trip: state.extra as Trip),
      ),
      GoRoute(
        path: '/currency-converter',
        builder: (context, state) => const CurrencyConverter(),
      ),
      GoRoute(
        path: '/ai-chat',
        builder: (context, state) => const GptScreen(),
      ),
      GoRoute(
        path: '/sos',
        builder: (context, state) => const SosScreen(),
      ),
      GoRoute(
        path: '/nearby/chat',
        builder: (context, state) =>
            TravelerChatScreen(traveler: state.extra as NearbyTraveler),
      ),
    ],
  );
});
