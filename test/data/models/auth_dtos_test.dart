import 'package:flutter_test/flutter_test.dart';
import 'package:sebhua_notes/data/models/auth_dtos.dart';

void main() {
  test('EmailSendCodeDto toJson includes purpose', () {
    expect(
      const EmailSendCodeDto(
        email: 'user@example.com',
        purpose: EmailCodePurpose.register,
      ).toJson(),
      {
        'email': 'user@example.com',
        'purpose': 'register',
      },
    );
    expect(
      const EmailSendCodeDto(
        email: 'user@example.com',
        purpose: EmailCodePurpose.resetPassword,
      ).toJson(),
      {
        'email': 'user@example.com',
        'purpose': 'reset_password',
      },
    );
  });

  test('EmailRegisterDto toJson', () {
    expect(
      const EmailRegisterDto(
        email: 'user@example.com',
        password: 'Abc12345',
        code: '482931',
      ).toJson(),
      {
        'email': 'user@example.com',
        'password': 'Abc12345',
        'code': '482931',
      },
    );
  });

  test('EmailResetPasswordDto toJson', () {
    expect(
      const EmailResetPasswordDto(
        email: 'user@example.com',
        password: 'Abc12345',
        code: '482931',
      ).toJson(),
      {
        'email': 'user@example.com',
        'password': 'Abc12345',
        'code': '482931',
      },
    );
  });
}
