import 'package:flutter_test/flutter_test.dart';
import 'package:sebhua_notes/data/models/auth_dtos.dart';

void main() {
  test('EmailSendCodeDto toJson', () {
    expect(
      const EmailSendCodeDto(email: 'user@example.com').toJson(),
      {'email': 'user@example.com'},
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
}
