import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/typewriter_text.dart';
import '../../auth/presentation/auth_controller.dart';
import 'onboarding_provider.dart';
import 'widgets/onboarding_answer.dart';

/// 계정이 없는 사용자가 앱을 켤 때마다 보는 화면.
///
/// 회원가입 폼을 따로 두지 않고 이 이야기 안에서 받는다. 이 앱은 계획 세우는
/// 일을 대신해 주는 앱이라, 첫 화면부터 한 번에 여러 칸을 채우게 하면 안 된다.
/// 한 화면에 한 문장, 한 번에 한 가지만 묻는다.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

enum _Step { mbti, name, difficulty, promise, together, email, password }

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  _Step _step = _Step.mbti;
  bool _typed = false;
  bool _submitting = false;
  String? _error;
  String _name = '';
  Timer? _autoAdvance;

  /// 답을 받지 않고 스스로 넘어가는 줄과 그 뜸.
  static const Map<_Step, Duration> _autoAdvanceAfter = <_Step, Duration>{
    _Step.difficulty: Duration(milliseconds: 1100),
    _Step.promise: Duration(milliseconds: 1500),
    _Step.together: Duration(milliseconds: 1200),
  };

  @override
  void dispose() {
    _autoAdvance?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _line => switch (_step) {
        _Step.mbti => '당신의 MBTI는 무엇인가요?',
        _Step.name => '이름은 무엇인가요?',
        _Step.difficulty => '계획 세우기 어려우신가요?',
        _Step.promise => '$_name님 계획은 저희가 관리할게요!',
        _Step.together => '저희 함께 시작해봐요',
        _Step.email => '이메일을 알려주세요',
        _Step.password => '비밀번호를 만들어주세요',
      };

  void _onTyped() {
    if (!mounted) return;
    setState(() => _typed = true);
    final delay = _autoAdvanceAfter[_step];
    if (delay != null) _autoAdvance = Timer(delay, _advance);
  }

  void _advance() {
    if (!mounted || _step == _Step.password) return;
    setState(() {
      _step = _Step.values[_step.index + 1];
      _typed = false;
      _error = null;
    });
  }

  void _submitName() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = '이름을 입력해 주세요.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _name = name);
    _advance();
  }

  void _submitEmail() {
    final email = _emailController.text.trim();
    if (!email.contains('@')) {
      setState(() => _error = '이메일 형식이 올바르지 않아요.');
      return;
    }
    FocusScope.of(context).unfocus();
    _advance();
  }

  Future<void> _submitPassword() async {
    if (_submitting) return;
    final password = _passwordController.text;
    if (password.length < 8) {
      setState(() => _error = '비밀번호는 8자 이상으로 만들어 주세요.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).signup(
            email: _emailController.text.trim(),
            password: password,
            nickname: _name,
          );
      // 가입에 성공하면 라우터가 홈으로 옮긴다.
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        if (error.code == ApiErrorCode.emailAlreadyExists) {
          // 이미 있는 계정이면 이메일부터 다시 받는다.
          _step = _Step.email;
          _typed = true;
          _error = '이미 가입된 이메일이에요. 아래에서 로그인해 주세요.';
        } else {
          _error = error.message;
        }
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.espresso,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(child: Center(child: _stage())),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s24,
                  0,
                  AppSpacing.s24,
                  AppSpacing.s16,
                ),
                child: FadeSlideIn(visible: _typed, child: _action()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stage() {
    final field = _field();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TypewriterText(
            key: ValueKey(_step),
            text: _line,
            textAlign: TextAlign.center,
            startDelay: const Duration(milliseconds: 320),
            style: AppTypography.story.copyWith(color: AppColors.onEspresso),
            onCompleted: _onTyped,
          ),
          if (field != null) ...[
            const SizedBox(height: AppSpacing.s32),
            FadeSlideIn(visible: _typed, child: field),
          ],
        ],
      ),
    );
  }

  Widget? _field() {
    switch (_step) {
      case _Step.name:
        return OnboardingField(
          key: const ValueKey('name'),
          controller: _nameController,
          hintText: '이름',
          errorText: _error,
          onSubmitted: _submitName,
        );
      case _Step.email:
        return OnboardingField(
          key: const ValueKey('email'),
          controller: _emailController,
          hintText: 'name@example.com',
          keyboardType: TextInputType.emailAddress,
          errorText: _error,
          onSubmitted: _submitEmail,
        );
      case _Step.password:
        return OnboardingField(
          key: const ValueKey('password'),
          controller: _passwordController,
          hintText: '8자 이상',
          obscureText: true,
          errorText: _error,
          onSubmitted: _submitPassword,
        );
      default:
        return null;
    }
  }

  Widget _action() {
    switch (_step) {
      case _Step.mbti:
        return Column(
          children: [
            OnboardingChoices(
              options: const ['P', 'J'],
              onSelected: (_) => _advance(),
            ),
            const SizedBox(height: AppSpacing.s8),
            TextButton(
              onPressed: ref.read(onboardingDoneProvider.notifier).complete,
              child: Text(
                '이미 계정이 있어요',
                style: AppTypography.caption.copyWith(
                  color: AppColors.onEspressoMuted,
                ),
              ),
            ),
          ],
        );
      case _Step.name:
        return FilledButton(onPressed: _submitName, child: const Text('확인'));
      case _Step.email:
        return FilledButton(onPressed: _submitEmail, child: const Text('다음'));
      case _Step.password:
        return FilledButton(
          onPressed: _submitting ? null : _submitPassword,
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('가입하고 시작하기'),
        );
      case _Step.difficulty:
      case _Step.promise:
      case _Step.together:
        return const SizedBox(height: 54);
    }
  }
}
