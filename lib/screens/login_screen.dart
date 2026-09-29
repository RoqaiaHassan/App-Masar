import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'home_screen.dart';

/// شاشة تسجيل الدخول: أول مرة = إنشاء حساب محلي، وبعدها = تسجيل دخول.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _name = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _hide = true;
  String? _error;
  late final bool _register;

  @override
  void initState() {
    super.initState();
    final state = AppScope.read(context);
    _register = !state.hasAccount;
    if (state.hasAccount) _name.text = state.userName;
  }

  @override
  void dispose() {
    _name.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _fail(String message) => setState(() => _error = message);

  Future<void> _submit() async {
    final state = AppScope.read(context);
    final name = _name.text.trim();
    final pass = _pass.text;

    if (name.isEmpty) {
      _fail('اكتب اسمك أولاً');
      return;
    }
    if (pass.length < 4) {
      _fail('كلمة المرور يجب ألا تقل عن 4 أحرف');
      return;
    }
    if (_register) {
      if (pass != _confirm.text) {
        _fail('كلمتا المرور غير متطابقتين');
        return;
      }
      await state.register(name, pass);
    } else if (!state.login(name, pass)) {
      _fail('الاسم أو كلمة المرور غير صحيحة');
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: AppText.body(size: 14.5, weight: FontWeight.w700)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: alpha(AppColors.navy, .25),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.flag_rounded, color: Colors.white, size: 42),
                ),
                const SizedBox(height: 18),
                Text(AppConstants.appName, style: AppText.heading(size: 46, color: AppColors.navy)),
                const SizedBox(height: 6),
                Container(width: 60, height: 3, color: AppColors.gold),
                const SizedBox(height: 10),
                Text(
                  AppConstants.tagline,
                  style: AppText.heading(size: 18, color: AppColors.muted, weight: FontWeight.w400),
                ),
                const SizedBox(height: 28),
                AppCard(
                  radius: 32,
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_register ? 'إنشاء حساب' : 'تسجيل الدخول', style: AppText.heading(size: 26)),
                      const SizedBox(height: 4),
                      Text(
                        _register
                            ? 'أنشئ حسابك المحلي لتبدأ تتبع أهدافك'
                            : 'مرحباً بعودتك، سجّل دخولك لمتابعة أهدافك',
                        style: AppText.body(size: 14, color: AppColors.muted),
                      ),
                      const SizedBox(height: 20),
                      _label('الاسم'),
                      TextField(
                        controller: _name,
                        textInputAction: TextInputAction.next,
                        style: AppText.body(size: 16),
                        decoration: AppInput.decoration(
                          'اكتب اسمك',
                          prefix: Icon(Icons.person_outline_rounded, color: AppColors.muted),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _label('كلمة المرور'),
                      TextField(
                        controller: _pass,
                        obscureText: _hide,
                        textInputAction: _register ? TextInputAction.next : TextInputAction.done,
                        onSubmitted: (_) {
                          if (!_register) _submit();
                        },
                        style: AppText.body(size: 16),
                        decoration: AppInput.decoration(
                          '••••••',
                          prefix: Icon(Icons.lock_outline_rounded, color: AppColors.muted),
                          suffix: IconButton(
                            onPressed: () => setState(() => _hide = !_hide),
                            icon: Icon(
                              _hide ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                      ),
                      if (_register) ...[
                        const SizedBox(height: 14),
                        _label('تأكيد كلمة المرور'),
                        TextField(
                          controller: _confirm,
                          obscureText: _hide,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                          style: AppText.body(size: 16),
                          decoration: AppInput.decoration(
                            '••••••',
                            prefix: Icon(Icons.lock_outline_rounded, color: AppColors.muted),
                          ),
                        ),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: 14),
                        Text(_error!, style: AppText.body(size: 14, color: AppColors.red)),
                      ],
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.navy,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                          ),
                          child: Text(
                            _register ? 'إنشاء الحساب' : 'تسجيل الدخول',
                            style: AppText.body(size: 17, weight: FontWeight.w700, color: Colors.white),
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
    );
  }
}
