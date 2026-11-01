import 'package:flutter_test/flutter_test.dart';
import 'package:krishi_queue/features/auth/domain/auth_validation.dart';
import 'package:krishi_queue/features/auth/domain/user_role.dart';

void main() {
  test('mobile input accepts Hindi digits and pasted country code', () {
    expect(normalizeIndianMobile('९८७६५४३२१०'), '+919876543210');
    expect(normalizeIndianMobile('+91 98765-43210'), '+919876543210');
    expect(normalizeIndianMobile('9876543210'), '+919876543210');
  });
  test('malformed mobile and OTP inputs are rejected', () {
    for (final input in [
      '1234567890',
      '987654321',
      '+1 9876543210',
      '98abc43210',
    ]) {
      expect(normalizeIndianMobile(input), isNull);
    }
    expect(isValidOtp('१२३४५६'), isTrue);
    expect(isValidOtp('abcdef'), isFalse);
    expect(isValidOtp('12345'), isFalse);
    expect(isValidOtp('1234567'), isFalse);
  });
  test('only recognised server role claims can grant staff access', () {
    expect(roleFromClaims(null), UserRole.farmer);
    expect(roleFromClaims({'role': 'staff'}), UserRole.staff);
    expect(roleFromClaims({'role': 'driver'}), UserRole.driver);
    expect(roleFromClaims({'role': 'admin'}), UserRole.admin);
    expect(roleFromClaims({'role': 'ADMIN'}), isNull);
    expect(roleFromClaims({'role': true}), isNull);
    expect(
      roleFromClaims({
        'role': ['admin'],
      }),
      isNull,
    );
    expect(roleFromClaims({'admin': true}), UserRole.farmer);
  });
}
