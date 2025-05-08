import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_pal_app/shared/services/mailer.dart';
import 'app_router.dart';
import 'shared/theme/design_tokens.dart';

void main() {
  runApp(const ProviderScope(child: PlantPalApp()));
}

class PlantPalApp extends StatelessWidget {
  const PlantPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PlantPal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),           // тема из Figma
      routerConfig: appRouter,
    );
  }
}
