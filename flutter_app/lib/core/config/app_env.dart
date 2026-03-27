import 'package:flutter_dotenv/flutter_dotenv.dart';

final class AppEnv {
  static String get supabaseUrl => _read('SUPABASE_URL');
  static String get supabaseAnonKey => _read('SUPABASE_ANON_KEY');
  static String get ravelryClientId => _read('RAVELRY_CLIENT_ID');
  static String get ravelryAuthorizeUrl =>
      dotenv.maybeGet('RAVELRY_AUTHORIZE_URL') ??
      'https://www.ravelry.com/oauth/authorize';
  static String get ravelryRedirectScheme =>
      dotenv.maybeGet('RAVELRY_REDIRECT_URI_SCHEME') ??
      'lupilup://oauth/ravelry';
  static String get ravelryExchangeFunction =>
      dotenv.maybeGet('SUPABASE_RAVELRY_EXCHANGE_FUNCTION') ??
      'ravelry-exchange-token';

  static String _read(String key) {
    final value = dotenv.maybeGet(key) ?? '';
    if (value.isEmpty) {
      throw StateError('Missing required environment variable: $key');
    }
    return value;
  }
}

