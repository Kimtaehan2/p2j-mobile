import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_text_field.dart';

/// 수동 추가 결과.
class NewTodoInput {
  const NewTodoInput({required this.title, this.estimatedMinutes});

  final String title;
  final int? estimatedMinutes;
}

/// 투두 수동 추가 바텀시트.
///
/// 제목만 필수다. 목표 연결은 이번 범위 밖이라 goal_id 는 항상 비운다.
class AddTodoSheet extends StatefulWidget {
  const AddTodoSheet({super.key});

  static Future<NewTodoInput?> show(BuildContext context) {
    return showModalBottomSheet<NewTodoInput>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddTodoSheet(),
    );
  }

  @override
  State<AddTodoSheet> createState() => _AddTodoSheetState();
}

class _AddTodoSheetState extends State<AddTodoSheet> {
  final _titleController = TextEditingController();
  final _minutesController = TextEditingController();
  String? _titleError;

  @override
  void dispose() {
    _titleController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = '할 일 이름을 입력하세요.');
      return;
    }
    Navigator.of(context).pop(
      NewTodoInput(
        title: title,
        estimatedMinutes: int.tryParse(_minutesController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.screenH,
        right: AppSpacing.screenH,
        top: AppSpacing.s8,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.s24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('할 일 추가', style: AppTypography.titleM),
          const SizedBox(height: AppSpacing.s20),
          AppTextField(
            label: '할 일',
            controller: _titleController,
            hintText: '헬스장 가서 하체 운동',
            errorText: _titleError,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.s16),
          AppTextField(
            label: '예상 소요시간 (선택)',
            controller: _minutesController,
            hintText: '분 단위로 입력',
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            '비워 두면 소요시간 없이 추가됩니다.',
            style: AppTypography.caption.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.s24),
          FilledButton(onPressed: _submit, child: const Text('추가')),
        ],
      ),
    );
  }
}
