import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Price Pulse',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PricePulseHomeScreen(),
    );
  }
}

class PricePulseHomeScreen extends StatefulWidget {
  const PricePulseHomeScreen({super.key});

  @override
  State<PricePulseHomeScreen> createState() => _PricePulseHomeScreenState();
}

class _PricePulseHomeScreenState extends State<PricePulseHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  // New state variable for disclaimer visibility
  bool _showDisclaimer = true; // Set to true by default to show it initially

  // Dummy product data (unchanged)
  final List<Map<String, dynamic>> _allProducts = [
    {
      'image': 'assets/shoprite_bread.png',
      'productName': 'Wholesome White Bread',
      'store': 'Shoprite',
      'price': 'R14,50',
      'lastUpdated': '30 Min ago',
      'isBestPrice': true,
    },
    {
      'image': 'assets/checkers_bread.png',
      'productName': 'Golden Crust White Bread',
      'store': 'Checkers',
      'price': 'R15,95',
      'lastUpdated': '30 Min ago',
      'isBestPrice': false,
    },
    {
      'image': 'assets/albany_bread.png',
      'productName': 'Albany White Bread',
      'store': 'Pick n Pay',
      'price': 'R17,50',
      'lastUpdated': '30 Min ago',
      'isBestPrice': false,
    },
    {
      'image': 'assets/woolworths_bread.png',
      'productName': 'Blue Ribbon White Bread',
      'store': 'Woolworths',
      'price': 'R18,99',
      'lastUpdated': '30 Min ago',
      'isBestPrice': false,
    },
    {
      'image': 'assets/shoprite_milk.png',
      'productName': 'Full Cream Milk 1L',
      'store': 'Shoprite',
      'price': 'R22,00',
      'lastUpdated': '25 Min ago',
      'isBestPrice': false,
    },
    {
      'image': 'assets/checkers_milk.png',
      'productName': 'Low Fat Milk 1L',
      'store': 'Checkers',
      'price': 'R23,50',
      'lastUpdated': '20 Min ago',
      'isBestPrice': false,
    },
    {
      'image': 'assets/picknpay_chicken.png',
      'productName': 'Chicken Breast Fillets 500g',
      'store': 'Pick n Pay',
      'price': 'R65,00',
      'lastUpdated': '1 Hour ago',
      'isBestPrice': true,
    },
    {
      'image': 'assets/woolworths_yogurt.png',
      'productName': 'Greek Yogurt 1kg',
      'store': 'Woolworths',
      'price': 'R45,00',
      'lastUpdated': '45 Min ago',
      'isBestPrice': false,
    },
    {
      'image': 'assets/checkers_eggs.png',
      'productName': 'Large Eggs 1 Dozen',
      'store': 'Checkers',
      'price': 'R35,00',
      'lastUpdated': '15 Min ago',
      'isBestPrice': false,
    },
    {
      'image': 'assets/shoprite_sugar.png',
      'productName': 'White Sugar 1kg',
      'store': 'Shoprite',
      'price': 'R25,00',
      'lastUpdated': '10 Min ago',
      'isBestPrice': false,
    },
  ];

  List<Map<String, dynamic>> _filteredProductsDisplay = [];
  List<String> _autocompleteSuggestions = [];
  final List<String> _allStores = ['Shoprite', 'Checkers', 'Pick n Pay', 'Woolworths'];

  @override
  void initState() {
    super.initState();
    _filteredProductsDisplay = [];
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _updateFilteredProductsAndSuggestions();
    });
  }

  void _updateFilteredProductsAndSuggestions() {
    if (_searchQuery.isEmpty) {
      _filteredProductsDisplay = [];
      _autocompleteSuggestions = [];
    } else {
      final queryLower = _searchQuery.toLowerCase();

      _filteredProductsDisplay = [];

      for (String store in _allStores) {
        final productInStore = _allProducts.firstWhere(
              (product) =>
          (product['productName'] as String).toLowerCase().contains(queryLower) &&
              (product['store'] as String).toLowerCase() == store.toLowerCase(),
          orElse: () => {},
        );

        if (productInStore.isNotEmpty) {
          _filteredProductsDisplay.add(productInStore);
        } else {
          _filteredProductsDisplay.add({
            'image': 'assets/placeholder.png',
            'productName': _searchQuery.isNotEmpty ? _searchQuery : 'Product',
            'store': store,
            'price': 'N/A',
            'lastUpdated': 'Unavailable',
            'isBestPrice': false,
            'isUnavailable': true,
          });
        }
      }

      _filteredProductsDisplay.sort((a, b) {
        final bool aUnavailable = a['isUnavailable'] ?? false;
        final bool bUnavailable = b['isUnavailable'] ?? false;

        if (aUnavailable && !bUnavailable) return 1;
        if (!aUnavailable && bUnavailable) return -1;

        if (a['isBestPrice'] == true && b['isBestPrice'] == false) return -1;
        if (a['isBestPrice'] == false && b['isBestPrice'] == true) return 1;
        return 0;
      });

      Set<String> uniqueSuggestions = {};
      for (var product in _allProducts) {
        final productName = product['productName'] as String;
        final storeName = product['store'] as String;

        if (productName.toLowerCase().contains(queryLower)) {
          uniqueSuggestions.add(productName);
        }
        if (storeName.toLowerCase().contains(queryLower)) {
          uniqueSuggestions.add(storeName);
        }
      }
      _autocompleteSuggestions = uniqueSuggestions.take(5).toList();
    }
  }

  void _selectSuggestion(String suggestion) {
    setState(() {
      _searchController.text = suggestion;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
      _searchQuery = suggestion;
      _autocompleteSuggestions = [];
      _updateFilteredProductsAndSuggestions();
    });
  }

  // Function to dismiss the disclaimer
  void _dismissDisclaimer() {
    setState(() {
      _showDisclaimer = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E2D3B),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with "Price Pulse"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              child: Row(
                children: [
                  Text(
                    'Price Pulse',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[200],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20), // Reduced height
                      // "Find the Best Prices" Section
                      Container(
                        width: double.infinity,
                        // Adjusted padding for a smaller container
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEE7FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Find the Best Prices',
                              style: TextStyle(
                                fontSize: 22, // Slightly reduced font size
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4C4A5C),
                              ),
                            ),
                            const SizedBox(height: 8), // Reduced height
                            const Text(
                              'Compare prices across all major South African\nretailers and save money on your shopping.',
                              style: TextStyle(
                                fontSize: 13, // Slightly reduced font size
                                color: Color(0xFF4C4A5C),
                              ),
                            ),
                            const SizedBox(height: 15), // Reduced height
                            // Search Bar
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2), // Reduced vertical padding
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  hintText: 'Search for products...',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                                ),
                              ),
                            ),
                            // Autocomplete Suggestions
                            if (_autocompleteSuggestions.isNotEmpty && _searchQuery.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  constraints: BoxConstraints(
                                      maxHeight:
                                      _autocompleteSuggestions.length * 48.0),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: _autocompleteSuggestions.length,
                                    itemBuilder: (context, index) {
                                      final suggestion = _autocompleteSuggestions[index];
                                      return ListTile(
                                        title: Text(suggestion),
                                        onTap: () => _selectSuggestion(suggestion),
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Conditional Product List or "No results found" message
                      if (_searchQuery.isNotEmpty && _filteredProductsDisplay.isNotEmpty)
                        Expanded(
                          child: ListView.builder(
                            itemCount: _filteredProductsDisplay.length,
                            itemBuilder: (context, index) {
                              final product = _filteredProductsDisplay[index];
                              return ProductCard(
                                imagePath: product['image'],
                                productName: product['productName'],
                                store: product['store'],
                                price: product['price'],
                                lastUpdated: product['lastUpdated'],
                                isBestPrice: product['isBestPrice'],
                                isUnavailable: product['isUnavailable'] ?? false,
                                searchQuery: _searchQuery,
                              );
                            },
                          ),
                        )
                      else if (_searchQuery.isNotEmpty && _filteredProductsDisplay.isEmpty)
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.sentiment_dissatisfied,
                                  size: 50,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'No results found for "${_searchQuery}"',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Please try a different search term.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        const Spacer(),

                      // Disclaimer Section at the bottom (Conditional Visibility)
                      if (_showDisclaimer)
                        Container(
                          padding: const EdgeInsets.only(bottom: 10, top: 10), // Added top padding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.info_outline, color: Colors.red[300], size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Price Disclaimer\n',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red[300],
                                            ),
                                          ),
                                          const TextSpan(
                                            text: 'Prices are updated regularly but may vary from actual store prices. Please verify prices before making purchases.',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Buttons for Disclaimer
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end, // Align buttons to the right
                                children: [
                                  TextButton(
                                    onPressed: _dismissDisclaimer, // Call dismiss function
                                    child: Text(
                                      'Dismiss',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: _dismissDisclaimer, // Call dismiss function
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple[400], // Use a primary color
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Accept'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10), // Added space below buttons
                              const Text(
                                'For more information, visit our Terms & Conditions',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String? imagePath;
  final String productName;
  final String store;
  final String price;
  final String lastUpdated;
  final bool isBestPrice;
  final bool isUnavailable;
  final String? searchQuery;

  const ProductCard({
    super.key,
    this.imagePath,
    required this.productName,
    required this.store,
    required this.price,
    required this.lastUpdated,
    this.isBestPrice = false,
    this.isUnavailable = false,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: isUnavailable ? Colors.grey[100] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isUnavailable ? Colors.grey[200] : null,
                image: imagePath != null && !isUnavailable
                    ? DecorationImage(
                  image: AssetImage(imagePath!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: isUnavailable
                  ? Icon(
                Icons.not_interested,
                color: Colors.grey[500],
                size: 40,
              )
                  : null,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUnavailable ? (searchQuery != null && searchQuery!.isNotEmpty ? searchQuery! : 'Product') : productName,
                    style: TextStyle(
                      fontSize: 12,
                      color: isUnavailable ? Colors.grey[600] : Colors.black87,
                      fontStyle: isUnavailable ? FontStyle.italic : null,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    store,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isUnavailable ? Colors.grey[800] : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isUnavailable ? 'Unavailable' : price,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isUnavailable ? Colors.red[300] : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isUnavailable ? 'Product is unavailable at this store' : 'Last updated $lastUpdated',
                    style: TextStyle(
                      fontSize: 10,
                      color: isUnavailable ? Colors.grey[500] : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (isBestPrice && !isUnavailable)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.teal[400],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Best Price',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}