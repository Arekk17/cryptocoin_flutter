import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Krypto Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial',
      ),
      home: CryptoListPage(),
    );
  }
}

class CryptoListPage extends StatefulWidget {
  @override
  _CryptoListPageState createState() => _CryptoListPageState();
}

class _CryptoListPageState extends State<CryptoListPage>
    with SingleTickerProviderStateMixin {
  List _cryptos = [];
  List _filteredCryptos = [];
  Set<String> _favorites = {};
  late TabController _tabController;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCryptoData();
    _loadFavorites();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_filterCryptos);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCryptoData() async {
    var url = Uri.parse(
        'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false');
    var response = await http.get(url);
    var responseBody = json.decode(response.body);

    setState(() {
      _cryptos = responseBody;
      _filteredCryptos =
          responseBody; // Initialize filtered list with all cryptos
    });
  }

  Future<void> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites = Set<String>.from(prefs.getStringList('favorites') ?? []);
    });
  }

  void _filterCryptos() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCryptos = _cryptos.where((crypto) {
        return crypto['name'].toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _toggleFavorite(String cryptoId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favorites.contains(cryptoId)) {
        _favorites.remove(cryptoId);
      } else {
        _favorites.add(cryptoId);
      }
      prefs.setStringList('favorites', _favorites.toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Krypto Tracker'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All Cryptos'),
            Tab(text: 'Favorites'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Cryptos',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                RefreshIndicator(
                  onRefresh: _loadCryptoData,
                  child: _buildCryptoList(),
                ),
                _buildFavoritesList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoList() {
    return ListView.builder(
      itemCount: _filteredCryptos.length,
      itemBuilder: (context, index) {
        var crypto = _filteredCryptos[index];
        double change = crypto['price_change_percentage_24h'] ?? 0;
        Color changeColor = change >= 0 ? Colors.green : Colors.red;
        bool isFavorite = _favorites.contains(crypto['id']);

        return ListTile(
          title: Text(
            crypto['name'],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Aktualna cena: \$${crypto['current_price']}\nZmiana 24h: ${change.toStringAsFixed(2)}%',
            style: TextStyle(color: changeColor),
          ),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(crypto['image']),
          ),
          trailing: IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            onPressed: () => _toggleFavorite(crypto['id']),
          ),
        );
      },
    );
  }

  Widget _buildFavoritesList() {
    List favoriteCryptos =
        _cryptos.where((crypto) => _favorites.contains(crypto['id'])).toList();

    return ListView.builder(
      itemCount: favoriteCryptos.length,
      itemBuilder: (context, index) {
        var crypto = favoriteCryptos[index];
        double change = crypto['price_change_percentage_24h'] ?? 0;
        Color changeColor = change >= 0 ? Colors.green : Colors.red;

        return ListTile(
          title: Text(
            crypto['name'],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Aktualna cena: \$${crypto['current_price']}\nZmiana 24h: ${change.toStringAsFixed(2)}%',
            style: TextStyle(color: changeColor),
          ),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(crypto['image']),
          ),
          trailing: IconButton(
            icon: Icon(Icons.favorite, color: Colors.red),
            onPressed: () => _toggleFavorite(crypto['id']),
          ),
        );
      },
    );
  }
}
