import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:email_validator/email_validator.dart';
import 'package:go_router/go_router.dart';
import '../../shared/services/mailer.dart';
import '../auth/auth_controller.dart';

class ProfileChangingScreen extends ConsumerWidget {
  const ProfileChangingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authController);
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: auth.user?.username ?? 'User Userovich');
    final _emailController = TextEditingController(text: auth.user?.email ?? 'User@user.u');
    String? _verificationCode;

    // Местоположение функции до её использования
    void _showVerificationDialog() {
      sendEmailVerificationCode(_emailController.text, _verificationCode ?? "123456");
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
                        context.pop();
                        ref.read(authController.notifier).changeName(_nameController.text.trim());
                        ref.read(authController.notifier).changeEmail(_emailController.text.trim());
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

    void _sendVerificationCode(String email) {
      // Здесь должна быть логика отправки email с кодом
      // Для демонстрации используем статический код
      _verificationCode = generate6DigitCode();
      _showVerificationDialog();
    }

    void _saveProfile() {
      if (_formKey.currentState?.validate() ?? false) {
        _sendVerificationCode(_emailController.text.trim());
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF8BBE81),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Кнопка назад
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFFCEDD4C),
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            // Заголовок
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Изменение профиля',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Основная форма
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 12, bottom: 24),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32), bottom: Radius.circular(32)),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/plant_header.png',
                              fit: BoxFit.fill,
                              height: 80,
                              width: 80,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Изменить фото',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Имя',
                            style: TextStyle(color: Color(0xFF4B8A4B)),
                          ),
                        ),
                        TextFormField(
                          controller: _nameController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty || value.length < 2) {
                              return 'Введите корректное имя';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'E-mail',
                            style: TextStyle(color: Color(0xFF4B8A4B)),
                          ),
                        ),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || !EmailValidator.validate(value)) {
                              return 'Введите корректный email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            shape: const StadiumBorder(),
                          ),
                          child: Text(
                            'Изменить пароль',
                            style: TextStyle(color: Colors.green.shade800),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5E8B6E),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            'Сохранить',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
