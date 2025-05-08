import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:math';

String generate6DigitCode() {
  final random = Random();
  return (100000 + random.nextInt(900000)).toString();
}


Future<void> sendEmailVerificationCode(String recipientEmail, String code) async {
  final smtpServer = SmtpServer(
    'smtp.mail.ru',
    username: 'plantpal@mail.ru',  // Ваш email
    password: 'kk2xdr5nfCNk8Kjjgpx9', // Ваш пароль
    port: 465,  // Порт для SMTP с SSL
    ssl: true,  // Включаем SSL
  );

  final message = Message()
    ..from = const Address('plantpal@mail.ru', 'PlantPal')
    ..recipients.add(recipientEmail)
    ..subject = 'Код подтверждения'
    ..text = 'Ваш код подтверждения: $code';

  try {
    final sendReport = await send(message, smtpServer);
    print('Письмо отправлено: ' + sendReport.toString());
  } on MailerException catch (e) {
    print('Ошибка отправки: $e');
    for (var p in e.problems) {
      print('Проблема: ${p.code}: ${p.msg}');
    }
  }
}
