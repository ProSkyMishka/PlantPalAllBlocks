import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/theme/design_tokens.dart';
import '../../shared/widgets/input_field.dart';
import '../../shared/widgets/custom_button.dart';
import '../auth/auth_controller.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final uCtrl = TextEditingController();
  final pCtrl = TextEditingController();
  String? err;

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(authController);

    ref.listen<AuthState>(authController, (_, s) {
      if (s.status == AuthStatus.auth) context.go('/home');
      if (s.status == AuthStatus.error) setState(() => err = s.message);
    });

    return Scaffold(
      backgroundColor: const Color(0xFF8BBE81),
      body: Column(
        children: [
          const SizedBox(height: 80),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Авторизация',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StyledInputField(
                    controller: uCtrl,
                    hintText: 'Логин',
                  ),
                  const SizedBox(height: 20),
                  _StyledInputField(
                    controller: pCtrl,
                    hintText: 'Пароль',
                    obscureText: true,
                  ),
                  if (err != null) ...[
                    const SizedBox(height: 12),
                    Text(err!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6D987A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        elevation: 4,
                      ),
                      onPressed: st.status == AuthStatus.loading
                          ? null
                          : () => ref.read(authController.notifier).login(
                        uCtrl.text.trim(),
                        pCtrl.text.trim(),
                      ),
                      child: st.status == AuthStatus.loading
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : const Text(
                        'Войти',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Нет аккаунта?',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: const Text(
                      'Зарегистрироваться',
                      style: TextStyle(
                        color: Color(0xFF4F765E),
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StyledInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const _StyledInputField({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      cursorColor: const Color(0xFFB2CB73),
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFFB2CB73),
          fontWeight: FontWeight.w600,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black12),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFB2CB73)),
        ),
      ),
    );
  }
}
