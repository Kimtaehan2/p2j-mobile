import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// 로그인/회원가입 화면의 공통 뼈대.
///
/// 한 화면에 질문 하나. 제목을 크게 쓰고 나머지는 비운다.
/// 주요 버튼은 아래에 붙여서 손가락이 닿는 곳에 둔다.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.title,
    required this.fields,
    required this.action,
    this.subtitle,
    this.banner,
    this.footer,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? banner;
  final List<Widget> fields;
  final Widget action;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.of(context).canPop() ? const BackButton() : null,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH,
                    AppSpacing.s8,
                    AppSpacing.screenH,
                    AppSpacing.s24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTypography.titleXL),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.s8),
                        Text(
                          subtitle!,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.s40),
                      if (banner != null) banner!,
                      ...fields,
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  0,
                  AppSpacing.screenH,
                  AppSpacing.s12,
                ),
                child: Column(
                  children: [
                    action,
                    if (footer != null) footer!,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 폼 전체에 걸리는 오류(자격 증명 실패, 네트워크 등) 배너.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.s20),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      decoration: BoxDecoration(
        color: AppColors.dangerSurface,
        borderRadius: BorderRadius.circular(AppRadius.r12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: AppColors.danger,
          ),
          const SizedBox(width: AppSpacing.s8),
          Expanded(
            child: Text(
              message,
              style: AppTypography.caption.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
