import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/settings/app_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../data/auth_service.dart';
import '../domain/auth_validation.dart';
import '../domain/user_role.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.onLoginSuccess, this.onContinueOffline});

  final ValueChanged<UserRole>? onLoginSuccess;
  final VoidCallback? onContinueOffline;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController();
  final _otp = TextEditingController();
  // Firebase web initialization can finish after the startup timeout on a slow
  // connection. Resolve again for each attempt rather than caching failure.
  AuthService? get _service => AuthService.tryCreate();
  Timer? _cooldownTimer;
  Timer? _requestTimer;
  ConfirmationResult? _webConfirmation;
  String? _verificationId;
  String? _requestedPhone;
  String? _message;
  int? _resendToken;
  int _cooldown = 0;
  int _operation = 0;
  bool _otpSent = false;
  bool _loading = false;
  bool _signingIn = false;
  bool _completed = false;

  String _t(String en, String hi) => AppPreferences.instance.text(en, hi);
  bool _active(int operation) =>
      mounted && !_completed && operation == _operation;

  @override
  void dispose() {
    _operation++;
    _cooldownTimer?.cancel();
    _requestTimer?.cancel();
    _phone.dispose();
    _otp.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted || _completed) return;
    setState(() => _message = message);
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    _cooldown = 60;
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _cooldown <= 1) {
        timer.cancel();
        if (mounted) setState(() => _cooldown = 0);
      } else {
        setState(() => _cooldown--);
      }
    });
  }

  Future<void> _sendOtp() async {
    if (_loading || _cooldown > 0 || _completed) return;
    final service = _service;
    if (service == null) {
      _showMessage(
        _t(
          'Sign-in is unavailable in this build. You can still use offline help.',
          'इस ऐप में अभी साइन इन उपलब्ध नहीं है। ऑफलाइन मदद का उपयोग कर सकते हैं।',
        ),
      );
      return;
    }
    if (!AuthService.supportsPhone) {
      _showMessage(
        _t(
          'Use the Android app or web app for mobile sign-in.',
          'मोबाइल से साइन इन करने के लिए Android या वेब ऐप खोलें।',
        ),
      );
      return;
    }
    final mobile = normalizeIndianMobile(_phone.text);
    if (mobile == null) {
      _showMessage(
        _t(
          'Enter a valid 10-digit Indian mobile number.',
          'भारत का सही 10 अंकों का मोबाइल नंबर लिखें।',
        ),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    final operation = ++_operation;
    setState(() {
      _loading = true;
      _message = null;
      _requestedPhone = mobile;
    });
    _startCooldown();
    _requestTimer?.cancel();
    _requestTimer = Timer(const Duration(seconds: 45), () {
      if (!_active(operation)) return;
      setState(() {
        _loading = false;
        _message = _t(
          'The connection is slow. If an SMS arrives, enter its code. Otherwise wait, then retry.',
          'कनेक्शन धीमा है। SMS आए तो उसका कोड लिखें। नहीं आए तो थोड़ी देर बाद फिर कोशिश करें।',
        );
      });
    });

    try {
      await service.auth.setLanguageCode(
        AppPreferences.instance.hindi ? 'hi' : 'en',
      );
      if (!_active(operation)) return;
      if (kIsWeb) {
        final confirmation = await service.auth.signInWithPhoneNumber(mobile);
        if (!_active(operation)) return;
        _webConfirmation = confirmation;
        _onCodeSent(operation);
      } else {
        await service.auth.verifyPhoneNumber(
          phoneNumber: mobile,
          timeout: const Duration(seconds: 60),
          forceResendingToken: _resendToken,
          verificationCompleted: (credential) async {
            if (!_active(operation) || _signingIn) return;
            _signingIn = true;
            _requestTimer?.cancel();
            setState(() => _loading = true);
            try {
              await service.auth
                  .signInWithCredential(credential)
                  .timeout(const Duration(seconds: 30));
              if (_active(operation)) await _finishLogin(operation);
            } catch (error) {
              if (_active(operation)) _showMessage(_errorText(error));
            } finally {
              _signingIn = false;
              if (_active(operation)) setState(() => _loading = false);
            }
          },
          verificationFailed: (error) {
            if (!_active(operation)) return;
            _requestTimer?.cancel();
            setState(() => _loading = false);
            _showMessage(_errorText(error));
          },
          codeSent: (verificationId, resendToken) {
            if (!_active(operation) || _signingIn) return;
            _verificationId = verificationId;
            _resendToken = resendToken;
            _onCodeSent(operation);
          },
          codeAutoRetrievalTimeout: (verificationId) {
            if (_active(operation)) _verificationId = verificationId;
          },
        );
      }
    } catch (error) {
      if (!_active(operation)) return;
      _requestTimer?.cancel();
      setState(() => _loading = false);
      _showMessage(_errorText(error));
    }
  }

  void _onCodeSent(int operation) {
    if (!_active(operation)) return;
    _requestTimer?.cancel();
    _otp.clear();
    setState(() {
      _loading = false;
      _otpSent = true;
      _message = null;
    });
  }

  Future<void> _verifyOtp() async {
    if (_loading || _signingIn || _completed) return;
    if (!isValidOtp(_otp.text)) {
      _showMessage(
        _t(
          'Enter the 6-digit code from the SMS.',
          'SMS में आया 6 अंकों का कोड लिखें।',
        ),
      );
      return;
    }
    final service = _service;
    if (service == null ||
        (kIsWeb ? _webConfirmation == null : _verificationId == null)) {
      _showMessage(
        _t(
          'Request a new code to continue.',
          'जारी रखने के लिए नया कोड मँगाएँ।',
        ),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    final operation = _operation;
    setState(() {
      _loading = true;
      _signingIn = true;
      _message = null;
    });
    try {
      final code = normalizeAuthDigits(_otp.text).trim();
      if (kIsWeb) {
        await _webConfirmation!
            .confirm(code)
            .timeout(const Duration(seconds: 30));
      } else {
        await service.auth
            .signInWithCredential(
              PhoneAuthProvider.credential(
                verificationId: _verificationId!,
                smsCode: code,
              ),
            )
            .timeout(const Duration(seconds: 30));
      }
      if (_active(operation)) await _finishLogin(operation);
    } catch (error) {
      if (_active(operation)) _showMessage(_errorText(error));
    } finally {
      _signingIn = false;
      if (_active(operation)) setState(() => _loading = false);
    }
  }

  Future<void> _googleLogin() async {
    if (_loading || _signingIn || _completed) return;
    final service = _service;
    if (service == null) {
      _showMessage(
        _t(
          'Sign-in is unavailable. Offline help is still available.',
          'साइन इन उपलब्ध नहीं है। ऑफलाइन मदद उपलब्ध है।',
        ),
      );
      return;
    }
    final operation = ++_operation;
    _requestTimer?.cancel();
    setState(() {
      _loading = true;
      _signingIn = true;
      _message = null;
    });
    try {
      await service.signInWithGoogle().timeout(const Duration(minutes: 2));
      if (_active(operation)) await _finishLogin(operation);
    } catch (error) {
      if (_active(operation)) _showMessage(_errorText(error));
    } finally {
      _signingIn = false;
      if (_active(operation)) setState(() => _loading = false);
    }
  }

  Future<void> _finishLogin(int operation) async {
    final role = await _service!.currentRole();
    if (!_active(operation)) return;
    if (role == null) throw FirebaseAuthException(code: 'user-not-found');
    _completed = true;
    _cooldownTimer?.cancel();
    _requestTimer?.cancel();
    TextInput.finishAutofillContext();
    widget.onLoginSuccess?.call(role);
  }

  void _changeMobile() {
    _operation++;
    _requestTimer?.cancel();
    _otp.clear();
    setState(() {
      _otpSent = false;
      _verificationId = null;
      _webConfirmation = null;
      _resendToken = null;
      _message = null;
      _loading = false;
    });
  }

  String _errorText(Object error) {
    if (error is TimeoutException) {
      return _t(
        'The connection is slow. Please wait a moment, then try again. Offline help is available below.',
        'कनेक्शन धीमा है। थोड़ी देर बाद फिर कोशिश करें। नीचे ऑफलाइन मदद उपलब्ध है।',
      );
    }
    if (error is GoogleSignInException) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return _t(
          'Google sign-in was closed. You can try again or use your mobile number.',
          'Google साइन इन बंद हो गया। फिर कोशिश करें या मोबाइल नंबर का उपयोग करें।',
        );
      }
      return _t(
        'Google sign-in is not available right now. Try mobile sign-in or offline help.',
        'अभी Google से साइन इन उपलब्ध नहीं है। मोबाइल या ऑफलाइन मदद का उपयोग करें।',
      );
    }
    final code = error is FirebaseAuthException ? error.code : '';
    return switch (code) {
      'invalid-phone-number' => _t(
        'Check your mobile number.',
        'अपना मोबाइल नंबर जाँचें।',
      ),
      'invalid-verification-code' || 'invalid-credential' => _t(
        'The code or sign-in details could not be verified. Please try again.',
        'कोड या साइन इन की जानकारी सही नहीं है। फिर कोशिश करें।',
      ),
      'session-expired' || 'code-expired' => _t(
        'This code has expired. Request a new code.',
        'यह कोड पुराना हो गया है। नया कोड मँगाएँ।',
      ),
      'too-many-requests' || 'quota-exceeded' => _t(
        'Too many attempts. Please try later. You can use offline help now.',
        'बहुत बार कोशिश की गई है। बाद में फिर कोशिश करें। अभी ऑफलाइन मदद ले सकते हैं।',
      ),
      'network-request-failed' => _t(
        'Could not connect. Check your network or use offline help.',
        'कनेक्शन नहीं हुआ। नेटवर्क जाँचें या ऑफलाइन मदद लें।',
      ),
      'popup-closed-by-user' || 'cancelled-popup-request' => _t(
        'Sign-in was closed. Try again when you are ready.',
        'साइन इन बंद हो गया। तैयार होने पर फिर कोशिश करें।',
      ),
      'popup-blocked' => _t(
        'Allow the sign-in pop-up in your browser, then try again.',
        'ब्राउज़र में साइन इन पॉप-अप की अनुमति दें और फिर कोशिश करें।',
      ),
      'operation-not-allowed' ||
      'unauthorized-domain' ||
      'app-not-authorized' ||
      'invalid-app-credential' => _t(
        'This sign-in option is not ready for this app. Try another option or offline help.',
        'इस ऐप में यह साइन इन विकल्प अभी तैयार नहीं है। दूसरा विकल्प या ऑफलाइन मदद चुनें।',
      ),
      'account-exists-with-different-credential' => _t(
        'Use the sign-in method you used for this account earlier.',
        'इस खाते के लिए पहले वाला साइन इन तरीका उपयोग करें।',
      ),
      'user-disabled' => _t(
        'This account is disabled. Contact the app operator.',
        'यह खाता बंद है। ऐप संचालक से संपर्क करें।',
      ),
      'invalid-role' => _t(
        'Access could not be verified. Contact your centre administrator.',
        'खाते की पहुँच सत्यापित नहीं हुई। केंद्र के व्यवस्थापक से संपर्क करें।',
      ),
      'unsupported-platform' => _t(
        'Use the Android app or web app for sign-in.',
        'साइन इन के लिए Android या वेब ऐप का उपयोग करें।',
      ),
      _ => _t(
        'Sign-in did not finish. Try again, or use offline help.',
        'साइन इन पूरा नहीं हुआ। फिर कोशिश करें या ऑफलाइन मदद लें।',
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final preferences = AppPreferences.of(context);
    final t = preferences.text;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.grass_rounded,
                          color: AppTheme.primaryGreen,
                          size: 34,
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () =>
                              preferences.setHindi(!preferences.hindi),
                          icon: const Icon(Icons.translate_rounded, size: 20),
                          label: Text(preferences.hindi ? 'English' : 'हिंदी'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Krishi Queue',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t(
                        'Less waiting. A better prepared visit.',
                        'कम इंतज़ार। केंद्र जाने की बेहतर तैयारी।',
                      ),
                      style: const TextStyle(fontSize: 18, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t(
                        'Chhattisgarh • Farmer support',
                        'छत्तीसगढ़ • किसान सहायता',
                      ),
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 28),
                    if (widget.onContinueOffline != null) ...[
                      OutlinedButton.icon(
                        onPressed: _signingIn
                            ? null
                            : () {
                                _operation++;
                                widget.onContinueOffline!();
                              },
                        icon: const Icon(Icons.offline_bolt_outlined),
                        label: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            t(
                              'Continue without signing in',
                              'बिना साइन इन किए आगे बढ़ें',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t(
                          'Read guides, prepare your visit and get basic help. No OTP needed.',
                          'जानकारी पढ़ें, केंद्र जाने की तैयारी करें और मदद लें। OTP की ज़रूरत नहीं।',
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Divider(),
                      ),
                    ],
                    Text(
                      t(
                        'Sign in to your account',
                        'अपने खाते में साइन इन करें',
                      ),
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t(
                        'Staff and drivers use their registered account here too.',
                        'कर्मचारी और चालक भी यहाँ अपने पंजीकृत खाते से साइन इन करें।',
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (!_otpSent)
                      TextField(
                        controller: _phone,
                        enabled: !_loading,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [
                          AutofillHints.telephoneNumberNational,
                        ],
                        maxLength: 16,
                        onSubmitted: (_) => _sendOtp(),
                        decoration: InputDecoration(
                          labelText: t('Mobile number', 'मोबाइल नंबर'),
                          hintText: t('10-digit number', '10 अंकों का नंबर'),
                          prefixIcon: const Icon(Icons.phone_outlined),
                          prefixText: '+91  ',
                          counterText: '',
                        ),
                      )
                    else ...[
                      Text(
                        t(
                          'Enter the SMS code sent to $_requestedPhone',
                          '$_requestedPhone पर SMS में आया कोड लिखें',
                        ),
                        style: const TextStyle(height: 1.5),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _otp,
                        enabled: !_loading,
                        keyboardType: TextInputType.number,
                        autofillHints: const [AutofillHints.oneTimeCode],
                        maxLength: 6,
                        onSubmitted: (_) => _verifyOtp(),
                        style: const TextStyle(fontSize: 24, letterSpacing: 6),
                        decoration: InputDecoration(
                          labelText: t('6-digit OTP', '6 अंकों का OTP'),
                          counterText: '',
                        ),
                      ),
                    ],
                    if (_message != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Semantics(
                          liveRegion: true,
                          child: Text(
                            _message!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _loading || (!_otpSent && _cooldown > 0)
                          ? null
                          : (_otpSent ? _verifyOtp : _sendOtp),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: _loading
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                      t('Please wait…', 'कृपया रुकें…'),
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                _otpSent
                                    ? t(
                                        'Verify and continue',
                                        'सत्यापित करें और आगे बढ़ें',
                                      )
                                    : _cooldown > 0
                                    ? t(
                                        'Try again in $_cooldown s',
                                        '$_cooldown सेकंड बाद फिर कोशिश करें',
                                      )
                                    : t('Send OTP', 'OTP भेजें'),
                              ),
                      ),
                    ),
                    if (_otpSent)
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: _loading || _cooldown > 0
                                ? null
                                : _sendOtp,
                            child: Text(
                              _cooldown > 0
                                  ? t(
                                      'Resend in $_cooldown s',
                                      '$_cooldown सेकंड बाद नया कोड',
                                    )
                                  : t('Resend OTP', 'नया OTP मँगाएँ'),
                            ),
                          ),
                          TextButton(
                            onPressed: _signingIn ? null : _changeMobile,
                            child: Text(t('Change number', 'नंबर बदलें')),
                          ),
                        ],
                      ),
                    const SizedBox(height: 14),
                    if (AuthService.supportsGoogle)
                      OutlinedButton.icon(
                        onPressed: _loading ? null : _googleLogin,
                        icon: const Icon(Icons.account_circle_outlined),
                        label: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            t('Continue with Google', 'Google से साइन इन करें'),
                          ),
                        ),
                      ),
                    const SizedBox(height: 18),
                    Text(
                      t(
                        'By requesting an OTP, you agree to receive an SMS for sign-in. Google processes your number to prevent abuse. Never share your OTP with anyone.',
                        'OTP मँगाने पर आप साइन इन के लिए SMS पाने की सहमति देते हैं। दुरुपयोग रोकने के लिए Google आपका नंबर संसाधित करता है। अपना OTP किसी को न बताएँ।',
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.6,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.lightOrange,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        t(
                          'Signing in verifies access to your account. Government farmer registration and procurement eligibility must be confirmed by the authorised centre.',
                          'साइन इन से आपके खाते की पहचान होती है। सरकारी किसान पंजीकरण और धान खरीदी की पात्रता की पुष्टि अधिकृत केंद्र से कराएँ।',
                        ),
                        style: const TextStyle(height: 1.5, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
