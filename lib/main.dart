import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/network/auth_interceptor.dart';
import 'core/router/app_router.dart';
import 'firebase_options.dart';
import 'shared/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: SonitApp()));
}

class SonitApp extends ConsumerWidget {
  const SonitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    ref.listen<int>(sessionExpiredProvider, (previous, next) {
      if (previous != next) {
        router.go(AppRouter.loginPath);
      }
    });

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Sonit',
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
