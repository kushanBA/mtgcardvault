class ApiEndpoints {
  static const String baseUrl = "https://api.tradingcard.idea8.cloud/api";

  static const String logIn = "$baseUrl/auth/login";
  static const String register = "$baseUrl/auth/signup";
  static const String logout = "$baseUrl/auth/logout";
  static const String scan = "$baseUrl/scans";
  static const String refreshToken = "$baseUrl/auth/refresh";

  static const String binders = "$baseUrl/binders";
  static const String publicBinders = "$baseUrl/binders/public";
  static String binder(String id) => "$baseUrl/binders/$id";
  static String binderPockets(String id) => "$baseUrl/binders/$id/pockets";
  static String binderPocket(String id, int position) => "$baseUrl/binders/$id/pockets/$position";
}
