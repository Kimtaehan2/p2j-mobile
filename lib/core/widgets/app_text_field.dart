import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 라벨이 필드 위에 붙는 입력 필드.
///
/// 서버 검증 오류를 [errorText] 로 그대로 받아 필드 하단에 보여준다.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    required this.controller,
    this.hintText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.autofillHints,
    this.onSubmitted,
    this.enabled = true,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.label.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: AppSpacing.s8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          autofillHints: autofillHints,
          onSubmitted: onSubmitted,
          enabled: enabled,
          style: AppTypography.body,
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}
