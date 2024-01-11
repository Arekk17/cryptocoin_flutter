import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List> loadCryptoData() async {
  var url = Uri.parse(
      'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false');
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    return jsonResponse;
  } else {
    throw Exception('Failed to load crypto data');
  }
}

Future<List> loadCryptoHistory(String cryptoId) async {
  var url = Uri.parse(
      'https://api.coingecko.com/api/v3/coins/$cryptoId/market_chart?vs_currency=usd&days=30&interval=daily');
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    return jsonResponse['prices']; // Zakładając, że interesują nas ceny
  } else {
    throw Exception('Failed to load crypto history data');
  }
}
