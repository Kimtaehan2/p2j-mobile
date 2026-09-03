import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// 음성 입력의 상태.
enum VoiceStatus {
  /// 아직 시작하지 않음.
  idle,

  /// 듣는 중.
  listening,

  /// 말이 끝나 인식 결과를 들고 있음.
  done,

  /// 마이크 권한이 없거나 기기에 음성 인식기가 없음.
  unavailable,
}

/// 마이크로 받아 적는 일만 한다.
///
/// 받아 적은 문장을 할 일로 쪼개는 건 서버가 할 일이다. 지금은 문장을
/// 그대로 제목으로 넘긴다. `/ai/parse` 가 붙으면 여기서 그쪽으로 보낸다.
class VoiceInputController extends ChangeNotifier {
  VoiceInputController({SpeechToText? speech})
      : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;

  VoiceStatus _status = VoiceStatus.idle;
  String _text = '';
  String? _errorMessage;

  VoiceStatus get status => _status;

  /// 지금까지 받아 적은 문장. 듣는 동안에도 계속 갱신된다.
  String get text => _text;

  String? get errorMessage => _errorMessage;

  bool get isListening => _status == VoiceStatus.listening;

  Future<void> start() async {
    _errorMessage = null;

    final ready = await _speech.initialize(
      onStatus: _handleStatus,
      onError: (error) => _fail('잘 못 들었어요. 다시 한 번 말씀해 주세요.'),
    );
    if (!ready) {
      _fail('마이크를 쓸 수 없어요. 권한을 켜고 다시 시도해 주세요.');
      return;
    }

    _text = '';
    _status = VoiceStatus.listening;
    notifyListeners();

    await _speech.listen(
      listenOptions: SpeechListenOptions(
        localeId: 'ko_KR',
        partialResults: true,
        cancelOnError: true,
      ),
      onResult: (result) {
        _text = result.recognizedWords;
        notifyListeners();
      },
    );
  }

  Future<void> stop() async {
    await _speech.stop();
    _status = _text.trim().isEmpty ? VoiceStatus.idle : VoiceStatus.done;
    notifyListeners();
  }

  Future<void> cancel() async {
    await _speech.cancel();
    _text = '';
    _status = VoiceStatus.idle;
    notifyListeners();
  }

  void _handleStatus(String status) {
    // 사용자가 말을 멈추면 플러그인이 알아서 끝낸다.
    if (status != 'done' && status != 'notListening') return;
    if (_status != VoiceStatus.listening) return;
    _status = _text.trim().isEmpty ? VoiceStatus.idle : VoiceStatus.done;
    notifyListeners();
  }

  void _fail(String message) {
    _status = VoiceStatus.unavailable;
    _errorMessage = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }
}
