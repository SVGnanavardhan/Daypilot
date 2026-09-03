enum VoiceServiceStatus {
  idle,
  listening,
  processing,
  unavailable,
}

class VoiceResult {
  const VoiceResult({
    required this.text,
    required this.isFinal,
  });

  final String text;
  final bool isFinal;
}

abstract class VoiceService {
  VoiceServiceStatus get status;

  Future<bool> initialize();

  Future<void> startListening({
    required void Function(VoiceResult result) onResult,
  });

  Future<void> stopListening();

  Future<void> cancel();
}

class LocalVoiceService implements VoiceService {
  VoiceServiceStatus _status = VoiceServiceStatus.idle;

  @override
  VoiceServiceStatus get status => _status;

  @override
  Future<bool> initialize() async {
    _status = VoiceServiceStatus.idle;
    return true;
  }

  @override
  Future<void> startListening({
    required void Function(VoiceResult result) onResult,
  }) async {
    _status = VoiceServiceStatus.listening;

    // Platform speech-to-text integration will feed results
    // through onResult when connected.
  }

  @override
  Future<void> stopListening() async {
    if (_status == VoiceServiceStatus.listening) {
      _status = VoiceServiceStatus.idle;
    }
  }

  @override
  Future<void> cancel() async {
    _status = VoiceServiceStatus.idle;
  }
}
