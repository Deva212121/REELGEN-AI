import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class VoiceRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  String? _currentPath;

  Future<String> startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        _currentPath = path;
        await _recorder.start(
          RecordConfig(
            encoder: AudioEncoder.aacLc,
            sampleRate: 44100,
            bitRate: 128000,
          ),
          path: path,
        );
        return path;
      } else {
        throw Exception('Microphone permission denied');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> stopRecording() async {
    try {
      final path = await _recorder.stop();
      _currentPath = null;
      return path ?? '';
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  void dispose() {
    _recorder.dispose();
  }
}