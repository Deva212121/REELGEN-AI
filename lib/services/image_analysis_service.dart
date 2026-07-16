import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';

class ImageAnalysisService {
  final TextRecognizer _textRecognizer = GoogleMlKit.vision.textRecognizer();

  Future<String> analyzeImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      String extractedText = '';
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          extractedText += '${line.text} ';
        }
      }

      return extractedText.isEmpty
          ? 'No text detected in the image. Please try with a clearer image.'
          : extractedText;
    } catch (e) {
      throw Exception('Image analysis failed: $e');
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}