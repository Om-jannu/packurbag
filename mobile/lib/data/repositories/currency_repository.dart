import '../api_client.dart';

/// Small shared helper for cross-currency conversion, backed by the same
/// `/currency/rates` proxy the Currency Converter screen uses.
class CurrencyRepository {
  CurrencyRepository(this._client);

  final ApiClient _client;

  /// USD-based rates: `1 USD == rates[code] code`.
  Future<Map<String, double>> fetchUsdBaseRates() async {
    final response = await _client.get('/currency/rates');
    final rates = response['rates'];
    if (rates is! Map) return {};
    return rates.map((code, value) => MapEntry(code as String, (value as num).toDouble()));
  }

  double convert({
    required double amount,
    required String from,
    required String to,
    required Map<String, double> usdBaseRates,
  }) {
    if (from == to) return amount;
    final fromRate = usdBaseRates[from];
    final toRate = usdBaseRates[to];
    if (fromRate == null || toRate == null) return amount;
    final usdAmount = amount / fromRate;
    return usdAmount * toRate;
  }
}
