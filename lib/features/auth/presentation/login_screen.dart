import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../onboarding/presentation/onboarding_provider.dart';
import 'auth_controller.dart';
import 'widgets/auth_scaffold.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _submitting = false;
  String? _formError;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _formError = null;
      _emailError = email.isEmpty ? '이메일을 입력하세요.' : null;
      _passwordError = password.isEmpty ? '비밀번호를 입력하세요.' : null;
    });
    if (_emailError != null || _passwordError != null) return;

    setState(() => _submitting = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .login(email: email, password: password);
      // 라우터가 인증 상태를 보고 홈으로 옮긴다.
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        if (error.code == ApiErrorCode.validationError) {
          _emailError = error.fieldMessage('email');
          _passwordError = error.fieldMessage('password');
          if (_emailError == null && _passwordError == null) {
            _formError = error.message;
          }
        } else if (error.code == ApiErrorCode.invalidCredentials) {
          _formError = '이메일 또는 비밀번호가 맞지 않아요.';
        } else {
          _formError = error.message;
        }
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: '다시 만나 반가워요',
      subtitle: '오늘 할 일을 이어서 정리해 봐요.',
      banner: _formError == null ? null : AuthErrorBanner(message: _formError!),
      fields: [
        AppTextField(
          label: '이메일',
          controller: _emailController,
          hintText: 'name@example.com',
          errorText: _emailError,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          enabled: !_submitting,
        ),
        const SizedBox(height: AppSpacing.s20),
        AppTextField(
          label: '비밀번호',
          controller: _passwordController,
          errorText: _passwordError,
          obscureText: true,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          onSubmitted: (_) => _submit(),
          enabled: !_submitting,
        ),
      ],
      action: FilledButton(
        onPressed: _submitting ? null : _submit,
        child: _submitting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text('로그인'),
      ),
      footer: TextButton(
        onPressed: _submitting
            ? null
            : ref.read(onboardingDoneProvider.notifier).restart,
        child: const Text('계정이 없다면 가입하기'),
      ),
    );
  }
}
