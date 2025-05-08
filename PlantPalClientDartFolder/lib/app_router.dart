import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:plant_pal_app/features/settings/profile_changing_screen.dart';
import 'package:plant_pal_app/features/settings/profile_screen.dart';

import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/home/home_screen.dart';
import 'features/plant/detect_plant_screen.dart';
import 'features/plant/plant_detail_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/settings/change_name_screen.dart';
import 'features/settings/change_password_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/detect',
      builder: (context, state) => const AddPlantView(),
    ),
    GoRoute(
      path: '/plant/:id',
      builder: (context, state) {
        final id = state.params['id']!;
        return PlantDetailScreen(plantId: id);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/change-name',
      builder: (context, state) => const ChangeNameScreen(),
    ),
    GoRoute(
      path: '/change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/profile-changing',
      builder: (context, state) => const ProfileChangingScreen(),
    ),
  ],
);
