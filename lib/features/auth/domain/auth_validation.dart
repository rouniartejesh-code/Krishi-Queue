import 'user_role.dart';

String normalizeAuthDigits(String input) {
  const devanagari = '०१२३४५६७८९';
  return input.split('').map((character) {
    final index = devanagari.indexOf(character);
    return index < 0 ? character : '$index';
  }).join();
}

String? normalizeIndianMobile(String input) {
  var digits = normalizeAuthDigits(input).replaceAll(RegExp(r'[\s()-]'), '');
  if (digits.startsWith('+91')) digits = digits.substring(3);
  return RegExp(r'^[6-9]\d{9}$').hasMatch(digits) ? '+91$digits' : null;
}

bool isValidOtp(String input) =>
    RegExp(r'^\d{6}$').hasMatch(normalizeAuthDigits(input).trim());

/// Claims must come from a trusted backend. Unknown roles never grant access.
UserRole? roleFromClaims(Map<String, dynamic>? claims) =>
    switch (claims?['role']) {
      null || 'farmer' => UserRole.farmer,
      'staff' => UserRole.staff,
      'driver' => UserRole.driver,
      'admin' => UserRole.admin,
      _ => null,
    };
