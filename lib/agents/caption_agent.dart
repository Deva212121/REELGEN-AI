class CaptionAgent {
  static Future<String> generateCaption(String product) async {
    return '''
✨ The $product you've been waiting for!
Limited stock — grab yours before it's gone!
Link in bio 👆
''';
  }
}