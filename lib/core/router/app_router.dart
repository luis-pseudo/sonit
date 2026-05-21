import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../storage/secure_storage.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/map/presentation/map_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';

class AppRouter {
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String mapPath = '/map';
  static const String profilePath = '/profile';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRouter.loginPath,
    redirect: (context, state) async {
      final storage = ref.read(secureStorageProvider);
      final accessToken = await storage.getAccessToken();
      final location = state.uri.path;
      final isOnAuthRoute = location == AppRouter.loginPath || location == AppRouter.registerPath;

      if (accessToken == null || accessToken.isEmpty) {
        return isOnAuthRoute ? null : AppRouter.loginPath;
      }

      if (isOnAuthRoute) {
        return AppRouter.mapPath;
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRouter.loginPath,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRouter.registerPath,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRouter.mapPath,
        builder: (context, state) => const MapScreen(),
      ),
      GoRoute(
        path: AppRouter.profilePath,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});