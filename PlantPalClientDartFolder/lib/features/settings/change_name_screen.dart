// lib/features/settings/change_name_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/input_field.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/theme/design_tokens.dart';
import '../auth/auth_controller.dart';
import 'package:go_router/go_router.dart';

class ChangeNameScreen extends ConsumerStatefulWidget {
  const ChangeNameScreen({super.key});
  @override ConsumerState<ChangeNameScreen> createState() => _ChangeNameState();
}

class _ChangeNameState extends ConsumerState<ChangeNameScreen> {
  final _ctrl = TextEditingController();
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
        title: Text('Изменить имя', style: Theme.of(context).textTheme.displayMedium),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InputField(
              controller: _ctrl,
              hint: 'Новое имя',
              obscureText: false,
            ),
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
                ref.read(authController.notifier).changeName(_ctrl.text.trim());
              },
            ),
          ],
        ),
      ),
    );
  }
}
