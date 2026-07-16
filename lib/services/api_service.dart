class APIService {
  static const String apiVersion = 'v1';
  
  static String get baseUrl => 'https://api.reelgen.ai/$apiVersion';
  
  static String get ordersUrl => '$baseUrl/orders';
  static String get productsUrl => '$baseUrl/products';
  static String get usersUrl => '$baseUrl/users';
}