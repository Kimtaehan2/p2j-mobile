import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 화면 전체 로딩.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.ink,
        ),
      ),
    );
  }
}
