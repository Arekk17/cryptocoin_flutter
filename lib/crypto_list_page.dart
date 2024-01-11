import 'package:flutter/material.dart';
import 'shared_prefs_utils.dart'; // Your shared preferences utilities
import 'crypto_api.dart'; // Your crypto API utilities
import 'crypto_detail_page.dart';

class CryptoListPage extends StatefulWidget {
  final Function(bool) toggleTheme;

  CryptoListPage({required this.toggleTheme});

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
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadCryptoData();
    _loadFavorites();
    _loadThemeMode();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_filterCryptos);
  }

  Future<void> _loadThemeMode() async {
    _isDarkMode = await getThemeMode();
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCryptoData() async {
    var cryptoData = await loadCryptoData();
    setState(() {
      _cryptos = cryptoData;
      _filteredCryptos = cryptoData;
    });
  }

  Future<void> _loadFavorites() async {
    var favorites = await loadFavorites();
    setState(() {
      _favorites = favorites;
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
    await toggleFavorite(cryptoId, _favorites);
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Krypto Tracker'),
        actions: <Widget>[
          IconButton(
            icon: Icon(_isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
                widget.toggleTheme(_isDarkMode);
              });
            },
          ),
        ],
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
          onTap: () async {
            var historicalData = await loadCryptoHistory(crypto['id']);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CryptoDetailPage(
                    crypto: crypto, historicalData: historicalData),
              ),
            );
          },
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
            onTap: () async {
              var historicalData = await loadCryptoHistory(crypto['id']);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CryptoDetailPage(
                      crypto: crypto, historicalData: historicalData),
                ),
              );
            });
      },
    );
  }
}
