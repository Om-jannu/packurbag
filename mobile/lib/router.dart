import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'models/nearby_traveler.dart';
import 'models/trip.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/sos_screen.dart';
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

/// Single route table replacing the ad hoc `Navigator.push` calls scattered
/// across the pre-revamp app.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
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
