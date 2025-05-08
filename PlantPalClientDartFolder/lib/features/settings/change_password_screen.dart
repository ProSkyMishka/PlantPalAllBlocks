// lib/features/settings/change_password_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/input_field.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/theme/design_tokens.dart';
import '../auth/auth_controller.dart';
import 'package:go_router/go_router.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});
  @override ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends ConsumerState<ChangePasswordScreen> {
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _error;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authController);

    ref.listen<AuthState>(authController, (_, s) {
      if (s.status == AuthStatus.auth) {
        context.pop();
      }
      if (s.status == AuthStatus.error) {
        setState(() => _error = s.message);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Изменить пароль', style: Theme.of(context).textTheme.displayMedium),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InputField(controller: _oldCtrl, hint: 'Старый пароль', obscureText: true),
            const SizedBox(height: AppSpacing.m),
            InputField(controller: _newCtrl, hint: 'Новый пароль', obscureText: true),
            const SizedBox(height: AppSpacing.m),
            InputField(controller: _confirmCtrl, hint: 'Повторите пароль', obscureText: true),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.s),
              Text(_error!, style: TextStyle(color: AppColors.error)),
            ],
            const SizedBox(height: AppSpacing.l),
            authState.status == AuthStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : CustomButton(
              text: 'ГОТОВО',
              onPressed: () {
                final oldP = _oldCtrl.text.trim();
                final newP = _newCtrl.text.trim();
                final conf = _confirmCtrl.text.trim();
                if (newP != conf) {
                  setState(() => _error = 'Пароли не совпадают');
                  return;
                }
                ref.read(authController.notifier).changePassword(oldP, newP);
              },
            ),
          ],
        ),
      ),
    );
  }
}
