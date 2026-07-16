class ReelConceptAgent {
  static Future<String> generateConcepts(String product) async {
    return '''
1. "The Unboxing" — Show product opening + first reaction
2. "The Styling" — Show how to style the product
3. "The Review" — Honest review + pros/cons
4. "The Transformation" — Before/after with product
5. "The Comparison" — Compare with similar products
''';
  }
}