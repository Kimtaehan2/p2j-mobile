import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_illustrations.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../voice_input_controller.dart';
import 'mic_button.dart';

/// 수동 추가 결과.
class NewTodoInput {
  const NewTodoInput({required this.title, this.estimatedMinutes});

  final String title;
  final int? estimatedMinutes;
}

/// 할 일 추가 바텀시트.
///
/// 말하는 게 기본이다. 이 앱은 계획 세우는 일을 대신해 주는 앱이라,
/// 사용자가 문장을 다듬어 입력할 필요가 없어야 한다. 타이핑은 빠져나갈
/// 길로만 둔다.
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
  final _voice = VoiceInputController();
  final _titleController = TextEditingController();
  final _minutesController = TextEditingController();

  /// 타이핑으로 넘어왔는지. 한 번 넘어오면 되돌아가지 않는다.
  bool _typing = false;
  String? _titleError;

  @override
  void initState() {
    super.initState();
    _voice.addListener(_onVoiceChanged);
  }

  @override
  void dispose() {
    _voice
      ..removeListener(_onVoiceChanged)
      ..dispose();
    _titleController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  void _onVoiceChanged() {
    if (!mounted) return;
    // 말이 끝나면 받아 적은 문장을 그대로 들고 타이핑 화면으로 넘긴다.
    // 고칠 게 있으면 고치고 없으면 바로 추가하면 된다.
    if (_voice.status == VoiceStatus.done && !_typing) {
      _titleController.text = _voice.text;
      setState(() => _typing = true);
      return;
    }
    setState(() {});
  }

  Future<void> _toggleListening() async {
    if (_voice.isListening) {
      await _voice.stop();
    } else {
      await _voice.start();
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = '무엇을 할지 알려주세요.');
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
      child: _typing ? _typingView() : _voiceView(),
    );
  }

  Widget _voiceView() {
    final listening = _voice.isListening;
    final failed = _voice.status == VoiceStatus.unavailable;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          AppIllustrations.voiceInput,
          height: 130,
          fit: BoxFit.contain,
        ),
        Text(
          listening ? '듣고 있어요' : '무엇을 할지 말해 주세요',
          style: AppTypography.titleM,
        ),
        const SizedBox(height: AppSpacing.s8),
        Text(
          listening
              ? _voice.text.isEmpty
                  ? '편하게 말씀하세요'
                  : _voice.text
              : '"내일까지 발표 자료 만들어야 해" 처럼 편하게요',
          textAlign: TextAlign.center,
          style: AppTypography.caption.copyWith(
            color: listening && _voice.text.isNotEmpty
                ? AppColors.ink
                : AppColors.muted,
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        MicButton(listening: listening, onTap: _toggleListening),
        if (failed) ...[
          Text(
            _voice.errorMessage ?? '마이크를 쓸 수 없어요.',
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(color: AppColors.danger),
          ),
          const SizedBox(height: AppSpacing.s12),
        ],
        TextButton(
          onPressed: () => setState(() => _typing = true),
          child: const Text('직접 쓸게요'),
        ),
      ],
    );
  }

  Widget _typingView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('무엇을 할까요?', style: AppTypography.titleM),
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
          '비워 두면 소요시간 없이 추가돼요.',
          style: AppTypography.caption.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: AppSpacing.s24),
        FilledButton(onPressed: _submit, child: const Text('추가')),
      ],
    );
  }
}
