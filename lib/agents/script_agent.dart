class ScriptAgent {
  static Future<String> generateScript(String product, String concept) async {
    return '''
Duration: 30 seconds
Scene 1: [0-5 sec] - Hook
Scene 2: [5-15 sec] - Product showcase
Scene 3: [15-25 sec] - Benefits
Scene 4: [25-30 sec] - CTA
''';
  }
}