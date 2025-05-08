import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/theme/design_tokens.dart';
import '../auth/auth_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authController);
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    return Scaffold(
      backgroundColor: const Color(0xFF8BBE81),
      body: Stack(
        children: [
          // Белый блок
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 2 / 3,
              widthFactor: 1,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Карточка профиля
                    GestureDetector(
                      onTap: () => context.push("/profile"),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF83A691),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 24,
                              backgroundImage: AssetImage(
                                  'assets/images/plant_header.png'),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  auth.user?.username ?? 'User Userovich',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  auth.user?.email ?? 'user@user.u',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Пункты меню
                    _SettingsItem(
                      icon: Icons.devices,
                      label: 'Устройства Яндекс',
                      onTap: () => context.push('/yandex-devices'),
                    ),
                    _SettingsItem(
                      icon: Icons.settings,
                      label: 'Настройки устройства',
                      onTap: () => context.push('/device-settings'),
                    ),
                    _SettingsItem(
                      icon: Icons.access_time,
                      label: 'График полива',
                      onTap: () => context.push('/watering-schedule'),
                    ),
                    _SettingsItem(
                      icon: Icons.thermostat,
                      label: 'Заболевания растений',
                      onTap: () => context.push('/plant-diseases'),
                    ),
                    _SettingsItem(icon: Icons.back_hand,
                        label: 'Выйти',
                        onTap: () {
                          ref.read(authController.notifier).logout();
                          context.go('/');
                        }
                    )
                  ],
                ),
              ),
            ),
          ),

          // Кнопка назад + заголовок под ней
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Кнопка назад
                  GestureDetector(
                    onTap: () => context.push('/home'),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFFCEDD4C),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          Positioned(
            // screenHeight/3 = начало белого блока, вычитаем 60 для отступа
            top: screenHeight / 3 - 60,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Настройки',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: Colors.green.shade800),
      title: Text(label),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
