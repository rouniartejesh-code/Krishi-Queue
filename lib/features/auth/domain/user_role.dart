enum UserRole {
  farmer,
  staff,
  driver,
  admin,
}

extension UserRoleDetails on UserRole {
  String get label {
    switch (this) {
      case UserRole.farmer:
        return 'Farmer';
      case UserRole.staff:
        return 'Staff';
      case UserRole.driver:
        return 'Driver';
      case UserRole.admin:
        return 'Admin';
    }
  }

  String get title {
    switch (this) {
      case UserRole.farmer:
        return 'Farmer Login';
      case UserRole.staff:
        return 'Staff Login';
      case UserRole.driver:
        return 'Driver Login';
      case UserRole.admin:
        return 'Admin Login';
    }
  }

  String get subtitle {
    switch (this) {
      case UserRole.farmer:
        return 'Book procurement slots and track your payment.';
      case UserRole.staff:
        return 'Manage queue and procurement-centre operations.';
      case UserRole.driver:
        return 'View assigned vehicles and arrival status.';
      case UserRole.admin:
        return 'Monitor centre operations and procurement status.';
    }
  }

  String get demoPhone {
    switch (this) {
      case UserRole.farmer:
        return '9000000001';
      case UserRole.staff:
        return '9000000002';
      case UserRole.driver:
        return '9000000003';
      case UserRole.admin:
        return '9000000004';
    }
  }
}
