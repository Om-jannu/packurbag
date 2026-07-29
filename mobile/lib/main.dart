import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/api_client.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'router.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    // A refresh call failing (dead/revoked refresh token) fires from deep
    // inside a background API call, with no BuildContext to navigate with —
    // clearing the session here is enough; the router's own redirect (see
    // router.dart) reacts to that state change and bounces to /login.
    ApiClient.instance.onUnauthorized = () {
      ref.read(authProvider.notifier).clearSessionLocally();
    };

    return MaterialApp.router(
      title: 'Packurbag',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
