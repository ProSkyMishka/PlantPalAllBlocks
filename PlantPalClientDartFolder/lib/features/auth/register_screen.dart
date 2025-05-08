import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/services/mailer.dart';
import '../../shared/theme/design_tokens.dart';
import '../auth/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final nameCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final repeatPassCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  String? err;
  String? _verificationCode;

  void _sendVerificationCode(String email) {
    // Здесь должна быть логика отправки email с кодом
    // Для демонстрации используем статический код
    _verificationCode = generate6DigitCode();
    _showVerificationDialog();
  }

  void _showVerificationDialog() {
    sendEmailVerificationCode(emailCtrl.text, _verificationCode ?? "123456");
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Подтверждение Email'),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(
            labelText: 'Введите код',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  child: const Text('Отмена'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text(
                    'Подтвердить',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    if (codeController.text == _verificationCode) {
                      ref.read(authController.notifier).register(nameCtrl.text, passCtrl.text, emailCtrl.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Email подтвержден')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Неверный код')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
                'Регистрация',
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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _StyledInputField(controller: nameCtrl, hintText: 'Имя'),
                    const SizedBox(height: 20),
                    _StyledInputField(controller: passCtrl, hintText: 'Пароль', obscureText: true),
                    const SizedBox(height: 20),
                    _StyledInputField(controller: repeatPassCtrl, hintText: 'Повторите пароль', obscureText: true),
                    const SizedBox(height: 20),
                    _StyledInputField(controller: emailCtrl, hintText: 'Email'),
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
                            : () async {
                          final name = nameCtrl.text.trim();
                          final pass = passCtrl.text.trim();
                          final repeat = repeatPassCtrl.text.trim();
                          final email = emailCtrl.text.trim();

                          if (pass != repeat) {
                            setState(() => err = 'Пароли не совпадают');
                            return;
                          }

                          final isValid = await ref.read(authController.notifier).check(
                            nameCtrl.text,
                            passCtrl.text,
                            emailCtrl.text,
                          );

                          if (isValid) {
                            _sendVerificationCode(emailCtrl.text);
                          }
                        },
                        child: st.status == AuthStatus.loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          'Зарегистрироваться',
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
                      'Уже есть аккаунт?',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text(
                        'Войти',
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
