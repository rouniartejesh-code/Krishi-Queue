import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/user_role.dart';

class LoginScreen extends StatefulWidget {
  final ValueChanged<UserRole>? onLoginSuccess;

  const LoginScreen({super.key, this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserRole _role = UserRole.farmer;

  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _otpSent = false;
  bool _loading = false;

  String? _verificationId;
  int? _resendToken;

  FirebaseAuth? _auth;

  @override
  void initState() {
    super.initState();
    _clearPhone();

    try {
      _auth = FirebaseAuth.instance;
    } on FirebaseException {
      // Keep the login screen usable in previews and show a clear message
      // when Firebase has not been configured for this build.
      _auth = null;
    }
  }

  void _clearPhone() {
    _phoneController.clear();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final auth = _auth;
    if (auth == null) {
      _showMessage('Phone sign-in is not configured for this build.');
      return;
    }

    final phone = _phoneController.text.trim();

    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      _showMessage('Enter a valid 10-digit mobile number.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
    });

    final fullPhoneNumber = '+91$phone';

    try {
      await auth.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,

        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await auth.signInWithCredential(credential);

            if (!mounted) return;

            setState(() {
              _loading = false;
            });

            await _handleSuccessfulLogin(auth);
          } on FirebaseAuthException catch (e) {
            if (!mounted) return;

            setState(() {
              _loading = false;
            });

            _showMessage(_firebaseErrorMessage(e));
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;

          setState(() {
            _loading = false;
          });

          _showMessage(_firebaseErrorMessage(e));
        },

        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;

          setState(() {
            _loading = false;
            _otpSent = true;
            _verificationId = verificationId;
            _resendToken = resendToken;
          });

          _showMessage('OTP sent to +91 $phone');
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },

        forceResendingToken: _resendToken,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _showMessage('Unable to send OTP. Please try again.');
    }
  }

  Future<void> _verifyOtp() async {
    final auth = _auth;
    if (auth == null) {
      _showMessage('Phone sign-in is not configured for this build.');
      return;
    }

    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      _showMessage('Enter the 6-digit OTP.');
      return;
    }

    final verificationId = _verificationId;

    if (verificationId == null) {
      _showMessage('OTP session expired. Please request a new OTP.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      await auth.signInWithCredential(credential);

      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      await _handleSuccessfulLogin(auth);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _showMessage(_firebaseErrorMessage(e));
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _showMessage('OTP verification failed. Please try again.');
    }
  }

  Future<void> _handleSuccessfulLogin(FirebaseAuth auth) async {
    final user = auth.currentUser;

    if (user == null) {
      _showMessage('Authentication failed. Please try again.');
      return;
    }

    try {
      final token = await user.getIdTokenResult(true);
      final roleClaim = token.claims?['role'];
      final authorizedRole = switch (roleClaim) {
        'farmer' => UserRole.farmer,
        'staff' => UserRole.staff,
        'driver' => UserRole.driver,
        'admin' => UserRole.admin,
        null => UserRole.farmer,
        _ => null,
      };

      if (!mounted) return;

      if (authorizedRole == null || authorizedRole != _role) {
        try {
          await auth.signOut();
        } catch (_) {}
        if (!mounted) return;
        _showMessage(
          authorizedRole == null
              ? 'This account has no valid app role. Contact your administrator.'
              : 'This account is not authorized for ${_role.label} access.',
        );
        return;
      }

      widget.onLoginSuccess?.call(authorizedRole);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      try {
        await auth.signOut();
      } catch (_) {}
      _showMessage(_firebaseErrorMessage(error));
    } catch (_) {
      if (!mounted) return;
      try {
        await auth.signOut();
      } catch (_) {}
      _showMessage(
        'Could not verify this account’s app role. Please try again.',
      );
    }
  }

  Future<void> _resendOtp() async {
    if (_loading) return;

    await _sendOtp();
  }

  void _changeRole(UserRole role) {
    if (_loading) return;

    setState(() {
      _role = role;
      _otpSent = false;
      _otpController.clear();
      _verificationId = null;
      _resendToken = null;
      _clearPhone();
    });
  }

  void _changeMobile() {
    if (_loading) return;

    setState(() {
      _otpSent = false;
      _otpController.clear();
      _verificationId = null;
      _resendToken = null;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _firebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'The phone number is invalid.';

      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again later.';

      case 'quota-exceeded':
        return 'OTP quota exceeded. Please try again later.';

      case 'invalid-verification-code':
        return 'Incorrect OTP. Please check the code and try again.';

      case 'session-expired':
        return 'OTP expired. Please request a new OTP.';

      case 'credential-already-in-use':
        return 'This phone number is already linked to another account.';

      case 'network-request-failed':
        return 'Network error. Check your internet connection.';

      case 'operation-not-allowed':
        return 'Phone authentication is not enabled in Firebase.';

      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color: AppTheme.lightOrange,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.agriculture_rounded,
                      size: 44,
                      color: AppTheme.primaryGreen,
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'Krishi Queue',
                    style: TextStyle(fontSize: 31, fontWeight: FontWeight.w900),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Smart procurement, simpler for everyone.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Welcome back',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Choose access',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 10),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.35,
                    children: [
                      _RoleChip(
                        role: UserRole.farmer,
                        selected: _role == UserRole.farmer,
                        onTap: () => _changeRole(UserRole.farmer),
                      ),

                      _RoleChip(
                        role: UserRole.staff,
                        selected: _role == UserRole.staff,
                        onTap: () => _changeRole(UserRole.staff),
                      ),

                      _RoleChip(
                        role: UserRole.driver,
                        selected: _role == UserRole.driver,
                        onTap: () => _changeRole(UserRole.driver),
                      ),

                      _RoleChip(
                        role: UserRole.admin,
                        selected: _role == UserRole.admin,
                        onTap: () => _changeRole(UserRole.admin),
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  Text(
                    _role.title,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    _role.subtitle,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (!_otpSent) ...[
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.phone_outlined),
                        prefixText: '+91  ',
                        hintText: 'Mobile number',
                        counterText: '',
                      ),
                    ),

                    const SizedBox(height: 16),

                    FilledButton(
                      onPressed: _loading ? null : _sendOtp,
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Send OTP',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ] else ...[
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      autofocus: true,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 7,
                      ),
                      decoration: const InputDecoration(
                        hintText: '••••••',
                        counterText: '',
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Enter the OTP sent to +91 ${_phoneController.text.trim()}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 16),

                    FilledButton(
                      onPressed: _loading ? null : _verifyOtp,
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Enter ${_role.label} App',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: _loading ? null : _resendOtp,
                          child: const Text('Resend OTP'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: _loading ? null : _changeMobile,
                          child: const Text('Change mobile'),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 22),

                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8F5),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          size: 18,
                          color: AppTheme.primaryGreen,
                        ),

                        const SizedBox(width: 9),

                        Expanded(
                          child: Text(
                            'Secure login powered by Firebase Phone Authentication.',
                            style: TextStyle(
                              fontSize: 10,
                              height: 1.4,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final UserRole role;
  final bool selected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.role,
    required this.selected,
    required this.onTap,
  });

  IconData get _icon {
    switch (role) {
      case UserRole.farmer:
        return Icons.agriculture_rounded;

      case UserRole.staff:
        return Icons.badge_rounded;

      case UserRole.driver:
        return Icons.local_shipping_rounded;

      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? AppTheme.primaryGreen : Colors.grey.shade200,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _icon,
              size: 20,
              color: selected ? AppTheme.primaryGreen : AppTheme.textSecondary,
            ),

            const SizedBox(width: 8),

            Text(
              role.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: selected ? AppTheme.primaryGreen : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
