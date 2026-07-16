class ProductionAgent {
  static Future<String> generateProductionGuide(String product) async {
    return '''
Shot 1: [5 sec] [Close-up] [Natural Light]
Shot 2: [10 sec] [Medium Shot] [Ring Light]
Shot 3: [10 sec] [Close-up] [Spotlight]
Shot 4: [5 sec] [Wide Shot] [Natural Light]
''';
  }
}